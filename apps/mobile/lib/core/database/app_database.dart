import 'package:drift/drift.dart';

import 'connection/connection.dart'
    if (dart.library.io) 'connection/native.dart'
    if (dart.library.js_interop) 'connection/web.dart';

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

class BibleChapters extends Table {
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  IntColumn get verseCount => integer()();
  IntColumn get estimatedReadingSeconds => integer()();
  IntColumn get estimatedReadingMinutes => integer()();

  @override
  Set<Column> get primaryKey => {bookKey, chapterNumber};
}

class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().withDefault(const Constant('guest'))();
  TextColumn get authUserId => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();

  /// Server-side profile / identity row id after sync (`docs/SYNC_STRATEGY.md`).
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlanTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get templateKey => text().unique()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get shortDescription => text().withDefault(const Constant(''))();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get planType => text().withDefault(const Constant('canonical'))();
  TextColumn get testamentScope =>
      text().withDefault(const Constant('whole_bible'))();
  TextColumn get difficulty => text().nullable()();
  IntColumn get estimatedMinutes => integer().nullable()();
  IntColumn get estimatedDays => integer().nullable()();
  IntColumn get totalChapters => integer().withDefault(const Constant(0))();
  TextColumn get primaryBookKey => text().nullable()();
  TextColumn get primaryCharacter => text().nullable()();
  BoolColumn get isBuiltin => boolean().withDefault(const Constant(true))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(true))();
  IntColumn get featuredRank => integer().nullable()();
  BoolColumn get browseVisible => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlanTemplateSections extends Table {
  TextColumn get id => text()();
  TextColumn get planTemplateId => text()();
  TextColumn get sectionKey => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get orderIndex => integer()();
  IntColumn get estimatedMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {planTemplateId, sectionKey},
      ];
}

class PlanTemplateItems extends Table {
  TextColumn get id => text()();
  TextColumn get sectionId => text()();
  IntColumn get orderIndex => integer()();
  TextColumn get bookKey => text()();
  IntColumn get startChapter => integer()();
  IntColumn get endChapter => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlanTags extends Table {
  TextColumn get id => text()();
  TextColumn get key => text().unique()();
  TextColumn get name => text()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlanTemplateTags extends Table {
  TextColumn get planTemplateId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {planTemplateId, tagId};
}

class UserReadingPlans extends Table {
  TextColumn get id => text()();
  TextColumn get localUserId => text()();
  TextColumn get templateId => text()();
  TextColumn get title => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get subscribedAt => dateTime()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get lastOpenedSectionId => text().nullable()();
  TextColumn get lastOpenedBookKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserPlanChapters extends Table {
  TextColumn get id => text()();
  TextColumn get userPlanId => text()();
  TextColumn get sectionId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  IntColumn get orderIndex => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userPlanId, bookKey, chapterNumber},
      ];
}

class PlanCompletionEvents extends Table {
  TextColumn get id => text()();
  TextColumn get localUserId => text()();
  TextColumn get userPlanId => text()();
  TextColumn get templateId => text()();
  IntColumn get completionNumber => integer()();
  DateTimeColumn get completedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userPlanId},
      ];
}

class ChapterProgressEntries extends Table {
  TextColumn get id => text()();
  TextColumn get localUserId => text()();
  TextColumn get userPlanId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {localUserId, userPlanId, bookKey, chapterNumber},
      ];
}

class ReadingActivities extends Table {
  TextColumn get id => text()();
  TextColumn get localUserId => text()();
  TextColumn get userPlanId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  TextColumn get action => text()();
  TextColumn get activityDate => text()();
  TextColumn get timezone => text()();
  DateTimeColumn get happenedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();
  TextColumn get serverId => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get clientRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  /// Idempotent "complete" per calendar day (`docs/DATA_MODEL.md`).
  @override
  List<Set<Column>> get uniqueKeys => [
        {localUserId, userPlanId, bookKey, chapterNumber, activityDate, action},
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
    BibleChapters,
    LocalUsers,
    PlanTemplates,
    PlanTemplateSections,
    PlanTemplateItems,
    PlanTags,
    PlanTemplateTags,
    UserReadingPlans,
    UserPlanChapters,
    PlanCompletionEvents,
    ChapterProgressEntries,
    ReadingActivities,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          final db = m.database;
          if (await _sqliteUserTableCount(db) == 0) {
            await m.createAll();
            return;
          }

          if (from < 2) {
            await _ensurePlanTemplateCatalog(m, db);
          }
          if (from < 3 &&
              !await _sqliteTableExists(db, 'bible_chapters')) {
            await m.createTable(bibleChapters);
          }
          if (from < 4) {
            await _repairIncompleteSchema(m, db);
          }
        },
      );

  Future<void> _ensurePlanTemplateCatalog(
    Migrator m,
    GeneratedDatabase db,
  ) async {
    if (await _sqliteTableExists(db, 'plan_templates')) {
      if (!await _sqliteColumnExists(db, 'plan_templates', 'featured_rank')) {
        await m.addColumn(planTemplates, planTemplates.featuredRank);
      }
      if (!await _sqliteColumnExists(db, 'plan_templates', 'browse_visible')) {
        await m.addColumn(planTemplates, planTemplates.browseVisible);
      }
      return;
    }

    await m.createTable(planTemplates);
    await m.createTable(planTemplateSections);
    await m.createTable(planTemplateItems);
    await m.createTable(planTags);
    await m.createTable(planTemplateTags);
  }

  Future<void> _repairIncompleteSchema(
    Migrator m,
    GeneratedDatabase db,
  ) async {
    if (!await _sqliteTableExists(db, 'bible_chapters')) {
      await m.createTable(bibleChapters);
    }
    await _ensurePlanTemplateCatalog(m, db);
  }
}

Future<int> _sqliteUserTableCount(GeneratedDatabase db) async {
  final row = await db.customSelect(
    'SELECT COUNT(*) AS count FROM sqlite_master '
    "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' "
    "AND name != 'drift_schema_versions'",
  ).getSingle();
  return row.read<int>('count');
}

Future<bool> _sqliteTableExists(GeneratedDatabase db, String tableName) async {
  final row = await db.customSelect(
    'SELECT 1 AS ok FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
    variables: [
      Variable.withString('table'),
      Variable.withString(tableName),
    ],
  ).getSingleOrNull();
  return row != null;
}

Future<bool> _sqliteColumnExists(
  GeneratedDatabase db,
  String tableName,
  String columnName,
) async {
  final row = await db.customSelect(
    "SELECT 1 AS ok FROM pragma_table_info('$tableName') "
    'WHERE name = ? LIMIT 1',
    variables: [Variable.withString(columnName)],
  ).getSingleOrNull();
  return row != null;
}
