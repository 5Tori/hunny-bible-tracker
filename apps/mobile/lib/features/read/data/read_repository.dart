import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/hunny_api_models.dart';
import '../../../core/bible/bible_chapter_metadata.dart';
import '../../../core/bible/bible_com.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/local_user_id.dart';
import '../domain/read_models.dart';
import 'plan_catalog_api_client.dart';
import 'plan_catalog_read_client.dart';

class ReadRepository {
  ReadRepository(
    this.db, {
    PlanCatalogReadClient? planCatalogReadClient,
  }) : _planCatalogReadClient = planCatalogReadClient ?? PlanCatalogReadClient();

  final AppDatabase db;
  final Uuid _uuid = const Uuid();
  final PlanCatalogReadClient _planCatalogReadClient;

  /// Shown after Supabase creates a new account from Google sign-in.
  static const kAppSettingInitialBackupPromptDone =
      'initial_backup_prompt_done';
  static const kAppSettingLastReadingSyncAt = 'last_reading_sync_at';
  static const kAppSettingOnboardingCompleted = 'onboarding_completed_v1';
  static const kAppSettingOnboardingReadingLevel = 'onboarding_reading_level';
  static const kAppSettingBibleComVersionId = 'bible_com_version_id';
  static const kAppSettingBibleComVersionAbbr = 'bible_com_version_abbr';

  BibleComVersion? _cachedBibleComVersion;
  BibleChapterMetadata? _chapterMetadata;

  Future<BibleChapterMetadata> _getChapterMetadata() async {
    _chapterMetadata ??= await BibleChapterMetadata.loadFromDatabase(db);
    return _chapterMetadata!;
  }

  Future<void> initializeLocalData() async {
    await db.transaction(() async {
      await _seedBibleBooksIfNeeded();
      await _seedBibleChaptersIfNeeded();
      await _ensureGuestLocalUser();
      await _seedDefaultSettingsIfNeeded();
    });
  }

  Future<void> refreshPlanTemplatesFromRemote({
    bool allowFailure = false,
    bool forceReachability = false,
  }) async {
    if (!_planCatalogReadClient.isConfigured) return;

    try {
      final plans = await _planCatalogReadClient.fetchPublishedPlans(
        detail: 'summary',
        forceReachability: forceReachability,
      );
      if (plans.isEmpty) return;
      // Summary catalog has no sections/items — merge metadata only so we do
      // not orphan user_plan_chapters that reference local section ids.
      await _upsertRemotePlanSummaries(plans);
    } catch (_) {
      if (!allowFailure) rethrow;
    }
  }

  /// Loads onboarding/catalog choices from the server (summary payload).
  /// Falls back to the local cache only when the network request fails.
  Future<List<ReadingPlanTemplateView>> fetchOnboardingPlanChoices({
    bool forceRefresh = false,
  }) async {
    try {
      final remotePlans = await _planCatalogReadClient.fetchPublishedPlans(
        detail: 'summary',
        forceReachability: forceRefresh,
      );
      if (remotePlans.isEmpty) {
        throw PlanCatalogFetchFailure('No published plans are available yet.');
      }
      await _upsertRemotePlanSummaries(remotePlans);
      return _mapRemotePlansToCatalogViews(remotePlans);
    } on PlanCatalogFetchFailure {
      final cached = await getPlanTemplatesForCatalog();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<List<ReadingPlanTemplateView>> _mapRemotePlansToCatalogViews(
    List<RemotePlanTemplate> plans,
  ) async {
    final added = await db.select(db.userReadingPlans).get();
    final inProgressTemplateIds = added
        .where(
          (plan) =>
              plan.archivedAt == null &&
              (plan.status == 'active' || plan.status == 'completion_ready'),
        )
        .map((plan) => plan.templateId)
        .toSet();
    final localUserId = await _activeLocalUserId();
    final completionEvents = await (db.select(db.planCompletionEvents)
          ..where((tbl) => tbl.localUserId.equals(localUserId)))
        .get();
    final completionCountByTemplateId = <String, int>{};
    for (final event in completionEvents) {
      completionCountByTemplateId[event.templateId] =
          (completionCountByTemplateId[event.templateId] ?? 0) + 1;
    }

    return plans
        .where((plan) => plan.isPublished && plan.browseVisible)
        .map(
          (plan) => ReadingPlanTemplateView(
            id: plan.id,
            templateKey: plan.templateKey,
            title: plan.title,
            description: plan.description,
            shortDescription: plan.shortDescription,
            planType: plan.planType,
            testamentScope: plan.testamentScope,
            difficulty: plan.difficulty,
            estimatedMinutes: plan.estimatedMinutes,
            totalChapters: plan.totalChapters,
            coverImageUrl: plan.coverImageUrl,
            isInProgress: inProgressTemplateIds.contains(plan.id),
            completionCount: completionCountByTemplateId[plan.id] ?? 0,
          ),
        )
        .toList();
  }

  Future<ReadingPlanView?> getCurrentPlan() async {
    final plan = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.isActive.equals(true) &
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();

    if (plan != null) return _toReadingPlanView(plan);

    final fallback = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();

    if (fallback == null) return null;
    await switchToPlan(fallback.id);
    return _toReadingPlanView(fallback);
  }

  Future<List<ReadingPlanView>> getAllCurrentPlans() async {
    final plans = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();

    return plans.map(_toReadingPlanView).toList();
  }

  Future<List<ReadingPlanSummary>> getCurrentPlanSummaries() async {
    final plans = await getAllCurrentPlans();
    return _summariesForPlans(plans);
  }

  Future<List<ReadingPlanSummary>> getArchivedPlanSummaries() async {
    final plans = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.archivedAt.isNotNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();

    return _summariesForPlans(plans.map(_toReadingPlanView).toList());
  }

  Future<List<CompletedPlanSummary>> getCompletedPlanSummaries() async {
    final localUserId = await _activeLocalUserId();
    final events = await (db.select(db.planCompletionEvents)
          ..where((tbl) => tbl.localUserId.equals(localUserId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.completedAt)]))
        .get();
    if (events.isEmpty) return [];

    final userPlanIds =
        events.map((event) => event.userPlanId).toSet().toList();
    final plans = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.isIn(userPlanIds)))
        .get();
    final plansById = {for (final plan in plans) plan.id: plan};

    final templateIds =
        events.map((event) => event.templateId).toSet().toList();
    final templates = await (db.select(db.planTemplates)
          ..where((tbl) => tbl.id.isIn(templateIds)))
        .get();
    final templatesById = {
      for (final template in templates) template.id: template
    };

    final aggregates = <String, _CompletedPlanAggregate>{};
    for (final event in events) {
      final plan = plansById[event.userPlanId];
      final template = templatesById[event.templateId];
      final aggregate = aggregates.putIfAbsent(
        event.templateId,
        () => _CompletedPlanAggregate(
          templateId: event.templateId,
          templateKey: template?.templateKey ?? '',
          title: plan?.title ?? template?.title ?? 'Reading Plan',
          totalChapters: template?.totalChapters ?? 0,
          estimatedMinutes: template?.estimatedMinutes,
        ),
      );
      aggregate.completionCount += 1;
      if (aggregate.lastCompletedAt == null ||
          event.completedAt.isAfter(aggregate.lastCompletedAt!)) {
        aggregate.lastCompletedAt = event.completedAt;
        aggregate.title = plan?.title ?? template?.title ?? aggregate.title;
      }
    }

    return aggregates.values
        .map(
          (aggregate) => CompletedPlanSummary(
            templateId: aggregate.templateId,
            templateKey: aggregate.templateKey,
            title: aggregate.title,
            completionCount: aggregate.completionCount,
            lastCompletedAt: aggregate.lastCompletedAt,
            totalChapters: aggregate.totalChapters,
            estimatedMinutes: aggregate.estimatedMinutes,
          ),
        )
        .toList()
      ..sort((a, b) {
        final aDate =
            a.lastCompletedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.lastCompletedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  Future<List<ReadingPlanSummary>> _summariesForPlans(
    List<ReadingPlanView> plans,
  ) async {
    final summaries = <ReadingPlanSummary>[];
    for (final plan in plans) {
      final stats = await getPlanProgressStats(plan.id);
      final event = await (db.select(db.planCompletionEvents)
            ..where((tbl) => tbl.userPlanId.equals(plan.id))
            ..limit(1))
          .getSingleOrNull();
      summaries.add(
        ReadingPlanSummary(
          plan: plan,
          completedChapters: stats.completedChapters,
          totalChapters: stats.totalChapters,
          completedAt: event?.completedAt,
          completionNumber: event?.completionNumber,
        ),
      );
    }
    return summaries;
  }

  Future<void> switchToPlan(String planId) async {
    final exists = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.id.equals(planId) &
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..limit(1))
        .getSingleOrNull();
    if (exists == null) return;

    await db.transaction(() async {
      await _deactivateAllActivePlans();
      final row = await (db.select(db.userReadingPlans)
            ..where((tbl) => tbl.id.equals(planId))
            ..limit(1))
          .getSingle();

      await (db.update(db.userReadingPlans)
            ..where((tbl) => tbl.id.equals(planId)))
          .write(
        UserReadingPlansCompanion(
          isActive: const Value(true),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
          clientRevision: Value(row.clientRevision + 1),
        ),
      );
    });
    await _setSetting('last_active_plan_id', planId);
  }

  Future<void> archiveCurrentPlan(String planId) async {
    final plan = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.id.equals(planId) &
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..limit(1))
        .getSingleOrNull();
    if (plan == null) return;

    final now = DateTime.now();
    await (db.update(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId)))
        .write(
      UserReadingPlansCompanion(
        status: const Value('archived'),
        archivedAt: Value(now),
        isActive: const Value(false),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
        clientRevision: Value(plan.clientRevision + 1),
      ),
    );

    if (!plan.isActive) return;

    final fallback = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();

    if (fallback == null) {
      await _setSetting('last_active_plan_id', '');
      return;
    }
    await switchToPlan(fallback.id);
  }

  Future<void> restoreArchivedPlan(String planId) async {
    final plan = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) => tbl.id.equals(planId) & tbl.archivedAt.isNotNull(),
          )
          ..limit(1))
        .getSingleOrNull();
    if (plan == null) return;

    final counts = await _getCompletionCounts(planId);
    final restoredStatus = counts.total > 0 && counts.completed >= counts.total
        ? 'completion_ready'
        : 'active';
    final now = DateTime.now();

    await db.transaction(() async {
      await _deactivateAllActivePlans();
      await (db.update(db.userReadingPlans)
            ..where((tbl) => tbl.id.equals(planId)))
          .write(
        UserReadingPlansCompanion(
          status: Value(restoredStatus),
          archivedAt: const Value(null),
          isActive: const Value(true),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
          clientRevision: Value(plan.clientRevision + 1),
        ),
      );
    });
    await _setSetting('last_active_plan_id', planId);
  }

  Future<List<ReadingPlanTemplateView>> getPlanTemplatesForCatalog() async {
    final rows = await (db.select(db.planTemplates)
          ..where((tbl) =>
              tbl.isPublished.equals(true) & tbl.browseVisible.equals(true))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.featuredRank, nulls: NullsOrder.last),
            (tbl) => OrderingTerm.asc(tbl.title),
          ]))
        .get();
    final added = await db.select(db.userReadingPlans).get();
    final inProgressTemplateIds = added
        .where(
          (plan) =>
              plan.archivedAt == null &&
              (plan.status == 'active' || plan.status == 'completion_ready'),
        )
        .map((plan) => plan.templateId)
        .toSet();
    final localUserId = await _activeLocalUserId();
    final completionEvents = await (db.select(db.planCompletionEvents)
          ..where((tbl) => tbl.localUserId.equals(localUserId)))
        .get();
    final completionCountByTemplateId = <String, int>{};
    for (final event in completionEvents) {
      completionCountByTemplateId[event.templateId] =
          (completionCountByTemplateId[event.templateId] ?? 0) + 1;
    }

    return rows
        .map(
          (row) => ReadingPlanTemplateView(
            id: row.id,
            templateKey: row.templateKey,
            title: row.title,
            description: row.description,
            shortDescription: row.shortDescription,
            planType: row.planType,
            testamentScope: row.testamentScope,
            difficulty: row.difficulty,
            estimatedMinutes: row.estimatedMinutes,
            totalChapters: row.totalChapters,
            coverImageUrl: row.coverImageUrl,
            isInProgress: inProgressTemplateIds.contains(row.id),
            completionCount: completionCountByTemplateId[row.id] ?? 0,
          ),
        )
        .toList();
  }

  /// Next catalog plan to suggest after completion (featured order, not in progress).
  Future<ReadingPlanTemplateView?> getSuggestedNextPlanTemplate({
    required String excludeTemplateId,
  }) async {
    final catalog = await getPlanTemplatesForCatalog();
    for (final template in catalog) {
      if (template.isInProgress) continue;
      if (template.id == excludeTemplateId) continue;
      return template;
    }
    for (final template in catalog) {
      if (!template.isInProgress) return template;
    }
    return null;
  }

  Future<ReadingPlanTemplateView?> getPlanTemplateByIdentifier(
    String identifier,
  ) async {
    final row = await (db.select(db.planTemplates)
          ..where(
            (tbl) =>
                tbl.templateKey.equals(identifier) | tbl.id.equals(identifier),
          )
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;

    return ReadingPlanTemplateView(
      id: row.id,
      templateKey: row.templateKey,
      title: row.title,
      description: row.description,
      shortDescription: row.shortDescription,
      planType: row.planType,
      testamentScope: row.testamentScope,
      difficulty: row.difficulty,
      estimatedMinutes: row.estimatedMinutes,
      totalChapters: row.totalChapters,
      coverImageUrl: row.coverImageUrl,
      isInProgress: false,
      completionCount: 0,
    );
  }

  Future<String> addPlanFromTemplate(String templateIdentifier) async {
    await _ensureTemplateReadyForStart(templateIdentifier);

    final template = await (db.select(db.planTemplates)
          ..where(
            (tbl) =>
                tbl.templateKey.equals(templateIdentifier) |
                tbl.id.equals(templateIdentifier),
          )
          ..limit(1))
        .getSingleOrNull();
    if (template == null) {
      throw ArgumentError.value(
        templateIdentifier,
        'templateIdentifier',
        'Unknown template',
      );
    }

    final existing = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.templateId.equals(template.id) &
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      await switchToPlan(existing.id);
      return existing.id;
    }

    return _createUserPlanFromTemplate(template);
  }

  /// Active or completion-ready user plan for this catalog template, if any.
  Future<String?> findActiveUserPlanIdForTemplate(
    String templateIdentifier,
  ) async {
    final template = await (db.select(db.planTemplates)
          ..where(
            (tbl) =>
                tbl.templateKey.equals(templateIdentifier) |
                tbl.id.equals(templateIdentifier),
          )
          ..limit(1))
        .getSingleOrNull();
    if (template == null) return null;

    final existing = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.templateId.equals(template.id) &
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
    return existing?.id;
  }

  Future<List<BookProgress>> getBooksWithProgress(String planId) async {
    final sections = await getSectionsWithProgress(planId);
    return sections.expand((section) => section.books).toList();
  }

  Future<List<PlanSectionProgress>> getSectionsWithProgress(
      String planId) async {
    await _rebuildUserPlanChaptersIfStale(planId);

    var planChapters = await (db.select(db.userPlanChapters)
          ..where((tbl) => tbl.userPlanId.equals(planId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();
    if (planChapters.isEmpty) return [];

    final sectionIds = planChapters.map((chapter) => chapter.sectionId).toSet();
    var sections = await (db.select(db.planTemplateSections)
          ..where((tbl) => tbl.id.isIn(sectionIds.toList()))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();

    if (sections.isEmpty) {
      final rebuilt = await _rebuildUserPlanChaptersIfStale(planId);
      if (!rebuilt) return [];

      planChapters = await (db.select(db.userPlanChapters)
            ..where((tbl) => tbl.userPlanId.equals(planId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
          .get();
      if (planChapters.isEmpty) return [];

      sections = await (db.select(db.planTemplateSections)
            ..where(
              (tbl) => tbl.id.isIn(
                planChapters.map((chapter) => chapter.sectionId).toList(),
              ),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
          .get();
      if (sections.isEmpty) return [];
    }

    final bookKeys = planChapters.map((chapter) => chapter.bookKey).toSet();
    final books = await (db.select(db.bibleBooks)
          ..where((tbl) => tbl.bookKey.isIn(bookKeys.toList())))
        .get();
    final booksByKey = {for (final book in books) book.bookKey: book};

    final chapterCountBySectionBook = <String, int>{};
    final firstOrderBySectionBook = <String, int>{};
    final totalBySection = <String, int>{};
    for (final chapter in planChapters) {
      final key = _sectionBookKey(chapter.sectionId, chapter.bookKey);
      firstOrderBySectionBook.putIfAbsent(key, () => chapter.orderIndex);
      chapterCountBySectionBook[key] =
          (chapterCountBySectionBook[key] ?? 0) + 1;
      totalBySection[chapter.sectionId] =
          (totalBySection[chapter.sectionId] ?? 0) + 1;
    }

    final progressRows = await (db.select(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.userPlanId.equals(planId) & tbl.isCompleted.equals(true),
          ))
        .get();

    final sectionByChapter = <String, String>{};
    for (final chapter in planChapters) {
      sectionByChapter[_chapterKey(chapter.bookKey, chapter.chapterNumber)] =
          chapter.sectionId;
    }

    final chaptersBySection = <String, List<UserPlanChapter>>{};
    for (final chapter in planChapters) {
      chaptersBySection.putIfAbsent(chapter.sectionId, () => []).add(chapter);
    }
    for (final sectionChapters in chaptersBySection.values) {
      sectionChapters.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    final completedBySectionBook = <String, int>{};
    final completedBySection = <String, int>{};
    for (final row in progressRows) {
      final sectionId = sectionByChapter[_chapterKey(
        row.bookKey,
        row.chapterNumber,
      )];
      if (sectionId == null) continue;
      final key = _sectionBookKey(sectionId, row.bookKey);
      completedBySectionBook[key] = (completedBySectionBook[key] ?? 0) + 1;
      completedBySection[sectionId] = (completedBySection[sectionId] ?? 0) + 1;
    }

    return sections.map((section) {
      final sectionBookKeys = firstOrderBySectionBook.keys
          .where((key) => key.startsWith('${section.id}|'))
          .toList()
        ..sort(
          (a, b) => (firstOrderBySectionBook[a] ?? 0)
              .compareTo(firstOrderBySectionBook[b] ?? 0),
        );
      final sectionBooks = <BookProgress>[];
      for (final sectionBook in sectionBookKeys) {
        final bookKey = sectionBook.split('|').last;
        final book = booksByKey[bookKey];
        if (book == null) continue;
        sectionBooks.add(
          BookProgress(
            sectionId: section.id,
            bookKey: book.bookKey,
            testament: book.testament,
            bookOrder: book.bookOrder,
            shortName: book.shortName,
            displayName: book.displayNameEn,
            chapterCount: chapterCountBySectionBook[sectionBook] ?? 0,
            completedCount: completedBySectionBook[sectionBook] ?? 0,
          ),
        );
      }
      final sectionChapterList = chaptersBySection[section.id];
      final firstChapter = sectionChapterList != null && sectionChapterList.isNotEmpty
          ? sectionChapterList.first
          : null;

      return PlanSectionProgress(
        sectionId: section.id,
        title: section.title,
        description: section.description,
        orderIndex: section.orderIndex,
        firstChapterBookKey: firstChapter?.bookKey,
        firstChapterNumber: firstChapter?.chapterNumber,
        books: sectionBooks,
        completedCount: completedBySection[section.id] ?? 0,
        totalCount: totalBySection[section.id] ?? 0,
      );
    }).toList();
  }

  Future<List<ChapterProgressView>> getChaptersForBook({
    required String planId,
    required String sectionId,
    required String bookKey,
  }) async {
    final planChapters = await (db.select(db.userPlanChapters)
          ..where(
            (tbl) =>
                tbl.userPlanId.equals(planId) &
                tbl.sectionId.equals(sectionId) &
                tbl.bookKey.equals(bookKey),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.chapterNumber)]))
        .get();

    final progressRows = await (db.select(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.userPlanId.equals(planId) &
                tbl.bookKey.equals(bookKey) &
                tbl.isCompleted.equals(true),
          ))
        .get();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final completedMap = <int, bool>{};
    for (final row in progressRows) {
      final isToday =
          row.completedAt != null && row.completedAt!.isAfter(todayStart);
      completedMap[row.chapterNumber] = isToday;
    }

    return planChapters.map((chapter) {
      final completedToday = completedMap[chapter.chapterNumber];
      return ChapterProgressView(
        chapterNumber: chapter.chapterNumber,
        isCompleted: completedToday != null,
        completedToday: completedToday ?? false,
      );
    }).toList();
  }

  Future<void> rememberLastOpenedBook({
    required String planId,
    required String sectionId,
    required String bookKey,
  }) async {
    final row = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return;

    await (db.update(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId)))
        .write(
      UserReadingPlansCompanion(
        lastOpenedBookKey: Value(bookKey),
        lastOpenedSectionId: Value(sectionId),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
        clientRevision: Value(row.clientRevision + 1),
      ),
    );

    await _setSetting('last_active_plan_id', planId);
  }

  Future<ChapterToggleResult> toggleChapter({
    required String planId,
    required String sectionId,
    required String bookKey,
    required int chapterNumber,
  }) async {
    final now = DateTime.now();
    final localUserId = await _activeLocalUserId();

    final plan = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId))
          ..limit(1))
        .getSingleOrNull();
    if (plan == null || plan.status == 'completed' || plan.archivedAt != null) {
      return const ChapterToggleResult.unchanged();
    }

    final inPlan = await (db.select(db.userPlanChapters)
          ..where(
            (tbl) =>
                tbl.userPlanId.equals(planId) &
                tbl.sectionId.equals(sectionId) &
                tbl.bookKey.equals(bookKey) &
                tbl.chapterNumber.equals(chapterNumber),
          )
          ..limit(1))
        .getSingleOrNull();
    if (inPlan == null) return const ChapterToggleResult.unchanged();

    var changed = false;
    await db.transaction(() async {
      final existing = await (db.select(db.chapterProgressEntries)
            ..where(
              (tbl) =>
                  tbl.localUserId.equals(localUserId) &
                  tbl.userPlanId.equals(planId) &
                  tbl.bookKey.equals(bookKey) &
                  tbl.chapterNumber.equals(chapterNumber),
            )
            ..limit(1))
          .getSingleOrNull();

      if (existing == null) {
        await db.into(db.chapterProgressEntries).insert(
              ChapterProgressEntriesCompanion.insert(
                id: _uuid.v4(),
                localUserId: localUserId,
                userPlanId: planId,
                bookKey: bookKey,
                chapterNumber: chapterNumber,
                isCompleted: const Value(true),
                completedAt: Value(now),
                updatedAt: now,
                syncStatus: const Value('pending'),
              ),
            );
        changed = true;
        await _markPlanStartedIfNeeded(planId, now);
        await _insertReadingActivity(
          planId: planId,
          bookKey: bookKey,
          chapterNumber: chapterNumber,
          now: now,
        );
        return;
      }

      if (existing.isCompleted) {
        final todayStart = DateTime(now.year, now.month, now.day);
        final completedAt = existing.completedAt;
        if (completedAt == null || completedAt.isBefore(todayStart)) {
          return;
        }
      }

      final nextValue = !existing.isCompleted;
      await (db.update(db.chapterProgressEntries)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        ChapterProgressEntriesCompanion(
          isCompleted: Value(nextValue),
          completedAt: Value<DateTime?>(nextValue ? now : null),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
          clientRevision: Value(existing.clientRevision + 1),
        ),
      );
      changed = true;

      if (nextValue) {
        await _markPlanStartedIfNeeded(planId, now);
        await _insertReadingActivity(
          planId: planId,
          bookKey: bookKey,
          chapterNumber: chapterNumber,
          now: now,
        );
      }
    });

    if (!changed) return const ChapterToggleResult.unchanged();
    return _markPlanCompletionReadyIfNeeded(planId, now);
  }

  Future<void> finishPlan(String planId) async {
    final now = DateTime.now();
    final localUserId = await _activeLocalUserId();
    final counts = await _getCompletionCounts(planId);
    if (counts.total == 0 || counts.completed < counts.total) return;

    await db.transaction(() async {
      final plan = await (db.select(db.userReadingPlans)
            ..where((tbl) => tbl.id.equals(planId))
            ..limit(1))
          .getSingleOrNull();
      if (plan == null || plan.status == 'completed') return;

      final existingEvent = await (db.select(db.planCompletionEvents)
            ..where((tbl) => tbl.userPlanId.equals(planId))
            ..limit(1))
          .getSingleOrNull();

      if (existingEvent == null) {
        final previousCompletions = await (db.select(db.planCompletionEvents)
              ..where(
                (tbl) =>
                    tbl.localUserId.equals(localUserId) &
                    tbl.templateId.equals(plan.templateId),
              ))
            .get();

        await db.into(db.planCompletionEvents).insert(
              PlanCompletionEventsCompanion.insert(
                id: _uuid.v4(),
                localUserId: localUserId,
                userPlanId: planId,
                templateId: plan.templateId,
                completionNumber: previousCompletions.length + 1,
                completedAt: now,
                createdAt: now,
                syncStatus: const Value('pending'),
              ),
            );
      }

      await (db.update(db.userReadingPlans)
            ..where((tbl) => tbl.id.equals(planId)))
          .write(
        UserReadingPlansCompanion(
          status: const Value('completed'),
          isActive: const Value(false),
          completedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
          clientRevision: Value(plan.clientRevision + 1),
        ),
      );
    });
  }

  ReadingPlanView _toReadingPlanView(UserReadingPlan plan) {
    return ReadingPlanView(
      id: plan.id,
      title: plan.title,
      templateId: plan.templateId,
      status: plan.status,
      lastOpenedSectionId: plan.lastOpenedSectionId,
      lastOpenedBookKey: plan.lastOpenedBookKey,
    );
  }

  Future<ChapterToggleResult> _markPlanCompletionReadyIfNeeded(
    String planId,
    DateTime now,
  ) async {
    final counts = await _getCompletionCounts(planId);
    final plan = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId))
          ..limit(1))
        .getSingleOrNull();

    if (plan == null || plan.status == 'completed') {
      return ChapterToggleResult(
        changed: true,
        completionReady: false,
        completedChapters: counts.completed,
        totalChapters: counts.total,
      );
    }

    if (counts.total == 0 || counts.completed < counts.total) {
      if (plan.status == 'completion_ready') {
        await (db.update(db.userReadingPlans)
              ..where((tbl) => tbl.id.equals(planId)))
            .write(
          UserReadingPlansCompanion(
            status: const Value('active'),
            updatedAt: Value(now),
            syncStatus: const Value('pending'),
            clientRevision: Value(plan.clientRevision + 1),
          ),
        );
      }
      return ChapterToggleResult(
        changed: true,
        completionReady: false,
        completedChapters: counts.completed,
        totalChapters: counts.total,
      );
    }

    if (plan.status == 'completion_ready') {
      return ChapterToggleResult(
        changed: true,
        completionReady: false,
        completedChapters: counts.completed,
        totalChapters: counts.total,
      );
    }

    await (db.update(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId)))
        .write(
      UserReadingPlansCompanion(
        status: const Value('completion_ready'),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
        clientRevision: Value(plan.clientRevision + 1),
      ),
    );

    return ChapterToggleResult(
      changed: true,
      completionReady: true,
      completedChapters: counts.completed,
      totalChapters: counts.total,
    );
  }

  Future<_CompletionCounts> _getCompletionCounts(String planId) async {
    final chapters = await (db.select(db.userPlanChapters)
          ..where((tbl) => tbl.userPlanId.equals(planId)))
        .get();
    final completed = await (db.select(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.userPlanId.equals(planId) & tbl.isCompleted.equals(true),
          ))
        .get();

    return _CompletionCounts(
      completed: completed.length,
      total: chapters.length,
    );
  }

  Future<PlanProgressStats> getPlanProgressStats(String planId) async {
    final planChapters = await (db.select(db.userPlanChapters)
          ..where((tbl) => tbl.userPlanId.equals(planId)))
        .get();

    final completed = await (db.select(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.userPlanId.equals(planId) & tbl.isCompleted.equals(true),
          ))
        .get();

    final localUserId = await _activeLocalUserId();
    final activitiesInPlan = await (db.select(db.readingActivities)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.userPlanId.equals(planId) &
                tbl.action.equals('complete'),
          ))
        .get();

    final readingDatesInPlan =
        activitiesInPlan.map((row) => row.activityDate).toSet();
    final average = readingDatesInPlan.isEmpty
        ? 0.0
        : completed.length / readingDatesInPlan.length;

    final metadata = await _getChapterMetadata();
    var minutesTotal = 0;
    var minutesCount = 0;
    for (final chapter in planChapters) {
      final estimate =
          metadata.getChapter(chapter.bookKey, chapter.chapterNumber);
      if (estimate == null) continue;
      minutesTotal += estimate.estimatedReadingMinutes;
      minutesCount += 1;
    }
    final averageMinutesPerChapter = minutesCount > 0
        ? (minutesTotal / minutesCount).roundToDouble()
        : 0.0;

    return PlanProgressStats(
      completedChapters: completed.length,
      totalChapters: planChapters.length,
      readingDaysInPlan: readingDatesInPlan.length,
      averageChaptersPerReadingDayInPlan: average,
      averageMinutesPerChapter: averageMinutesPerChapter,
    );
  }

  Future<AccountActivityStats> getAccountActivityStats() async {
    final localUserId = await _activeLocalUserId();
    final activities = await (db.select(db.readingActivities)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.action.equals('complete'),
          ))
        .get();

    final readingDates = activities.map((row) => row.activityDate).toSet();
    final currentStreak = _calculateCurrentStreak(readingDates);

    return AccountActivityStats(
      currentStreak: currentStreak,
      readingDaysTotal: readingDates.length,
    );
  }

  Future<ReadingOverview> getReadingOverview(String planId) async {
    final plan = await getPlanProgressStats(planId);
    final account = await getAccountActivityStats();
    return ReadingOverview(plan: plan, account: account);
  }

  Future<LocalUserProfile?> getLocalUserProfile() async {
    final row = await (db.select(db.localUsers)..limit(1)).getSingleOrNull();
    if (row == null) return null;
    return LocalUserProfile(
      localUserId: row.id,
      authUserId: row.authUserId,
      accountType: row.type,
    );
  }

  Future<void> syncAuthUserId(String authUserId) async {
    final row = await (db.select(db.localUsers)..limit(1)).getSingleOrNull();
    if (row == null) return;

    if (row.authUserId == authUserId) {
      if (row.type != 'authenticated') {
        final now = DateTime.now();
        await (db.update(db.localUsers)..where((t) => t.id.equals(row.id)))
            .write(
          LocalUsersCompanion(
            type: const Value('authenticated'),
            updatedAt: Value(now),
            syncStatus: const Value('pending'),
            clientRevision: Value(row.clientRevision + 1),
          ),
        );
      }
      return;
    }

    final now = DateTime.now();
    await (db.update(db.localUsers)..where((t) => t.id.equals(row.id))).write(
      LocalUsersCompanion(
        authUserId: Value(authUserId),
        type: const Value('authenticated'),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
        clientRevision: Value(row.clientRevision + 1),
      ),
    );
    await _setSetting('account_mode', 'authenticated');
  }

  Future<void> clearAuthLink() async {
    final row = await (db.select(db.localUsers)..limit(1)).getSingleOrNull();
    if (row == null) return;
    final now = DateTime.now();
    await (db.update(db.localUsers)..where((t) => t.id.equals(row.id))).write(
      LocalUsersCompanion(
        authUserId: const Value<String?>(null),
        type: const Value('guest'),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
        clientRevision: Value(row.clientRevision + 1),
      ),
    );
    await _setSetting('account_mode', 'guest');
  }

  Future<bool> isOnboardingCompleted() async {
    final value = await getAppSetting(kAppSettingOnboardingCompleted);
    return value == 'true';
  }

  Future<bool> hasAnyUserReadingPlan() async {
    final localUserId = await _activeLocalUserId();
    final row = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.localUserId.equals(localUserId))
          ..limit(1))
        .getSingleOrNull();
    return row != null;
  }

  Future<bool> shouldShowOnboarding() async {
    if (await isOnboardingCompleted()) return false;
    if (await hasAnyUserReadingPlan()) return false;
    return true;
  }

  Future<void> completeOnboarding(String level) async {
    await _setSetting(kAppSettingOnboardingReadingLevel, level);
    await _setSetting(kAppSettingOnboardingCompleted, 'true');
  }

  Future<Map<String, dynamic>> exportReadingBackupSnapshot() async {
    final localUserId = await _activeLocalUserId();
    final plans = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.localUserId.equals(localUserId)))
        .get();
    final planIds = plans.map((plan) => plan.id).toSet().toList();

    final progress = planIds.isEmpty
        ? <ChapterProgressEntry>[]
        : await (db.select(db.chapterProgressEntries)
              ..where(
                (tbl) =>
                    tbl.localUserId.equals(localUserId) &
                    tbl.userPlanId.isIn(planIds) &
                    tbl.isCompleted.equals(true),
              ))
            .get();
    final activities = planIds.isEmpty
        ? <ReadingActivity>[]
        : await (db.select(db.readingActivities)
              ..where(
                (tbl) =>
                    tbl.localUserId.equals(localUserId) &
                    tbl.userPlanId.isIn(planIds),
              ))
            .get();
    final completionEvents = planIds.isEmpty
        ? <PlanCompletionEvent>[]
        : await (db.select(db.planCompletionEvents)
              ..where(
                (tbl) =>
                    tbl.localUserId.equals(localUserId) &
                    tbl.userPlanId.isIn(planIds),
              ))
            .get();

    final templates = <String, PlanTemplate>{};
    for (final plan in plans) {
      final template = await (db.select(db.planTemplates)
            ..where((tbl) => tbl.id.equals(plan.templateId))
            ..limit(1))
          .getSingleOrNull();
      if (template != null) {
        templates[plan.templateId] = template;
      }
    }
    final lastActivePlanId = await getAppSetting('last_active_plan_id');

    return {
      'v': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'plans': plans
          .map((plan) => _backupPlanToJson(plan, templates[plan.templateId]))
          .toList(),
      'progress': progress.map(_backupProgressToJson).toList(),
      'activities': activities.map(_backupActivityToJson).toList(),
      'completionEvents': completionEvents
          .map(
            (event) => _backupCompletionToJson(
              event,
              templates[event.templateId],
            ),
          )
          .toList(),
      'settings': {
        if (lastActivePlanId != null && planIds.contains(lastActivePlanId))
          'lastActivePlanId': lastActivePlanId,
      },
    };
  }

  @Deprecated('Use exportReadingBackupSnapshot.')
  Future<Map<String, dynamic>> buildReadingSyncPushPayload() =>
      exportReadingBackupSnapshot();

  Future<void> applyReadingSyncPushResult(
    HunnySyncPushResult result,
  ) async {
    final syncedAt = result.updatedAt;
    final localUserId = await _activeLocalUserId();
    await db.transaction(() async {
      await _markReadingRowsSynced(localUserId, syncedAt);
    });
    await _setSetting(
      kAppSettingLastReadingSyncAt,
      syncedAt.toUtc().toIso8601String(),
    );
  }

  Future<void> _markReadingRowsSynced(
    String localUserId,
    DateTime syncedAt,
  ) async {
    final now = syncedAt;
    await (db.update(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.syncStatus.equals('pending'),
          ))
        .write(
      UserReadingPlansCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await (db.update(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.syncStatus.equals('pending'),
          ))
        .write(
      ChapterProgressEntriesCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await (db.update(db.readingActivities)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.syncStatus.equals('pending'),
          ))
        .write(
      ReadingActivitiesCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(now),
      ),
    );
    await (db.update(db.planCompletionEvents)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.syncStatus.equals('pending'),
          ))
        .write(
      PlanCompletionEventsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(now),
      ),
    );
  }

  Future<void> applyReadingSyncBootstrap(
    HunnySyncBootstrapResult result,
  ) async {
    if (!result.hasBackup) {
      await _setSetting(
        kAppSettingLastReadingSyncAt,
        result.serverTime.toUtc().toIso8601String(),
      );
      return;
    }

    await refreshPlanTemplatesFromRemote(allowFailure: true);

    final localUserId = await _activeLocalUserId();
    final syncedAt = result.serverTime;
    final restoredPlanIds = result.plans
        .map((row) => _readString(row, 'id'))
        .where((id) => id.isNotEmpty)
        .toSet();

    await db.transaction(() async {
      await _clearLocalReadingStateForRestore(localUserId);

      final restoredTemplateIds = <String, String>{};
      for (final row in result.plans) {
        final template = await _templateForBackupPlan(row);
        if (template == null) {
          throw StateError(
            'Missing plan template for ${_readString(row, 'templateKey')}',
          );
        }
        final planId = _readString(row, 'id');
        restoredTemplateIds[planId] = template.id;
        await db.into(db.userReadingPlans).insertOnConflictUpdate(
              UserReadingPlansCompanion.insert(
                id: planId,
                localUserId: localUserId,
                templateId: template.id,
                title: _readString(row, 'title', fallback: template.title),
                status: Value(_readString(row, 'status', fallback: 'active')),
                subscribedAt: _readDate(row, 'subscribedAt'),
                startedAt: Value(_readOptionalDate(row, 'startedAt')),
                completedAt: Value(_readOptionalDate(row, 'completedAt')),
                archivedAt: Value(_readOptionalDate(row, 'archivedAt')),
                isActive: Value(_readBool(row, 'isActive')),
                lastOpenedSectionId:
                    Value(_readOptionalString(row, 'lastOpenedSectionId')),
                lastOpenedBookKey:
                    Value(_readOptionalString(row, 'lastOpenedBookKey')),
                createdAt: _readDate(row, 'createdAt'),
                updatedAt: _readDate(row, 'updatedAt'),
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(syncedAt),
              ),
            );

        final chapters = await _resolveTemplateChapters(
          userPlanId: planId,
          templateId: template.id,
        );
        await db.batch((batch) {
          batch.insertAll(db.userPlanChapters, chapters);
        });
      }

      final validChapters = await _chapterKeysForPlans(restoredPlanIds);
      for (final raw in result.progress) {
        final item = _backupTuple(raw);
        if (item.length < 3) continue;
        final planId = _tupleString(item, 0);
        final bookKey = _tupleString(item, 1);
        final chapterNumber = _tupleInt(item, 2);
        if (!_hasRestoredChapter(
          validChapters,
          planId,
          bookKey,
          chapterNumber,
        )) {
          continue;
        }
        final completedAt = item.length > 3 ? _tupleDate(item, 3) : syncedAt;
        await db.into(db.chapterProgressEntries).insertOnConflictUpdate(
              ChapterProgressEntriesCompanion.insert(
                id: _backupProgressId(planId, bookKey, chapterNumber),
                localUserId: localUserId,
                userPlanId: planId,
                bookKey: bookKey,
                chapterNumber: chapterNumber,
                isCompleted: const Value(true),
                completedAt: Value(completedAt),
                updatedAt: completedAt ?? syncedAt,
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(syncedAt),
              ),
            );
      }

      for (final raw in result.activities) {
        final item = _backupTuple(raw);
        if (item.length != 7) continue;
        final planId = _tupleString(item, 0);
        final bookKey = _tupleString(item, 1);
        final chapterNumber = _tupleInt(item, 2);
        if (!_hasRestoredChapter(
          validChapters,
          planId,
          bookKey,
          chapterNumber,
        )) {
          continue;
        }
        final activityDate = _tupleString(item, 3);
        final action = _tupleString(item, 4);
        await db.into(db.readingActivities).insertOnConflictUpdate(
              ReadingActivitiesCompanion.insert(
                id: _backupActivityId(
                  planId,
                  bookKey,
                  chapterNumber,
                  activityDate,
                  action,
                ),
                localUserId: localUserId,
                userPlanId: planId,
                bookKey: bookKey,
                chapterNumber: chapterNumber,
                action: action,
                activityDate: activityDate,
                timezone: _tupleString(item, 5),
                happenedAt: _tupleDate(item, 6) ?? syncedAt,
                createdAt: _tupleDate(item, 6) ?? syncedAt,
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(syncedAt),
              ),
            );
      }

      for (final row in result.completionEvents) {
        final planId = _readString(row, 'planId');
        final templateId = restoredTemplateIds[planId];
        if (templateId == null) continue;
        await db.into(db.planCompletionEvents).insertOnConflictUpdate(
              PlanCompletionEventsCompanion.insert(
                id: _readString(
                  row,
                  'id',
                  fallback: 'backup:completion:$planId',
                ),
                localUserId: localUserId,
                userPlanId: planId,
                templateId: templateId,
                completionNumber: _readInt(row, 'completionNumber'),
                completedAt: _readDate(row, 'completedAt'),
                createdAt: _readDate(row, 'createdAt'),
                syncStatus: const Value('synced'),
                lastSyncedAt: Value(syncedAt),
              ),
            );
      }

      await _setSetting(
        kAppSettingLastReadingSyncAt,
        syncedAt.toUtc().toIso8601String(),
      );
      if (restoredPlanIds.isNotEmpty) {
        final settings = result.payload?['settings'];
        final lastActivePlanId =
            settings is Map ? settings['lastActivePlanId'] as String? : null;
        await _setSetting(
          'last_active_plan_id',
          lastActivePlanId != null && restoredPlanIds.contains(lastActivePlanId)
              ? lastActivePlanId
              : restoredPlanIds.first,
        );
      }
    });
  }

  Future<DateTime?> getLastReadingSyncAt() async {
    final value = await getAppSetting(kAppSettingLastReadingSyncAt);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  /// True when local reading rows changed since last successful push.
  Future<bool> hasUnsyncedReadingChanges() async {
    final localUserId = await _activeLocalUserId();

    Future<bool> hasPendingRows<T extends Table, D>(
      TableInfo<T, D> table,
      Expression<bool> Function(T tbl) where,
    ) async {
      final rows = await (db.select(table)..where(where)).get();
      return rows.isNotEmpty;
    }

    if (await hasPendingRows(
      db.userReadingPlans,
      (tbl) =>
          tbl.localUserId.equals(localUserId) &
          tbl.syncStatus.equals('pending'),
    )) {
      return true;
    }
    if (await hasPendingRows(
      db.chapterProgressEntries,
      (tbl) =>
          tbl.localUserId.equals(localUserId) &
          tbl.syncStatus.equals('pending'),
    )) {
      return true;
    }
    if (await hasPendingRows(
      db.readingActivities,
      (tbl) =>
          tbl.localUserId.equals(localUserId) &
          tbl.syncStatus.equals('pending'),
    )) {
      return true;
    }
    if (await hasPendingRows(
      db.planCompletionEvents,
      (tbl) =>
          tbl.localUserId.equals(localUserId) &
          tbl.syncStatus.equals('pending'),
    )) {
      return true;
    }

    final lastSyncedAt = await getLastReadingSyncAt();
    if (lastSyncedAt != null) return false;
    return hasAnyUserReadingPlan();
  }

  Future<void> _ensureGuestLocalUser() async {
    final existing =
        await (db.select(db.localUsers)..limit(1)).getSingleOrNull();
    if (existing != null) return;
    final now = DateTime.now();
    await db.into(db.localUsers).insert(
          LocalUsersCompanion.insert(
            id: generateShortLocalUserId(),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<String> _activeLocalUserId() async {
    final row = await (db.select(db.localUsers)..limit(1)).getSingleOrNull();
    if (row == null) {
      throw StateError('local_users missing; call initializeLocalData first');
    }
    return row.id;
  }

  Future<void> _seedBibleBooksIfNeeded() async {
    final existingCount = await db.select(db.bibleBooks).get();
    if (existingCount.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/data/bible_books.en.json');
    final rows =
        (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

    await db.batch((batch) {
      batch.insertAll(
        db.bibleBooks,
        rows.map((row) {
          return BibleBooksCompanion.insert(
            bookKey: row['book_key'] as String,
            testament: row['testament'] as String,
            bookOrder: row['book_order'] as int,
            shortName: row['short_name'] as String,
            displayNameEn: row['display_name_en'] as String,
            chapterCount: row['chapter_count'] as int,
          );
        }).toList(),
      );
    });
  }

  Future<void> _seedBibleChaptersIfNeeded() async {
    final existingCount = await db.select(db.bibleChapters).get();
    if (existingCount.isNotEmpty) return;

    final raw =
        await rootBundle.loadString('assets/data/bible_chapters.json');
    final rows =
        (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

    await db.batch((batch) {
      batch.insertAll(
        db.bibleChapters,
        rows.map((row) {
          return BibleChaptersCompanion.insert(
            bookKey: row['book_key'] as String,
            chapterNumber: row['chapter_number'] as int,
            verseCount: row['verse_count'] as int,
            estimatedReadingSeconds: row['estimated_reading_seconds'] as int,
            estimatedReadingMinutes: row['estimated_reading_minutes'] as int,
          );
        }).toList(),
      );
    });
  }

  Future<void> _upsertRemotePlanSummaries(List<RemotePlanTemplate> plans) async {
    if (plans.isEmpty) return;

    await db.transaction(() async {
      for (final plan in plans) {
        await db.into(db.planTemplates).insertOnConflictUpdate(
              PlanTemplatesCompanion.insert(
                id: plan.id,
                templateKey: plan.templateKey,
                title: plan.title,
                subtitle: Value(plan.subtitle),
                description: Value(plan.description),
                shortDescription: Value(plan.shortDescription),
                coverImageUrl: Value(plan.coverImageUrl),
                planType: Value(plan.planType),
                testamentScope: Value(plan.testamentScope),
                difficulty: Value(plan.difficulty),
                estimatedMinutes: Value(plan.estimatedMinutes),
                estimatedDays: Value(plan.estimatedDays),
                totalChapters: Value(plan.totalChapters),
                primaryBookKey: Value(plan.primaryBookKey),
                primaryCharacter: Value(plan.primaryCharacter),
                isBuiltin: Value(plan.isBuiltin),
                isPublished: Value(plan.isPublished),
                featuredRank: Value(plan.featuredRank),
                browseVisible: Value(plan.browseVisible),
                createdAt: plan.createdAt,
                updatedAt: plan.updatedAt,
              ),
            );
      }
    });
  }

  Future<void> _ensureTemplateReadyForStart(String templateIdentifier) async {
    final existing = await (db.select(db.planTemplates)
          ..where(
            (tbl) =>
                tbl.templateKey.equals(templateIdentifier) |
                tbl.id.equals(templateIdentifier),
          )
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) {
      final sections = await (db.select(db.planTemplateSections)
            ..where((tbl) => tbl.planTemplateId.equals(existing.id)))
          .get();
      if (sections.isNotEmpty) {
        final sectionIds = sections.map((section) => section.id).toList();
        final items = await (db.select(db.planTemplateItems)
              ..where((tbl) => tbl.sectionId.isIn(sectionIds)))
            .get();
        if (items.isNotEmpty) return;
      }
    }

    final remote = await _planCatalogReadClient.fetchPublishedPlanByIdentifier(
      templateIdentifier,
      forceReachability: true,
    );
    await _upsertRemotePlanTemplate(remote);
  }

  Future<void> _upsertRemotePlanTemplate(RemotePlanTemplate plan) async {
    await db.transaction(() async {
      await (db.delete(db.planTemplateTags)
            ..where((tbl) => tbl.planTemplateId.equals(plan.id)))
          .go();

      final existingSections = await (db.select(db.planTemplateSections)
            ..where((tbl) => tbl.planTemplateId.equals(plan.id)))
          .get();
      final sectionIds = existingSections.map((section) => section.id).toList();
      if (sectionIds.isNotEmpty) {
        await (db.delete(db.planTemplateItems)
              ..where((tbl) => tbl.sectionId.isIn(sectionIds)))
            .go();
      }

      await (db.delete(db.planTemplateSections)
            ..where((tbl) => tbl.planTemplateId.equals(plan.id)))
          .go();
      await (db.delete(db.planTemplates)..where((tbl) => tbl.id.equals(plan.id)))
          .go();

      await db.into(db.planTemplates).insert(
            PlanTemplatesCompanion.insert(
              id: plan.id,
              templateKey: plan.templateKey,
              title: plan.title,
              subtitle: Value(plan.subtitle),
              description: Value(plan.description),
              shortDescription: Value(plan.shortDescription),
              coverImageUrl: Value(plan.coverImageUrl),
              planType: Value(plan.planType),
              testamentScope: Value(plan.testamentScope),
              difficulty: Value(plan.difficulty),
              estimatedMinutes: Value(plan.estimatedMinutes),
              estimatedDays: Value(plan.estimatedDays),
              totalChapters: Value(plan.totalChapters),
              primaryBookKey: Value(plan.primaryBookKey),
              primaryCharacter: Value(plan.primaryCharacter),
              isBuiltin: Value(plan.isBuiltin),
              isPublished: Value(plan.isPublished),
              featuredRank: Value(plan.featuredRank),
              browseVisible: Value(plan.browseVisible),
              createdAt: plan.createdAt,
              updatedAt: plan.updatedAt,
            ),
          );

      for (final section in plan.sections) {
        await db.into(db.planTemplateSections).insert(
              PlanTemplateSectionsCompanion.insert(
                id: section.id,
                planTemplateId: plan.id,
                sectionKey: section.sectionKey,
                title: section.title,
                description: Value(section.description),
                orderIndex: section.orderIndex,
                createdAt: section.createdAt,
                updatedAt: section.updatedAt,
              ),
            );

        for (final item in section.items) {
          await db.into(db.planTemplateItems).insert(
                PlanTemplateItemsCompanion.insert(
                  id: item.id,
                  sectionId: section.id,
                  orderIndex: item.orderIndex,
                  bookKey: item.bookKey,
                  startChapter: item.startChapter,
                  endChapter: item.endChapter,
                ),
              );
        }
      }

      for (final tag in plan.tags) {
        await db.into(db.planTags).insertOnConflictUpdate(
              PlanTagsCompanion.insert(
                id: tag.id,
                key: tag.key,
                name: tag.name,
                type: tag.type,
              ),
            );
        await db.into(db.planTemplateTags).insert(
              PlanTemplateTagsCompanion.insert(
                planTemplateId: plan.id,
                tagId: tag.id,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  Future<String> _createUserPlanFromTemplate(PlanTemplate template) async {
    final now = DateTime.now();
    final planId = _uuid.v4();
    final localUserId = await _activeLocalUserId();
    final chapters = await _resolveTemplateChapters(
      userPlanId: planId,
      templateId: template.id,
    );
    if (chapters.isEmpty) {
      throw StateError('Template ${template.templateKey} has no chapters');
    }

    final firstChapter = chapters.first;

    await db.transaction(() async {
      await _deactivateAllActivePlans();

      await db.into(db.userReadingPlans).insert(
            UserReadingPlansCompanion.insert(
              id: planId,
              localUserId: localUserId,
              templateId: template.id,
              title: template.title,
              status: const Value('active'),
              subscribedAt: now,
              isActive: const Value(true),
              lastOpenedSectionId: Value(firstChapter.sectionId.value),
              lastOpenedBookKey: Value(firstChapter.bookKey.value),
              createdAt: now,
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      await db.batch((batch) {
        batch.insertAll(db.userPlanChapters, chapters);
      });
    });

    await _setSetting('last_active_plan_id', planId);
    return planId;
  }

  Future<bool> _rebuildUserPlanChaptersIfStale(String planId) async {
    final plan = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId))
          ..limit(1))
        .getSingleOrNull();
    if (plan == null) return false;

    final template = await (db.select(db.planTemplates)
          ..where((tbl) => tbl.id.equals(plan.templateId))
          ..limit(1))
        .getSingleOrNull();
    if (template == null) return false;

    var templateSections = await (db.select(db.planTemplateSections)
          ..where((tbl) => tbl.planTemplateId.equals(template.id)))
        .get();
    if (templateSections.isEmpty) {
      try {
        await _ensureTemplateReadyForStart(template.templateKey);
      } catch (_) {
        return false;
      }
      templateSections = await (db.select(db.planTemplateSections)
            ..where((tbl) => tbl.planTemplateId.equals(template.id)))
          .get();
      if (templateSections.isEmpty) return false;
    }

    final validSectionIds = templateSections.map((section) => section.id).toSet();
    final existingChapters = await (db.select(db.userPlanChapters)
          ..where((tbl) => tbl.userPlanId.equals(planId)))
        .get();

    final hasStaleSectionRefs = existingChapters.any(
      (chapter) => !validSectionIds.contains(chapter.sectionId),
    );
    if (existingChapters.isNotEmpty && !hasStaleSectionRefs) {
      return false;
    }

    final rebuiltChapters = await _resolveTemplateChapters(
      userPlanId: planId,
      templateId: template.id,
    );
    if (rebuiltChapters.isEmpty) return false;

    final firstChapter = rebuiltChapters.first;
    await db.transaction(() async {
      await (db.delete(db.userPlanChapters)
            ..where((tbl) => tbl.userPlanId.equals(planId)))
          .go();
      await db.batch((batch) {
        batch.insertAll(db.userPlanChapters, rebuiltChapters);
      });

      if (plan.lastOpenedSectionId == null ||
          !validSectionIds.contains(plan.lastOpenedSectionId)) {
        await (db.update(db.userReadingPlans)
              ..where((tbl) => tbl.id.equals(planId)))
            .write(
          UserReadingPlansCompanion(
            lastOpenedSectionId: Value(firstChapter.sectionId.value),
            lastOpenedBookKey: Value(firstChapter.bookKey.value),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('pending'),
            clientRevision: Value(plan.clientRevision + 1),
          ),
        );
      }
    });

    return true;
  }

  Future<List<UserPlanChaptersCompanion>> _resolveTemplateChapters({
    required String userPlanId,
    required String templateId,
  }) async {
    final sections = await (db.select(db.planTemplateSections)
          ..where((tbl) => tbl.planTemplateId.equals(templateId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();

    var orderIndex = 0;
    final chapters = <UserPlanChaptersCompanion>[];
    for (final section in sections) {
      final items = await (db.select(db.planTemplateItems)
            ..where((tbl) => tbl.sectionId.equals(section.id))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
          .get();
      for (final item in items) {
        for (var chapter = item.startChapter;
            chapter <= item.endChapter;
            chapter += 1) {
          orderIndex += 1;
          chapters.add(
            UserPlanChaptersCompanion.insert(
              id: _uuid.v4(),
              userPlanId: userPlanId,
              sectionId: section.id,
              bookKey: item.bookKey,
              chapterNumber: chapter,
              orderIndex: orderIndex,
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }
    return chapters;
  }

  Future<void> _deactivateAllActivePlans() async {
    final now = DateTime.now();
    final active = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) => tbl.archivedAt.isNull() & tbl.isActive.equals(true),
          ))
        .get();

    for (final plan in active) {
      await (db.update(db.userReadingPlans)
            ..where((tbl) => tbl.id.equals(plan.id)))
          .write(
        UserReadingPlansCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
          clientRevision: Value(plan.clientRevision + 1),
        ),
      );
    }
  }

  Future<void> _markPlanStartedIfNeeded(String planId, DateTime now) async {
    final row = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null || row.startedAt != null) return;
    await (db.update(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId)))
        .write(
      UserReadingPlansCompanion(
        startedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
        clientRevision: Value(row.clientRevision + 1),
      ),
    );
  }

  Future<void> _seedDefaultSettingsIfNeeded() async {
    await _setSettingIfMissing('language', 'en');
    await _setSettingIfMissing('timezone', DateTime.now().timeZoneName);
    await _setSettingIfMissing('account_mode', 'guest');
    await _setSettingIfMissing(
      kAppSettingBibleComVersionId,
      BibleComVersion.defaultVersion.id,
    );
    await _setSettingIfMissing(
      kAppSettingBibleComVersionAbbr,
      BibleComVersion.defaultVersion.abbr,
    );
  }

  Future<BibleComVersion> getBibleComVersion() async {
    if (_cachedBibleComVersion != null) return _cachedBibleComVersion!;
    final id = await getAppSetting(kAppSettingBibleComVersionId);
    final abbr = await getAppSetting(kAppSettingBibleComVersionAbbr);
    _cachedBibleComVersion =
        BibleComVersion.tryParse(id: id, abbr: abbr) ?? BibleComVersion.defaultVersion;
    return _cachedBibleComVersion!;
  }

  Future<void> setBibleComVersion(BibleComVersion version) async {
    await _setSetting(kAppSettingBibleComVersionId, version.id);
    await _setSetting(kAppSettingBibleComVersionAbbr, version.abbr);
    _cachedBibleComVersion = version;
  }

  Future<String?> getAppSetting(String key) async {
    final row = await (db.select(db.appSettings)
          ..where((tbl) => tbl.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setAppSetting(String key, String value) =>
      _setSetting(key, value);

  Future<void> _setSettingIfMissing(String key, String value) async {
    final existing = await (db.select(db.appSettings)
          ..where((tbl) => tbl.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;
    await _setSetting(key, value);
  }

  Future<void> _setSetting(String key, String value) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _insertReadingActivity({
    required String planId,
    required String bookKey,
    required int chapterNumber,
    required DateTime now,
  }) async {
    final localUserId = await _activeLocalUserId();
    await db.into(db.readingActivities).insert(
          ReadingActivitiesCompanion.insert(
            id: _uuid.v4(),
            localUserId: localUserId,
            userPlanId: planId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            action: 'complete',
            activityDate: DateFormat('yyyy-MM-dd').format(now),
            timezone: DateTime.now().timeZoneName,
            happenedAt: now,
            createdAt: now,
            syncStatus: const Value('pending'),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  int _calculateCurrentStreak(Set<String> readingDates) {
    if (readingDates.isEmpty) return 0;

    var cursor = DateTime.now();
    var streak = 0;

    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(cursor);
      if (!readingDates.contains(key)) break;
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  String _sectionBookKey(String sectionId, String bookKey) =>
      '$sectionId|$bookKey';

  String _chapterKey(String bookKey, int chapterNumber) =>
      '$bookKey|$chapterNumber';

  Map<String, dynamic> _backupPlanToJson(
    UserReadingPlan row,
    PlanTemplate? template,
  ) {
    return {
      'id': row.id,
      'templateKey': template?.templateKey ?? row.templateId,
      'templateId': row.templateId,
      'title': row.title,
      'status': row.status,
      'subscribedAt': _dateToJson(row.subscribedAt),
      'startedAt': _optionalDateToJson(row.startedAt),
      'completedAt': _optionalDateToJson(row.completedAt),
      'archivedAt': _optionalDateToJson(row.archivedAt),
      'isActive': row.isActive,
      'lastOpenedSectionId': row.lastOpenedSectionId,
      'lastOpenedBookKey': row.lastOpenedBookKey,
      'createdAt': _dateToJson(row.createdAt),
      'updatedAt': _dateToJson(row.updatedAt),
    };
  }

  List<dynamic> _backupProgressToJson(ChapterProgressEntry row) {
    return [
      row.userPlanId,
      row.bookKey,
      row.chapterNumber,
      _optionalDateToJson(row.completedAt) ?? _dateToJson(row.updatedAt),
    ];
  }

  List<dynamic> _backupActivityToJson(ReadingActivity row) {
    return [
      row.userPlanId,
      row.bookKey,
      row.chapterNumber,
      row.activityDate,
      row.action,
      row.timezone,
      _dateToJson(row.happenedAt),
    ];
  }

  Map<String, dynamic> _backupCompletionToJson(
    PlanCompletionEvent row,
    PlanTemplate? template,
  ) {
    return {
      'id': row.id,
      'planId': row.userPlanId,
      'templateKey': template?.templateKey ?? row.templateId,
      'completedAt': _dateToJson(row.completedAt),
      'completionNumber': row.completionNumber,
      'createdAt': _dateToJson(row.createdAt),
    };
  }

  Future<void> _clearLocalReadingStateForRestore(String localUserId) async {
    final existingPlans = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.localUserId.equals(localUserId)))
        .get();
    final existingPlanIds = existingPlans.map((plan) => plan.id).toList();
    if (existingPlanIds.isEmpty) return;

    await (db.delete(db.planCompletionEvents)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.userPlanId.isIn(existingPlanIds),
          ))
        .go();
    await (db.delete(db.readingActivities)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.userPlanId.isIn(existingPlanIds),
          ))
        .go();
    await (db.delete(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.userPlanId.isIn(existingPlanIds),
          ))
        .go();
    await (db.delete(db.userPlanChapters)
          ..where((tbl) => tbl.userPlanId.isIn(existingPlanIds)))
        .go();
    await (db.delete(db.userReadingPlans)
          ..where((tbl) => tbl.localUserId.equals(localUserId)))
        .go();
  }

  Future<PlanTemplate?> _templateForBackupPlan(
    Map<String, dynamic> plan,
  ) async {
    final templateKey = _readString(plan, 'templateKey');
    final templateId = _readOptionalString(plan, 'templateId') ?? '';
    final identifier = templateKey.isNotEmpty ? templateKey : templateId;
    if (identifier.isEmpty) return null;

    var template = await _findPlanTemplate(
      templateKey: templateKey,
      templateId: templateId,
    );

    if (template == null || !await _templateHasChapterScope(template.id)) {
      try {
        await _ensureTemplateReadyForStart(identifier);
      } catch (_) {
        return template;
      }
      template = await _findPlanTemplate(
        templateKey: templateKey,
        templateId: templateId,
      );
    }

    return template;
  }

  Future<PlanTemplate?> _findPlanTemplate({
    required String templateKey,
    required String templateId,
  }) async {
    if (templateKey.isNotEmpty) {
      final byKey = await (db.select(db.planTemplates)
            ..where((tbl) => tbl.templateKey.equals(templateKey))
            ..limit(1))
          .getSingleOrNull();
      if (byKey != null) return byKey;
    }

    if (templateId.isEmpty) return null;
    return (db.select(db.planTemplates)
          ..where((tbl) => tbl.id.equals(templateId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<bool> _templateHasChapterScope(String templateId) async {
    final sections = await (db.select(db.planTemplateSections)
          ..where((tbl) => tbl.planTemplateId.equals(templateId)))
        .get();
    if (sections.isEmpty) return false;

    final sectionIds = sections.map((section) => section.id).toList();
    final items = await (db.select(db.planTemplateItems)
          ..where((tbl) => tbl.sectionId.isIn(sectionIds)))
        .get();
    return items.isNotEmpty;
  }

  Future<Set<String>> _chapterKeysForPlans(Set<String> planIds) async {
    if (planIds.isEmpty) return const {};
    final rows = await (db.select(db.userPlanChapters)
          ..where((tbl) => tbl.userPlanId.isIn(planIds.toList())))
        .get();
    return rows
        .map(
          (row) => _restoredChapterKey(
            row.userPlanId,
            row.bookKey,
            row.chapterNumber,
          ),
        )
        .toSet();
  }

  bool _hasRestoredChapter(
    Set<String> chapterKeys,
    String planId,
    String bookKey,
    int chapterNumber,
  ) {
    return chapterKeys.contains(
      _restoredChapterKey(planId, bookKey, chapterNumber),
    );
  }

  String _restoredChapterKey(
    String planId,
    String bookKey,
    int chapterNumber,
  ) =>
      '$planId|$bookKey|$chapterNumber';

  List<dynamic> _backupTuple(Object? value) =>
      value is List ? value : const <dynamic>[];

  String _tupleString(List<dynamic> row, int index) {
    final value = index < row.length ? row[index] : null;
    return value is String ? value : '';
  }

  int _tupleInt(List<dynamic> row, int index) {
    final value = index < row.length ? row[index] : null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  DateTime? _tupleDate(List<dynamic> row, int index) {
    final value = index < row.length ? row[index] : null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  String _backupProgressId(
    String planId,
    String bookKey,
    int chapterNumber,
  ) =>
      'backup:progress:$planId:$bookKey:$chapterNumber';

  String _backupActivityId(
    String planId,
    String bookKey,
    int chapterNumber,
    String activityDate,
    String action,
  ) =>
      'backup:activity:$planId:$bookKey:$chapterNumber:$activityDate:$action';

  String _dateToJson(DateTime date) => date.toUtc().toIso8601String();

  String? _optionalDateToJson(DateTime? date) =>
      date == null ? null : _dateToJson(date);

  String _readString(
    Map<String, dynamic> row,
    String key, {
    String fallback = '',
  }) {
    final value = row[key];
    return value is String ? value : fallback;
  }

  String? _readOptionalString(Map<String, dynamic> row, String key) {
    final value = row[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  int _readInt(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  bool _readBool(Map<String, dynamic> row, String key) {
    final value = row[key];
    return value is bool ? value : false;
  }

  DateTime _readDate(Map<String, dynamic> row, String key) {
    return _readOptionalDate(row, key) ?? DateTime.now();
  }

  DateTime? _readOptionalDate(Map<String, dynamic> row, String key) {
    final value = row[key];
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

class _CompletionCounts {
  const _CompletionCounts({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;
}

class _CompletedPlanAggregate {
  _CompletedPlanAggregate({
    required this.templateId,
    required this.templateKey,
    required this.title,
    required this.totalChapters,
    this.estimatedMinutes,
  });

  final String templateId;
  final String templateKey;
  String title;
  int completionCount = 0;
  DateTime? lastCompletedAt;
  final int totalChapters;
  final int? estimatedMinutes;
}
