import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import 'data/today_message_api_client.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import '../read/widgets/current_plan_progress_panel.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    required this.readRepository,
    required this.onReadTap,
    TodayMessageApiClient? todayMessageApiClient,
  }) : todayMessageApiClient = todayMessageApiClient ?? TodayMessageApiClient();

  final ReadRepository readRepository;
  final VoidCallback onReadTap;
  final TodayMessageApiClient todayMessageApiClient;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  ReadingOverview? _readingOverview;
  ReadingPlanView? _plan;
  TodayMessage? _todayMessage;
  var _todayMessageLoading = false;
  var _todayMessageHearted = false;
  var _todayMessageActionPending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    if (mounted) setState(() => _todayMessageLoading = true);
    final plan = await widget.readRepository.getCurrentPlan();
    final overview = plan == null
        ? null
        : await widget.readRepository.getReadingOverview(plan.id);
    final todayMessage = await _fetchTodayMessage();
    final todayMessageHearted = todayMessage == null
        ? false
        : await _isTodayMessageHearted(todayMessage.id);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _readingOverview = overview;
      _todayMessage = todayMessage;
      _todayMessageHearted = todayMessageHearted;
      _todayMessageLoading = false;
    });
  }

  Future<TodayMessage?> _fetchTodayMessage() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return await widget.todayMessageApiClient.fetchTodayMessage(
        date: today,
        language: 'en',
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isTodayMessageHearted(String id) async {
    final value =
        await widget.readRepository.getAppSetting(_heartedSettingKey(id));
    return value == '1';
  }

  Future<void> _heartTodayMessage() async {
    final message = _todayMessage;
    if (message == null || _todayMessageHearted || _todayMessageActionPending) {
      return;
    }

    setState(() {
      _todayMessageHearted = true;
      _todayMessageActionPending = true;
      _todayMessage = message.copyWith(heartCount: message.heartCount + 1);
    });

    try {
      final engagement =
          await widget.todayMessageApiClient.heartTodayMessage(message.id);
      await widget.readRepository.setAppSetting(
        _heartedSettingKey(message.id),
        '1',
      );
      if (!mounted) return;
      setState(() {
        _todayMessage = _todayMessage?.copyWith(
          heartCount: engagement.heartCount,
          shareCount: engagement.shareCount,
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _todayMessageHearted = false;
        _todayMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this heart.')),
      );
    } finally {
      if (mounted) setState(() => _todayMessageActionPending = false);
    }
  }

  Future<void> _shareTodayMessage() async {
    final message = _todayMessage;
    if (message == null || _todayMessageActionPending) return;

    setState(() => _todayMessageActionPending = true);
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          title: message.shareTitle,
          subject: message.shareTitle,
          text: message.shareText,
        ),
      );
      if (result.status == ShareResultStatus.dismissed) return;

      setState(() {
        _todayMessage = message.copyWith(shareCount: message.shareCount + 1);
      });
      final engagement =
          await widget.todayMessageApiClient.shareTodayMessage(message.id);
      if (!mounted) return;
      setState(() {
        _todayMessage = _todayMessage?.copyWith(
          heartCount: engagement.heartCount,
          shareCount: engagement.shareCount,
        );
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share this message.')),
      );
    } finally {
      if (mounted) setState(() => _todayMessageActionPending = false);
    }
  }

  String _heartedSettingKey(String id) => 'today_message_hearted_$id';

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
    final dateLabel = DateFormat('EEEE · MMM d').format(now).toUpperCase();

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

            _SectionLabel(title: "TODAY'S MESSAGE"),
            const SizedBox(height: 12),
            TodayMessageCard(
              message: _todayMessage,
              loading: _todayMessageLoading,
              hearted: _todayMessageHearted,
              actionPending: _todayMessageActionPending,
              onHeart: _heartTodayMessage,
              onShare: _shareTodayMessage,
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
              planTitle: _plan?.title ?? 'No current plan',
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

class TodayMessageCard extends StatelessWidget {
  const TodayMessageCard({
    super.key,
    required this.message,
    required this.loading,
    required this.hearted,
    required this.actionPending,
    required this.onHeart,
    required this.onShare,
  });

  final TodayMessage? message;
  final bool loading;
  final bool hearted;
  final bool actionPending;
  final VoidCallback onHeart;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final current = message;
    if (loading && current == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (current == null) {
      return Container(
        height: 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          'No message published yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedInk,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    final imageUrl = current.imageUrl;
    final hasImage = imageUrl != null;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: AppTheme.ink,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: hasImage
                ? [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0.76),
                  ]
                : const [
                    AppTheme.ink,
                    Color(0xFF30302A),
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MessageActionButton(
                  icon: hearted ? Icons.favorite : Icons.favorite_border,
                  label: _compactCount(current.heartCount),
                  selected: hearted,
                  onTap: actionPending || hearted ? null : onHeart,
                ),
                const SizedBox(width: 8),
                _MessageActionButton(
                  icon: Icons.ios_share,
                  label: _compactCount(current.shareCount),
                  selected: false,
                  onTap: actionPending ? null : onShare,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              current.primaryText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
            ),
            if (current.verseText != null && current.message != null) ...[
              const SizedBox(height: 8),
              Text(
                current.message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              current.verseReference.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _compactCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _MessageActionButton extends StatelessWidget {
  const _MessageActionButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: selected ? 0.96 : 0.18),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppTheme.ink : Colors.white,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? AppTheme.ink : Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
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
