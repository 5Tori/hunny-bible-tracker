import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import 'data/read_repository.dart';
import 'domain/read_models.dart';
import 'widgets/book_card.dart';
import 'widgets/chapter_grid.dart';
import 'widgets/current_plan_progress_panel.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key, required this.readRepository});

  final ReadRepository readRepository;

  @override
  State<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  ReadingPlanView? _plan;
  List<PlanSectionProgress> _sections = const [];
  List<ChapterProgressView> _chapters = const [];
  ReadingOverview? _readingOverview;
  String? _selectedSectionId;
  String? _selectedBookKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    setState(() => _loading = true);
    final plan = await widget.readRepository.getCurrentPlan();
    if (plan == null) {
      if (!mounted) return;
      setState(() {
        _plan = null;
        _sections = const [];
        _selectedSectionId = null;
        _selectedBookKey = null;
        _chapters = const [];
        _readingOverview = null;
        _loading = false;
      });
      return;
    }

    final sections =
        await widget.readRepository.getSectionsWithProgress(plan.id);
    if (sections.isEmpty) {
      final overview = await widget.readRepository.getReadingOverview(plan.id);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _sections = sections;
        _selectedSectionId = null;
        _selectedBookKey = null;
        _chapters = const [];
        _readingOverview = overview;
        _loading = false;
      });
      return;
    }

    var selectedSectionId = plan.lastOpenedSectionId;
    var selectedBookKey = plan.lastOpenedBookKey;
    var selectedBook = _findBook(
      sections: sections,
      sectionId: selectedSectionId,
      bookKey: selectedBookKey,
    );
    final selected = selectedBook ?? sections.first.books.first;
    final chapters = await widget.readRepository.getChaptersForBook(
      planId: plan.id,
      sectionId: selected.sectionId,
      bookKey: selected.bookKey,
    );
    final overview = await widget.readRepository.getReadingOverview(plan.id);

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _sections = sections;
      _selectedSectionId = selected.sectionId;
      _selectedBookKey = selected.bookKey;
      _chapters = chapters;
      _readingOverview = overview;
      _loading = false;
    });
  }

  Future<void> _selectBook(BookProgress book) async {
    final plan = _plan;
    if (plan == null) return;

    setState(() {
      _selectedSectionId = book.sectionId;
      _selectedBookKey = book.bookKey;
      _chapters = const [];
    });

    await widget.readRepository.rememberLastOpenedBook(
      planId: plan.id,
      sectionId: book.sectionId,
      bookKey: book.bookKey,
    );

    final chapters = await widget.readRepository.getChaptersForBook(
      planId: plan.id,
      sectionId: book.sectionId,
      bookKey: book.bookKey,
    );

    if (!mounted) return;
    setState(() => _chapters = chapters);
  }

  Future<void> _toggleChapter(ChapterProgressView chapter) async {
    final plan = _plan;
    final sectionId = _selectedSectionId;
    final bookKey = _selectedBookKey;
    if (plan == null || sectionId == null || bookKey == null) return;

    final result = await widget.readRepository.toggleChapter(
      planId: plan.id,
      sectionId: sectionId,
      bookKey: bookKey,
      chapterNumber: chapter.chapterNumber,
    );

    await _refreshAfterChange();
    if (result.completionReady && mounted) setState(() {});
  }

  Future<void> _refreshAfterChange() async {
    final plan = _plan;
    final sectionId = _selectedSectionId;
    final bookKey = _selectedBookKey;
    if (plan == null || sectionId == null || bookKey == null) return;

    final sections =
        await widget.readRepository.getSectionsWithProgress(plan.id);
    final chapters = await widget.readRepository.getChaptersForBook(
      planId: plan.id,
      sectionId: sectionId,
      bookKey: bookKey,
    );
    final overview = await widget.readRepository.getReadingOverview(plan.id);
    final currentPlan = await widget.readRepository.getCurrentPlan();

    if (!mounted) return;
    setState(() {
      _plan = currentPlan ?? plan;
      _sections = sections;
      _chapters = chapters;
      _readingOverview = overview;
    });
  }

  Future<void> _finishPlan() async {
    final plan = _plan;
    if (plan == null) return;

    await widget.readRepository.finishPlan(plan.id);
    await _loadInitialState();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan completed')),
    );
  }

  Future<void> _showPlanPicker() async {
    final currentPlans = await widget.readRepository.getCurrentPlanSummaries();
    final completedPlans =
        await widget.readRepository.getCompletedPlanSummaries();
    if (!mounted) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _PlanPickerSheet(
        readRepository: widget.readRepository,
        currentPlans: currentPlans,
        completedPlans: completedPlans,
        currentPlanId: _plan?.id,
        inProgressTemplateIds: {
          for (final s in currentPlans) s.plan.templateId,
        },
      ),
    );

    if (!mounted) return;

    if (selected == _PlanPickerSheet.addNewSentinel) {
      try {
        await widget.readRepository.refreshPlanTemplatesFromRemote();
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not refresh plans. Showing saved plans.'),
          ),
        );
      }
      final templates =
          await widget.readRepository.getPlanTemplatesForCatalog();
      if (!mounted) return;
      final templateKey = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => _PlanTemplatePickerSheet(templates: templates),
      );
      if (templateKey == null || !mounted) return;
      await widget.readRepository.addPlanFromTemplate(templateKey);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan added')),
      );
      await _loadInitialState();
      return;
    }

    if (selected == null || selected == _plan?.id) return;

    await widget.readRepository.switchToPlan(selected);
    await _loadInitialState();
  }

  List<Widget> _buildBookRows({
    required String sectionId,
    required List<BookProgress> books,
  }) {
    const columns = 3;
    const spacing = 6.0;
    final rowCount = (books.length / columns).ceil();
    final slivers = <Widget>[];

    for (int row = 0; row < rowCount; row++) {
      final start = row * columns;
      final end = (start + columns).clamp(0, books.length);
      final rowBooks = books.sublist(start, end);

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, row == 0 ? 0 : spacing, 20, 0),
            child: Row(
              children: [
                for (int i = 0; i < columns; i++) ...[
                  if (i > 0) const SizedBox(width: spacing),
                  Expanded(
                    child: i < rowBooks.length
                        ? AspectRatio(
                            aspectRatio: 0.96,
                            child: BookCard(
                              book: rowBooks[i],
                              isSelected:
                                  rowBooks[i].sectionId == _selectedSectionId &&
                                      rowBooks[i].bookKey == _selectedBookKey,
                              onTap: () => _selectBook(rowBooks[i]),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

      final selectedBook = _findBook(
        sections: _sections,
        sectionId: sectionId,
        bookKey: _selectedBookKey,
      );
      final hasSelected = rowBooks.any(
        (book) =>
            book.sectionId == _selectedSectionId &&
            book.bookKey == _selectedBookKey,
      );
      if (hasSelected && selectedBook != null) {
        slivers.add(
          SliverToBoxAdapter(
            child: _ChapterSection(
              book: selectedBook,
              chapters: _chapters,
              onChapterTap: _toggleChapter,
            ),
          ),
        );
      }
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final overview = _readingOverview;

    if (_plan == null) {
      return SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialState,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No current plan',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Browse plans to start a new reading journey.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mutedInk,
                            ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _showPlanPicker,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Browse Plans'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.ink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_sections.isEmpty) {
      return SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadInitialState,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Center(
                    child: GestureDetector(
                      onTap: _showPlanPicker,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _plan?.title ?? 'Reading plan',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'This plan has no books in scope yet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.mutedInk,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bookSlivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CurrentPlanProgressPanel(
                overview: overview,
                planTitle: _plan?.title ?? 'Bible in a Year',
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    ];

    for (var index = 0; index < _sections.length; index += 1) {
      final section = _sections[index];
      if (section.books.isEmpty) continue;
      bookSlivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 28, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: section.title),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
      bookSlivers.addAll(
        _buildBookRows(
          sectionId: section.sectionId,
          books: section.books,
        ),
      );
    }

    bookSlivers.add(const SliverToBoxAdapter(child: SizedBox(height: 48)));

    final showCompletionBanner =
        _plan?.status == 'completion_ready' && overview?.plan.progress == 1;

    return SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadInitialState,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      showCompletionBanner ? 122 : 16,
                      20,
                      0,
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: _showPlanPicker,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _plan?.title ?? 'Bible in a Year',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ...bookSlivers,
              ],
            ),
          ),
          _CompletionBanner(
            visible: showCompletionBanner,
            planTitle: _plan?.title ?? 'Reading plan',
            totalChapters: overview?.plan.totalChapters ?? 0,
            onFinish: _finishPlan,
          ),
        ],
      ),
    );
  }

  BookProgress? _findBook({
    required List<PlanSectionProgress> sections,
    required String? sectionId,
    required String? bookKey,
  }) {
    if (sectionId == null || bookKey == null) return null;
    for (final section in sections) {
      if (section.sectionId != sectionId) continue;
      for (final book in section.books) {
        if (book.bookKey == bookKey) return book;
      }
    }
    return null;
  }
}

class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    required this.book,
    required this.chapters,
    required this.onChapterTap,
  });

  final BookProgress book;
  final List<ChapterProgressView> chapters;
  final ValueChanged<ChapterProgressView> onChapterTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChapterGrid(
            chapters: chapters,
            onChapterTap: onChapterTap,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(color: AppTheme.border),
        ),
      ],
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({
    required this.visible,
    required this.planTitle,
    required this.totalChapters,
    required this.onFinish,
  });

  final bool visible;
  final String planTitle;
  final int totalChapters;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 20,
      right: 20,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(0, -1.2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: visible ? 1 : 0,
            child: Material(
              color: Colors.white,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(3),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan complete',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You finished all $totalChapters chapters in $planTitle.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.mutedInk,
                                      height: 1.25,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: onFinish,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.ink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Finish Plan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanPickerSheet extends StatefulWidget {
  const _PlanPickerSheet({
    required this.readRepository,
    required this.currentPlans,
    required this.completedPlans,
    required this.currentPlanId,
    required this.inProgressTemplateIds,
  });

  /// Returned from this sheet when the user chooses Browse Plans.
  static const addNewSentinel = '__plan_picker_add_new__';

  final ReadRepository readRepository;
  final List<ReadingPlanSummary> currentPlans;
  final List<CompletedPlanSummary> completedPlans;
  final String? currentPlanId;
  final Set<String> inProgressTemplateIds;

  @override
  State<_PlanPickerSheet> createState() => _PlanPickerSheetState();
}

class _PlanPickerSheetState extends State<_PlanPickerSheet> {
  var _tab = _PlanPickerTab.current;

  @override
  Widget build(BuildContext context) {
    final showingCurrent = _tab == _PlanPickerTab.current;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'My Plans',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                showingCurrent
                    ? 'Switch between your current plans'
                    : 'Review completed reading plans',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedInk,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 22),
              _PlanPickerTabs(
                value: _tab,
                onChanged: (tab) => setState(() => _tab = tab),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.48,
                ),
                child: showingCurrent
                    ? _CurrentPlansList(
                        plans: widget.currentPlans,
                        currentPlanId: widget.currentPlanId,
                      )
                    : _CompletedPlansList(
                        readRepository: widget.readRepository,
                        plans: widget.completedPlans,
                        inProgressTemplateIds: widget.inProgressTemplateIds,
                      ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context, _PlanPickerSheet.addNewSentinel);
                },
                icon: const Icon(Icons.add, size: 22),
                label: const Text('Browse Plans'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.mutedInk,
                  side: BorderSide(
                    color: AppTheme.border,
                    style: BorderStyle.solid,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PlanPickerTab { current, completed }

class _PlanPickerTabs extends StatelessWidget {
  const _PlanPickerTabs({
    required this.value,
    required this.onChanged,
  });

  final _PlanPickerTab value;
  final ValueChanged<_PlanPickerTab> onChanged;

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
          _PlanPickerTabButton(
            label: 'Current',
            selected: value == _PlanPickerTab.current,
            onTap: () => onChanged(_PlanPickerTab.current),
          ),
          _PlanPickerTabButton(
            label: 'Completed',
            selected: value == _PlanPickerTab.completed,
            onTap: () => onChanged(_PlanPickerTab.completed),
          ),
        ],
      ),
    );
  }
}

class _PlanPickerTabButton extends StatelessWidget {
  const _PlanPickerTabButton({
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
          padding: const EdgeInsets.symmetric(vertical: 10),
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

class _PlanPickerEmptyState extends StatelessWidget {
  const _PlanPickerEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedInk,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _CurrentPlansList extends StatelessWidget {
  const _CurrentPlansList({
    required this.plans,
    required this.currentPlanId,
  });

  final List<ReadingPlanSummary> plans;
  final String? currentPlanId;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const _PlanPickerEmptyState(message: 'No current plans yet.');
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final summary = plans[index];
        return _PlanSummaryCard(
          summary: summary,
          isCurrent: summary.plan.id == currentPlanId,
          onTap: () => Navigator.pop(context, summary.plan.id),
        );
      },
    );
  }
}

class _CompletedPlansList extends StatelessWidget {
  const _CompletedPlansList({
    required this.readRepository,
    required this.plans,
    required this.inProgressTemplateIds,
  });

  final ReadRepository readRepository;
  final List<CompletedPlanSummary> plans;
  final Set<String> inProgressTemplateIds;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const _PlanPickerEmptyState(message: 'No completed plans yet.');
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final summary = plans[index];
        final hasActiveRun = inProgressTemplateIds.contains(summary.templateId);
        return _CompletedPlanSummaryCard(
          summary: summary,
          hasActiveRunForTemplate: hasActiveRun,
          readRepository: readRepository,
        );
      },
    );
  }
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({
    required this.summary,
    required this.isCurrent,
    required this.onTap,
  });

  final ReadingPlanSummary summary;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isCurrent ? AppTheme.ink : AppTheme.border,
            width: isCurrent ? 1.4 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          summary.plan.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.ink,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  summary.progressLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: summary.progress,
                backgroundColor: AppTheme.softSurface,
                valueColor: const AlwaysStoppedAnimation(AppTheme.ink),
              ),
            ),
            if (summary.plan.status == 'completion_ready') ...[
              const SizedBox(height: 10),
              Text(
                'All chapters read — tap Finish on Read when you are ready.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedInk,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompletedPlanSummaryCard extends StatefulWidget {
  const _CompletedPlanSummaryCard({
    required this.summary,
    required this.hasActiveRunForTemplate,
    required this.readRepository,
  });

  final CompletedPlanSummary summary;
  final bool hasActiveRunForTemplate;
  final ReadRepository readRepository;

  @override
  State<_CompletedPlanSummaryCard> createState() =>
      _CompletedPlanSummaryCardState();
}

class _CompletedPlanSummaryCardState extends State<_CompletedPlanSummaryCard> {
  var _startingAgain = false;

  Future<void> _onStartAgain(BuildContext context) async {
    final key = widget.summary.templateKey;
    if (key.isEmpty || _startingAgain) return;

    setState(() => _startingAgain = true);
    try {
      final planId = await widget.readRepository.addPlanFromTemplate(key);
      if (!context.mounted) return;
      Navigator.pop(context, planId);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start plan. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _startingAgain = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final completedAt = summary.lastCompletedAt;
    final dateLabel = completedAt == null
        ? null
        : 'Last completed ${DateFormat('MMM d, y').format(completedAt)}';
    final chaptersLabel = summary.totalChapters <= 0
        ? null
        : summary.totalChapters == 1
            ? '1 chapter'
            : '${summary.totalChapters} chapters';
    final timeLabel = summary.estimatedReadingLabel;
    final canStartAgain =
        summary.templateKey.isNotEmpty && !widget.hasActiveRunForTemplate;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            summary.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.completionLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (dateLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (chaptersLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              chaptersLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (timeLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              timeLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          if (widget.hasActiveRunForTemplate) ...[
            const SizedBox(height: 10),
            Text(
              'This plan is already in Current.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: !canStartAgain || _startingAgain
                  ? null
                  : () => _onStartAgain(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.softSurface,
                disabledForegroundColor: AppTheme.mutedInk,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: _startingAgain
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Start Again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedChip extends StatelessWidget {
  const _CompletedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentYellowLight,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label.isEmpty ? 'Completed once' : label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PlanTemplatePickerSheet extends StatelessWidget {
  const _PlanTemplatePickerSheet({required this.templates});

  final List<ReadingPlanTemplateView> templates;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 14 + bottomInset),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 96,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Browse Plans',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Browse plans and add to your list',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedInk,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 28),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.62,
                ),
                child: templates.isEmpty
                    ? const _PlanPickerEmptyState(
                        message: 'No published plans yet.',
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: templates.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final template = templates[index];
                          return _PlanCatalogCard(
                            template: template,
                            onAdd: template.isInProgress
                                ? null
                                : () => Navigator.pop(
                                    context, template.templateKey),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCatalogCard extends StatelessWidget {
  const _PlanCatalogCard({
    required this.template,
    required this.onAdd,
  });

  final ReadingPlanTemplateView template;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final minutes = template.estimatedMinutes;
    final timeLabel = minutes == null
        ? null
        : minutes >= 60
            ? 'About ${(minutes / 60).round()} hours'
            : 'About $minutes min';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.accentYellowDark,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              template.planTypeLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
          if (template.completionCount > 0) ...[
            const SizedBox(height: 12),
            _CompletedChip(label: template.completionLabel),
          ],
          const SizedBox(height: 18),
          Text(
            template.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            template.shortDescription.isNotEmpty
                ? template.shortDescription
                : template.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mutedInk,
                  fontSize: 16,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _CatalogMeta(
                icon: Icons.menu_book_outlined,
                text: '${template.totalChapters} chapters',
              ),
              if (timeLabel != null)
                _CatalogMeta(
                  icon: Icons.schedule,
                  text: timeLabel,
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: template.isInProgress
                ? OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('In Progress'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add, size: 22),
                    label: Text(
                      template.completionCount > 0 ? 'Start Again' : 'Add Plan',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CatalogMeta extends StatelessWidget {
  const _CatalogMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: AppTheme.mutedInk),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedInk,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
