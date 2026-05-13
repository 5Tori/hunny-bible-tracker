import 'package:drift/drift.dart';

import 'connection/connection.dart'
    if (dart.library.io) 'connection/native.dart'
    if (dart.library.js_interop) 'connection/web.dart';
import 'local_user_id.dart';

part 'app_database.g.dart';

class BibleBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookKey => text().unique()();
  TextColumn get testament => text()();
  IntColumn get bookOrder => integer()();
  TextColumn get shortName => text()();
  TextColumn get displayNameEn => text()();
  TextColumn get displayNameKo => text().nullable()();
  IntColumn get chapterCount => integer()();
}

class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(const Constant('guest'))();
  TextColumn get authUserId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  /// Server-side profile / identity row id after sync (`docs/SYNC_PLAN.md`).
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ReadingPlanTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get templateKey => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get planType => text().withDefault(const Constant('free_order'))();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserReadingPlans extends Table {
  TextColumn get id => text()();
  TextColumn get localUserId => text()();
  TextColumn get templateKey => text()();
  TextColumn get title => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get lastOpenedBookKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class PlanScopeChapters extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  IntColumn get orderIndex => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {planId, bookKey, chapterNumber},
      ];
}

class ChapterProgressEntries extends Table {
  TextColumn get id => text()();
  TextColumn get localUserId => text()();
  TextColumn get planId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {planId, bookKey, chapterNumber},
      ];
}

class ReadingActivities extends Table {
  TextColumn get id => text()();
  TextColumn get localUserId => text()();
  TextColumn get planId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  TextColumn get action => text()();
  TextColumn get activityDate => text()();
  TextColumn get timezone => text()();
  DateTimeColumn get happenedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  /// Idempotent "complete" per calendar day (`docs/PROGRESS_AND_ACTIVITY_PLAN.md` §5.2).
  @override
  List<Set<Column>> get uniqueKeys => [
        {localUserId, planId, bookKey, chapterNumber, activityDate, action},
      ];
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    BibleBooks,
    LocalUsers,
    ReadingPlanTemplates,
    UserReadingPlans,
    PlanScopeChapters,
    ChapterProgressEntries,
    ReadingActivities,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(localUsers);
            final now = DateTime.now();
            await into(localUsers).insert(
              LocalUsersCompanion.insert(
                id: generateShortLocalUserId(),
                createdAt: now,
                updatedAt: now,
              ),
            );

            await m.addColumn(userReadingPlans, userReadingPlans.localUserId);
            await m.addColumn(userReadingPlans, userReadingPlans.status);
            await m.addColumn(userReadingPlans, userReadingPlans.startedAt);
            await m.addColumn(userReadingPlans, userReadingPlans.completedAt);

            await m.addColumn(
              chapterProgressEntries,
              chapterProgressEntries.localUserId,
            );
            await m.addColumn(
              readingActivities,
              readingActivities.localUserId,
            );

            await customStatement(
              'UPDATE user_reading_plans SET started_at = created_at '
              'WHERE started_at IS NULL',
            );

            await customStatement('''
DELETE FROM reading_activities
WHERE rowid NOT IN (
  SELECT MIN(rowid) FROM reading_activities
  GROUP BY local_user_id, plan_id, book_key, chapter_number, activity_date, action
)
''');

            await customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS reading_activities_complete_unique
ON reading_activities (
  local_user_id,
  plan_id,
  book_key,
  chapter_number,
  activity_date,
  action
)
''');
          }
          if (from < 3) {
            await m.addColumn(localUsers, localUsers.syncStatus);
            await m.addColumn(localUsers, localUsers.serverId);
            await m.addColumn(localUsers, localUsers.lastSyncedAt);
            await m.addColumn(localUsers, localUsers.clientRevision);

            await m.addColumn(userReadingPlans, userReadingPlans.serverId);
            await m.addColumn(userReadingPlans, userReadingPlans.lastSyncedAt);
            await m.addColumn(userReadingPlans, userReadingPlans.clientRevision);

            await m.addColumn(
              planScopeChapters,
              planScopeChapters.syncStatus,
            );
            await m.addColumn(planScopeChapters, planScopeChapters.serverId);
            await m.addColumn(
              planScopeChapters,
              planScopeChapters.lastSyncedAt,
            );
            await m.addColumn(
              planScopeChapters,
              planScopeChapters.clientRevision,
            );

            await m.addColumn(
              chapterProgressEntries,
              chapterProgressEntries.serverId,
            );
            await m.addColumn(
              chapterProgressEntries,
              chapterProgressEntries.lastSyncedAt,
            );
            await m.addColumn(
              chapterProgressEntries,
              chapterProgressEntries.clientRevision,
            );

            await m.addColumn(readingActivities, readingActivities.serverId);
            await m.addColumn(
              readingActivities,
              readingActivities.lastSyncedAt,
            );
            await m.addColumn(
              readingActivities,
              readingActivities.clientRevision,
            );
          }
          if (from < 4) {
            final row = await (select(localUsers)..limit(1)).getSingleOrNull();
            if (row != null && row.id == kLegacyGuestLocalUserId) {
              final newId = generateShortLocalUserId();
              await customStatement(
                'UPDATE user_reading_plans SET local_user_id = ? '
                'WHERE local_user_id = ?',
                [newId, kLegacyGuestLocalUserId],
              );
              await customStatement(
                'UPDATE chapter_progress_entries SET local_user_id = ? '
                'WHERE local_user_id = ?',
                [newId, kLegacyGuestLocalUserId],
              );
              await customStatement(
                'UPDATE reading_activities SET local_user_id = ? '
                'WHERE local_user_id = ?',
                [newId, kLegacyGuestLocalUserId],
              );
              await customStatement(
                'UPDATE local_users SET id = ? WHERE id = ?',
                [newId, kLegacyGuestLocalUserId],
              );
            }
          }
        },
      );
}
