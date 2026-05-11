import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/read_models.dart';

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({super.key, required this.overview});

  final OverviewStats? overview;

  @override
  Widget build(BuildContext context) {
    final stats = overview;
    final progress = stats?.progress ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Current plan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                backgroundColor: AppTheme.softSurface,
                valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _MiniStat(
                  value: '${stats?.completedChapters ?? 0}/${stats?.totalChapters ?? 0}',
                  label: 'chapters',
                ),
                _MiniStat(
                  value: '${stats?.currentStreak ?? 0}',
                  label: 'streak',
                ),
                _MiniStat(
                  value: stats == null
                      ? '0.0'
                      : stats.averageChaptersPerReadingDay.toStringAsFixed(1),
                  label: 'avg/day',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
