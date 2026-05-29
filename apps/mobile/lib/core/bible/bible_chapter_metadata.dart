/// Verse-based reading time estimates for Bible chapters.
library;

import 'dart:math';

import '../database/app_database.dart';

/// Seconds allocated per verse for MVP reading-time estimates.
const int kSecondsPerVerse = 7;

int readingSecondsForVerseCount(int verseCount) {
  return verseCount * kSecondsPerVerse;
}

int readingMinutesForVerseCount(int verseCount) {
  final seconds = readingSecondsForVerseCount(verseCount);
  return max(1, (seconds / 60).ceil());
}

class BibleChapterReadingEstimate {
  const BibleChapterReadingEstimate({
    required this.bookKey,
    required this.chapterNumber,
    required this.verseCount,
    required this.estimatedReadingSeconds,
    required this.estimatedReadingMinutes,
  });

  final String bookKey;
  final int chapterNumber;
  final int verseCount;
  final int estimatedReadingSeconds;
  final int estimatedReadingMinutes;

  factory BibleChapterReadingEstimate.fromJson(Map<String, dynamic> json) {
    return BibleChapterReadingEstimate(
      bookKey: json['book_key'] as String,
      chapterNumber: json['chapter_number'] as int,
      verseCount: json['verse_count'] as int,
      estimatedReadingSeconds: json['estimated_reading_seconds'] as int,
      estimatedReadingMinutes: json['estimated_reading_minutes'] as int,
    );
  }

  factory BibleChapterReadingEstimate.fromRow(BibleChapter row) {
    return BibleChapterReadingEstimate(
      bookKey: row.bookKey,
      chapterNumber: row.chapterNumber,
      verseCount: row.verseCount,
      estimatedReadingSeconds: row.estimatedReadingSeconds,
      estimatedReadingMinutes: row.estimatedReadingMinutes,
    );
  }
}

/// In-memory lookup for chapter verse counts and reading estimates.
class BibleChapterMetadata {
  BibleChapterMetadata._(this._chapters);

  final Map<String, Map<int, BibleChapterReadingEstimate>> _chapters;

  static Future<BibleChapterMetadata> loadFromDatabase(AppDatabase db) async {
    final rows = await db.select(db.bibleChapters).get();
    return BibleChapterMetadata._fromRows(rows);
  }

  static BibleChapterMetadata fromJsonList(List<Map<String, dynamic>> json) {
    return BibleChapterMetadata._fromEstimates(
      json.map(BibleChapterReadingEstimate.fromJson).toList(),
    );
  }

  static BibleChapterMetadata _fromRows(List<BibleChapter> rows) {
    return _fromEstimates(rows.map(BibleChapterReadingEstimate.fromRow).toList());
  }

  static BibleChapterMetadata _fromEstimates(
    List<BibleChapterReadingEstimate> estimates,
  ) {
    final chapters = <String, Map<int, BibleChapterReadingEstimate>>{};
    for (final estimate in estimates) {
      chapters
          .putIfAbsent(estimate.bookKey, () => {})
          [estimate.chapterNumber] = estimate;
    }
    return BibleChapterMetadata._(chapters);
  }

  BibleChapterReadingEstimate? getChapter(String bookKey, int chapterNumber) {
    return _chapters[bookKey]?[chapterNumber];
  }

  int sumReadingMinutesForRange(
    String bookKey,
    int startChapter,
    int endChapter,
  ) {
    final start = min(startChapter, endChapter);
    final end = max(startChapter, endChapter);
    var total = 0;
    for (var chapter = start; chapter <= end; chapter += 1) {
      total += getChapter(bookKey, chapter)?.estimatedReadingMinutes ?? 0;
    }
    return total;
  }

  int sumReadingSecondsForRange(
    String bookKey,
    int startChapter,
    int endChapter,
  ) {
    final start = min(startChapter, endChapter);
    final end = max(startChapter, endChapter);
    var total = 0;
    for (var chapter = start; chapter <= end; chapter += 1) {
      total += getChapter(bookKey, chapter)?.estimatedReadingSeconds ?? 0;
    }
    return total;
  }

  int averageReadingMinutesForRange(
    String bookKey,
    int startChapter,
    int endChapter,
  ) {
    final start = min(startChapter, endChapter);
    final end = max(startChapter, endChapter);
    final chapterCount = end - start + 1;
    if (chapterCount <= 0) return 0;
    final totalMinutes = sumReadingMinutesForRange(bookKey, start, end);
    return (totalMinutes / chapterCount).round();
  }

  int sumReadingMinutesForPlanItems(
    Iterable<({String bookKey, int startChapter, int endChapter})> items,
  ) {
    var total = 0;
    for (final item in items) {
      total += sumReadingMinutesForRange(
        item.bookKey,
        item.startChapter,
        item.endChapter,
      );
    }
    return total;
  }

  int averageReadingMinutesForPlanItems(
    Iterable<({String bookKey, int startChapter, int endChapter})> items,
  ) {
    var totalMinutes = 0;
    var chapterCount = 0;
    for (final item in items) {
      final start = min(item.startChapter, item.endChapter);
      final end = max(item.startChapter, item.endChapter);
      chapterCount += end - start + 1;
      totalMinutes += sumReadingMinutesForRange(
        item.bookKey,
        start,
        end,
      );
    }
    if (chapterCount <= 0) return 0;
    return (totalMinutes / chapterCount).round();
  }
}
