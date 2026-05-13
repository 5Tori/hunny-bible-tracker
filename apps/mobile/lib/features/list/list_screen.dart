import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SavedListScreen extends StatelessWidget {
  const SavedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Your bookmarked verses, notes, and content.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.softSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.bookmark_border,
                          size: 32, color: AppTheme.mutedInk),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nothing saved yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tap the bookmark icon on any verse\nor content to save it here.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
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
}
