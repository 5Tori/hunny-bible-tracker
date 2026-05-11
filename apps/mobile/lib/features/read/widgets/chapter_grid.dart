import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/read_models.dart';

class ChapterGrid extends StatelessWidget {
  const ChapterGrid({
    super.key,
    required this.chapters,
    required this.onChapterTap,
  });

  final List<ChapterProgressView> chapters;
  final ValueChanged<ChapterProgressView> onChapterTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: chapters.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onChapterTap(chapter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: chapter.isCompleted ? AppTheme.accentYellow : Colors.white,
              shape: BoxShape.circle,
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
      },
    );
  }
}
