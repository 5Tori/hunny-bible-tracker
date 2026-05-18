import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../domain/read_models.dart';
import 'chapter_grid.dart';

/// Soft accordion panel under a book row: [AnimatedSize] open/close + chapter grid.
class BookChapterExpansion extends StatelessWidget {
  const BookChapterExpansion({
    super.key,
    required this.isExpanded,
    required this.expansionKey,
    required this.chapters,
    required this.onChapterTap,
    required this.animateEntrance,
    this.isLoading = false,
    this.onEntranceComplete,
  });

  final bool isExpanded;
  final String expansionKey;
  final List<ChapterProgressView> chapters;
  final ValueChanged<ChapterProgressView> onChapterTap;
  final bool animateEntrance;
  final bool isLoading;
  final VoidCallback? onEntranceComplete;

  static const _openDuration = Duration(milliseconds: 200);
  static const _closeDuration = Duration(milliseconds: 140);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: _openDuration,
      reverseDuration: _closeDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: isExpanded
          ? _ExpandedPanel(
              key: ValueKey(expansionKey),
              expansionKey: expansionKey,
              chapters: chapters,
              onChapterTap: onChapterTap,
              animateEntrance: animateEntrance,
              isLoading: isLoading,
              onEntranceComplete: onEntranceComplete,
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

class _ExpandedPanel extends StatefulWidget {
  const _ExpandedPanel({
    super.key,
    required this.expansionKey,
    required this.chapters,
    required this.onChapterTap,
    required this.animateEntrance,
    required this.isLoading,
    this.onEntranceComplete,
  });

  final String expansionKey;
  final List<ChapterProgressView> chapters;
  final ValueChanged<ChapterProgressView> onChapterTap;
  final bool animateEntrance;
  final bool isLoading;
  final VoidCallback? onEntranceComplete;

  @override
  State<_ExpandedPanel> createState() => _ExpandedPanelState();
}

class _ExpandedPanelState extends State<_ExpandedPanel> {
  @override
  void initState() {
    super.initState();
    if (widget.animateEntrance) {
      _scheduleEntranceComplete();
    }
  }

  @override
  void didUpdateWidget(covariant _ExpandedPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateEntrance && !oldWidget.animateEntrance) {
      _scheduleEntranceComplete();
    }
  }

  void _scheduleEntranceComplete() {
    final callback = widget.onEntranceComplete;
    if (callback == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final maxDelay = widget.chapters.length * 8 + 140;
      Future<void>.delayed(Duration(milliseconds: maxDelay), () {
        if (mounted) callback();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.isLoading && widget.chapters.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        : ChapterGrid(
            chapters: widget.chapters,
            onChapterTap: widget.onChapterTap,
            animateEntrance: widget.animateEntrance,
          );

    // Horizontal inset comes from the book row parent (20px); keep vertical gap only.
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: content
          .animate(key: ValueKey('panel-${widget.expansionKey}'))
          .fadeIn(duration: 150.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.05,
            end: 0,
            duration: 150.ms,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
