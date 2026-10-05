import 'package:flutter/material.dart' show immutable;

@immutable
final class SmartContextMenuBlur {
  final double sigmaX;
  final double sigmaY;

  /// Creates a blur with the same [sigma] on both axes.
  ///
  /// A [sigma] of 0 disables the blur.
  const SmartContextMenuBlur(double sigma)
    : assert(sigma >= 0, 'Blur sigma must not be negative.'),
      sigmaX = sigma,
      sigmaY = sigma;

  static const none = SmartContextMenuBlur(0);
  static const small = SmartContextMenuBlur(4);
  static const medium = SmartContextMenuBlur(6);
  static const strong = SmartContextMenuBlur(8);
  static const extraStrong = SmartContextMenuBlur(20);
}
