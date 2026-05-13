import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import '../read/widgets/current_plan_progress_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.readRepository,
    required this.onReadTap,
  });

  final ReadRepository readRepository;
  final VoidCallback onReadTap;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  ReadingOverview? _readingOverview;
  ReadingPlanView? _plan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final plan = await widget.readRepository.getActivePlan();
    final overview = await widget.readRepository.getReadingOverview(plan.id);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _readingOverview = overview;
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
    final overview = _readingOverview;
    final now = DateTime.now();
    final dateLabel =
        DateFormat('EEEE · MMM d').format(now).toUpperCase();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.ink,
                  child: Text(
                    'B',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Verse of the Day
            _SectionLabel(title: 'VERSE OF THE DAY'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1507400492013-162706c8c05e?w=600&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Be still, and know that I am God."',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PSALM 46:10',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _IconLabel(icon: Icons.favorite_border, label: '1.2k'),
                const SizedBox(width: 16),
                _IconLabel(icon: Icons.bookmark_border, label: 'Save'),
                const Spacer(),
                const Icon(Icons.share_outlined, size: 18, color: AppTheme.mutedInk),
              ],
            ),
            const SizedBox(height: 32),

            // Progress
            Row(
              children: [
                _SectionLabel(title: 'PROGRESS'),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onReadTap,
                  child: Text(
                    'Read ›',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CurrentPlanProgressPanel(
              overview: overview,
              planTitle: _plan?.title ?? 'Bible in a Year',
              showContinueReading: true,
              onContinueReading: widget.onReadTap,
            ),
            const SizedBox(height: 32),

            // Featured Content
            Row(
              children: [
                _SectionLabel(title: 'FEATURED CONTENT'),
                const Spacer(),
                Text(
                  'All ›',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ink,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _FeaturedCard(
                    type: 'VIDEO',
                    title: 'Sermon on the Mount',
                    duration: '12 min',
                  ),
                  SizedBox(width: 12),
                  _FeaturedCard(
                    type: 'READ',
                    title: 'Finding peace in chaos',
                    duration: '5 min read',
                  ),
                  SizedBox(width: 12),
                  _FeaturedCard(
                    type: 'AUDIO',
                    title: 'Morning devotional',
                    duration: '8 min',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
            color: AppTheme.mutedInk,
          ),
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.mutedInk),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.type,
    required this.title,
    required this.duration,
  });
  final String type;
  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.ink,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          const Spacer(),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.accentYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_arrow, size: 18, color: AppTheme.ink),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.ink),
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
        ],
      ),
    );
  }
}
