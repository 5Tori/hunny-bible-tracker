import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/core/database/app_database.dart';
import 'package:hunny_bible_tracker/features/read/domain/read_models.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'support/test_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('daily reading goal', () {
    test('getDailyReadingGoalMinutes returns 0 when unset', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (repository, _) = await createTestRepositories(database: database);

      expect(await repository.getDailyReadingGoalMinutes(), 0);

      await database.close();
    });

    test('setDailyReadingGoalMinutes persists and clears on off', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (repository, _) = await createTestRepositories(database: database);

      await repository.setDailyReadingGoalMinutes(10);
      expect(await repository.getDailyReadingGoalMinutes(), 10);

      await repository.setDailyReadingGoalMinutes(0);
      expect(await repository.getDailyReadingGoalMinutes(), 0);

      await repository.setDailyReadingGoalMinutes(null);
      expect(await repository.getDailyReadingGoalMinutes(), 0);

      await database.close();
    });
  });

  group('getDailyReadingStats', () {
    test('returns zero progress when goal is off', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (repository, _) = await createTestRepositories(database: database);

      final stats = await repository.getDailyReadingStats();

      expect(stats.goalMinutes, 0);
      expect(stats.hasGoal, isFalse);
      expect(stats.todayMinutes, 0);
      expect(stats.chaptersToday, 0);
      expect(stats.goalMet, isFalse);
      expect(stats.progress, 0);

      await database.close();
    });

    test('sums today minutes from reading activities and bible_chapters', () async {
      const planId = 'plan-daily';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (repository, _) = await createTestRepositories(database: database);

      final profile = await repository.getLocalUserProfile();
      expect(profile, isNotNull);

      final today = DateTime(2026, 5, 30, 15, 30);
      final activityDate = DateFormat('yyyy-MM-dd').format(today);
      final now = DateTime(2026, 5, 30, 9, 0);

      await database.batch((batch) {
        batch.insertAll(database.readingActivities, [
          ReadingActivitiesCompanion.insert(
            id: uuid.v4(),
            localUserId: profile!.localUserId,
            userPlanId: planId,
            bookKey: 'genesis',
            chapterNumber: 37,
            action: 'complete',
            activityDate: activityDate,
            timezone: 'UTC',
            happenedAt: now,
            createdAt: now,
          ),
          ReadingActivitiesCompanion.insert(
            id: uuid.v4(),
            localUserId: profile.localUserId,
            userPlanId: planId,
            bookKey: 'genesis',
            chapterNumber: 38,
            action: 'complete',
            activityDate: activityDate,
            timezone: 'UTC',
            happenedAt: now,
            createdAt: now,
          ),
        ]);
      });

      await repository.setDailyReadingGoalMinutes(10);
      final stats = await repository.getDailyReadingStats(date: today);

      expect(stats.goalMinutes, 10);
      expect(stats.hasGoal, isTrue);
      expect(stats.chaptersToday, 2);
      expect(stats.todayMinutes, greaterThan(0));
      expect(stats.goalMet, stats.todayMinutes >= 10);
      expect(stats.progress, closeTo(stats.todayMinutes / 10, 0.001));

      await database.close();
    });

    test('goalMet is true when today minutes meet or exceed goal', () async {
      const planId = 'plan-goal-met';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (repository, _) = await createTestRepositories(database: database);

      final profile = await repository.getLocalUserProfile();
      final today = DateTime(2026, 5, 30);
      final activityDate = DateFormat('yyyy-MM-dd').format(today);
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
            activityDate: activityDate,
            timezone: 'UTC',
            happenedAt: today,
            createdAt: today,
          ),
        );
      }

      await database.batch((batch) {
        batch.insertAll(database.readingActivities, chapters);
      });

      await repository.setDailyReadingGoalMinutes(10);
      final stats = await repository.getDailyReadingStats(date: today);

      expect(stats.todayMinutes, 58);
      expect(stats.goalMet, isTrue);
      expect(stats.progress, 1.0);

      await database.close();
    });

    test('ignores reading activities on other dates', () async {
      const planId = 'plan-other-day';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (repository, _) = await createTestRepositories(database: database);

      final profile = await repository.getLocalUserProfile();
      final yesterday = DateTime(2026, 5, 29, 12, 0);

      await database.into(database.readingActivities).insert(
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
          );

      await repository.setDailyReadingGoalMinutes(10);
      final stats = await repository.getDailyReadingStats(
        date: DateTime(2026, 5, 30),
      );

      expect(stats.todayMinutes, 0);
      expect(stats.chaptersToday, 0);
      expect(stats.goalMet, isFalse);

      await database.close();
    });

    test('progressLabel uses English copy', () {
      const met = DailyReadingStats(
        goalMinutes: 10,
        todayMinutes: 12,
        chaptersToday: 2,
      );
      expect(met.progressLabel, '12 / 10 min today · Goal met');

      const inProgress = DailyReadingStats(
        goalMinutes: 10,
        todayMinutes: 3,
        chaptersToday: 1,
      );
      expect(inProgress.progressLabel, '3 / 10 min today');
      expect(inProgress.progress, closeTo(0.3, 0.001));
    });
  });

  group('exportReadingBackupSnapshot', () {
    test('includes dailyReadingGoalMinutes in settings when set', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (repository, _) = await createTestRepositories(database: database);

      await repository.setDailyReadingGoalMinutes(15);
      final snapshot = await repository.exportReadingBackupSnapshot();
      final settings = snapshot['settings'] as Map<String, dynamic>;

      expect(settings['dailyReadingGoalMinutes'], 15);

      await repository.setDailyReadingGoalMinutes(null);
      final offSnapshot = await repository.exportReadingBackupSnapshot();
      final offSettings = offSnapshot['settings'] as Map<String, dynamic>;
      expect(offSettings.containsKey('dailyReadingGoalMinutes'), isFalse);

      await database.close();
    });
  });
}
