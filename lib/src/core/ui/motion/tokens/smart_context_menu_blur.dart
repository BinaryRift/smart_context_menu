import 'package:flutter/material.dart' show immutable, Offset;

@immutable
final class SmartContextMenuBlur {
  final double sigmaX;
  final double sigmaY;

  const SmartContextMenuBlur._(this.sigmaX, this.sigmaY);

  static const none = SmartContextMenuBlur._(0, 0);
  static const small = SmartContextMenuBlur._(4, 4);
  static const medium = SmartContextMenuBlur._(6, 6);
  static const strong = SmartContextMenuBlur._(8, 8);
  static const extraStrong = SmartContextMenuBlur._(20, 20);

  Offset get offset => Offset(sigmaX, sigmaY);
}