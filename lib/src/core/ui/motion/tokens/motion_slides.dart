import 'package:flutter/material.dart' show immutable, Offset;

@immutable
/// Fractional values
final class MotionSlide {
  final double dx;
  final double dy;

  const MotionSlide._(this.dx, this.dy);

  static const none = MotionSlide._(0, 0);
  static const rightHalf = MotionSlide._(0.5, 0);
  static const leftHalf = MotionSlide._(-0.5, 0);
  static const right = MotionSlide._(1, 0);

  Offset get offset => Offset(dx, dy);
}
