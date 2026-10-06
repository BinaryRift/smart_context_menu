import 'package:flutter/material.dart' show immutable;

@immutable
/// Fractional values
final class MotionTranslationFactor {
  final double dx;
  final double dy;
  final double dz;

  const MotionTranslationFactor._(this.dx, this.dy, this.dz);

  static const none = MotionTranslationFactor._(0, 0, 0);
  static const full = MotionTranslationFactor._(1.0, 1.0, 1.0);
}