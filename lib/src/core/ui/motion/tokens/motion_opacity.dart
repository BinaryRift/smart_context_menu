import 'package:flutter/material.dart' show immutable;

@immutable
final class MotionOpacity {
  final double value;

  const MotionOpacity._(this.value);

  /// 1.0
  static const visible = MotionOpacity._(1.0);
  /// 0.0
  static const hidden = MotionOpacity._(0.0);
  /// 0.25
  static const almostHidden = MotionOpacity._(0.25);
  /// 0.8
  static const almostVisible = MotionOpacity._(0.8);
  /// 0.5
  static const medium = MotionOpacity._(0.5);
}