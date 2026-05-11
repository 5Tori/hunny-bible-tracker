import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/read_models.dart';

class ReadRepository {
  ReadRepository(this.db);

  final AppDatabase db;
  final Uuid _uuid = const Uuid();

  Future<void> initializeLocalData() async {
    await db.transaction(() async {
      await _seedBibleBooksIfNeeded();
      await _seedDefaultPlanTemplateIfNeeded();
      await _createDefaultUserPlanIfNeeded();
      await _seedDefaultSettingsIfNeeded();
    });
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

  Future<List<BookProgress>> getBooksWithProgress(String planId) async {
    final books = await (db.select(db.bibleBooks)
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

    final completed = progressRows.map((row) => row.chapterNumber).toSet();

    return List.generate(
      book.chapterCount,
      (index) {
        final chapterNumber = index + 1;
        return ChapterProgressView(
          chapterNumber: chapterNumber,
          isCompleted: completed.contains(chapterNumber),
        );
      },
    );
  }

  Future<void> rememberLastOpenedBook({
    required String planId,
    required String bookKey,
  }) async {
    await (db.update(db.userReadingPlans)..where((tbl) => tbl.id.equals(planId)))
        .write(
      UserReadingPlansCompanion(
        lastOpenedBookKey: Value(bookKey),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
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

  Future<OverviewStats> getOverviewStats(String planId) async {
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

    final activities = await (db.select(db.readingActivities)
          ..where(
            (tbl) =>
                tbl.planId.equals(planId) &
                tbl.action.equals('complete'),
          ))
        .get();

    final readingDates = activities.map((row) => row.activityDate).toSet();
    final currentStreak = _calculateCurrentStreak(readingDates);

    final average = readingDates.isEmpty
        ? 0.0
        : activities.length.toDouble() / readingDates.length.toDouble();

    return OverviewStats(
      completedChapters: completed.length,
      totalChapters: planChapters.length,
      currentStreak: currentStreak,
      readingDays: readingDates.length,
      averageChaptersPerReadingDay: average,
    );
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
            title: 'Whole Bible',
            description: const Value('Track every chapter of the Bible in any order.'),
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

    await db.into(db.userReadingPlans).insert(
          UserReadingPlansCompanion.insert(
            id: planId,
            templateKey: 'whole_bible',
            title: 'Whole Bible',
            isActive: const Value(true),
            lastOpenedBookKey: const Value('genesis'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final books = await (db.select(db.bibleBooks)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.bookOrder)]))
        .get();

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

    await db.batch((batch) {
      batch.insertAll(db.planScopeChapters, chapters);
    });

    await _setSetting('last_active_plan_id', planId);
  }

  Future<void> _seedDefaultSettingsIfNeeded() async {
    await _setSettingIfMissing('language', 'en');
    await _setSettingIfMissing('timezone', DateTime.now().timeZoneName);
    await _setSettingIfMissing('account_mode', 'guest');
  }

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
    await db.into(db.readingActivities).insert(
          ReadingActivitiesCompanion.insert(
            id: _uuid.v4(),
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
