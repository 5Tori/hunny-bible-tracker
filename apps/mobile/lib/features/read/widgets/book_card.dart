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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.softSurface : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppTheme.ink : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: SizedBox(
          height: 80, // Fixed height to prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${book.completedCount}/${book.chapterCount}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.ink,
                    ),
              ),
              const Spacer(),
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  book.shortName,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28, // Reduced font size
                        letterSpacing: -1.4,
                      ),
                ),
              ),
              const SizedBox(height: 2), // Reduced spacing
              Text(
                book.displayName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Limit to 1 line
                style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
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
