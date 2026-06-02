import 'package:flutter/material.dart';

import '../../../core/bible/reading_time_format.dart';
import '../../../core/theme/app_theme.dart';
import '../../stats/domain/reading_stats_models.dart';

/// Lifetime and plan lifecycle stats for Settings.
class ReadingStatsSummaryPanel extends StatelessWidget {
  const ReadingStatsSummaryPanel({
    super.key,
    required this.stats,
  });

  final ReadingTrackerStats stats;

  @override
  Widget build(BuildContext context) {
    final avgCompletion = stats.averagePlanCompletionDays;
    final avgLabel = avgCompletion == null
        ? '—'
        : '${avgCompletion.toStringAsFixed(1)} days';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reading stats',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Total chapters read',
            value: '${stats.lifetimeChapters}',
          ),
          _StatRow(
            label: 'Total estimated reading time',
            value: formatReadingDuration(stats.lifetimeEstimatedMinutes),
          ),
          _StatRow(
            label: 'Reading days total',
            value: '${stats.lifetimeReadingDays}',
          ),
          _StatRow(
            label: 'Current streak',
            value: '${stats.currentStreak} days',
          ),
          _StatRow(
            label: 'Longest streak',
            value: '${stats.longestStreak} days',
          ),
          _StatRow(
            label: 'This month',
            value: '${stats.readingDaysThisMonth} reading days',
          ),
          _StatRow(
            label: 'Completed plans',
            value: '${stats.completedPlanCount}',
          ),
          _StatRow(
            label: 'Active plans',
            value: '${stats.activePlanCount}',
          ),
          _StatRow(
            label: 'Avg plan completion',
            value: avgLabel,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
