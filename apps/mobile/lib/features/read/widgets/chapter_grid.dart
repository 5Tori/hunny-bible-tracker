import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/read_models.dart';

class ChapterGrid extends StatelessWidget {
  const ChapterGrid({
    super.key,
    required this.chapters,
    required this.onChapterTap,
    this.animateEntrance = false,
    this.scrollTargetChapterNumber,
    this.scrollTargetKey,
  });

  final List<ChapterProgressView> chapters;
  final ValueChanged<ChapterProgressView> onChapterTap;
  final bool animateEntrance;
  final int? scrollTargetChapterNumber;
  final GlobalKey? scrollTargetKey;

  @override
  Widget build(BuildContext context) {
    if (chapters.isEmpty) {
      return const SizedBox(width: double.infinity);
    }

    return GridView.builder(
      itemCount: chapters.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        final cell = _ChapterCell(
          chapter: chapter,
          onTap: () => onChapterTap(chapter),
        );
        final isScrollTarget = scrollTargetChapterNumber != null &&
            scrollTargetChapterNumber == chapter.chapterNumber &&
            scrollTargetKey != null;
        final wrapped = isScrollTarget
            ? KeyedSubtree(key: scrollTargetKey, child: cell)
            : cell;

        if (animateEntrance) {
          return wrapped
              .animate(delay: (index * 8).ms)
              .fadeIn(
                duration: 140.ms,
                curve: Curves.easeOut,
              )
              .slideY(
                begin: 0.1,
                end: 0,
                duration: 140.ms,
                curve: Curves.easeOutCubic,
              )
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1, 1),
                duration: 140.ms,
                curve: Curves.easeOutCubic,
              );
        }

        return wrapped;
      },
    );
  }
}

class _ChapterCell extends StatelessWidget {
  const _ChapterCell({
    required this.chapter,
    required this.onTap,
  });

  final ChapterProgressView chapter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: chapter.isCompleted
              ? (chapter.completedToday
                  ? AppTheme.accentYellowLight
                  : AppTheme.accentYellowDark)
              : Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: chapter.isCompleted ? AppTheme.ink : AppTheme.border,
          ),
        ),
        child: Text(
          '${chapter.chapterNumber}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
