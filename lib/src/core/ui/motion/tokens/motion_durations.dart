import 'package:flutter/material.dart' show immutable;

@immutable
abstract final class MotionDurations {
  /// 30 ms
  static const instant = Duration(milliseconds: 30);
  /// 120 ms
  static const ultraFast = Duration(milliseconds: 120);
  /// 200 ms
  static const fast = Duration(milliseconds: 200);
  /// 300 ms
  static const standard = Duration(milliseconds: 300);
  /// 450 ms
  static const medium = Duration(milliseconds: 450);
}
