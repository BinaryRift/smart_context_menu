import 'package:flutter/material.dart' show Offset, immutable;

@immutable
// Absolute values
final class MotionTranslation {
  final double dx;
  final double dy;
  final double dz;

  const MotionTranslation._(this.dx, this.dy, this.dz);

  static const none = MotionTranslation._(0, 0, 0);
  static const subtle = MotionTranslation._(8.0, 8.0, 8.0);

  Offset get toOffset => Offset(dx, dy);
}