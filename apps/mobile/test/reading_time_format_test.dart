import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/core/bible/reading_time_format.dart';

void main() {
  group('reading_time_format', () {
    test('formatReadingDuration', () {
      expect(formatReadingDuration(0), '0 min');
      expect(formatReadingDuration(1), '1 min');
      expect(formatReadingDuration(24), '24 mins');
      expect(formatReadingDuration(56), '56 mins');
      expect(formatReadingDuration(60), '1 hr');
      expect(formatReadingDuration(100), '1 hr 40 mins');
      expect(formatReadingDuration(4205), '70 hrs 5 mins');
    });

    test('formatCatalogReadingDuration', () {
      expect(formatCatalogReadingDuration(0), '0 hrs');
      expect(formatCatalogReadingDuration(15), '0.5 hrs');
      expect(formatCatalogReadingDuration(56), '1 hr');
      expect(formatCatalogReadingDuration(3600), '60 hrs');
      expect(formatCatalogReadingDuration(3716), '62 hrs');
    });

    test('formatReadingDurationRemaining', () {
      expect(formatReadingDurationRemaining(18), '18 mins left');
      expect(formatReadingDurationRemaining(1), '1 min left');
    });

    test('formatCatalogPlanTotalDuration', () {
      expect(
        formatCatalogPlanTotalDuration(
          minutesPerChapter: 4,
          totalChapters: 14,
        ),
        '1 hr',
      );
      expect(
        formatCatalogPlanTotalDuration(
          minutesPerChapter: 2,
          totalChapters: 12,
        ),
        '0.5 hrs',
      );
      expect(
        formatCatalogPlanTotalDuration(
          minutesPerChapter: 4,
          totalChapters: 929,
        ),
        '62 hrs',
      );
    });

    test('formatPlanProgressDuration', () {
      expect(
        formatPlanProgressDuration(
          totalMinutes: 4205,
          remainingMinutes: 4205,
        ),
        '70 hrs 5 mins',
      );
      expect(
        formatPlanProgressDuration(
          totalMinutes: 100,
          remainingMinutes: 40,
        ),
        '40 mins left · 1 hr 40 mins',
      );
    });

    test('formatHomeWeeklyChapterCount', () {
      expect(formatHomeWeeklyChapterCount(1), '1 Ch.');
      expect(formatHomeWeeklyChapterCount(129), '129 Ch.');
    });
  });
}
