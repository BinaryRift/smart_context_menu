import 'package:flutter/material.dart' show immutable;

/// The strength of a Gaussian blur used by the menu.
///
/// Used by [SmartContextMenuConfig.backgroundBlur],
/// [SmartContextMenuConfig.menuBlur] and
/// [SmartContextMenuConfig.backButtonBlur]. Pick a preset or create your own:
///
/// ```dart
/// const SmartContextMenuConfig(menuBlur: SmartContextMenuBlur(10))
/// ```
@immutable
final class SmartContextMenuBlur {
  /// The standard deviation of the blur along the horizontal axis.
  final double sigmaX;

  /// The standard deviation of the blur along the vertical axis.
  final double sigmaY;

  /// Creates a blur with the same [sigma] on both axes.
  ///
  /// A [sigma] of 0 disables the blur.
  const SmartContextMenuBlur(double sigma)
    : assert(sigma >= 0, 'Blur sigma must not be negative.'),
      sigmaX = sigma,
      sigmaY = sigma;

  /// No blur.
  ///
  /// To turn a blur off in [SmartContextMenuConfig], prefer null:
  /// it skips the blur filter entirely.
  static const none = SmartContextMenuBlur(0);

  /// A light blur with a sigma of 4.
  static const small = SmartContextMenuBlur(4);

  /// A moderate blur with a sigma of 6.
  static const medium = SmartContextMenuBlur(6);

  /// A strong blur with a sigma of 8.
  static const strong = SmartContextMenuBlur(8);

  /// A very strong blur with a sigma of 20.
  static const extraStrong = SmartContextMenuBlur(20);
}
