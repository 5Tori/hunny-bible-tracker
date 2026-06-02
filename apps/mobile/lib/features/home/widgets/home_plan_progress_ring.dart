import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Plan cover with circular progress ring (Home hero).
class HomePlanProgressRing extends StatelessWidget {
  const HomePlanProgressRing({
    super.key,
    required this.progress,
    required this.imageUrl,
    this.size = 240,
    this.ringWidth = 8,
  });

  final double progress;
  final String? imageUrl;
  final double size;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    final innerSize = size - (ringWidth * 2) - 10;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedProgress <= 0 ? null : clampedProgress,
              strokeWidth: ringWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: AppTheme.softSurface,
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow),
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.softSurface,
              border: Border.all(color: AppTheme.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _coverContent(innerSize),
          ),
        ],
      ),
    );
  }

  Widget _coverContent(double innerSize) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return Icon(
        Icons.menu_book_rounded,
        size: innerSize * 0.34,
        color: AppTheme.mutedInk,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: innerSize,
      height: innerSize,
      errorBuilder: (_, __, ___) => Icon(
        Icons.menu_book_rounded,
        size: innerSize * 0.34,
        color: AppTheme.mutedInk,
      ),
    );
  }
}
