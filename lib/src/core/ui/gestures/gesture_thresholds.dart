import 'package:flutter/gestures.dart' show kTouchSlop;

/// Thresholds for recognizing gestures on the menu and the preview.
abstract final class GestureThresholds {
  /// Maximum pointer travel for a gesture to still count as a tap.
  static const double tapSlop = kTouchSlop;

  /// Tolerance for treating the anchor as horizontally centered.
  static const double centerThreshold = 6;

  /// Drag resistance of the preview: 0.05 means it moves
  /// 20 times slower than the finger.
  static const double dragResistance = 0.05;

  /// The part of the menu width a swipe back must pass to return
  /// to the parent level when released slowly.
  static const double swipeBackDistance = 0.5;

  /// The swipe speed, in menu widths per second, that returns to the
  /// parent level or cancels the swipe regardless of the distance.
  static const double swipeBackVelocity = 1;
}
