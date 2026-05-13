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

  /// Shown after first sign-up (`post_signup_backup_dialog`).
  static const kAppSettingInitialBackupPromptDone =
      'initial_backup_prompt_done';

  Future<void> initializeLocalData() async {
    await db.transaction(() async {
      await _seedBibleBooksIfNeeded();
      await _ensureGuestLocalUser();
      await _seedDefaultPlanTemplateIfNeeded();
      await _seedFourGospelsTemplateIfNeeded();
      await _createDefaultUserPlanIfNeeded();
      await _seedDefaultSettingsIfNeeded();
    });
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

  Future<ReadingPlanView> getActivePlan() async {
    final plan = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.isActive.equals(true) & tbl.deletedAt.isNull())
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
      templateKey: plan.templateKey,
      lastOpenedBookKey: plan.lastOpenedBookKey,
    );
  }

  Future<List<ReadingPlanView>> getAllPlans() async {
    final plans = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();

    return plans
        .map((p) => ReadingPlanView(
              id: p.id,
              title: p.title,
              templateKey: p.templateKey,
              lastOpenedBookKey: p.lastOpenedBookKey,
            ))
        .toList();
  }

  Future<void> switchToPlan(String planId) async {
    final exists = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) => tbl.id.equals(planId) & tbl.deletedAt.isNull(),
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

  /// Templates the user can instantiate (reading_plan_templates).
  Future<List<ReadingPlanTemplateView>> getPlanTemplatesForCatalog() async {
    final rows = await (db.select(db.readingPlanTemplates)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.title)]))
        .get();

    return rows
        .map(
          (r) => ReadingPlanTemplateView(
            templateKey: r.templateKey,
            title: r.title,
            description: r.description,
          ),
        )
        .toList();
  }

  /// Creates a new user plan from a catalog template and makes it active.
  Future<String> addPlanFromTemplate(String templateKey) async {
    final template = await (db.select(db.readingPlanTemplates)
          ..where((tbl) => tbl.templateKey.equals(templateKey))
          ..limit(1))
        .getSingleOrNull();
    if (template == null) {
      throw ArgumentError.value(templateKey, 'templateKey', 'Unknown template');
    }

    final now = DateTime.now();
    final planId = _uuid.v4();
    final localUserId = await _activeLocalUserId();

    final booksOrdered = await _bibleBooksForTemplate(templateKey);
    if (booksOrdered.isEmpty) {
      throw StateError('Template $templateKey has no books in scope');
    }
    final firstBookKey = booksOrdered.first.bookKey;

    final scope = await _planScopeChaptersForTemplate(
      planId: planId,
      templateKey: templateKey,
      now: now,
    );
    if (scope.isEmpty) {
      throw StateError('Template $templateKey produced no scope chapters');
    }

    await db.transaction(() async {
      await _deactivateAllActivePlans();

      await db.into(db.userReadingPlans).insert(
            UserReadingPlansCompanion.insert(
              id: planId,
              localUserId: localUserId,
              templateKey: templateKey,
              title: template.title,
              status: const Value('active'),
              startedAt: Value(now),
              isActive: const Value(true),
              lastOpenedBookKey: Value(firstBookKey),
              createdAt: now,
              updatedAt: now,
              syncStatus: const Value('pending'),
            ),
          );

      await db.batch((batch) {
        batch.insertAll(db.planScopeChapters, scope);
      });
    });

    await _setSetting('last_active_plan_id', planId);
    return planId;
  }

  Future<void> _deactivateAllActivePlans() async {
    final now = DateTime.now();
    final active = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) => tbl.deletedAt.isNull() & tbl.isActive.equals(true),
          ))
        .get();

    for (final p in active) {
      await (db.update(db.userReadingPlans)..where((tbl) => tbl.id.equals(p.id)))
          .write(
        UserReadingPlansCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
          syncStatus: const Value('pending'),
          clientRevision: Value(p.clientRevision + 1),
        ),
      );
    }
  }

  Future<List<BookProgress>> getBooksWithProgress(String planId) async {
    final scopeRows = await (db.select(db.planScopeChapters)
          ..where((tbl) => tbl.planId.equals(planId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .get();
    if (scopeRows.isEmpty) return [];

    final bookKeys = <String>{};
    for (final row in scopeRows) {
      bookKeys.add(row.bookKey);
    }

    final books = await (db.select(db.bibleBooks)
          ..where((tbl) => tbl.bookKey.isIn(bookKeys.toList()))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.bookOrder)]))
        .get();

    final progressRows = await (db.select(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.planId.equals(planId) &
                tbl.isCompleted.equals(true) &
                tbl.deletedAt.isNull(),
          ))
        .get();

    final completedByBook = <String, int>{};
    for (final row in progressRows) {
      completedByBook[row.bookKey] = (completedByBook[row.bookKey] ?? 0) + 1;
    }

    return books
        .map(
          (book) => BookProgress(
            bookKey: book.bookKey,
            testament: book.testament,
            bookOrder: book.bookOrder,
            shortName: book.shortName,
            displayName: book.displayNameEn,
            chapterCount: book.chapterCount,
            completedCount: completedByBook[book.bookKey] ?? 0,
          ),
        )
        .toList();
  }

  Future<List<ChapterProgressView>> getChaptersForBook({
    required String planId,
    required String bookKey,
  }) async {
    final book = await (db.select(db.bibleBooks)
          ..where((tbl) => tbl.bookKey.equals(bookKey))
          ..limit(1))
        .getSingle();

    final progressRows = await (db.select(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.planId.equals(planId) &
                tbl.bookKey.equals(bookKey) &
                tbl.isCompleted.equals(true) &
                tbl.deletedAt.isNull(),
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

    return List.generate(
      book.chapterCount,
      (index) {
        final chapterNumber = index + 1;
        final entry = completedMap[chapterNumber];
        return ChapterProgressView(
          chapterNumber: chapterNumber,
          isCompleted: entry != null,
          completedToday: entry ?? false,
        );
      },
    );
  }

  Future<void> rememberLastOpenedBook({
    required String planId,
    required String bookKey,
  }) async {
    final row = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.equals(planId))
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return;

    await (db.update(db.userReadingPlans)..where((tbl) => tbl.id.equals(planId)))
        .write(
      UserReadingPlansCompanion(
        lastOpenedBookKey: Value(bookKey),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
        clientRevision: Value(row.clientRevision + 1),
      ),
    );

    await _setSetting('last_active_plan_id', planId);
  }

  Future<void> toggleChapter({
    required String planId,
    required String bookKey,
    required int chapterNumber,
  }) async {
    final now = DateTime.now();

    final localUserId = await _activeLocalUserId();

    await db.transaction(() async {
      final existing = await (db.select(db.chapterProgressEntries)
            ..where(
              (tbl) =>
                  tbl.planId.equals(planId) &
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
                planId: planId,
                bookKey: bookKey,
                chapterNumber: chapterNumber,
                isCompleted: const Value(true),
                completedAt: Value(now),
                updatedAt: now,
                syncStatus: const Value('pending'),
              ),
            );
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
          deletedAt: const Value<DateTime?>(null),
          syncStatus: const Value('pending'),
          clientRevision: Value(existing.clientRevision + 1),
        ),
      );

      if (nextValue) {
        await _insertReadingActivity(
          planId: planId,
          bookKey: bookKey,
          chapterNumber: chapterNumber,
          now: now,
        );
      }
    });
  }

  Future<PlanProgressStats> getPlanProgressStats(String planId) async {
    final planChapters = await (db.select(db.planScopeChapters)
          ..where((tbl) => tbl.planId.equals(planId)))
        .get();

    final completed = await (db.select(db.chapterProgressEntries)
          ..where(
            (tbl) =>
                tbl.planId.equals(planId) &
                tbl.isCompleted.equals(true) &
                tbl.deletedAt.isNull(),
          ))
        .get();

    final localUserId = await _activeLocalUserId();
    final activitiesInPlan = await (db.select(db.readingActivities)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.planId.equals(planId) &
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
      neonUserId: row.authUserId,
      accountType: row.type,
    );
  }

  /// Links the single local profile to Neon Auth `user.id` (Phase F merge).
  Future<void> syncNeonAuthUserId(String neonUserId) async {
    final row = await (db.select(db.localUsers)..limit(1)).getSingleOrNull();
    if (row == null) return;

    if (row.authUserId == neonUserId) {
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
        authUserId: Value(neonUserId),
        type: const Value('authenticated'),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
        clientRevision: Value(row.clientRevision + 1),
      ),
    );
    await _setSetting('account_mode', 'authenticated');
  }

  Future<void> clearNeonAuthLink() async {
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

  Future<void> _seedBibleBooksIfNeeded() async {
    final existingCount = await db.select(db.bibleBooks).get();
    if (existingCount.isNotEmpty) return;

    final raw = await rootBundle.loadString('assets/data/bible_books.en.json');
    final rows = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

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

  Future<void> _seedDefaultPlanTemplateIfNeeded() async {
    final existing = await (db.select(db.readingPlanTemplates)
          ..where((tbl) => tbl.templateKey.equals('whole_bible'))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;

    final now = DateTime.now();
    await db.into(db.readingPlanTemplates).insert(
          ReadingPlanTemplatesCompanion.insert(
            id: _uuid.v4(),
            templateKey: 'whole_bible',
            title: 'Bible in a Year',
            description: const Value('Track every chapter of the Bible in any order.'),
            planType: const Value('free_order'),
            isBuiltin: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _seedFourGospelsTemplateIfNeeded() async {
    final existing = await (db.select(db.readingPlanTemplates)
          ..where((tbl) => tbl.templateKey.equals('four_gospels'))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;

    final now = DateTime.now();
    await db.into(db.readingPlanTemplates).insert(
          ReadingPlanTemplatesCompanion.insert(
            id: _uuid.v4(),
            templateKey: 'four_gospels',
            title: 'Four Gospels',
            description: const Value(
              'Matthew, Mark, Luke, and John — for testing shorter plans.',
            ),
            planType: const Value('free_order'),
            isBuiltin: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _createDefaultUserPlanIfNeeded() async {
    final existing = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.templateKey.equals('whole_bible') &
                tbl.deletedAt.isNull(),
          )
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return;

    final now = DateTime.now();
    final planId = _uuid.v4();
    final localUserId = await _activeLocalUserId();

    await db.into(db.userReadingPlans).insert(
          UserReadingPlansCompanion.insert(
            id: planId,
            localUserId: localUserId,
            templateKey: 'whole_bible',
            title: 'Bible in a Year',
            status: const Value('active'),
            startedAt: Value(now),
            isActive: const Value(true),
            lastOpenedBookKey: const Value('genesis'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final chapters = await _planScopeChaptersForTemplate(
      planId: planId,
      templateKey: 'whole_bible',
      now: now,
    );

    await db.batch((batch) {
      batch.insertAll(db.planScopeChapters, chapters);
    });

    await _setSetting('last_active_plan_id', planId);
  }

  Future<List<PlanScopeChaptersCompanion>> _planScopeChaptersForTemplate({
    required String planId,
    required String templateKey,
    required DateTime now,
  }) async {
    final books = await _bibleBooksForTemplate(templateKey);
    var orderIndex = 0;
    final chapters = <PlanScopeChaptersCompanion>[];
    for (final book in books) {
      for (var chapter = 1; chapter <= book.chapterCount; chapter++) {
        orderIndex += 1;
        chapters.add(
          PlanScopeChaptersCompanion.insert(
            id: _uuid.v4(),
            planId: planId,
            bookKey: book.bookKey,
            chapterNumber: chapter,
            orderIndex: orderIndex,
            createdAt: now,
          ),
        );
      }
    }
    return chapters;
  }

  Future<List<BibleBook>> _bibleBooksForTemplate(String templateKey) async {
    switch (templateKey) {
      case 'whole_bible':
        return (db.select(db.bibleBooks)
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.bookOrder)]))
            .get();
      case 'four_gospels':
        const keys = <String>['matthew', 'mark', 'luke', 'john'];
        return (db.select(db.bibleBooks)
              ..where((tbl) => tbl.bookKey.isIn(keys))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.bookOrder)]))
            .get();
      default:
        return [];
    }
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
            planId: planId,
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
}
