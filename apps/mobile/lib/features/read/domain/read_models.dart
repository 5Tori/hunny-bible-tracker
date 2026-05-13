class BookProgress {
  const BookProgress({
    required this.bookKey,
    required this.testament,
    required this.bookOrder,
    required this.shortName,
    required this.displayName,
    required this.chapterCount,
    required this.completedCount,
  });

  final String bookKey;
  final String testament;
  final int bookOrder;
  final String shortName;
  final String displayName;
  final int chapterCount;
  final int completedCount;

  double get progress => chapterCount == 0 ? 0 : completedCount / chapterCount;
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
    required this.templateKey,
    required this.lastOpenedBookKey,
  });

  final String id;
  final String title;
  final String templateKey;
  final String? lastOpenedBookKey;
}

/// On-device profile row (`local_users`) for Settings / auth UI.
class LocalUserProfile {
  const LocalUserProfile({
    required this.localUserId,
    this.neonUserId,
    required this.accountType,
  });

  final String localUserId;
  final String? neonUserId;
  final String accountType;

  bool get isNeonLinked =>
      neonUserId != null && neonUserId!.isNotEmpty;
}

/// Built-in (or future catalog) plan definition for “add plan” flows.
class ReadingPlanTemplateView {
  const ReadingPlanTemplateView({
    required this.templateKey,
    required this.title,
    required this.description,
  });

  final String templateKey;
  final String title;
  final String description;
}

/// Chapters and averages scoped to one plan (`plan_id`).
/// See `docs/PROGRESS_AND_ACTIVITY_PLAN.md` §7.
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
