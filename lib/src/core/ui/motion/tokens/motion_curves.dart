import 'package:flutter/material.dart' show immutable, Curves;

@immutable
abstract final class MotionCurves {
  static const standard = Curves.easeInOut;
  static const emphasized = Curves.easeInOutCubic;
  static const entrance = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const quartOut = Curves.easeOutQuart;
  static const quartIn = Curves.easeInQuart;
  static const lightSpring = Curves.easeOutBack;
  static const slow = Curves.fastOutSlowIn;
}
