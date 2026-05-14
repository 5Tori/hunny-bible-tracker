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
  });

  final String sectionId;
  final String bookKey;
  final String testament;
  final int bookOrder;
  final String shortName;
  final String displayName;
  final int chapterCount;
  final int completedCount;

  double get progress => chapterCount == 0 ? 0 : completedCount / chapterCount;
}

class PlanSectionProgress {
  const PlanSectionProgress({
    required this.sectionId,
    required this.title,
    required this.orderIndex,
    required this.books,
    required this.completedCount,
    required this.totalCount,
  });

  final String sectionId;
  final String title;
  final int orderIndex;
  final List<BookProgress> books;
  final int completedCount;
  final int totalCount;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}

class ChapterProgressView {
  const ChapterProgressView({
    required this.chapterNumber,
    required this.isCompleted,
    required this.completedToday,
  });

  final int chapterNumber;
  final bool isCompleted;
  final bool completedToday;
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
    required this.templateKey,
    required this.title,
    required this.description,
    required this.shortDescription,
    required this.planType,
    required this.estimatedMinutes,
    required this.totalChapters,
    required this.coverImageUrl,
    required this.isInProgress,
    required this.completionCount,
  });

  final String templateKey;
  final String title;
  final String description;
  final String shortDescription;
  final String planType;
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
}

/// Chapters and averages scoped to one user plan run (`user_plan_id`).
/// See `docs/DATA_MODEL.md`.
class PlanProgressStats {
  const PlanProgressStats({
    required this.completedChapters,
    required this.totalChapters,
    required this.readingDaysInPlan,
    required this.averageChaptersPerReadingDayInPlan,
  });

  final int completedChapters;
  final int totalChapters;
  final int readingDaysInPlan;
  final double averageChaptersPerReadingDayInPlan;

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

/// Bundles plan-scoped and account-scoped stats for Home / Read summary UIs.
class ReadingOverview {
  const ReadingOverview({
    required this.plan,
    required this.account,
  });

  final PlanProgressStats plan;
  final AccountActivityStats account;
}
