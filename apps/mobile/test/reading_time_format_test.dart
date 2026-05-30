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
        '56 mins',
      );
      expect(
        formatCatalogPlanTotalDuration(
          minutesPerChapter: 2,
          totalChapters: 12,
        ),
        '24 mins',
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
  });
}
