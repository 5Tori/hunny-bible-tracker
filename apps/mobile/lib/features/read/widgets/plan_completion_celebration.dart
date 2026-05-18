import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/read_models.dart';

enum PlanCompletionCelebrationAction {
  dismissed,
  browseAll,
  continuePlan,
}

class PlanCompletionCelebrationOutcome {
  const PlanCompletionCelebrationOutcome(
    this.action, {
    this.planId,
  });

  final PlanCompletionCelebrationAction action;
  final String? planId;
}

/// Typical party-confetti palette (not app brand colors).
const _confettiColors = [
  Color(0xFFFF5252),
  Color(0xFFFF4081),
  Color(0xFFFF9800),
  Color(0xFFFFEB3B),
  Color(0xFF69F0AE),
  Color(0xFF40C4FF),
  Color(0xFF7C4DFF),
  Color(0xFFE040FB),
  Color(0xFF18FFFF),
  Color(0xFFFFFFFF),
];

/// Full-screen celebration after the user finishes a reading plan.
Future<PlanCompletionCelebrationOutcome> showPlanCompletionCelebration({
  required BuildContext context,
  required String planTitle,
  required int totalChapters,
  required List<ReadingPlanSummary> currentPlans,
}) {
  return showGeneralDialog<PlanCompletionCelebrationOutcome>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Plan completed',
    barrierColor: Colors.black.withValues(alpha: 0.48),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) {
      return PlanCompletionCelebrationOverlay(
        planTitle: planTitle,
        totalChapters: totalChapters,
        currentPlans: currentPlans,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curve),
          child: child,
        ),
      );
    },
  ).then(
    (value) => value ?? const PlanCompletionCelebrationOutcome(
      PlanCompletionCelebrationAction.dismissed,
    ),
  );
}

class PlanCompletionCelebrationOverlay extends StatefulWidget {
  const PlanCompletionCelebrationOverlay({
    super.key,
    required this.planTitle,
    required this.totalChapters,
    required this.currentPlans,
  });

  final String planTitle;
  final int totalChapters;
  final List<ReadingPlanSummary> currentPlans;

  @override
  State<PlanCompletionCelebrationOverlay> createState() =>
      _PlanCompletionCelebrationOverlayState();
}

class _PlanCompletionCelebrationOverlayState
    extends State<PlanCompletionCelebrationOverlay> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _close(PlanCompletionCelebrationOutcome outcome) {
    Navigator.of(context).pop(outcome);
  }

  void _dismiss() {
    _close(
      const PlanCompletionCelebrationOutcome(
        PlanCompletionCelebrationAction.dismissed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                emissionFrequency: 0.07,
                numberOfParticles: 48,
                minimumSize: const Size(3, 5),
                maximumSize: const Size(6, 9),
                maxBlastForce: 24,
                minBlastForce: 10,
                gravity: 0.12,
                colors: _confettiColors,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _CelebrationCard(
                  planTitle: widget.planTitle,
                  totalChapters: widget.totalChapters,
                  currentPlans: widget.currentPlans,
                  onBrowseAll: () => _close(
                    const PlanCompletionCelebrationOutcome(
                      PlanCompletionCelebrationAction.browseAll,
                    ),
                  ),
                  onContinuePlan: (planId) => _close(
                    PlanCompletionCelebrationOutcome(
                      PlanCompletionCelebrationAction.continuePlan,
                      planId: planId,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({
    required this.planTitle,
    required this.totalChapters,
    required this.currentPlans,
    required this.onBrowseAll,
    required this.onContinuePlan,
  });

  final String planTitle;
  final int totalChapters;
  final List<ReadingPlanSummary> currentPlans;
  final VoidCallback onBrowseAll;
  final ValueChanged<String> onContinuePlan;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Material(
      color: Colors.white,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(3),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 480,
          maxHeight: screenHeight * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.accentYellowLight,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(
                  Icons.auto_stories_outlined,
                  size: 38,
                  color: AppTheme.ink,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    duration: 420.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 220.ms),
            ),
            const SizedBox(height: 40),
            Text(
              'You finished your plan!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  ),
            )
                .animate()
                .fadeIn(delay: 80.ms, duration: 240.ms)
                .slideY(begin: 0.08, end: 0, duration: 240.ms),
            const SizedBox(height: 20),
            Text(
              planTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
            )
                .animate()
                .fadeIn(delay: 120.ms, duration: 240.ms)
                .slideY(begin: 0.06, end: 0, duration: 240.ms),
            const SizedBox(height: 18),
            Text(
              totalChapters > 0
                  ? 'All $totalChapters chapters complete. Well done.'
                  : 'Every chapter is complete. Well done.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedInk,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
            )
                .animate()
                .fadeIn(delay: 160.ms, duration: 240.ms),
            const SizedBox(height: 52),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Continue your journey',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedInk,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          fontSize: 12,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: onBrowseAll,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See all plans'),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 200.ms),
            const SizedBox(height: 20),
            ContinueJourneyPlanCarousel(
              currentPlans: currentPlans,
              onContinuePlan: onContinuePlan,
            )
                .animate()
                .fadeIn(delay: 220.ms, duration: 240.ms),
          ],
        ),
      ),
    );
  }
}

/// Swipeable plan cards (~70% width so the next card peeks in).
class ContinueJourneyPlanCarousel extends StatefulWidget {
  const ContinueJourneyPlanCarousel({
    super.key,
    required this.currentPlans,
    required this.onContinuePlan,
  });

  final List<ReadingPlanSummary> currentPlans;
  final ValueChanged<String> onContinuePlan;

  static const _cardHeight = 108.0;
  static const _viewportFraction = 0.48;

  @override
  State<ContinueJourneyPlanCarousel> createState() =>
      _ContinueJourneyPlanCarouselState();
}

class _ContinueJourneyPlanCarouselState extends State<ContinueJourneyPlanCarousel> {
  late final PageController _pageController;
  int _pageIndex = 0;

  int get _planCount => widget.currentPlans.length;

  bool get _hasPlans => _planCount > 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: ContinueJourneyPlanCarousel._viewportFraction,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: ContinueJourneyPlanCarousel._cardHeight,
          child: _hasPlans
              ? PageView.builder(
                  controller: _pageController,
                  padEnds: false,
                  itemCount: _planCount,
                  onPageChanged: (index) => setState(() => _pageIndex = index),
                  itemBuilder: (context, index) {
                    final summary = widget.currentPlans[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _JourneyPlanCard(
                        summary: summary,
                        onTap: () =>
                            widget.onContinuePlan(summary.plan.id),
                      ),
                    );
                  },
                )
              : const _JourneyPlansEmptyCard(),
        ),
        if (_planCount > 1) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_planCount, (index) {
              final active = index == _pageIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppTheme.ink : AppTheme.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _JourneyPlansEmptyCard extends StatelessWidget {
  const _JourneyPlansEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No other plans in progress',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _JourneyPlanCard extends StatelessWidget {
  const _JourneyPlanCard({
    required this.summary,
    required this.onTap,
  });

  final ReadingPlanSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.softSurface,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                summary.plan.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      height: 1.15,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${summary.completedChapters} / ${summary.totalChapters} chapters · ${summary.progressLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedInk,
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: summary.progress,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
