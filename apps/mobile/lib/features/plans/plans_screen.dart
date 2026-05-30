import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/bible/reading_time_format.dart';
import '../../core/theme/app_theme.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';

enum PlansInitialTab { myPlans, catalog }

/// Result when [PlansScreen] is popped.
class PlansScreenPopResult {
  const PlansScreenPopResult({
    this.dataChanged = false,
    this.openOnRead = false,
  });

  final bool dataChanged;
  final bool openOnRead;

  bool get shouldRefreshRead => dataChanged || openOnRead;
}

class PlansScreen extends StatefulWidget {
  const PlansScreen({
    super.key,
    required this.readRepository,
    this.initialTab = PlansInitialTab.myPlans,
  });

  final ReadRepository readRepository;
  final PlansInitialTab initialTab;

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late PlansInitialTab _tab = widget.initialTab;
  ReadingPlanView? _currentPlan;
  List<ReadingPlanSummary> _currentPlans = const [];
  List<ReadingPlanSummary> _archivedPlans = const [];
  List<CompletedPlanSummary> _completedPlans = const [];
  List<ReadingPlanTemplateView> _catalog = const [];
  bool _loading = true;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final currentPlan = await widget.readRepository.getCurrentPlan();
    final currentPlans = await widget.readRepository.getCurrentPlanSummaries();
    final archivedPlans =
        await widget.readRepository.getArchivedPlanSummaries();
    final completedPlans =
        await widget.readRepository.getCompletedPlanSummaries();
    final catalog = await widget.readRepository.getPlanTemplatesForCatalog();

    if (!mounted) return;
    setState(() {
      _currentPlan = currentPlan;
      _currentPlans = currentPlans;
      _archivedPlans = archivedPlans;
      _completedPlans = completedPlans;
      _catalog = catalog;
      _loading = false;
    });
    unawaited(_refreshRemoteCatalog());
  }

  Future<void> _refreshRemoteCatalog() async {
    try {
      await widget.readRepository.refreshPlanTemplatesFromRemote(
        allowFailure: true,
      );
      final catalog = await widget.readRepository.getPlanTemplatesForCatalog();
      if (!mounted) return;
      setState(() => _catalog = catalog);
    } catch (_) {}
  }

  Future<void> _continueToRead(String planId) async {
    await widget.readRepository.switchToPlan(planId);
    if (!mounted) return;
    Navigator.of(context).pop(
      const PlansScreenPopResult(dataChanged: true, openOnRead: true),
    );
  }

  Future<void> _startPlan(String templateKey) async {
    await widget.readRepository.addPlanFromTemplate(templateKey);
    _changed = true;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan ready')),
    );
  }

  Future<void> _archivePlan(ReadingPlanSummary summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive plan?'),
        content: Text(
          '"${summary.plan.title}" will move out of Current Plans. '
          'Your progress and reading history will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.readRepository.archiveCurrentPlan(summary.plan.id);
    _changed = true;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan archived')),
    );
  }

  Future<void> _restorePlan(String planId) async {
    await widget.readRepository.restoreArchivedPlan(planId);
    _changed = true;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan restored')),
    );
  }

  void _close() {
    if (_changed) {
      Navigator.of(context).pop(
        const PlansScreenPopResult(dataChanged: true),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<PlansScreenPopResult?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          foregroundColor: AppTheme.ink,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _close,
          ),
          title: const Text('Plans'),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    children: [
                      _PlansTabSwitcher(
                        value: _tab,
                        onChanged: (tab) => setState(() => _tab = tab),
                      ),
                      const SizedBox(height: 24),
                      if (_tab == PlansInitialTab.myPlans)
                        _MyPlansView(
                          currentPlanId: _currentPlan?.id,
                          currentPlans: _currentPlans,
                          archivedPlans: _archivedPlans,
                          completedPlans: _completedPlans,
                          onContinue: _continueToRead,
                          onArchive: _archivePlan,
                          onRestore: _restorePlan,
                          onStartAgain: _startPlan,
                        )
                      else
                        _CatalogView(
                          currentPlanId: _currentPlan?.id,
                          currentPlans: _currentPlans,
                          templates: _catalog,
                          onContinue: _continueToRead,
                          onStartPlan: _startPlan,
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _PlansTabSwitcher extends StatelessWidget {
  const _PlansTabSwitcher({
    required this.value,
    required this.onChanged,
  });

  final PlansInitialTab value;
  final ValueChanged<PlansInitialTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _PlansTabButton(
            label: 'My Plans',
            selected: value == PlansInitialTab.myPlans,
            onTap: () => onChanged(PlansInitialTab.myPlans),
          ),
          _PlansTabButton(
            label: 'Catalog',
            selected: value == PlansInitialTab.catalog,
            onTap: () => onChanged(PlansInitialTab.catalog),
          ),
        ],
      ),
    );
  }
}

class _PlansTabButton extends StatelessWidget {
  const _PlansTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
            border: selected ? Border.all(color: AppTheme.border) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? AppTheme.ink : AppTheme.mutedInk,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ),
    );
  }
}

class _MyPlansView extends StatelessWidget {
  const _MyPlansView({
    required this.currentPlanId,
    required this.currentPlans,
    required this.archivedPlans,
    required this.completedPlans,
    required this.onContinue,
    required this.onArchive,
    required this.onRestore,
    required this.onStartAgain,
  });

  final String? currentPlanId;
  final List<ReadingPlanSummary> currentPlans;
  final List<ReadingPlanSummary> archivedPlans;
  final List<CompletedPlanSummary> completedPlans;
  final ValueChanged<String> onContinue;
  final ValueChanged<ReadingPlanSummary> onArchive;
  final ValueChanged<String> onRestore;
  final ValueChanged<String> onStartAgain;

  @override
  Widget build(BuildContext context) {
    final activeTemplateIds = {
      for (final summary in currentPlans) summary.plan.templateId,
    };
    final activeByTemplateId = {
      for (final summary in currentPlans) summary.plan.templateId: summary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PlansSectionTitle('Current'),
        const SizedBox(height: 12),
        if (currentPlans.isEmpty)
          const _PlansEmptyState('No current plans yet.')
        else
          for (final summary in currentPlans) ...[
            _CurrentPlanCard(
              summary: summary,
              isCurrent: summary.plan.id == currentPlanId,
              onContinue: () => onContinue(summary.plan.id),
              onArchive: () => onArchive(summary),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 16),
        const _PlansSectionTitle('Completed'),
        const SizedBox(height: 12),
        if (completedPlans.isEmpty)
          const _PlansEmptyState('Completed plans will appear here.')
        else
          for (final summary in completedPlans) ...[
            _CompletedPlanCard(
              summary: summary,
              hasActiveRun: activeTemplateIds.contains(summary.templateId),
              onContinue: activeByTemplateId[summary.templateId] == null
                  ? null
                  : () => onContinue(
                        activeByTemplateId[summary.templateId]!.plan.id,
                      ),
              onStartAgain: summary.templateKey.isEmpty
                  ? null
                  : () => onStartAgain(summary.templateKey),
            ),
            const SizedBox(height: 12),
          ],
        if (archivedPlans.isNotEmpty) ...[
          const SizedBox(height: 16),
          const _PlansSectionTitle('Archived'),
          const SizedBox(height: 12),
          for (final summary in archivedPlans) ...[
            _ArchivedPlanCard(
              summary: summary,
              onRestore: () => onRestore(summary.plan.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView({
    required this.currentPlanId,
    required this.currentPlans,
    required this.templates,
    required this.onContinue,
    required this.onStartPlan,
  });

  final String? currentPlanId;
  final List<ReadingPlanSummary> currentPlans;
  final List<ReadingPlanTemplateView> templates;
  final ValueChanged<String> onContinue;
  final ValueChanged<String> onStartPlan;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const _PlansEmptyState('No published plans yet.');
    }

    final activeByTemplateId = {
      for (final summary in currentPlans) summary.plan.templateId: summary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PlansSectionTitle('Plan Catalog'),
        const SizedBox(height: 12),
        for (final template in templates) ...[
          _CatalogPlanCard(
            template: template,
            activeSummary: activeByTemplateId[template.id],
            currentPlanId: currentPlanId,
            onContinue: onContinue,
            onStartPlan: onStartPlan,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({
    required this.summary,
    required this.isCurrent,
    required this.onContinue,
    required this.onArchive,
  });

  final ReadingPlanSummary summary;
  final bool isCurrent;
  final VoidCallback onContinue;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final countLabel =
        '${summary.completedChapters} / ${summary.totalChapters} chapters';
    return _PlanCardFrame(
      highlighted: isCurrent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            summary.plan.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$countLabel · ${summary.progressLabel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            minHeight: 6,
            value: summary.progress,
            backgroundColor: AppTheme.softSurface,
            valueColor: const AlwaysStoppedAnimation(AppTheme.ink),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: onArchive,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.mutedInk,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 13,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: const Text('Archive'),
              ),
              const Spacer(),
              _PlanActionButton(
                label: 'Continue',
                onPressed: onContinue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedPlanCard extends StatelessWidget {
  const _CompletedPlanCard({
    required this.summary,
    required this.hasActiveRun,
    required this.onContinue,
    required this.onStartAgain,
  });

  final CompletedPlanSummary summary;
  final bool hasActiveRun;
  final VoidCallback? onContinue;
  final VoidCallback? onStartAgain;

  @override
  Widget build(BuildContext context) {
    final completedAt = summary.lastCompletedAt;
    final dateLabel =
        completedAt == null ? null : DateFormat('MMM d').format(completedAt);
    // Completion count is on the title badge; meta keeps the last-run date only.
    final meta = dateLabel ?? summary.completionLabel;

    return _PlanCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  summary.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (summary.completionCount > 0) ...[
                const SizedBox(width: 10),
                _PlanCompletionBadge(label: summary.completionBadgeLabel),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _PlanActionButton(
              label: hasActiveRun ? 'Continue' : 'Start Again',
              onPressed: hasActiveRun ? onContinue : onStartAgain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivedPlanCard extends StatelessWidget {
  const _ArchivedPlanCard({
    required this.summary,
    required this.onRestore,
  });

  final ReadingPlanSummary summary;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final countLabel =
        '${summary.completedChapters} / ${summary.totalChapters} chapters';

    return _PlanCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            summary.plan.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '$countLabel · ${summary.progressLabel}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            minHeight: 6,
            value: summary.progress,
            backgroundColor: AppTheme.softSurface,
            valueColor: const AlwaysStoppedAnimation(AppTheme.mutedInk),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _PlanActionButton(
              label: 'Restore',
              onPressed: onRestore,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogPlanCard extends StatelessWidget {
  const _CatalogPlanCard({
    required this.template,
    required this.activeSummary,
    required this.currentPlanId,
    required this.onContinue,
    required this.onStartPlan,
  });

  final ReadingPlanTemplateView template;
  final ReadingPlanSummary? activeSummary;
  final String? currentPlanId;
  final ValueChanged<String> onContinue;
  final ValueChanged<String> onStartPlan;

  @override
  Widget build(BuildContext context) {
    final active = activeSummary;
    final totalDuration = formatCatalogPlanTotalDuration(
      minutesPerChapter: template.estimatedMinutes,
      totalChapters: template.totalChapters,
    );
    final meta = [
      '${template.totalChapters} chapters',
      if (totalDuration != null) totalDuration,
    ].join(' · ');
    final tags = [
      template.planTypeLabel,
      _scopeLabel(template.testamentScope),
      if (template.difficulty != null) _titleCase(template.difficulty!),
    ].where((label) => label.isNotEmpty).join(' · ');

    final ctaLabel = active != null
        ? 'Continue'
        : template.completionCount > 0
            ? 'Start Again'
            : 'Start Plan';
    final ctaAction = active != null
        ? () => onContinue(active.plan.id)
        : () => onStartPlan(template.templateKey);
    final showCompletionBadge = template.completionCount > 0;

    return _PlanCardFrame(
      highlighted: active?.plan.id == currentPlanId,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  template.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (showCompletionBadge) ...[
                const SizedBox(width: 10),
                _PlanCompletionBadge(label: template.completionBadgeLabel),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meta,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              tags,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _PlanActionButton(
              label: ctaLabel,
              onPressed: ctaAction,
            ),
          ),
        ],
      ),
    );
  }

  String _scopeLabel(String scope) {
    switch (scope) {
      case 'old_testament':
        return 'Old Testament';
      case 'new_testament':
        return 'New Testament';
      case 'whole_bible':
        return 'Whole Bible';
      default:
        return _titleCase(scope);
    }
  }

  String _titleCase(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class _PlanCompletionBadge extends StatelessWidget {
  const _PlanCompletionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentYellowLight,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              height: 1.1,
            ),
      ),
    );
  }
}

class _PlanCardFrame extends StatelessWidget {
  const _PlanCardFrame({
    required this.child,
    this.highlighted = false,
  });

  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: highlighted ? AppTheme.ink : AppTheme.border,
          width: highlighted ? 1.4 : 1,
        ),
      ),
      child: child,
    );
  }
}

class _PlanActionButton extends StatelessWidget {
  const _PlanActionButton({
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
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppTheme.softSurface,
        disabledForegroundColor: AppTheme.mutedInk,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      child: Text(label),
    );
  }
}

class _PlansSectionTitle extends StatelessWidget {
  const _PlansSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mutedInk,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
    );
  }
}

class _PlansEmptyState extends StatelessWidget {
  const _PlansEmptyState(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mutedInk,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
