import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../read/domain/read_models.dart';

/// Settings-only habit summary: streak stats + GitHub-style year grid.
class ReadingActivityPanel extends StatefulWidget {
  const ReadingActivityPanel({
    super.key,
    required this.stats,
  });

  final AccountReadingStats stats;

  @override
  State<ReadingActivityPanel> createState() => _ReadingActivityPanelState();
}

class _ReadingActivityPanelState extends State<ReadingActivityPanel> {
  final ScrollController _scrollController = ScrollController();

  static const double _cellSize = 11;
  static const double _cellGap = 3;
  static const double _columnWidth = _cellSize + _cellGap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
  }

  @override
  void didUpdateWidget(covariant ReadingActivityPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stats.activityYear.weekColumns.length !=
        widget.stats.activityYear.weekColumns.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToLatest());
    }
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;
    final year = stats.activityYear;
    final monthLabels = _monthLabelsForColumns(year.weekColumns);
    final gridWidth = year.weekColumns.length * _columnWidth;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      '${stats.currentStreak} day streak',
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
          const SizedBox(height: 10),
          Text(
            'Best ${stats.longestStreak} · ${stats.readingDaysTotal} reading days total',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
          if (stats.readingDaysInRange > 0) ...[
            const SizedBox(height: 4),
            Text(
              _rangeSummary(stats),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '${year.yearLabel} reading activity',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 18),
                    for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                      SizedBox(
                        height: _cellSize + _cellGap,
                        width: 14,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            label,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontSize: 9,
                                      color: AppTheme.mutedInk,
                                      height: 1,
                                    ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: gridWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 14,
                            child: Row(
                              children: [
                                for (var index = 0;
                                    index < monthLabels.length;
                                    index++)
                                  SizedBox(
                                    width: _columnWidth,
                                    child: Text(
                                      monthLabels[index] ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: 9,
                                            color: AppTheme.mutedInk,
                                            height: 1,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final column in year.weekColumns)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: _cellGap),
                                  child: Column(
                                    children: [
                                      for (final day in column.days)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: _cellGap,
                                          ),
                                          child: _ActivityCell(day: day),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: const [
              _LegendSwatch(
                color: AppTheme.softSurface,
                borderColor: AppTheme.border,
                label: 'No reading',
              ),
              _LegendSwatch(
                color: Color(0xFFFFE566),
                label: 'Read',
              ),
              _LegendSwatch(
                color: AppTheme.accentYellowDark,
                label: 'Goal met',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _rangeSummary(AccountReadingStats stats) {
    final base =
        '${stats.readingDaysInRange} reading days in the last 12 months';
    if (stats.goalMetDaysInRange <= 0) return base;
    return '$base · ${stats.goalMetDaysInRange} goal met';
  }

  List<String?> _monthLabelsForColumns(List<ReadingActivityWeekColumn> columns) {
    final labels = List<String?>.filled(columns.length, null);
    String? lastMonth;

    for (var index = 0; index < columns.length; index++) {
      final weekStart = columns[index].weekStartDate;
      final monthKey = DateFormat('yyyy-MM').format(weekStart);
      if (monthKey == lastMonth) continue;

      labels[index] = DateFormat('MMM').format(weekStart);
      lastMonth = monthKey;
    }

    return labels;
  }
}

class _ActivityCell extends StatelessWidget {
  const _ActivityCell({required this.day});

  final ReadingDaySummary? day;

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const SizedBox(width: _ReadingActivityPanelState._cellSize,
          height: _ReadingActivityPanelState._cellSize);
    }

    final summary = day!;
    Color fill;
    Color? borderColor;

    if (!summary.hasReading) {
      fill = AppTheme.softSurface;
      borderColor = AppTheme.border;
    } else if (summary.goalMet) {
      fill = AppTheme.accentYellowDark;
    } else {
      fill = const Color(0xFFFFE566);
    }

    return Container(
      width: _ReadingActivityPanelState._cellSize,
      height: _ReadingActivityPanelState._cellSize,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(2),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor, width: 0.5),
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({
    required this.color,
    required this.label,
    this.borderColor,
  });

  final Color color;
  final Color? borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!, width: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.mutedInk,
              ),
        ),
      ],
    );
  }
}
