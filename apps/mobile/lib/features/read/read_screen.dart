import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'data/read_repository.dart';
import 'domain/read_models.dart';
import 'widgets/book_card.dart';
import 'widgets/chapter_grid.dart';
import 'widgets/progress_summary_card.dart';

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
  OverviewStats? _overview;
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
    final selectedBookKey = plan.lastOpenedBookKey ?? books.first.bookKey;
    final chapters = await widget.readRepository.getChaptersForBook(
      planId: plan.id,
      bookKey: selectedBookKey,
    );
    final overview = await widget.readRepository.getOverviewStats(plan.id);

    if (!mounted) return;
    setState(() {
      _plan = plan;
      _books = books;
      _selectedBookKey = selectedBookKey;
      _chapters = chapters;
      _overview = overview;
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
    final overview = await widget.readRepository.getOverviewStats(plan.id);

    if (!mounted) return;
    setState(() {
      _books = books;
      _chapters = chapters;
      _overview = overview;
    });
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

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadInitialState,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Read', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      _plan?.title ?? 'Whole Bible',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    ProgressSummaryCard(overview: _overview),
                    const SizedBox(height: 28),
                    _SectionHeader(title: 'Old Testament'),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: _BookGridSliver(
                books: oldBooks,
                selectedBookKey: _selectedBookKey,
                onSelected: _selectBook,
              ),
            ),
            if (selectedBook?.testament == 'old')
              SliverToBoxAdapter(
                child: _ChapterSection(
                  book: selectedBook!,
                  chapters: _chapters,
                  onChapterTap: _toggleChapter,
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: _BookGridSliver(
                books: newBooks,
                selectedBookKey: _selectedBookKey,
                onSelected: _selectBook,
              ),
            ),
            if (selectedBook?.testament == 'new')
              SliverToBoxAdapter(
                child: _ChapterSection(
                  book: selectedBook!,
                  chapters: _chapters,
                  onChapterTap: _toggleChapter,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
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
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '${book.completedCount}/${book.chapterCount} chapters completed',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          ChapterGrid(
            chapters: chapters,
            onChapterTap: onChapterTap,
          ),
        ],
      ),
    );
  }
}

class _BookGridSliver extends StatelessWidget {
  const _BookGridSliver({
    required this.books,
    required this.selectedBookKey,
    required this.onSelected,
  });

  final List<BookProgress> books;
  final String? selectedBookKey;
  final ValueChanged<BookProgress> onSelected;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.96,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final book = books[index];
          return BookCard(
            book: book,
            isSelected: book.bookKey == selectedBookKey,
            onTap: () => onSelected(book),
          );
        },
        childCount: books.length,
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
