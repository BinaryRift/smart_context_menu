import 'package:flutter/painting.dart';

import '../../core/ui/gestures/gesture_thresholds.dart';

/// How the preview, the menu and the header slivers line up horizontally.
///
/// They line up with the left or right edge of the widget, or center
/// under it, depending on where the widget is on the screen.
final class SmartContextMenuHorizontalLayout {
  /// [Alignment.topLeft], [Alignment.topCenter] or [Alignment.topRight].
  final Alignment alignment;

  /// Puts the edge of the content at the edge of the widget, but not
  /// closer to the screen edge than the screen padding.
  final EdgeInsets padding;

  const SmartContextMenuHorizontalLayout._(this.alignment, this.padding);

  factory SmartContextMenuHorizontalLayout({
    required Rect anchorRect,
    required double screenWidth,
    required EdgeInsets screenPadding,
  }) {
    final double centerX = anchorRect.center.dx;
    final double screenCenter = screenWidth / 2;

    if ((centerX - screenCenter).abs() < GestureThresholds.centerThreshold) {
      return const SmartContextMenuHorizontalLayout._(
        Alignment.topCenter,
        EdgeInsets.zero,
      );
    }
    if (centerX < screenCenter) {
      return SmartContextMenuHorizontalLayout._(
        Alignment.topLeft,
        EdgeInsets.only(
          left: anchorRect.left.clamp(screenPadding.left, screenWidth),
        ),
      );
    }
    return SmartContextMenuHorizontalLayout._(
      Alignment.topRight,
      EdgeInsets.only(
        right: (screenWidth - anchorRect.right).clamp(
          screenPadding.right,
          screenWidth,
        ),
      ),
    );
  }
}
