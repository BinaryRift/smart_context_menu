import 'package:flutter/material.dart' show immutable, Offset;

@immutable
/// Fractional values
final class MotionSlide {
  final double dx;
  final double dy;

  const MotionSlide._(this.dx, this.dy);

  static const none = MotionSlide._(0, 0);
  static const down = MotionSlide._(0, 1);
  static const downHalf = MotionSlide._(0, 0.5);
  static const rightHalf = MotionSlide._(0.5, 0);
  static const leftHalf = MotionSlide._(-0.5, 0);
  static const left = MotionSlide._(-1, 0);
  static const right = MotionSlide._(1, 0);
  static const up = MotionSlide._(0, -1);

  Offset get offset => Offset(dx, dy);
}
