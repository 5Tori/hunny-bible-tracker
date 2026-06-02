import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/core/database/app_database.dart';
import 'package:hunny_bible_tracker/features/read/data/read_repository.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'support/test_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReadingStatsRepository', () {
    test('returns zeros when no activities exist', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (_, stats) = await createTestRepositories(database: database);

      final anchor = DateTime(2026, 5, 29);
      final tracker = await stats.getReadingTrackerStats(anchorDate: anchor);

      expect(tracker.chaptersToday, 0);
      expect(tracker.estimatedMinutesToday, 0);
      expect(tracker.chaptersThisWeek, 0);
      expect(tracker.readingDaysThisWeek, 0);
      expect(tracker.readingDaysThisMonth, 0);
      expect(tracker.lifetimeChapters, 0);
      expect(tracker.lifetimeReadingDays, 0);
      expect(tracker.currentStreak, 0);
      expect(tracker.activePlanCount, 0);
      expect(tracker.completedPlanCount, 0);

      await database.close();
    });

    test('counts today chapters from reading activities', () async {
      const planId = 'plan-today';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (read, stats) = await createTestRepositories(database: database);
      final profile = await read.getLocalUserProfile();
      final today = DateTime(2026, 5, 29, 15, 0);
      final activityDate = DateFormat('yyyy-MM-dd').format(today);

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
            happenedAt: today,
            createdAt: today,
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
            happenedAt: today,
            createdAt: today,
          ),
        ]);
      });

      final tracker = await stats.getReadingTrackerStats(anchorDate: today);

      expect(tracker.chaptersToday, 2);
      expect(tracker.estimatedMinutesToday, greaterThan(0));

      await database.close();
    });

    test('uncheck keeps today activity count but progress drops', () async {
      const planId = 'plan-uncheck';
      const sectionId = 'section-1';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (read, stats) = await createTestRepositories(database: database);
      final profile = await read.getLocalUserProfile();
      final now = DateTime.now();

      await database.into(database.userReadingPlans).insert(
            UserReadingPlansCompanion.insert(
              id: planId,
              localUserId: profile!.localUserId,
              templateId: 'template-1',
              title: 'Test Plan',
              subscribedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database.batch((batch) {
        batch.insertAll(database.userPlanChapters, [
          UserPlanChaptersCompanion.insert(
            id: uuid.v4(),
            userPlanId: planId,
            sectionId: sectionId,
            bookKey: 'genesis',
            chapterNumber: 37,
            orderIndex: 1,
            createdAt: now,
          ),
          UserPlanChaptersCompanion.insert(
            id: uuid.v4(),
            userPlanId: planId,
            sectionId: sectionId,
            bookKey: 'genesis',
            chapterNumber: 38,
            orderIndex: 2,
            createdAt: now,
          ),
        ]);
      });

      await read.toggleChapter(
        planId: planId,
        sectionId: sectionId,
        bookKey: 'genesis',
        chapterNumber: 37,
      );
      await read.toggleChapter(
        planId: planId,
        sectionId: sectionId,
        bookKey: 'genesis',
        chapterNumber: 38,
      );

      var tracker = await stats.getReadingTrackerStats();
      var planStats = await read.getPlanProgressStats(planId);
      expect(tracker.chaptersToday, 2);
      expect(planStats.completedChapters, 2);

      await read.toggleChapter(
        planId: planId,
        sectionId: sectionId,
        bookKey: 'genesis',
        chapterNumber: 38,
      );

      tracker = await stats.getReadingTrackerStats();
      planStats = await read.getPlanProgressStats(planId);
      expect(tracker.chaptersToday, 2);
      expect(planStats.completedChapters, 1);

      await database.close();
    });

    test('same chapter same day does not duplicate activity', () async {
      const planId = 'plan-dup';
      const sectionId = 'section-dup';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (read, stats) = await createTestRepositories(database: database);
      final profile = await read.getLocalUserProfile();
      final now = DateTime.now();

      await database.into(database.userReadingPlans).insert(
            UserReadingPlansCompanion.insert(
              id: planId,
              localUserId: profile!.localUserId,
              templateId: 'template-dup',
              title: 'Dup Plan',
              subscribedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await database.into(database.userPlanChapters).insert(
            UserPlanChaptersCompanion.insert(
              id: uuid.v4(),
              userPlanId: planId,
              sectionId: sectionId,
              bookKey: 'genesis',
              chapterNumber: 37,
              orderIndex: 1,
              createdAt: now,
            ),
          );

      await read.toggleChapter(
        planId: planId,
        sectionId: sectionId,
        bookKey: 'genesis',
        chapterNumber: 37,
      );
      await read.toggleChapter(
        planId: planId,
        sectionId: sectionId,
        bookKey: 'genesis',
        chapterNumber: 37,
      );
      await read.toggleChapter(
        planId: planId,
        sectionId: sectionId,
        bookKey: 'genesis',
        chapterNumber: 37,
      );

      final tracker = await stats.getReadingTrackerStats();
      expect(tracker.chaptersToday, 1);
      expect(tracker.lifetimeChapters, 1);

      await database.close();
    });

    test('same chapter on different days increases lifetime count', () async {
      const planId = 'plan-days';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (read, stats) = await createTestRepositories(database: database);
      final profile = await read.getLocalUserProfile();
      final day1 = DateTime(2026, 5, 28);
      final day2 = DateTime(2026, 5, 29);

      for (final day in [day1, day2]) {
        await database.into(database.readingActivities).insert(
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
            );
      }

      final tracker = await stats.getReadingTrackerStats(anchorDate: day2);
      expect(tracker.lifetimeChapters, 2);

      await database.close();
    });

    test('weekly stats use Sunday through Saturday and count reading days', () async {
      const planId = 'plan-week';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (_, stats) = await createTestRepositories(database: database);
      final profile = (await database.select(database.localUsers).get()).first;

      final anchor = DateTime(2026, 5, 29);
      final inWeekDays = [
        DateTime(2026, 5, 24),
        DateTime(2026, 5, 26),
        DateTime(2026, 5, 28),
      ];

      for (final day in inWeekDays) {
        await database.into(database.readingActivities).insert(
              ReadingActivitiesCompanion.insert(
                id: uuid.v4(),
                localUserId: profile.id,
                userPlanId: planId,
                bookKey: 'genesis',
                chapterNumber: day.day,
                action: 'complete',
                activityDate: DateFormat('yyyy-MM-dd').format(day),
                timezone: 'UTC',
                happenedAt: day,
                createdAt: day,
              ),
            );
      }

      await database.into(database.readingActivities).insert(
            ReadingActivitiesCompanion.insert(
              id: uuid.v4(),
              localUserId: profile.id,
              userPlanId: planId,
              bookKey: 'genesis',
              chapterNumber: 99,
              action: 'complete',
              activityDate: '2026-05-23',
              timezone: 'UTC',
              happenedAt: DateTime(2026, 5, 23),
              createdAt: DateTime(2026, 5, 23),
            ),
          );

      final weekly = await stats.getWeeklyReadingDayStats(anchorDate: anchor);
      final tracker = await stats.getReadingTrackerStats(anchorDate: anchor);

      expect(weekly.readingDays, 3);
      expect(weekly.chapters, 3);
      expect(tracker.readingDaysThisWeek, 3);
      expect(tracker.chaptersThisWeek, 3);

      await database.close();
    });

    test('monthly reading day count uses current calendar month', () async {
      const planId = 'plan-month';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (_, stats) = await createTestRepositories(database: database);
      final profile = (await database.select(database.localUsers).get()).first;
      final anchor = DateTime(2026, 5, 29);

      for (var day = 1; day <= 10; day += 1) {
        final date = DateTime(2026, 5, day);
        await database.into(database.readingActivities).insert(
              ReadingActivitiesCompanion.insert(
                id: uuid.v4(),
                localUserId: profile.id,
                userPlanId: planId,
                bookKey: 'genesis',
                chapterNumber: day,
                action: 'complete',
                activityDate: DateFormat('yyyy-MM-dd').format(date),
                timezone: 'UTC',
                happenedAt: date,
                createdAt: date,
              ),
            );
      }

      await database.into(database.readingActivities).insert(
            ReadingActivitiesCompanion.insert(
              id: uuid.v4(),
              localUserId: profile.id,
              userPlanId: planId,
              bookKey: 'genesis',
              chapterNumber: 30,
              action: 'complete',
              activityDate: '2026-04-30',
              timezone: 'UTC',
              happenedAt: DateTime(2026, 4, 30),
              createdAt: DateTime(2026, 4, 30),
            ),
          );

      final monthly = await stats.getMonthlyReadingDayStats(anchorDate: anchor);
      final tracker = await stats.getReadingTrackerStats(anchorDate: anchor);

      expect(monthly.readingDays, 10);
      expect(tracker.readingDaysThisMonth, 10);

      await database.close();
    });

    test('plan lifecycle stats count active and completed plans', () async {
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (_, stats) = await createTestRepositories(database: database);
      final profile = (await database.select(database.localUsers).get()).first;
      final started = DateTime(2026, 5, 1);
      final completed = DateTime(2026, 5, 10);

      await database.batch((batch) {
        batch.insertAll(database.userReadingPlans, [
          UserReadingPlansCompanion.insert(
            id: 'active-plan',
            localUserId: profile.id,
            templateId: 't1',
            title: 'Active',
            status: const Value('active'),
            subscribedAt: started,
            startedAt: Value(started),
            createdAt: started,
            updatedAt: started,
          ),
          UserReadingPlansCompanion.insert(
            id: 'completed-plan',
            localUserId: profile.id,
            templateId: 't2',
            title: 'Done',
            status: const Value('completed'),
            subscribedAt: started,
            startedAt: Value(started),
            completedAt: Value(completed),
            createdAt: started,
            updatedAt: completed,
          ),
        ]);
        batch.insertAll(database.planCompletionEvents, [
          PlanCompletionEventsCompanion.insert(
            id: uuid.v4(),
            localUserId: profile.id,
            userPlanId: 'completed-plan',
            templateId: 't2',
            completionNumber: 1,
            completedAt: completed,
            createdAt: completed,
          ),
          PlanCompletionEventsCompanion.insert(
            id: uuid.v4(),
            localUserId: profile.id,
            userPlanId: 'completed-plan-2',
            templateId: 't3',
            completionNumber: 1,
            completedAt: completed,
            createdAt: completed,
          ),
        ]);
      });

      final lifecycle = await stats.getPlanLifecycleStats();
      final tracker = await stats.getReadingTrackerStats();

      expect(lifecycle.activePlanCount, 1);
      expect(lifecycle.completedPlanCount, 2);
      expect(lifecycle.averagePlanCompletionDays, closeTo(9, 0.01));
      expect(tracker.completedPlanCount, 2);

      await database.close();
    });

    test('excludes completion events without started_at from average', () async {
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final (_, stats) = await createTestRepositories(database: database);
      final profile = (await database.select(database.localUsers).get()).first;
      final completed = DateTime(2026, 5, 10);

      await database.into(database.userReadingPlans).insert(
            UserReadingPlansCompanion.insert(
              id: 'no-start-plan',
              localUserId: profile.id,
              templateId: 't-no-start',
              title: 'No start',
              status: const Value('completed'),
              subscribedAt: completed,
              createdAt: completed,
              updatedAt: completed,
            ),
          );

      await database.into(database.planCompletionEvents).insert(
            PlanCompletionEventsCompanion.insert(
              id: uuid.v4(),
              localUserId: profile.id,
              userPlanId: 'no-start-plan',
              templateId: 't-no-start',
              completionNumber: 1,
              completedAt: completed,
              createdAt: completed,
            ),
          );

      final lifecycle = await stats.getPlanLifecycleStats();
      expect(lifecycle.completedPlanCount, 1);
      expect(lifecycle.averagePlanCompletionDays, null);

      await database.close();
    });
  });
}
