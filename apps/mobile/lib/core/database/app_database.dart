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
  TextColumn get templateKey => text()();
  TextColumn get title => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get lastOpenedBookKey => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();

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

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {planId, bookKey, chapterNumber},
      ];
}

class ChapterProgressEntries extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {planId, bookKey, chapterNumber},
      ];
}

class ReadingActivities extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  TextColumn get bookKey => text()();
  IntColumn get chapterNumber => integer()();
  TextColumn get action => text()();
  TextColumn get activityDate => text()();
  TextColumn get timezone => text()();
  DateTimeColumn get happenedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only'))();

  @override
  Set<Column> get primaryKey => {id};
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
  int get schemaVersion => 1;
}
