import 'package:flutter/material.dart' show immutable, Curves, Interval;

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

  /// A menu level fades in over the first 60% of its entrance.
  static const levelFadeIn = Interval(0.0, 0.6, curve: Curves.easeIn);

  /// Reverse curve: a menu level fades out over the first 60% of its exit.
  static const levelFadeOut = Interval(0.4, 1.0, curve: Curves.easeOut);

  /// The menu scales in with a spring after the first 20% of opening.
  static const menuScaleIn = Interval(0.2, 1.0, curve: lightSpring);

  /// Reverse curve: the menu scales out over the first half of closing.
  static const menuScaleOut = Interval(0.5, 1.0, curve: slow);
}
