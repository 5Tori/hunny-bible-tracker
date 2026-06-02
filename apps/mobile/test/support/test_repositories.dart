import 'package:drift/native.dart';
import 'package:hunny_bible_tracker/core/database/app_database.dart';
import 'package:hunny_bible_tracker/features/read/data/read_repository.dart';
import 'package:hunny_bible_tracker/features/stats/data/reading_stats_repository.dart';

Future<(ReadRepository read, ReadingStatsRepository stats)> createTestRepositories({
  AppDatabase? database,
}) async {
  final db = database ?? AppDatabase.forTesting(NativeDatabase.memory());
  final stats = ReadingStatsRepository(db);
  final read = ReadRepository(db, statsRepository: stats);
  await read.initializeLocalData();
  return (read, stats);
}
