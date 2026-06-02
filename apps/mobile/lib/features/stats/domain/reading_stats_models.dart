/// Habit / lifetime reading stats derived from [reading_activities].
library;

/// Flat summary for tracker UIs (Home, Settings, Dev).
class ReadingTrackerStats {
  const ReadingTrackerStats({
    required this.chaptersToday,
    required this.estimatedMinutesToday,
    required this.chaptersThisWeek,
    required this.estimatedMinutesThisWeek,
    required this.readingDaysThisWeek,
    required this.readingDaysThisMonth,
    required this.lifetimeChapters,
    required this.lifetimeEstimatedMinutes,
    required this.lifetimeReadingDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.activePlanCount,
    required this.completedPlanCount,
    required this.averagePlanCompletionDays,
  });

  final int chaptersToday;
  final int estimatedMinutesToday;

  final int chaptersThisWeek;
  final int estimatedMinutesThisWeek;
  final int readingDaysThisWeek;

  final int readingDaysThisMonth;

  final int lifetimeChapters;
  final int lifetimeEstimatedMinutes;
  final int lifetimeReadingDays;

  final int currentStreak;
  final int longestStreak;

  final int activePlanCount;
  final int completedPlanCount;
  final double? averagePlanCompletionDays;
}

/// Activity aggregates for a calendar date range (week or month).
class ReadingDayRangeStats {
  const ReadingDayRangeStats({
    required this.rangeStart,
    required this.rangeEnd,
    required this.readingDays,
    required this.chapters,
    required this.estimatedMinutes,
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int readingDays;
  final int chapters;
  final int estimatedMinutes;
}

/// Plan run counts and average completion duration.
class PlanLifecycleStats {
  const PlanLifecycleStats({
    required this.activePlanCount,
    required this.completedPlanCount,
    required this.averagePlanCompletionDays,
  });

  final int activePlanCount;
  final int completedPlanCount;
  final double? averagePlanCompletionDays;
}
