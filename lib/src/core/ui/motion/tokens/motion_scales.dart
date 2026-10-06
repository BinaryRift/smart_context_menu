import 'package:flutter/material.dart' show immutable;

@immutable
final class MotionScale {
  final double x;
  final double y;
  final double value;

  const MotionScale._(this.x, this.y, this.value);

  static const none = MotionScale._(1.0, 1.0, 1.0);
  static const pressed = MotionScale._(0.92, 0.92, 0.92);

  /// The maximum stretch of the menu while it is dragged.
  static const stretch = MotionScale._(1.05, 1.04, 1.0);
}