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
  });

  final int chapterNumber;
  final bool isCompleted;
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

class OverviewStats {
  const OverviewStats({
    required this.completedChapters,
    required this.totalChapters,
    required this.currentStreak,
    required this.readingDays,
    required this.averageChaptersPerReadingDay,
  });

  final int completedChapters;
  final int totalChapters;
  final int currentStreak;
  final int readingDays;
  final double averageChaptersPerReadingDay;

  double get progress => totalChapters == 0 ? 0 : completedChapters / totalChapters;
}
