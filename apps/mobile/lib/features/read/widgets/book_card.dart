import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/read_models.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.isSelected,
    required this.onTap,
  });

  final BookProgress book;
  final bool isSelected;
  final VoidCallback onTap;

  Color get _fillColor {
    Color base;
    if (book.chapterCount == 0 || book.completedCount == 0) {
      base = Colors.white;
    } else if (book.completedCount >= book.chapterCount) {
      base = AppTheme.accentYellowDark;
    } else {
      base = Color.lerp(Colors.white, AppTheme.accentYellowDark, 0.5)!;
    }

    if (!isSelected) return base;
    if (base == Colors.white) return AppTheme.softSurface;
    return Color.alphaBlend(
      AppTheme.softSurface.withValues(alpha: 0.28),
      base,
    );
  }

  Color get _borderColor {
    if (isSelected) return AppTheme.ink;
    if (book.chapterCount > 0 && book.completedCount >= book.chapterCount) {
      return AppTheme.ink;
    }
    return AppTheme.border;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _fillColor,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: _borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: SizedBox(
          height: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                '${book.completedCount}/${book.chapterCount}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.ink,
                    ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  book.shortName,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        letterSpacing: -1.4,
                      ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                book.displayName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.ink,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
