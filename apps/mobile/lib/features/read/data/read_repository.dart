import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/local_user_id.dart';
import '../domain/read_models.dart';

class ReadRepository {
  ReadRepository(this.db);

  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  /// Shown after Firebase creates a new account from Google sign-in.
  static const kAppSettingInitialBackupPromptDone =
      'initial_backup_prompt_done';

  Future<void> initializeLocalData() async {
    await db.transaction(() async {
      await _seedBibleBooksIfNeeded();
      await _ensureGuestLocalUser();
      await _seedPlanTemplatesIfNeeded();
      await _createDefaultUserPlanIfNeeded();
      await _seedDefaultSettingsIfNeeded();
    });
  }

  Future<ReadingPlanView> getActivePlan() async {
    final plan = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.isActive.equals(true) & tbl.archivedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();

    if (plan == null) {
      await _createDefaultUserPlanIfNeeded();
      return getActivePlan();
    }

    return ReadingPlanView(
      id: plan.id,
      title: plan.title,
      templateId: plan.templateId,
      lastOpenedSectionId: plan.lastOpenedSectionId,
      lastOpenedBookKey: plan.lastOpenedBookKey,
    );
  }

  Future<List<ReadingPlanView>> getAllPlans() async {
    final plans = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.archivedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();

    return plans
        .map(
          (plan) => ReadingPlanView(
            id: plan.id,
            title: plan.title,
            templateId: plan.templateId,
            lastOpenedSectionId: plan.lastOpenedSectionId,
            lastOpenedBookKey: plan.lastOpenedBookKey,
          ),
        )
        .toList();
  }

  Future<List<ReadingPlanSummary>> getPlanSummaries() async {
    final plans = await getAllPlans();
    final summaries = <ReadingPlanSummary>[];
    for (final plan in plans) {
      final stats = await getPlanProgressStats(plan.id);
      summaries.add(
        ReadingPlanSummary(
          plan: plan,
          completedChapters: stats.completedChapters,
          totalChapters: stats.totalChapters,
        ),
      );
    }
    return summaries;
  }

  Future<void> switchToPlan(String planId) async {
    final exists = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId) & tbl.archivedAt.isNull())
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

  Future<List<ReadingPlanTemplateView>> getPlanTemplatesForCatalog() async {
    final rows = await (db.select(db.planTemplates)
          ..where((tbl) => tbl.isPublished.equals(true))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]))
        .get();
    final added = await db.select(db.userReadingPlans).get();
    final addedTemplateIds = added
        .where((plan) => plan.archivedAt == null)
        .map((plan) => plan.templateId)
        .toSet();

    return rows
        .map(
          (row) => ReadingPlanTemplateView(
            templateKey: row.templateKey,
            title: row.title,
            description: row.description,
            shortDescription: row.shortDescription,
            planType: row.planType,
            estimatedMinutes: row.estimatedMinutes,
            totalChapters: row.totalChapters,
            coverImageUrl: row.coverImageUrl,
            isAdded: addedTemplateIds.contains(row.id),
          ),
        )
        .toList();
  }

  Future<String> addPlanFromTemplate(String templateKey) async {
    final template = await (db.select(db.planTemplates)
          ..where((tbl) => tbl.templateKey.equals(templateKey))
          ..limit(1))
        .getSingleOrNull();
    if (template == null) {
      throw ArgumentError.value(templateKey, 'templateKey', 'Unknown template');
    }

    return _createUserPlanFromTemplate(template);
  }

  Future<List<BookProgress>> getBooksWithProgress(String planId) async {
    final sections = await getSectionsWithProgress(planId);
    return sections.expand((section) => section.books).toList();
  }

  Future<List<PlanSectionProgress>> getSectionsWithProgress(
      String planId) async {
    final planChapters = await (db.select(db.userPlanChapters)
          ..where((tbl) => tbl.userPlanId.equals(planId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();
    if (planChapters.isEmpty) return [];

    final sectionIds = planChapters.map((chapter) => chapter.sectionId).toSet();
    final sections = await (db.select(db.planTemplateSections)
          ..where((tbl) => tbl.id.isIn(sectionIds.toList()))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();

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
      return PlanSectionProgress(
        sectionId: section.id,
        title: section.title,
        orderIndex: section.orderIndex,
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
          completedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
          clientRevision: Value(plan.clientRevision + 1),
        ),
      );
    });
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

    return PlanProgressStats(
      completedChapters: completed.length,
      totalChapters: planChapters.length,
      readingDaysInPlan: readingDatesInPlan.length,
      averageChaptersPerReadingDayInPlan: average,
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

  Future<void> _seedPlanTemplatesIfNeeded() async {
    final existing = await db.select(db.planTemplates).get();
    if (existing.isNotEmpty) return;

    await _seedBibleInAYearTemplate();
    await _seedSamuelStoryTemplate();
  }

  Future<void> _seedBibleInAYearTemplate() async {
    final now = DateTime.now();
    final templateId = _uuid.v4();
    final oldSectionId = _uuid.v4();
    final newSectionId = _uuid.v4();
    final books = await (db.select(db.bibleBooks)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.bookOrder)]))
        .get();

    await db.into(db.planTemplates).insert(
          PlanTemplatesCompanion.insert(
            id: templateId,
            templateKey: 'bible_in_a_year',
            title: 'Bible in a Year',
            subtitle: const Value('Whole Bible'),
            description: const Value(
              'Track every chapter of the Bible across the Old and New Testament.',
            ),
            shortDescription:
                const Value('Read the whole Bible chapter by chapter.'),
            planType: const Value('canonical'),
            testamentScope: const Value('whole_bible'),
            estimatedMinutes: const Value(4756),
            estimatedDays: const Value(365),
            totalChapters: Value(
              books.fold<int>(0, (sum, book) => sum + book.chapterCount),
            ),
            isBuiltin: const Value(true),
            isPublished: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.batch((batch) {
      batch.insertAll(db.planTemplateSections, [
        PlanTemplateSectionsCompanion.insert(
          id: oldSectionId,
          planTemplateId: templateId,
          sectionKey: 'old_testament',
          title: 'Old Testament',
          orderIndex: 1,
          createdAt: now,
          updatedAt: now,
        ),
        PlanTemplateSectionsCompanion.insert(
          id: newSectionId,
          planTemplateId: templateId,
          sectionKey: 'new_testament',
          title: 'New Testament',
          orderIndex: 2,
          createdAt: now,
          updatedAt: now,
        ),
      ]);

      batch.insertAll(
        db.planTemplateItems,
        books.map((book) {
          return PlanTemplateItemsCompanion.insert(
            id: _uuid.v4(),
            sectionId: book.testament == 'old' ? oldSectionId : newSectionId,
            orderIndex: book.bookOrder,
            bookKey: book.bookKey,
            startChapter: 1,
            endChapter: book.chapterCount,
          );
        }).toList(),
      );
    });
  }

  Future<void> _seedSamuelStoryTemplate() async {
    final now = DateTime.now();
    final templateId = _uuid.v4();
    final beforeSamuelId = _uuid.v4();
    final youngSamuelId = _uuid.v4();
    final samuelAndSaulId = _uuid.v4();

    await db.into(db.planTemplates).insert(
          PlanTemplatesCompanion.insert(
            id: templateId,
            templateKey: 'samuel_story',
            title: 'Samuel Story',
            subtitle: const Value('Story Plan'),
            description: const Value(
              "From Samuel's birth to Israel's first king.",
            ),
            shortDescription: const Value(
              "From Samuel's birth to Israel's first king.",
            ),
            planType: const Value('story'),
            testamentScope: const Value('old_testament'),
            difficulty: const Value('easy'),
            estimatedMinutes: const Value(76),
            estimatedDays: const Value(7),
            totalChapters: const Value(19),
            primaryBookKey: const Value('1_samuel'),
            primaryCharacter: const Value('Samuel'),
            isBuiltin: const Value(true),
            isPublished: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.batch((batch) {
      batch.insertAll(db.planTemplateSections, [
        PlanTemplateSectionsCompanion.insert(
          id: beforeSamuelId,
          planTemplateId: templateId,
          sectionKey: 'before_samuel',
          title: 'Before Samuel',
          orderIndex: 1,
          createdAt: now,
          updatedAt: now,
        ),
        PlanTemplateSectionsCompanion.insert(
          id: youngSamuelId,
          planTemplateId: templateId,
          sectionKey: 'young_samuel',
          title: 'Young Samuel',
          orderIndex: 2,
          createdAt: now,
          updatedAt: now,
        ),
        PlanTemplateSectionsCompanion.insert(
          id: samuelAndSaulId,
          planTemplateId: templateId,
          sectionKey: 'samuel_and_saul',
          title: 'Samuel and Saul',
          orderIndex: 3,
          createdAt: now,
          updatedAt: now,
        ),
      ]);

      batch.insertAll(db.planTemplateItems, [
        PlanTemplateItemsCompanion.insert(
          id: _uuid.v4(),
          sectionId: beforeSamuelId,
          orderIndex: 1,
          bookKey: 'ruth',
          startChapter: 1,
          endChapter: 4,
        ),
        PlanTemplateItemsCompanion.insert(
          id: _uuid.v4(),
          sectionId: beforeSamuelId,
          orderIndex: 2,
          bookKey: '1_samuel',
          startChapter: 1,
          endChapter: 2,
        ),
        PlanTemplateItemsCompanion.insert(
          id: _uuid.v4(),
          sectionId: youngSamuelId,
          orderIndex: 1,
          bookKey: '1_samuel',
          startChapter: 3,
          endChapter: 7,
        ),
        PlanTemplateItemsCompanion.insert(
          id: _uuid.v4(),
          sectionId: samuelAndSaulId,
          orderIndex: 1,
          bookKey: '1_samuel',
          startChapter: 8,
          endChapter: 15,
        ),
      ]);
    });
  }

  Future<void> _createDefaultUserPlanIfNeeded() async {
    final existing = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.archivedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;

    final template = await (db.select(db.planTemplates)
          ..where((tbl) => tbl.templateKey.equals('bible_in_a_year'))
          ..limit(1))
        .getSingle();

    await _createUserPlanFromTemplate(template);
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
}

class _CompletionCounts {
  const _CompletionCounts({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;
}
