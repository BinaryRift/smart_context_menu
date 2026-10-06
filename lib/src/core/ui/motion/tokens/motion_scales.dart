import 'package:flutter/material.dart' show immutable, Offset;

@immutable
final class MotionScale {
  final double x;
  final double y;
  final double value;

  const MotionScale._(this.x, this.y, this.value);

  static const hidden = MotionScale._(0.0, 0.0, 0.0);
  static const none = MotionScale._(1.0, 1.0, 1.0);
  static const pressed = MotionScale._(0.92, 0.92, 0.92);
  static const subtle = MotionScale._(1.2, 1.2, 1.2);
  static const medium = MotionScale._(1.5, 1.5, 1.5);

  /// The maximum stretch of the menu while it is dragged.
  static const stretch = MotionScale._(1.05, 1.04, 1.0);

  Offset get offset => Offset(x, y);
}