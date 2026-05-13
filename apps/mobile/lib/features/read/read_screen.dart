import 'package:flutter/material.dart';

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
  List<BookProgress> _books = const [];
  List<ChapterProgressView> _chapters = const [];
  ReadingOverview? _readingOverview;
  String? _selectedBookKey;
  bool _loading = true;

  BookProgress? get _selectedBook {
    final key = _selectedBookKey;
    if (key == null) return null;
    for (final book in _books) {
      if (book.bookKey == key) return book;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    setState(() => _loading = true);
    final plan = await widget.readRepository.getActivePlan();
    final books = await widget.readRepository.getBooksWithProgress(plan.id);
    if (books.isEmpty) {
      final overview = await widget.readRepository.getReadingOverview(plan.id);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _books = books;
        _selectedBookKey = null;
        _chapters = const [];
        _readingOverview = overview;
        _loading = false;
      });
      return;
    }

    var selectedBookKey = plan.lastOpenedBookKey;
    if (selectedBookKey == null ||
        !books.any((b) => b.bookKey == selectedBookKey)) {
      selectedBookKey = books.first.bookKey;
    }
    final chapters = await widget.readRepository.getChaptersForBook(
      planId: plan.id,
      bookKey: selectedBookKey,
    );
    final overview = await widget.readRepository.getReadingOverview(plan.id);

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _books = books;
      _selectedBookKey = selectedBookKey;
      _chapters = chapters;
      _readingOverview = overview;
      _loading = false;
    });
  }

  Future<void> _selectBook(BookProgress book) async {
    final plan = _plan;
    if (plan == null) return;

    setState(() {
      _selectedBookKey = book.bookKey;
      _chapters = const [];
    });

    await widget.readRepository.rememberLastOpenedBook(
      planId: plan.id,
      bookKey: book.bookKey,
    );

    final chapters = await widget.readRepository.getChaptersForBook(
      planId: plan.id,
      bookKey: book.bookKey,
    );

    if (!mounted) return;
    setState(() => _chapters = chapters);
  }

  Future<void> _toggleChapter(ChapterProgressView chapter) async {
    final plan = _plan;
    final bookKey = _selectedBookKey;
    if (plan == null || bookKey == null) return;

    await widget.readRepository.toggleChapter(
      planId: plan.id,
      bookKey: bookKey,
      chapterNumber: chapter.chapterNumber,
    );

    await _refreshAfterChange();
  }

  Future<void> _refreshAfterChange() async {
    final plan = _plan;
    final bookKey = _selectedBookKey;
    if (plan == null || bookKey == null) return;

    final books = await widget.readRepository.getBooksWithProgress(plan.id);
    final chapters = await widget.readRepository.getChaptersForBook(
      planId: plan.id,
      bookKey: bookKey,
    );
    final overview = await widget.readRepository.getReadingOverview(plan.id);

    if (!mounted) return;
    setState(() {
      _books = books;
      _chapters = chapters;
      _readingOverview = overview;
    });
  }

  Future<void> _showPlanPicker() async {
    final plans = await widget.readRepository.getAllPlans();
    if (!mounted) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _PlanPickerSheet(
        plans: plans,
        currentPlanId: _plan?.id,
      ),
    );

    if (!mounted) return;

    if (selected == _PlanPickerSheet.addNewSentinel) {
      final templates = await widget.readRepository.getPlanTemplatesForCatalog();
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
      await _loadInitialState();
      return;
    }

    if (selected == null || selected == _plan?.id) return;

    await widget.readRepository.switchToPlan(selected);
    await _loadInitialState();
  }

  List<Widget> _buildBookRows({
    required List<BookProgress> books,
    required BookProgress? selectedBook,
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

      final hasSelected = rowBooks.any((b) => b.bookKey == _selectedBookKey);
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

    final oldBooks = _books.where((book) => book.testament == 'old').toList();
    final newBooks = _books.where((book) => book.testament == 'new').toList();
    final selectedBook = _selectedBook;
    final overview = _readingOverview;

    if (_books.isEmpty) {
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

    if (oldBooks.isNotEmpty) {
      bookSlivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'Old Testament'),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
      bookSlivers.addAll(
        _buildBookRows(
          books: oldBooks,
          selectedBook:
              selectedBook?.testament == 'old' ? selectedBook : null,
        ),
      );
    }

    if (newBooks.isNotEmpty) {
      bookSlivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, oldBooks.isNotEmpty ? 28 : 0, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'New Testament'),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
      bookSlivers.addAll(
        _buildBookRows(
          books: newBooks,
          selectedBook:
              selectedBook?.testament == 'new' ? selectedBook : null,
        ),
      );
    }

    bookSlivers.add(const SliverToBoxAdapter(child: SizedBox(height: 48)));

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
    );
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

class _PlanPickerSheet extends StatelessWidget {
  const _PlanPickerSheet({
    required this.plans,
    required this.currentPlanId,
  });

  /// Returned from this sheet when the user chooses “Add new plan”.
  static const addNewSentinel = '__plan_picker_add_new__';

  final List<ReadingPlanView> plans;
  final String? currentPlanId;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final maxH = (screenH * 0.36).clamp(220.0, 320.0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reading Plans',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: maxH,
              child: ListView(
                children: [
                  ...plans.map((plan) {
                    final isCurrent = plan.id == currentPlanId;
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(
                        plan.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.check, size: 20, color: AppTheme.ink)
                          : null,
                      onTap: () => Navigator.pop(context, plan.id),
                    );
                  }),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    leading:
                        const Icon(Icons.add, size: 20, color: AppTheme.ink),
                    title: Text(
                      'Add new plan',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    onTap: () => Navigator.pop(context, addNewSentinel),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final screenH = MediaQuery.sizeOf(context).height;
    final maxH = (screenH * 0.36).clamp(220.0, 320.0);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 12, 0, 8 + bottomInset),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Choose a plan',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: maxH,
              child: ListView(
                children: [
                  for (final t in templates)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(t.title),
                      subtitle: t.description.isEmpty
                          ? null
                          : Text(
                              t.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => Navigator.pop(context, t.templateKey),
                    ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
