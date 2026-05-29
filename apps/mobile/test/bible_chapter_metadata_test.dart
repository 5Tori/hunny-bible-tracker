import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/core/bible/bible_chapter_metadata.dart';

void main() {
  group('BibleChapterMetadata', () {
    late BibleChapterMetadata metadata;

    setUp(() {
      final file = File('assets/data/bible_chapters.json');
      final rows = (jsonDecode(file.readAsStringSync()) as List<dynamic>)
          .cast<Map<String, dynamic>>();
      metadata = BibleChapterMetadata.fromJsonList(rows);
    });

    test('loads 1189 chapters', () {
      expect(metadata.getChapter('genesis', 1)?.verseCount, 31);
      expect(metadata.getChapter('revelation', 22)?.verseCount, greaterThan(0));
    });

    test('genesis 37-50 matches Joseph plan range', () {
      final totalMinutes =
          metadata.sumReadingMinutesForRange('genesis', 37, 50);
      final averageMinutes =
          metadata.averageReadingMinutesForRange('genesis', 37, 50);

      expect(totalMinutes, 58);
      expect(averageMinutes, 4);
    });

    test('reading time helpers use 7 seconds per verse', () {
      expect(readingSecondsForVerseCount(31), 217);
      expect(readingMinutesForVerseCount(31), 4);
      expect(readingMinutesForVerseCount(1), 1);
    });
  });
}
