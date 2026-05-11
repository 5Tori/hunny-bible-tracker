import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.readRepository,
    required this.onReadTap,
  });

  final ReadRepository readRepository;
  final VoidCallback onReadTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OverviewStats? _stats;
  ReadingPlanView? _plan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await widget.readRepository.getActivePlan();
    final stats = await widget.readRepository.getOverviewStats(plan.id);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final progress = stats == null ? 0.0 : stats.progress;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'Hunny Bible Tracker',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _PlaceholderCard(
              title: 'Today\'s message',
              body:
                  'A daily verse and image will appear here after online content is connected.',
              icon: Icons.wb_sunny_outlined,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      _plan?.title ?? 'Whole Bible',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                        backgroundColor: AppTheme.softSurface,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            value:
                                '${stats?.completedChapters ?? 0}/${stats?.totalChapters ?? 0}',
                            label: 'chapters',
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            value: '${stats?.currentStreak ?? 0}',
                            label: 'day streak',
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            value: stats == null
                                ? '0.0'
                                : stats.averageChaptersPerReadingDay.toStringAsFixed(1),
                            label: 'avg/day',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.onReadTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Continue reading'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _PlaceholderCard(
              title: 'Curated contents',
              body:
                  'Popular videos, images, and guided content will be added in a later phase.',
              icon: Icons.play_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.softSurface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.ink),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
