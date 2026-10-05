import 'package:flutter/cupertino.dart';

/// Default values for menu configuration: layout, radii, colors,
/// text style and icons.
///
/// Colors are [CupertinoDynamicColor]s with light and dark variants
/// and must be resolved with [CupertinoDynamicColor.resolve] before use.
abstract final class SmartContextMenuDefaults {
  // Layout

  static const EdgeInsets screenPadding = EdgeInsets.all(16);
  static const double menuGap = 12;
  static const double subMenuOffset = 12;
  static const double childrenGap = 12;
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const double loaderVerticalPadding = 12;
  static const double iconSize = 20;

  // Radii

  static const double cornerRadius = 16;

  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(cornerRadius),
  );

  static const BorderRadius backButtonBorderRadius = BorderRadius.vertical(
    top: Radius.circular(cornerRadius),
  );

  // Colors

  /// Translucent menu background, shown over the blur.
  static const CupertinoDynamicColor menuColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xB3F2F2F7),
        darkColor: Color(0xB324252A),
      );

  static const CupertinoDynamicColor borderColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFC6C6C8),
        darkColor: Color(0xFF636366),
      );

  static const CupertinoDynamicColor textColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF000000),
        darkColor: Color(0xFFFAFAFA),
      );

  /// Text and icons of disabled items, submenu chevron.
  static const CupertinoDynamicColor secondaryTextColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x993C3C43),
        darkColor: Color(0x66FFFFFF),
      );

  static const CupertinoDynamicColor destructiveColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFFF3B30),
        darkColor: Color(0xFFF85032),
      );

  /// Screen dimming behind the menu.
  static const Color backgroundColor = Color(0x42000000);

  /// Background of disabled items.
  static const Color disabledItemColor = Color(0x1F000000);

  static const Color dividerColor = Color(0x999E9E9E);

  // Shadows

  static const List<BoxShadow> menuShadows = [
    // Main soft shadow.
    BoxShadow(
      color: Color(0x42000000),
      blurRadius: 30,
      offset: Offset(0, 15),
      spreadRadius: -5,
    ),
    // Thin shadow for crisp edges.
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ];

  // Text

  static const TextStyle textStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  // Icons

  static const IconData submenuIcon = CupertinoIcons.chevron_forward;
  static const IconData backIcon = CupertinoIcons.chevron_back;
  static const IconData errorIcon = CupertinoIcons.exclamationmark_triangle;
  static const IconData retryIcon = CupertinoIcons.refresh;
}
