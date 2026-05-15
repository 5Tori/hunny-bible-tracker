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
  var _todayMessageSaved = false;
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
    final todayMessageSaved = todayMessage == null
        ? false
        : await _isTodayMessageSaved(todayMessage.id);
    if (!mounted) return;
    setState(() {
      _plan = plan;
      _readingOverview = overview;
      _todayMessage = todayMessage;
      _todayMessageHearted = todayMessageHearted;
      _todayMessageSaved = todayMessageSaved;
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

  Future<bool> _isTodayMessageSaved(String id) async {
    final value =
        await widget.readRepository.getAppSetting(_savedSettingKey(id));
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

  Future<void> _toggleSaveTodayMessage() async {
    final message = _todayMessage;
    if (message == null) return;

    final nextValue = !_todayMessageSaved;
    setState(() => _todayMessageSaved = nextValue);
    await widget.readRepository.setAppSetting(
      _savedSettingKey(message.id),
      nextValue ? '1' : '0',
    );
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
  String _savedSettingKey(String id) => 'today_message_saved_$id';

  Future<void> _openTodayMessageArticle() async {
    final message = _todayMessage;
    if (message == null) return;
    final relatedPlan = message.planTemplateIdentifier == null
        ? null
        : await widget.readRepository.getPlanTemplateByIdentifier(
            message.planTemplateIdentifier!,
          );
    if (!mounted) return;

    final started = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TodayMessageArticleSheet(
          message: message,
          relatedPlan: relatedPlan,
          onStartPlan: widget.readRepository.addPlanFromTemplate,
        );
      },
    );

    if (!mounted || started != true) return;
    await _load();
    widget.onReadTap();
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
              saved: _todayMessageSaved,
              actionPending: _todayMessageActionPending,
              onHeart: _heartTodayMessage,
              onSave: _toggleSaveTodayMessage,
              onShare: _shareTodayMessage,
              onReadMore: _openTodayMessageArticle,
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
    required this.saved,
    required this.actionPending,
    required this.onHeart,
    required this.onSave,
    required this.onShare,
    required this.onReadMore,
  });

  final TodayMessage? message;
  final bool loading;
  final bool hearted;
  final bool saved;
  final bool actionPending;
  final VoidCallback onHeart;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onReadMore;

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.86,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.ink,
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: hasImage
                        ? [
                            Colors.black.withValues(alpha: 0.02),
                            Colors.black.withValues(alpha: 0.82),
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
                    Text(
                      '"${current.primaryText}"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      current.referenceLabel.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Row(
              children: [
                _MessageActionButton(
                  icon: hearted ? Icons.favorite : Icons.favorite_border,
                  label: _compactCount(current.heartCount),
                  selected: hearted,
                  onTap: actionPending || hearted ? null : onHeart,
                ),
                const SizedBox(width: 18),
                _MessageActionButton(
                  icon: saved ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Save',
                  selected: saved,
                  onTap: onSave,
                ),
                const Spacer(),
                _MessageActionButton(
                  icon: Icons.ios_share,
                  label: current.shareCount > 0
                      ? _compactCount(current.shareCount)
                      : '',
                  selected: false,
                  onTap: actionPending ? null : onShare,
                  compact: true,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.reflectionTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 7),
                Text(
                  current.reflectionSummary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.ink,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: onReadMore,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text('Read more'),
                ),
              ],
            ),
          ),
        ],
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
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 2,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 25,
                color: selected ? AppTheme.ink : AppTheme.mutedInk,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 7),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedInk,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayMessageArticleSheet extends StatefulWidget {
  const _TodayMessageArticleSheet({
    required this.message,
    required this.relatedPlan,
    required this.onStartPlan,
  });

  final TodayMessage message;
  final ReadingPlanTemplateView? relatedPlan;
  final Future<String> Function(String templateKey) onStartPlan;

  @override
  State<_TodayMessageArticleSheet> createState() =>
      _TodayMessageArticleSheetState();
}

class _TodayMessageArticleSheetState extends State<_TodayMessageArticleSheet> {
  var _startingPlan = false;

  Future<void> _startPlan() async {
    final identifier = widget.message.planTemplateIdentifier ??
        widget.relatedPlan?.templateKey;
    if (identifier == null || _startingPlan) return;
    setState(() => _startingPlan = true);
    try {
      await widget.onStartPlan(identifier);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _startingPlan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start this plan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final relatedPlan = widget.relatedPlan;
    final showRelatedPlan = message.hasRelatedPlan || relatedPlan != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 44, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.softSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      message.referenceLabel.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mutedInk,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      message.articleHeading,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.ink,
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                                height: 1.16,
                              ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      message.articleText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.ink,
                            fontSize: 20,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (showRelatedPlan) ...[
                      const SizedBox(height: 28),
                      _RelatedPlanCard(
                        title: relatedPlan?.title ?? message.planTitle,
                        chapters:
                            relatedPlan?.totalChapters ?? message.planChapters,
                        minutes: relatedPlan?.estimatedMinutes ??
                            message.planMinutes,
                        starting: _startingPlan,
                        onStartPlan: _startPlan,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: _startingPlan
                      ? null
                      : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                  color: AppTheme.ink,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RelatedPlanCard extends StatelessWidget {
  const _RelatedPlanCard({
    required this.title,
    required this.chapters,
    required this.minutes,
    required this.starting,
    required this.onStartPlan,
  });

  final String title;
  final int chapters;
  final int minutes;
  final bool starting;
  final VoidCallback onStartPlan;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (chapters > 0) '$chapters chapters',
      if (minutes > 0) '~$minutes min',
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'READ IN CONTEXT',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        details,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mutedInk,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: starting ? null : onStartPlan,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.mutedInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: Text(starting ? 'Starting...' : 'Start plan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
