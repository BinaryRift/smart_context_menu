import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../core/ui/gestures/gesture_thresholds.dart';

/// How the preview, the menu and the header slivers line up horizontally.
///
/// They line up with the left or right edge of the widget, or center
/// under it, depending on where the widget is on the screen.
final class SmartContextMenuHorizontalLayout {
  /// [Alignment.topLeft], [Alignment.topCenter] or [Alignment.topRight].
  final Alignment alignment;

  /// Puts the edge of the preview and the header slivers at the edge of
  /// the widget, but not closer to the screen edge than the screen padding.
  final EdgeInsets padding;

  /// Puts the edge of the menu at the edge of the widget, but moves it
  /// towards the middle of the screen if the menu does not fit there.
  ///
  /// Keeps the screen padding on both sides, so on a screen narrower than
  /// the menu with the padding, the menu gets narrower.
  final EdgeInsets menuPadding;

  const SmartContextMenuHorizontalLayout._(
    this.alignment,
    this.padding,
    this.menuPadding,
  );

  /// [screenPadding] is the distance to keep from the screen edges,
  /// including the system paddings.
  factory SmartContextMenuHorizontalLayout({
    required Rect anchorRect,
    required double screenWidth,
    required EdgeInsets screenPadding,
    required double menuWidth,
  }) {
    final double centerX = anchorRect.center.dx;
    final double screenCenter = screenWidth / 2;
    final double maxMenuInset = math.max(
      screenWidth - screenPadding.horizontal - menuWidth,
      0,
    );

    if ((centerX - screenCenter).abs() < GestureThresholds.centerThreshold) {
      return SmartContextMenuHorizontalLayout._(
        Alignment.topCenter,
        EdgeInsets.zero,
        EdgeInsets.only(left: screenPadding.left, right: screenPadding.right),
      );
    }
    if (centerX < screenCenter) {
      final double left = anchorRect.left.clamp(
        screenPadding.left,
        screenWidth,
      );
      return SmartContextMenuHorizontalLayout._(
        Alignment.topLeft,
        EdgeInsets.only(left: left),
        EdgeInsets.only(
          left: math.min(left, screenPadding.left + maxMenuInset),
          right: screenPadding.right,
        ),
      );
    }
    final double right = (screenWidth - anchorRect.right).clamp(
      screenPadding.right,
      screenWidth,
    );
    return SmartContextMenuHorizontalLayout._(
      Alignment.topRight,
      EdgeInsets.only(right: right),
      EdgeInsets.only(
        left: screenPadding.left,
        right: math.min(right, screenPadding.right + maxMenuInset),
      ),
    );
  }
}
