import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/core/database/app_database.dart';
import 'package:hunny_bible_tracker/features/read/data/read_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getPlanProgressStats', () {
    test('computes average minutes per chapter from plan chapters', () async {
      const planId = 'plan-joseph';
      const sectionId = 'section-joseph';
      const uuid = Uuid();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = ReadRepository(database);
      await repository.initializeLocalData();

      final now = DateTime.now();
      final chapters = <UserPlanChaptersCompanion>[];
      var orderIndex = 0;
      for (var chapter = 37; chapter <= 50; chapter += 1) {
        orderIndex += 1;
        chapters.add(
          UserPlanChaptersCompanion.insert(
            id: uuid.v4(),
            userPlanId: planId,
            sectionId: sectionId,
            bookKey: 'genesis',
            chapterNumber: chapter,
            orderIndex: orderIndex,
            createdAt: now,
          ),
        );
      }

      await database.batch((batch) {
        batch.insertAll(database.userPlanChapters, chapters);
      });

      final stats = await repository.getPlanProgressStats(planId);

      expect(stats.totalChapters, 14);
      expect(stats.averageMinutesPerChapter, closeTo(4, 0.01));

      await database.close();
    });
  });
}
