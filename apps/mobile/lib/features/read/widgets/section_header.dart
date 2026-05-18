import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Set to `true` when the section "Read online" (Bible.com) action is ready to ship.
/// URL building and Settings → Bible version already exist; this only hides the UI.
const bool kSectionReadOnlineEnabled = false;

/// Section title row with an optional info affordance that opens a tooltip-style
/// overlay above the help button.
class SectionHeader extends StatefulWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.description,
    this.onlineReadUrl,
    this.onReadOnline,
  });

  final String title;
  final String description;
  final Uri? onlineReadUrl;
  final VoidCallback? onReadOnline;

  @override
  State<SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<SectionHeader> {
  static _SectionHeaderState? _openHeader;

  final GlobalKey _helpButtonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  bool get _hasDescription => widget.description.trim().isNotEmpty;

  @override
  void dispose() {
    _removeOverlay(notify: false);
    if (_openHeader == this) _openHeader = null;
    super.dispose();
  }

  void _toggleDescription() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _openHeader?._removeOverlay(notify: false);
    _openHeader = this;
    _showOverlay();
  }

  void _removeOverlay({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_openHeader == this) _openHeader = null;
    if (notify && mounted) setState(() {});
  }

  void _showOverlay() {
    final box = _helpButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final position = box.localToGlobal(Offset.zero);
    final buttonSize = box.size;
    const gap = 8.0;
    const maxBubbleWidth = 280.0;
    const horizontalPadding = 20.0;

    final bubbleLeft = (position.dx + buttonSize.width / 2 - maxBubbleWidth / 2)
        .clamp(horizontalPadding, screenSize.width - maxBubbleWidth - horizontalPadding);
    final bubbleBottom = screenSize.height - position.dy + gap;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: bubbleLeft,
              bottom: bubbleBottom,
              width: maxBubbleWidth,
              child: Material(
                color: Colors.transparent,
                child: _SectionDescriptionBubble(
                  description: widget.description,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() {});
  }

  bool get _showReadOnline =>
      kSectionReadOnlineEnabled &&
      widget.onlineReadUrl != null &&
      widget.onReadOnline != null;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_hasDescription) ...[
                const SizedBox(width: 6),
                _SectionHelpButton(
                  key: _helpButtonKey,
                  isOpen: _overlayEntry != null,
                  onPressed: _toggleDescription,
                ),
              ],
            ],
          ),
        ),
        if (_showReadOnline) ...[
          const SizedBox(width: 12),
          _SectionReadOnlineButton(onPressed: widget.onReadOnline!),
        ],
      ],
    );
  }
}

class _SectionReadOnlineButton extends StatelessWidget {
  const _SectionReadOnlineButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.ink,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(color: AppTheme.border),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: const Text('Read online'),
    );
  }
}

class _SectionHelpButton extends StatelessWidget {
  const _SectionHelpButton({
    super.key,
    required this.isOpen,
    required this.onPressed,
  });

  final bool isOpen;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOpen ? AppTheme.accentYellowLight : AppTheme.softSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isOpen ? AppTheme.ink : AppTheme.border,
              width: isOpen ? 1.2 : 1,
            ),
          ),
          child: Icon(
            Icons.help_outline,
            size: 14,
            color: isOpen ? AppTheme.ink : AppTheme.mutedInk,
          ),
        ),
      ),
    );
  }
}

class _SectionDescriptionBubble extends StatelessWidget {
  const _SectionDescriptionBubble({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.ink,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

/// Dismiss any open section description overlay (e.g. when the read list scrolls).
void dismissOpenSectionDescription() {
  _SectionHeaderState._openHeader?._removeOverlay();
}
