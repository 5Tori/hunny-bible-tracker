import 'package:flutter/material.dart';

import '../../../core/bible/reading_time_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../read/domain/read_models.dart';
import '../../stats/domain/reading_stats_models.dart';

/// Bottom row: last 7 days activity + last read position.
class HomeReadingFooter extends StatelessWidget {
  const HomeReadingFooter({
    super.key,
    required this.recentStats,
    this.lastRead,
  });

  final ReadingDayRangeStats recentStats;
  final LastReadPosition? lastRead;

  @override
  Widget build(BuildContext context) {
    final chapterLabel = formatHomeWeeklyChapterCount(recentStats.chapters);
    final minutesLabel = formatReadingDuration(recentStats.estimatedMinutes);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 7 days',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      chapterLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      minutesLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedInk,
                            height: 1.2,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Last read',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  lastRead?.label ?? '—',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
