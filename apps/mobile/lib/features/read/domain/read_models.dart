import '../../../core/bible/reading_time_format.dart';

class BookProgress {
  const BookProgress({
    required this.sectionId,
    required this.bookKey,
    required this.testament,
    required this.bookOrder,
    required this.shortName,
    required this.displayName,
    required this.chapterCount,
    required this.completedCount,
    this.estimatedTotalMinutes = 0,
    this.remainingEstimatedMinutes = 0,
  });

  final String sectionId;
  final String bookKey;
  final String testament;
  final int bookOrder;
  final String shortName;
  final String displayName;
  final int chapterCount;
  final int completedCount;
  final int estimatedTotalMinutes;
  final int remainingEstimatedMinutes;

  double get progress => chapterCount == 0 ? 0 : completedCount / chapterCount;
}

class PlanSectionProgress {
  const PlanSectionProgress({
    required this.sectionId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.firstChapterBookKey,
    required this.firstChapterNumber,
    required this.books,
    required this.completedCount,
    required this.totalCount,
    this.estimatedTotalMinutes = 0,
    this.remainingEstimatedMinutes = 0,
  });

  final String sectionId;
  final String title;
  final String description;
  final int orderIndex;
  final String? firstChapterBookKey;
  final int? firstChapterNumber;
  final List<BookProgress> books;
  final int completedCount;
  final int totalCount;
  final int estimatedTotalMinutes;
  final int remainingEstimatedMinutes;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}

class ChapterProgressView {
  const ChapterProgressView({
    required this.chapterNumber,
    required this.isCompleted,
    required this.completedToday,
    this.estimatedReadingMinutes,
  });

  final int chapterNumber;
  final bool isCompleted;
  final bool completedToday;

  /// From `bible_chapters` (7 seconds per verse).
  final int? estimatedReadingMinutes;
}

class ReadingPlanView {
  const ReadingPlanView({
    required this.id,
    required this.title,
    required this.templateId,
    required this.status,
    required this.lastOpenedSectionId,
    required this.lastOpenedBookKey,
  });

  final String id;
  final String title;
  final String templateId;
  final String status;
  final String? lastOpenedSectionId;
  final String? lastOpenedBookKey;
}

class ReadingPlanSummary {
  const ReadingPlanSummary({
    required this.plan,
    required this.completedChapters,
    required this.totalChapters,
    required this.completedAt,
    required this.completionNumber,
  });

  final ReadingPlanView plan;
  final int completedChapters;
  final int totalChapters;
  final DateTime? completedAt;
  final int? completionNumber;

  double get progress =>
      totalChapters == 0 ? 0 : completedChapters / totalChapters;

  String get progressLabel => '${(progress * 100).round()}%';

  String get completionLabel {
    final count = completionNumber ?? 0;
    if (count <= 0) return '';
    if (count == 1) return 'Completed once';
    return 'Completed $count times';
  }
}

class CompletedPlanSummary {
  const CompletedPlanSummary({
    required this.templateId,
    required this.templateKey,
    required this.title,
    required this.completionCount,
    required this.lastCompletedAt,
    required this.totalChapters,
    this.estimatedMinutes,
  });

  final String templateId;
  final String templateKey;
  final String title;
  final int completionCount;
  final DateTime? lastCompletedAt;
  final int totalChapters;
  final int? estimatedMinutes;

  String get completionLabel {
    if (completionCount <= 1) return 'Completed once';
    return 'Completed $completionCount times';
  }

  /// Compact label for inline badges on plan cards.
  String get completionBadgeLabel {
    if (completionCount <= 0) return '';
    if (completionCount == 1) return 'Completed';
    return 'Completed · $completionCount';
  }

  /// Short label for optional catalog-style meta row (e.g. "56 mins").
  String? get estimatedReadingLabel {
    return formatCatalogPlanTotalDuration(
      minutesPerChapter: estimatedMinutes,
      totalChapters: totalChapters,
    );
  }
}

class ChapterToggleResult {
  const ChapterToggleResult({
    required this.changed,
    required this.completionReady,
    required this.completedChapters,
    required this.totalChapters,
  });

  const ChapterToggleResult.unchanged()
      : changed = false,
        completionReady = false,
        completedChapters = 0,
        totalChapters = 0;

  final bool changed;
  final bool completionReady;
  final int completedChapters;
  final int totalChapters;
}

/// On-device profile row (`local_users`) for Settings / auth UI.
class LocalUserProfile {
  const LocalUserProfile({
    required this.localUserId,
    this.authUserId,
    required this.accountType,
  });

  final String localUserId;
  final String? authUserId;
  final String accountType;

  bool get isAuthLinked => authUserId != null && authUserId!.isNotEmpty;
}

/// Built-in (or future catalog) plan definition for “add plan” flows.
class ReadingPlanTemplateView {
  const ReadingPlanTemplateView({
    required this.id,
    required this.templateKey,
    required this.title,
    required this.description,
    required this.shortDescription,
    required this.planType,
    required this.testamentScope,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.totalChapters,
    required this.coverImageUrl,
    required this.isInProgress,
    required this.completionCount,
  });

  final String id;
  final String templateKey;
  final String title;
  final String description;
  final String shortDescription;
  final String planType;
  final String testamentScope;
  final String? difficulty;
  final int? estimatedMinutes;
  final int totalChapters;
  final String? coverImageUrl;
  final bool isInProgress;
  final int completionCount;

  String get planTypeLabel => planType
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => part.toUpperCase())
      .join(' ');

  String get completionLabel {
    if (completionCount <= 0) return '';
    if (completionCount == 1) return 'Completed once';
    return 'Completed $completionCount times';
  }

  /// Compact label for inline badges on plan cards.
  String get completionBadgeLabel {
    if (completionCount <= 0) return '';
    if (completionCount == 1) return 'Completed';
    return 'Completed · $completionCount';
  }
}

/// Chapters and averages scoped to one user plan run (`user_plan_id`).
/// See `docs/DATA_MODEL.md`.
class PlanProgressStats {
  const PlanProgressStats({
    required this.completedChapters,
    required this.totalChapters,
    required this.readingDaysInPlan,
    required this.averageChaptersPerReadingDayInPlan,
    this.averageMinutesPerChapter = 0,
    this.totalEstimatedMinutes = 0,
    this.remainingEstimatedMinutes = 0,
  });

  final int completedChapters;
  final int totalChapters;
  final int readingDaysInPlan;
  final double averageChaptersPerReadingDayInPlan;

  /// Average estimated reading minutes per chapter in this plan (0 if unknown).
  final double averageMinutesPerChapter;

  /// Sum of `bible_chapters` estimates for all chapters in the plan.
  final int totalEstimatedMinutes;

  /// Sum for chapters not yet marked complete in this plan run.
  final int remainingEstimatedMinutes;

  double get progress =>
      totalChapters == 0 ? 0 : completedChapters / totalChapters;
}

/// Streak and reading-day counts across all plans (device / future `local_user_id`).
class AccountActivityStats {
  const AccountActivityStats({
    required this.currentStreak,
    required this.readingDaysTotal,
  });

  final int currentStreak;
  final int readingDaysTotal;
}

/// Today’s estimated reading time vs optional daily goal (local `app_settings`).
class DailyReadingStats {
  const DailyReadingStats({
    required this.goalMinutes,
    required this.todayMinutes,
    required this.chaptersToday,
  });

  final int goalMinutes;
  final int todayMinutes;
  final int chaptersToday;

  bool get hasGoal => goalMinutes > 0;

  bool get goalMet => hasGoal && todayMinutes >= goalMinutes;

  double get progress =>
      hasGoal ? (todayMinutes / goalMinutes).clamp(0.0, 1.0) : 0.0;

  /// English label for Home / Read summary (null when goal is off).
  String? get progressLabel {
    if (!hasGoal) return null;
    if (goalMet) {
      return '$todayMinutes / $goalMinutes min today · Goal met';
    }
    return '$todayMinutes / $goalMinutes min today';
  }
}

/// Per-day reading summary for habit / activity grids.
class ReadingDaySummary {
  const ReadingDaySummary({
    required this.activityDate,
    required this.chaptersCompleted,
    required this.estimatedMinutes,
    required this.goalMet,
  });

  final String activityDate;
  final int chaptersCompleted;
  final int estimatedMinutes;
  final bool goalMet;

  bool get hasReading => chaptersCompleted > 0;

  factory ReadingDaySummary.empty(String activityDate) {
    return ReadingDaySummary(
      activityDate: activityDate,
      chaptersCompleted: 0,
      estimatedMinutes: 0,
      goalMet: false,
    );
  }
}

/// One week column in a GitHub-style activity grid (Sunday → Saturday).
class ReadingActivityWeekColumn {
  const ReadingActivityWeekColumn({
    required this.weekStartDate,
    required this.days,
  });

  final DateTime weekStartDate;

  /// Seven slots (Sun–Sat). `null` when the day is outside the visible range.
  final List<ReadingDaySummary?> days;
}

/// Rolling ~12-month activity grid for horizontal scroll (oldest → newest).
class ReadingActivityYear {
  const ReadingActivityYear({
    required this.weekColumns,
    required this.rangeStart,
    required this.rangeEnd,
    required this.yearLabel,
  });

  final List<ReadingActivityWeekColumn> weekColumns;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int yearLabel;
}

/// Account-wide reading stats + activity grid (Settings habit section).
class AccountReadingStats {
  const AccountReadingStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.readingDaysTotal,
    required this.readingDaysInRange,
    required this.goalMetDaysInRange,
    required this.activityYear,
  });

  final int currentStreak;
  final int longestStreak;
  final int readingDaysTotal;
  final int readingDaysInRange;
  final int goalMetDaysInRange;
  final ReadingActivityYear activityYear;
}

/// Bundles plan-scoped and account-scoped stats for Home / Read summary UIs.
class ReadingOverview {
  const ReadingOverview({
    required this.plan,
    required this.account,
    required this.daily,
  });

  final PlanProgressStats plan;
  final AccountActivityStats account;
  final DailyReadingStats daily;
}
