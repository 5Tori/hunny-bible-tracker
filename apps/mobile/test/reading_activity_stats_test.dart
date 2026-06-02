import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/core/database/app_database.dart';
import 'package:hunny_bible_tracker/features/read/domain/read_models.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'support/test_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getAccountReadingStats', () {
    test('returns empty streaks and year grid when no activities', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (_, statsRepo) = await createTestRepositories(database: database);

      final anchor = DateTime(2026, 5, 30);
      final stats = await statsRepo.getAccountReadingStats(anchorDate: anchor);

      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.readingDaysTotal, 0);
      expect(stats.readingDaysInRange, 0);
      expect(stats.activityYear.yearLabel, 2026);
      expect(stats.activityYear.weekColumns, isNotEmpty);
      expect(stats.activityYear.rangeEnd, DateTime(2026, 5, 30));

      await database.close();
    });

    test('current streak requires reading on anchor day', () async {
      const planId = 'plan-streak';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (readRepo, statsRepo) = await createTestRepositories(database: database);

      final profile = await readRepo.getLocalUserProfile();
      final anchor = DateTime(2026, 5, 30, 12, 0);
      final yesterday = anchor.subtract(const Duration(days: 1));

      await database.batch((batch) {
        batch.insertAll(database.readingActivities, [
          ReadingActivitiesCompanion.insert(
            id: uuid.v4(),
            localUserId: profile!.localUserId,
            userPlanId: planId,
            bookKey: 'genesis',
            chapterNumber: 1,
            action: 'complete',
            activityDate: DateFormat('yyyy-MM-dd').format(yesterday),
            timezone: 'UTC',
            happenedAt: yesterday,
            createdAt: yesterday,
          ),
        ]);
      });

      final withoutToday =
          await statsRepo.getAccountReadingStats(anchorDate: anchor);
      expect(withoutToday.currentStreak, 0);
      expect(withoutToday.longestStreak, 1);

      await database.into(database.readingActivities).insert(
            ReadingActivitiesCompanion.insert(
              id: uuid.v4(),
              localUserId: profile!.localUserId,
              userPlanId: planId,
              bookKey: 'genesis',
              chapterNumber: 2,
              action: 'complete',
              activityDate: DateFormat('yyyy-MM-dd').format(anchor),
              timezone: 'UTC',
              happenedAt: anchor,
              createdAt: anchor,
            ),
          );

      final withToday =
          await statsRepo.getAccountReadingStats(anchorDate: anchor);
      expect(withToday.currentStreak, 2);
      expect(withToday.longestStreak, 2);

      await database.close();
    });

    test('longest streak spans a gap', () async {
      const planId = 'plan-longest';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (readRepo, statsRepo) = await createTestRepositories(database: database);

      final profile = await readRepo.getLocalUserProfile();
      final anchor = DateTime(2026, 5, 30, 12, 0);
      final day1 = anchor.subtract(const Duration(days: 3));
      final day2 = anchor.subtract(const Duration(days: 2));
      final day3 = anchor.subtract(const Duration(days: 1));
      final day4 = anchor;

      await database.batch((batch) {
        batch.insertAll(database.readingActivities, [
          for (final day in [day1, day2, day3, day4])
            ReadingActivitiesCompanion.insert(
              id: uuid.v4(),
              localUserId: profile!.localUserId,
              userPlanId: planId,
              bookKey: 'genesis',
              chapterNumber: 1,
              action: 'complete',
              activityDate: DateFormat('yyyy-MM-dd').format(day),
              timezone: 'UTC',
              happenedAt: day,
              createdAt: day,
            ),
        ]);
      });

      final stats =
          await statsRepo.getAccountReadingStats(anchorDate: anchor);
      expect(stats.currentStreak, 4);
      expect(stats.longestStreak, 4);
      expect(stats.readingDaysInRange, 4);

      await database.close();
    });

    test('marks goal met days in rolling range', () async {
      const planId = 'plan-goal';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (readRepo, statsRepo) = await createTestRepositories(database: database);

      final profile = await readRepo.getLocalUserProfile();
      final anchor = DateTime(2026, 5, 30, 12, 0);

      await readRepo.setDailyReadingGoalMinutes(10);
      final chapters = <ReadingActivitiesCompanion>[];
      for (var chapter = 37; chapter <= 50; chapter += 1) {
        chapters.add(
          ReadingActivitiesCompanion.insert(
            id: uuid.v4(),
            localUserId: profile!.localUserId,
            userPlanId: planId,
            bookKey: 'genesis',
            chapterNumber: chapter,
            action: 'complete',
            activityDate: DateFormat('yyyy-MM-dd').format(anchor),
            timezone: 'UTC',
            happenedAt: anchor,
            createdAt: anchor,
          ),
        );
      }
      await database.batch((batch) {
        batch.insertAll(database.readingActivities, chapters);
      });

      final stats =
          await statsRepo.getAccountReadingStats(anchorDate: anchor);

      expect(stats.goalMetDaysInRange, 1);
      final todaySummary = stats.activityYear.weekColumns
          .expand((column) => column.days)
          .whereType<ReadingDaySummary>()
          .where((day) => day.activityDate == '2026-05-30')
          .single;
      expect(todaySummary.goalMet, isTrue);

      await database.close();
    });
  });
}
