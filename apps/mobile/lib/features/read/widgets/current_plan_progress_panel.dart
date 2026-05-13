import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/read_models.dart';

/// Home Progress card and Read tab summary — same layout; optional “Continue reading”.
class CurrentPlanProgressPanel extends StatelessWidget {
  const CurrentPlanProgressPanel({
    super.key,
    required this.overview,
    required this.planTitle,
    this.showContinueReading = false,
    this.onContinueReading,
  });

  final ReadingOverview? overview;
  final String planTitle;
  final bool showContinueReading;
  final VoidCallback? onContinueReading;

  static const double _minutesPerChapter = 4.0;

  @override
  Widget build(BuildContext context) {
    final planStats = overview?.plan;
    final accountStats = overview?.account;
    final progress = planStats?.progress ?? 0.0;
    final chaptersPerDay =
        planStats?.averageChaptersPerReadingDayInPlan ?? 0.0;
    final minutesPerDay = chaptersPerDay * _minutesPerChapter;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  planTitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 14, color: AppTheme.ink),
                    const SizedBox(width: 4),
                    Text(
                      '${accountStats?.currentStreak ?? 0} day streak',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: AppTheme.softSurface,
              valueColor: const AlwaysStoppedAnimation(AppTheme.ink),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                value: '${planStats?.completedChapters ?? 0}',
                label: 'chapters',
              ),
              const SizedBox(width: 12),
              _StatChip(
                value: chaptersPerDay.toStringAsFixed(1),
                label: 'ch. / day',
              ),
              const SizedBox(width: 12),
              _StatChip(
                value: minutesPerDay.toStringAsFixed(1),
                label: 'min / day',
              ),
            ],
          ),
          if (showContinueReading && onContinueReading != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContinueReading,
                icon: const Icon(Icons.menu_book, size: 18),
                label: const Text('Continue reading'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.3,
                    height: 1.2,
                    color: AppTheme.mutedInk,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
