import 'package:flutter/material.dart' show immutable;

@immutable
abstract final class MotionDurations {
  /// 120 ms
  static const ultraFast = Duration(milliseconds: 120);
  /// 200 ms
  static const fast = Duration(milliseconds: 200);
  /// 300 ms
  static const standard = Duration(milliseconds: 300);
  /// 450 ms
  static const medium = Duration(milliseconds: 450);
  /// 600 ms
  static const slow = Duration(milliseconds: 600);
  /// 1000 ms
  static const extraSlow = Duration(seconds: 1);
  /// 100 ms
  static const delay = Duration(milliseconds: 100);
  /// 30 ms
  static const smallDelay = Duration(milliseconds: 30);
  /// 350 ms
  static const longDelay = Duration(milliseconds: 350);
}
