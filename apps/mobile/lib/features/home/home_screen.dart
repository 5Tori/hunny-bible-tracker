import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import '../stats/data/reading_stats_repository.dart';
import '../stats/domain/reading_stats_models.dart';
import 'widgets/home_plan_progress_ring.dart';
import 'widgets/home_reading_footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.readRepository,
    required this.readingStatsRepository,
    required this.onReadTap,
  });

  final ReadRepository readRepository;
  final ReadingStatsRepository readingStatsRepository;
  final void Function({bool scrollToLastRead}) onReadTap;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  ReadingOverview? _readingOverview;
  ReadingPlanView? _plan;
  ReadingPlanTemplateView? _planTemplate;
  LastReadPosition? _lastRead;
  ReadingDayRangeStats? _recentStats;
  var _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    final plan = await widget.readRepository.getCurrentPlan();
    ReadingOverview? overview;
    ReadingPlanTemplateView? template;
    LastReadPosition? lastRead;
    if (plan != null) {
      overview = await widget.readRepository.getReadingOverview(plan.id);
      template =
          await widget.readRepository.getPlanTemplateByIdentifier(plan.templateId);
      lastRead = await widget.readRepository.getLastReadPosition(plan.id);
    }
    ReadingDayRangeStats? recentStats;
    try {
      recentStats =
          await widget.readingStatsRepository.getRecentReadingStats(dayCount: 7);
    } catch (_) {
      recentStats = null;
    }
    if (!mounted || generation != _loadGeneration) return;
    setState(() {
      _plan = plan;
      _readingOverview = overview;
      _planTemplate = template;
      _lastRead = lastRead;
      _recentStats = recentStats;
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    final overview = _readingOverview;
    final planStats = overview?.plan;
    final progress = planStats?.progress ?? 0.0;
    final title = plan?.title ?? _planTemplate?.title ?? 'No current plan';
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE · MMM d').format(now).toUpperCase();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              letterSpacing: 0.5,
                              color: AppTheme.mutedInk,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _greeting(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Current plan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: plan == null
                        ? null
                        : () => widget.onReadTap(scrollToLastRead: true),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          HomePlanProgressRing(
                            progress: progress,
                            imageUrl: _planTemplate?.coverImageUrl,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                          if (planStats != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${planStats.completedChapters} chapters read',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.mutedInk,
                                        fontWeight: FontWeight.w600,
                                        fontSize: (Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.fontSize ??
                                                12) +
                                            2,
                                      ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Text(
                            'Continue reading',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: plan == null
                                          ? AppTheme.mutedInk.withValues(alpha: 0.5)
                                          : AppTheme.mutedInk,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: plan == null
                                          ? AppTheme.mutedInk.withValues(alpha: 0.35)
                                          : AppTheme.mutedInk.withValues(alpha: 0.65),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_recentStats != null) ...[
              const SizedBox(height: 16),
              HomeReadingFooter(
                recentStats: _recentStats!,
                lastRead: _lastRead,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
