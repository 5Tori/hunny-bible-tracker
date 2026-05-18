import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/bible/bible_com.dart';
import '../../core/theme/app_theme.dart';
import '../plans/plans_screen.dart';
import 'data/read_repository.dart';
import 'domain/read_models.dart';
import 'widgets/book_card.dart';
import 'widgets/book_chapter_expansion.dart';
import 'widgets/current_plan_progress_panel.dart';
import 'widgets/plan_completion_celebration.dart';
import 'widgets/section_header.dart';

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
  bool _loadingChapters = false;
  String? _chapterEntranceKey;
  BibleComVersion _bibleVersion = BibleComVersion.defaultVersion;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    setState(() => _loading = true);
    final bibleVersion = await widget.readRepository.getBibleComVersion();
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
        _bibleVersion = bibleVersion;
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
        _bibleVersion = bibleVersion;
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
      _bibleVersion = bibleVersion;
      _loading = false;
    });
  }

  Uri? _sectionOnlineReadUrl(PlanSectionProgress section) {
    final bookKey = section.firstChapterBookKey;
    final chapter = section.firstChapterNumber;
    if (bookKey == null || chapter == null) return null;
    return BibleCom.chapterUrl(
      version: _bibleVersion,
      bookKey: bookKey,
      chapter: chapter,
    );
  }

  Future<void> _openSectionOnline(PlanSectionProgress section) async {
    final url = _sectionOnlineReadUrl(section);
    if (url == null) return;
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Bible.com')),
      );
    }
  }

  Future<void> _selectBook(BookProgress book) async {
    final plan = _plan;
    if (plan == null) return;

    final isSameBook = _selectedSectionId == book.sectionId &&
        _selectedBookKey == book.bookKey;
    if (isSameBook) {
      setState(() {
        _selectedSectionId = null;
        _selectedBookKey = null;
        _chapters = const [];
        _chapterEntranceKey = null;
        _loadingChapters = false;
      });
      return;
    }

    setState(() {
      _selectedSectionId = book.sectionId;
      _selectedBookKey = book.bookKey;
      _chapters = const [];
      _chapterEntranceKey = null;
      _loadingChapters = true;
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
    setState(() {
      _chapters = chapters;
      _loadingChapters = false;
      _chapterEntranceKey = '${book.sectionId}|${book.bookKey}';
    });
  }

  void _clearChapterEntrance() {
    if (_chapterEntranceKey == null) return;
    setState(() => _chapterEntranceKey = null);
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

    final planTitle = plan.title;
    final totalChapters = _readingOverview?.plan.totalChapters ?? 0;

    await widget.readRepository.finishPlan(plan.id);
    if (!mounted) return;

    final currentPlans =
        await widget.readRepository.getCurrentPlanSummaries();
    if (!mounted) return;

    final outcome = await showPlanCompletionCelebration(
      context: context,
      planTitle: planTitle,
      totalChapters: totalChapters,
      currentPlans: currentPlans,
    );
    if (!mounted) return;

    switch (outcome.action) {
      case PlanCompletionCelebrationAction.continuePlan:
        final planId = outcome.planId;
        if (planId != null && planId.isNotEmpty) {
          await widget.readRepository.switchToPlan(planId);
        }
        break;
      case PlanCompletionCelebrationAction.browseAll:
        await _loadInitialState();
        if (!mounted) return;
        await _openPlansScreen(PlansInitialTab.catalog);
        return;
      case PlanCompletionCelebrationAction.dismissed:
        break;
    }

    await _loadInitialState();
  }

  Future<void> _showPlanPicker() async {
    final currentPlans = await widget.readRepository.getCurrentPlanSummaries();
    if (!mounted) return;

    final selected = await showModalBottomSheet<_PlanPickerSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _PlanPickerSheet(
        currentPlans: currentPlans,
        currentPlanId: _plan?.id,
      ),
    );

    if (!mounted || selected == null) return;

    switch (selected.action) {
      case _PlanPickerAction.switchPlan:
        final planId = selected.planId;
        if (planId == null || planId == _plan?.id) return;
        await widget.readRepository.switchToPlan(planId);
        await _loadInitialState();
        return;
      case _PlanPickerAction.browsePlans:
        await _openPlansScreen(PlansInitialTab.catalog);
        return;
      case _PlanPickerAction.managePlans:
        await _openPlansScreen(PlansInitialTab.myPlans);
        return;
    }
  }

  Future<void> _openPlansScreen(PlansInitialTab initialTab) async {
    final result = await Navigator.of(context).push<PlansScreenPopResult>(
      MaterialPageRoute(
        builder: (context) => PlansScreen(
          readRepository: widget.readRepository,
          initialTab: initialTab,
        ),
      ),
    );
    if (!mounted) return;
    if (result?.shouldRefreshRead == true) {
      await _loadInitialState();
    }
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

      final selectedBook = _findBook(
        sections: _sections,
        sectionId: sectionId,
        bookKey: _selectedBookKey,
      );
      final isExpanded = selectedBook != null &&
          rowBooks.any(
            (book) =>
                book.sectionId == _selectedSectionId &&
                book.bookKey == _selectedBookKey,
          );
      final expansionKey = selectedBook != null
          ? '${selectedBook.sectionId}|${selectedBook.bookKey}'
          : '';

      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, row == 0 ? 0 : spacing, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: spacing),
                      Expanded(
                        child: i < rowBooks.length
                            ? AspectRatio(
                                aspectRatio: 0.96,
                                child: BookCard(
                                  book: rowBooks[i],
                                  isSelected: rowBooks[i].sectionId ==
                                          _selectedSectionId &&
                                      rowBooks[i].bookKey == _selectedBookKey,
                                  onTap: () => _selectBook(rowBooks[i]),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ],
                ),
                BookChapterExpansion(
                  isExpanded: isExpanded,
                  expansionKey: expansionKey,
                  chapters: isExpanded ? _chapters : const [],
                  onChapterTap: _toggleChapter,
                  animateEntrance:
                      isExpanded && _chapterEntranceKey == expansionKey,
                  isLoading: isExpanded && _loadingChapters,
                  onEntranceComplete: _clearChapterEntrance,
                ),
              ],
            ),
          ),
        ),
      );
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
                        onPressed: () =>
                            _openPlansScreen(PlansInitialTab.catalog),
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
                SectionHeader(
                  title: section.title,
                  description: section.description,
                  onlineReadUrl: _sectionOnlineReadUrl(section),
                  onReadOnline: () => _openSectionOnline(section),
                ),
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  dismissOpenSectionDescription();
                }
                return false;
              },
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
    required this.currentPlans,
    required this.currentPlanId,
  });

  final List<ReadingPlanSummary> currentPlans;
  final String? currentPlanId;

  @override
  State<_PlanPickerSheet> createState() => _PlanPickerSheetState();
}

class _PlanPickerSheetState extends State<_PlanPickerSheet> {
  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.48,
                ),
                child: _CurrentPlansList(
                  plans: widget.currentPlans,
                  currentPlanId: widget.currentPlanId,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    const _PlanPickerSelection.browsePlans(),
                  );
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
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    const _PlanPickerSelection.managePlans(),
                  );
                },
                icon: const Icon(Icons.tune, size: 20),
                label: const Text('Manage Plans'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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

enum _PlanPickerAction { switchPlan, browsePlans, managePlans }

class _PlanPickerSelection {
  const _PlanPickerSelection.switchPlan(this.planId)
      : action = _PlanPickerAction.switchPlan;

  const _PlanPickerSelection.browsePlans()
      : action = _PlanPickerAction.browsePlans,
        planId = null;

  const _PlanPickerSelection.managePlans()
      : action = _PlanPickerAction.managePlans,
        planId = null;

  final _PlanPickerAction action;
  final String? planId;
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
          onTap: () => Navigator.pop(
            context,
            _PlanPickerSelection.switchPlan(summary.plan.id),
          ),
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
