/// Human-readable reading time labels for plan summaries and catalog cards.
library;

String _hourUnit(int hours) => hours == 1 ? 'hr' : 'hrs';

String _minuteUnit(int minutes) => minutes == 1 ? 'min' : 'mins';

/// Total duration as `N hr M min` (omits zero parts, e.g. `24 min`, `70 hrs`).
String formatReadingDuration(int totalMinutes) {
  if (totalMinutes <= 0) return '0 min';

  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;

  if (hours == 0) {
    return '$minutes ${_minuteUnit(minutes)}';
  }
  if (minutes == 0) {
    return '$hours ${_hourUnit(hours)}';
  }
  return '$hours ${_hourUnit(hours)} $minutes ${_minuteUnit(minutes)}';
}

String formatReadingDurationRemaining(int totalMinutes) {
  return '${formatReadingDuration(totalMinutes)} left';
}

/// Catalog / content cards: `estimated_minutes` is average per chapter.
int? estimateCatalogPlanTotalMinutes({
  required int? minutesPerChapter,
  required int? totalChapters,
}) {
  if (minutesPerChapter == null || minutesPerChapter <= 0) return null;
  if (totalChapters == null || totalChapters <= 0) return null;
  return minutesPerChapter * totalChapters;
}

String? formatCatalogPlanTotalDuration({
  required int? minutesPerChapter,
  required int? totalChapters,
}) {
  final total = estimateCatalogPlanTotalMinutes(
    minutesPerChapter: minutesPerChapter,
    totalChapters: totalChapters,
  );
  if (total == null || total <= 0) return null;
  return formatReadingDuration(total);
}

/// Plan progress panel: remaining + total from bible_chapters sums.
String? formatPlanProgressDuration({
  required int totalMinutes,
  required int remainingMinutes,
}) {
  if (totalMinutes <= 0) return null;
  if (remainingMinutes > 0 && remainingMinutes < totalMinutes) {
    return '${formatReadingDurationRemaining(remainingMinutes)} · '
        '${formatReadingDuration(totalMinutes)}';
  }
  return formatReadingDuration(totalMinutes);
}
