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
}
