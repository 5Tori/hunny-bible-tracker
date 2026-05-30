import 'package:flutter/material.dart';

import '../../core/bible/reading_time_format.dart';
import '../../core/theme/app_theme.dart';
import '../read/data/plan_catalog_api_client.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';

enum _OnboardingStep { welcome, level, plan, done }

enum _ReadingLevel {
  beginner('Beginner', 'easy'),
  intermediate('Intermediate', 'medium'),
  advanced('Advanced', 'hard');

  const _ReadingLevel(this.label, this.difficulty);

  final String label;
  final String difficulty;

  String get storageValue => name;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.readRepository,
    required this.onFinished,
  });

  final ReadRepository readRepository;
  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  _OnboardingStep _step = _OnboardingStep.welcome;
  _ReadingLevel? _level;
  List<ReadingPlanTemplateView> _plans = const [];
  ReadingPlanTemplateView? _selectedPlan;
  bool _showAll = false;
  bool _loadingPlans = false;
  bool _startingPlan = false;
  String? _planError;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans({bool forceRefresh = false}) async {
    setState(() {
      _loadingPlans = true;
      _planError = null;
    });
    try {
      final plans = await widget.readRepository.fetchOnboardingPlanChoices(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _selectedPlan ??= plans.isNotEmpty ? plans.first : null;
        _loadingPlans = false;
      });
    } on PlanCatalogFetchFailure catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingPlans = false;
        _planError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingPlans = false;
        _planError = 'Plans could not be loaded. Please try again.';
      });
    }
  }

  Future<void> _startSelectedPlan() async {
    final level = _level;
    final plan = _selectedPlan;
    if (level == null || plan == null || _startingPlan) return;

    setState(() => _startingPlan = true);
    try {
      await widget.readRepository.addPlanFromTemplate(plan.templateKey);
      await widget.readRepository.completeOnboarding(level.storageValue);
      if (!mounted) return;
      setState(() {
        _startingPlan = false;
        _step = _OnboardingStep.done;
      });
    } on PlanCatalogFetchFailure catch (error) {
      if (!mounted) return;
      setState(() => _startingPlan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
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
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _buildStep(context),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case _OnboardingStep.welcome:
        return _OnboardingFrame(
          key: const ValueKey('welcome'),
          title: 'Hunny Bible Tracker',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _BulletLine('Start small.'),
              _BulletLine('Read approachable stories.'),
              _BulletLine('Track your progress.'),
              _BulletLine('Keep going gently.'),
            ],
          ),
          action: _PrimaryButton(
            label: 'Get started',
            onPressed: () => setState(() => _step = _OnboardingStep.level),
          ),
        );
      case _OnboardingStep.level:
        return _OnboardingFrame(
          key: const ValueKey('level'),
          title: 'Where should we start?',
          subtitle:
              'Choose what feels comfortable today. You can change plans anytime.',
          body: Column(
            children: _ReadingLevel.values
                .map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionTile(
                      label: level.label,
                      selected: _level == level,
                      onTap: () => setState(() => _level = level),
                    ),
                  ),
                )
                .toList(),
          ),
          action: _PrimaryButton(
            label: 'Continue',
            onPressed: _level == null
                ? null
                : () => setState(() => _step = _OnboardingStep.plan),
          ),
        );
      case _OnboardingStep.plan:
        return _PlanSelectionStep(
          key: const ValueKey('plan'),
          level: _level!,
          plans: _plans,
          selectedPlan: _selectedPlan,
          showAll: _showAll,
          loading: _loadingPlans,
          error: _planError,
          starting: _startingPlan,
          onRetry: () => _loadPlans(forceRefresh: true),
          onShowAllChanged: (value) => setState(() {
            _showAll = value;
            _selectedPlan = null;
          }),
          onPlanSelected: (plan) => setState(() => _selectedPlan = plan),
          onStart: _startSelectedPlan,
        );
      case _OnboardingStep.done:
        return _OnboardingFrame(
          key: const ValueKey('done'),
          title: 'You’re ready to begin',
          subtitle:
              'Your first reading plan is ready. Start gently and keep going one chapter at a time.',
          body: const SizedBox.shrink(),
          action: _PrimaryButton(
            label: 'Start reading',
            onPressed: widget.onFinished,
          ),
        );
    }
  }
}

class _PlanSelectionStep extends StatelessWidget {
  const _PlanSelectionStep({
    super.key,
    required this.level,
    required this.plans,
    required this.selectedPlan,
    required this.showAll,
    required this.loading,
    required this.error,
    required this.starting,
    required this.onRetry,
    required this.onShowAllChanged,
    required this.onPlanSelected,
    required this.onStart,
  });

  final _ReadingLevel level;
  final List<ReadingPlanTemplateView> plans;
  final ReadingPlanTemplateView? selectedPlan;
  final bool showAll;
  final bool loading;
  final String? error;
  final bool starting;
  final VoidCallback onRetry;
  final ValueChanged<bool> onShowAllChanged;
  final ValueChanged<ReadingPlanTemplateView> onPlanSelected;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final recommended = plans
        .where((plan) => plan.difficulty?.toLowerCase() == level.difficulty)
        .toList();
    final fallbackToAll = recommended.isEmpty && plans.isNotEmpty;
    final visiblePlans = showAll || fallbackToAll ? plans : recommended;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose your first plan',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Start with a short story that feels easy to begin.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Choose one for now. You can add more plans later.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed:
                    plans.isEmpty ? null : () => onShowAllChanged(!showAll),
                child: Text(showAll ? 'Recommended' : 'See all'),
              ),
            ],
          ),
          if (fallbackToAll && !showAll) ...[
            const SizedBox(height: 8),
            const _InfoNote(
              'We couldn’t find a perfect match yet, so here are all available plans.',
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: _buildPlanList(context, visiblePlans),
          ),
          const SizedBox(height: 14),
          _PrimaryButton(
            label: starting ? 'Starting…' : 'Start this plan',
            onPressed: selectedPlan == null || starting ? null : onStart,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanList(
    BuildContext context,
    List<ReadingPlanTemplateView> visiblePlans,
  ) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (visiblePlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              error ?? 'No plans are available yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: visiblePlans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final plan = visiblePlans[index];
        return _PlanChoiceCard(
          plan: plan,
          selected: selectedPlan?.templateKey == plan.templateKey,
          onTap: () => onPlanSelected(plan),
        );
      },
    );
  }
}

class _OnboardingFrame extends StatelessWidget {
  const _OnboardingFrame({
    super.key,
    required this.title,
    required this.body,
    required this.action,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 14),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ],
          const SizedBox(height: 28),
          body,
          const Spacer(),
          action,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppTheme.accentYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.softSurface : AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: selected ? AppTheme.ink : AppTheme.border,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppTheme.ink : AppTheme.mutedInk,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanChoiceCard extends StatelessWidget {
  const _PlanChoiceCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final ReadingPlanTemplateView plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final description = plan.shortDescription.trim().isNotEmpty
        ? plan.shortDescription.trim()
        : plan.description.trim();
    final totalDuration = formatCatalogPlanTotalDuration(
      minutesPerChapter: plan.estimatedMinutes,
      totalChapters: plan.totalChapters,
    );
    final estimatedTime = totalDuration ?? 'Time varies';
    final difficulty = _titleCase(plan.difficulty ?? 'Flexible');

    return Material(
      color: selected ? AppTheme.softSurface : AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: selected ? AppTheme.ink : AppTheme.border,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? AppTheme.ink : AppTheme.mutedInk,
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip('${plan.totalChapters} chapters'),
                  _MetaChip(estimatedTime),
                  _MetaChip(difficulty),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleCase(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.mutedInk,
            fontStyle: FontStyle.italic,
          ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.ink,
        foregroundColor: AppTheme.surface,
        disabledBackgroundColor: AppTheme.border,
        disabledForegroundColor: AppTheme.mutedInk,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(label),
    );
  }
}
