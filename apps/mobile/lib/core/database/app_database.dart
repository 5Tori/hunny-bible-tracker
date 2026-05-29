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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(planTemplates, planTemplates.featuredRank);
            await m.addColumn(planTemplates, planTemplates.browseVisible);
          }
          if (from < 3) {
            await m.createTable(bibleChapters);
          }
        },
      );
}
