import 'dart:ui' as ui show Image;

import 'package:flutter/widgets.dart';

import '../../core/ui/gestures/gesture_thresholds.dart';
import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_translation.dart';
import '../layout/smart_context_menu_horizontal_layout.dart';

/// The snapshot of the widget above the open menu.
///
/// Follows [motion] and writes to it while dragged, with resistance and up
/// to a small distance, so the preview feels attached to its place.
final class SmartContextMenuPreview extends StatefulWidget {
  final ui.Image? snapshot;
  final Size size;
  final String heroTag;
  final SmartContextMenuHorizontalLayout layout;
  final ValueNotifier<Offset> motion;
  final VoidCallback? onTap;

  /// The key of the box with the snapshot, without the padding around it.
  final GlobalKey snapshotKey;

  const SmartContextMenuPreview({
    super.key,
    required this.snapshot,
    required this.size,
    required this.heroTag,
    required this.layout,
    required this.motion,
    required this.snapshotKey,
    this.onTap,
  });

  @override
  State<SmartContextMenuPreview> createState() =>
      _SmartContextMenuPreviewState();
}

final class _SmartContextMenuPreviewState
    extends State<SmartContextMenuPreview> {
  Offset _startPosition = MotionTranslation.none.toOffset;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.motion,
      builder: (context, offset, child) {
        return TweenAnimationBuilder<Offset>(
          duration: MotionDurations.fast,
          curve: MotionCurves.entrance,
          tween: Tween<Offset>(begin: offset, end: offset),
          builder: (context, animatedOffset, child) {
            return Transform.translate(offset: animatedOffset, child: child);
          },
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: (_) => _reset(),
        onPanCancel: _reset,
        child: Padding(
          padding: widget.layout.padding,
          child: Align(
            alignment: widget.layout.alignment,
            child: SizedBox.fromSize(
              size: widget.size,
              child: KeyedSubtree(
                key: widget.snapshotKey,
                child: Hero(
                  tag: widget.heroTag,
                  child: RawImage(image: widget.snapshot, fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final Offset delta = details.localPosition - _startPosition;
    final double maxTranslation = MotionTranslation.subtle.dx;

    final double tx = (delta.dx * GestureThresholds.dragResistance).clamp(
      -maxTranslation,
      maxTranslation,
    );
    final double ty = (delta.dy * GestureThresholds.dragResistance).clamp(
      -maxTranslation,
      maxTranslation,
    );

    widget.motion.value = Offset(tx, ty);
  }

  void _reset() {
    widget.motion.value = MotionTranslation.none.toOffset;
    _startPosition = MotionTranslation.none.toOffset;
  }
}
