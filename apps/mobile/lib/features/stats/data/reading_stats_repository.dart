import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../../core/bible/bible_chapter_metadata.dart';
import '../../../core/database/app_database.dart';
import '../../read/data/read_repository.dart';
import '../../read/domain/read_models.dart';
import '../domain/reading_stats_models.dart';

/// Read-side aggregations from [reading_activities], streaks, and plan lifecycle.
///
/// Progress UI should use [ReadRepository] / [chapter_progress_entries] instead.
class ReadingStatsRepository {
  ReadingStatsRepository(this.db);

  final AppDatabase db;

  BibleChapterMetadata? _chapterMetadata;

  Future<BibleChapterMetadata> _getChapterMetadata() async {
    _chapterMetadata ??= await BibleChapterMetadata.loadFromDatabase(db);
    return _chapterMetadata!;
  }

  Future<ReadingTrackerStats> getReadingTrackerStats({DateTime? anchorDate}) async {
    final anchor = _dateOnly(anchorDate ?? DateTime.now());
    final summaries = await _loadReadingDaySummariesByDate();
    final readingDates = summaries.keys.toSet();

    final todayKey = DateFormat('yyyy-MM-dd').format(anchor);
    final todaySummary = summaries[todayKey];

    final weekStart = _startOfWeekSunday(anchor);
    final weekEnd = weekStart.add(const Duration(days: 6));
    final monthStart = _startOfMonth(anchor);
    final monthEnd = _endOfMonth(anchor);

    final weeklyTotals = _sumDaySummaries(
      summaries,
      fromInclusive: weekStart,
      toInclusive: weekEnd,
    );
    final lifetimeTotals = _sumDaySummaries(summaries);
    final lifecycle = await getPlanLifecycleStats();

    return ReadingTrackerStats(
      chaptersToday: todaySummary?.chaptersCompleted ?? 0,
      estimatedMinutesToday: todaySummary?.estimatedMinutes ?? 0,
      chaptersThisWeek: weeklyTotals.chapters,
      estimatedMinutesThisWeek: weeklyTotals.minutes,
      readingDaysThisWeek: _countReadingDays(
        summaries,
        fromInclusive: weekStart,
        toInclusive: weekEnd,
      ),
      readingDaysThisMonth: _countReadingDays(
        summaries,
        fromInclusive: monthStart,
        toInclusive: monthEnd,
      ),
      lifetimeChapters: lifetimeTotals.chapters,
      lifetimeEstimatedMinutes: lifetimeTotals.minutes,
      lifetimeReadingDays: readingDates.length,
      currentStreak: _calculateCurrentStreak(readingDates, anchor: anchor),
      longestStreak: _calculateLongestStreak(readingDates),
      activePlanCount: lifecycle.activePlanCount,
      completedPlanCount: lifecycle.completedPlanCount,
      averagePlanCompletionDays: lifecycle.averagePlanCompletionDays,
    );
  }

  Future<ReadingDayRangeStats> getWeeklyReadingDayStats({DateTime? anchorDate}) async {
    final anchor = _dateOnly(anchorDate ?? DateTime.now());
    final rangeStart = _startOfWeekSunday(anchor);
    final rangeEnd = rangeStart.add(const Duration(days: 6));
    return _rangeStats(
      summaries: await _loadReadingDaySummariesByDate(),
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }

  Future<ReadingDayRangeStats> getMonthlyReadingDayStats({DateTime? anchorDate}) async {
    final anchor = _dateOnly(anchorDate ?? DateTime.now());
    return _rangeStats(
      summaries: await _loadReadingDaySummariesByDate(),
      rangeStart: _startOfMonth(anchor),
      rangeEnd: _endOfMonth(anchor),
    );
  }

  /// Rolling window ending on [anchorDate] (default today), inclusive.
  Future<ReadingDayRangeStats> getRecentReadingStats({
    DateTime? anchorDate,
    int dayCount = 7,
  }) async {
    assert(dayCount > 0);
    final anchor = _dateOnly(anchorDate ?? DateTime.now());
    final rangeStart = anchor.subtract(Duration(days: dayCount - 1));
    return _rangeStats(
      summaries: await _loadReadingDaySummariesByDate(),
      rangeStart: rangeStart,
      rangeEnd: anchor,
    );
  }

  Future<PlanLifecycleStats> getPlanLifecycleStats() async {
    final localUserId = await _activeLocalUserId();

    final activePlans = await (db.select(db.userReadingPlans)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.archivedAt.isNull() &
                tbl.status.isIn(['active', 'completion_ready']),
          ))
        .get();

    final events = await (db.select(db.planCompletionEvents)
          ..where((tbl) => tbl.localUserId.equals(localUserId)))
        .get();

    if (events.isEmpty) {
      return PlanLifecycleStats(
        activePlanCount: activePlans.length,
        completedPlanCount: 0,
        averagePlanCompletionDays: null,
      );
    }

    final planIds = events.map((event) => event.userPlanId).toSet().toList();
    final plans = await (db.select(db.userReadingPlans)
          ..where((tbl) => tbl.id.isIn(planIds)))
        .get();
    final plansById = {for (final plan in plans) plan.id: plan};

    var totalDays = 0.0;
    var counted = 0;
    for (final event in events) {
      final plan = plansById[event.userPlanId];
      final startedAt = plan?.startedAt;
      if (startedAt == null) continue;
      totalDays += event.completedAt.difference(startedAt).inDays;
      counted += 1;
    }

    return PlanLifecycleStats(
      activePlanCount: activePlans.length,
      completedPlanCount: events.length,
      averagePlanCompletionDays: counted == 0 ? null : totalDays / counted,
    );
  }

  /// Streak, longest streak, and rolling-year activity grid for Settings.
  Future<AccountReadingStats> getAccountReadingStats({DateTime? anchorDate}) async {
    final anchor = _dateOnly(anchorDate ?? DateTime.now());
    final summaries = await _loadReadingDaySummariesByDate();
    final readingDates = summaries.keys.toSet();
    final currentStreak = _calculateCurrentStreak(readingDates, anchor: anchor);
    final longestStreak = _calculateLongestStreak(readingDates);
    final activityYear = _buildReadingActivityYear(
      dayMap: summaries,
      anchorDate: anchor,
    );

    var readingDaysInRange = 0;
    var goalMetDaysInRange = 0;
    for (final summary in summaries.values) {
      final day = _parseActivityDate(summary.activityDate);
      if (day.isBefore(activityYear.rangeStart) || day.isAfter(anchor)) {
        continue;
      }
      readingDaysInRange += 1;
      if (summary.goalMet) goalMetDaysInRange += 1;
    }

    return AccountReadingStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      readingDaysTotal: readingDates.length,
      readingDaysInRange: readingDaysInRange,
      goalMetDaysInRange: goalMetDaysInRange,
      activityYear: activityYear,
    );
  }

  ReadingDayRangeStats _rangeStats({
    required Map<String, ReadingDaySummary> summaries,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final totals = _sumDaySummaries(
      summaries,
      fromInclusive: rangeStart,
      toInclusive: rangeEnd,
    );
    return ReadingDayRangeStats(
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      readingDays: _countReadingDays(
        summaries,
        fromInclusive: rangeStart,
        toInclusive: rangeEnd,
      ),
      chapters: totals.chapters,
      estimatedMinutes: totals.minutes,
    );
  }

  Future<Map<String, ReadingDaySummary>> _loadReadingDaySummariesByDate() async {
    final localUserId = await _activeLocalUserId();
    final goalMinutes = await _dailyReadingGoalMinutes();
    final activities = await (db.select(db.readingActivities)
          ..where(
            (tbl) =>
                tbl.localUserId.equals(localUserId) &
                tbl.action.equals('complete'),
          ))
        .get();
    if (activities.isEmpty) return {};

    final metadata = await _getChapterMetadata();
    final grouped = <String, _DayActivityAggregate>{};
    for (final activity in activities) {
      final aggregate = grouped.putIfAbsent(
        activity.activityDate,
        () => _DayActivityAggregate(),
      );
      aggregate.chapters += 1;
      aggregate.minutes +=
          metadata
              .getChapter(activity.bookKey, activity.chapterNumber)
              ?.estimatedReadingMinutes ??
          0;
    }

    return {
      for (final entry in grouped.entries)
        entry.key: ReadingDaySummary(
          activityDate: entry.key,
          chaptersCompleted: entry.value.chapters,
          estimatedMinutes: entry.value.minutes,
          goalMet: goalMinutes > 0 && entry.value.minutes >= goalMinutes,
        ),
    };
  }

  Future<int> _dailyReadingGoalMinutes() async {
    final row = await (db.select(db.appSettings)
          ..where(
            (tbl) =>
                tbl.key.equals(ReadRepository.kAppSettingDailyReadingGoalMinutes),
          )
          ..limit(1))
        .getSingleOrNull();
    if (row == null || row.value.trim().isEmpty) return 0;
    final parsed = int.tryParse(row.value.trim());
    if (parsed == null || parsed <= 0) return 0;
    return parsed;
  }

  ({int chapters, int minutes}) _sumDaySummaries(
    Map<String, ReadingDaySummary> summaries, {
    DateTime? fromInclusive,
    DateTime? toInclusive,
  }) {
    var chapters = 0;
    var minutes = 0;
    for (final summary in summaries.values) {
      final day = _parseActivityDate(summary.activityDate);
      if (fromInclusive != null && day.isBefore(fromInclusive)) continue;
      if (toInclusive != null && day.isAfter(toInclusive)) continue;
      chapters += summary.chaptersCompleted;
      minutes += summary.estimatedMinutes;
    }
    return (chapters: chapters, minutes: minutes);
  }

  int _countReadingDays(
    Map<String, ReadingDaySummary> summaries, {
    required DateTime fromInclusive,
    required DateTime toInclusive,
  }) {
    var count = 0;
    for (final summary in summaries.values) {
      if (!summary.hasReading) continue;
      final day = _parseActivityDate(summary.activityDate);
      if (day.isBefore(fromInclusive) || day.isAfter(toInclusive)) continue;
      count += 1;
    }
    return count;
  }

  ReadingActivityYear _buildReadingActivityYear({
    required Map<String, ReadingDaySummary> dayMap,
    required DateTime anchorDate,
  }) {
    final end = _dateOnly(anchorDate);
    final rangeStart = end.subtract(const Duration(days: 364));
    final gridStart = _startOfWeekSunday(rangeStart);
    final columns = <ReadingActivityWeekColumn>[];

    var weekStart = gridStart;
    while (!weekStart.isAfter(end)) {
      final days = <ReadingDaySummary?>[];
      for (var offset = 0; offset < 7; offset++) {
        final day = weekStart.add(Duration(days: offset));
        if (day.isAfter(end) || day.isBefore(rangeStart)) {
          days.add(null);
        } else {
          final key = DateFormat('yyyy-MM-dd').format(day);
          days.add(dayMap[key] ?? ReadingDaySummary.empty(key));
        }
      }
      columns.add(
        ReadingActivityWeekColumn(weekStartDate: weekStart, days: days),
      );
      weekStart = weekStart.add(const Duration(days: 7));
    }

    return ReadingActivityYear(
      weekColumns: columns,
      rangeStart: rangeStart,
      rangeEnd: end,
      yearLabel: end.year,
    );
  }

  Future<String> _activeLocalUserId() async {
    final row = await (db.select(db.localUsers)..limit(1)).getSingleOrNull();
    if (row == null) {
      throw StateError('local_users missing; call initializeLocalData first');
    }
    return row.id;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  DateTime _parseActivityDate(String activityDate) {
    final parsed = DateTime.tryParse(activityDate);
    if (parsed == null) return _dateOnly(DateTime.now());
    return _dateOnly(parsed);
  }

  DateTime _startOfWeekSunday(DateTime date) {
    final normalized = _dateOnly(date);
    return normalized.subtract(Duration(days: normalized.weekday % 7));
  }

  DateTime _startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  DateTime _endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  int _calculateCurrentStreak(
    Set<String> readingDates, {
    DateTime? anchor,
  }) {
    if (readingDates.isEmpty) return 0;

    var cursor = _dateOnly(anchor ?? DateTime.now());
    var streak = 0;

    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(cursor);
      if (!readingDates.contains(key)) break;
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateLongestStreak(Set<String> readingDates) {
    if (readingDates.isEmpty) return 0;

    final sorted = readingDates.map(_parseActivityDate).toList()
      ..sort((a, b) => a.compareTo(b));

    var longest = 1;
    var current = 1;
    for (var index = 1; index < sorted.length; index++) {
      final gap = sorted[index].difference(sorted[index - 1]).inDays;
      if (gap == 1) {
        current += 1;
        if (current > longest) longest = current;
      } else if (gap > 1) {
        current = 1;
      }
    }

    return longest;
  }
}

class _DayActivityAggregate {
  int chapters = 0;
  int minutes = 0;
}
