import 'package:flutter/cupertino.dart';

/// Default values of the menu: layout, radii, colors, opacities, shadows,
/// text and icons.
///
/// Most of them are defaults of [SmartContextMenuConfig],
/// [SmartContextMenuStyle] and [SmartContextMenuItem] fields. The rest, such
/// as [menuShadows], [errorIcon] and the opacities, are fixed. All are
/// public, so custom content, for example from [SmartContextMenuItem.customBuilder], can match
/// the default look.
///
/// Colors are [CupertinoDynamicColor]s with light and dark variants.
/// Resolve them with [CupertinoDynamicColor.resolve] before use.
abstract final class SmartContextMenuDefaults {
  // Layout

  /// The default of [SmartContextMenuConfig.screenPadding].
  static const EdgeInsets screenPadding = EdgeInsets.all(16);

  /// The default of [SmartContextMenuConfig.menuGap].
  static const double menuGap = 12;

  /// The default of [SmartContextMenuItem.childrenGap].
  static const double childrenGap = 12;

  /// The default of [SmartContextMenuItem.padding].
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// The default of [SmartContextMenuStyle.loaderVerticalPadding].
  static const double loaderVerticalPadding = 12;

  /// The default of [SmartContextMenuStyle.defaultIconSize].
  static const double iconSize = 20;

  // Loading

  /// How long [SmartContextMenuItem.async] waits for its item.
  static const Duration loadingTimeout = Duration(seconds: 10);

  // Radii

  /// The corner radius of [borderRadius] and [backButtonBorderRadius].
  static const double cornerRadius = 16;

  /// The default of [SmartContextMenuStyle.borderRadius].
  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(cornerRadius),
  );

  /// The default of [SmartContextMenuStyle.backButtonBorderRadius].
  static const BorderRadius backButtonBorderRadius = BorderRadius.vertical(
    top: Radius.circular(cornerRadius),
  );

  // Colors

  /// The menu background, the default of [SmartContextMenuStyle.menuColor].
  ///
  /// Translucent, so [SmartContextMenuStyle.menuBlur] shows through it.
  static const CupertinoDynamicColor menuColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xB3F2F2F7),
        darkColor: Color(0xB324252A),
      );

  /// The menu border, the default of [SmartContextMenuStyle.borderColor].
  static const CupertinoDynamicColor borderColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF9D9D9F),
        darkColor: Color(0xFF636366),
      );

  /// The title of an enabled item that is not destructive, used when
  /// [SmartContextMenuStyle.textStyle] has no color.
  static const CupertinoDynamicColor textColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF000000),
        darkColor: Color(0xFFFAFAFA),
      );

  /// The default of [SmartContextMenuStyle.secondaryTextColor].
  static const CupertinoDynamicColor secondaryTextColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x993C3C43),
        darkColor: Color(0x66FFFFFF),
      );

  /// The default of [SmartContextMenuStyle.destructiveColor].
  static const CupertinoDynamicColor destructiveColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFFF3B30),
        darkColor: Color(0xFFF85032),
      );

  /// The screen dimming behind the menu, the default of
  /// [SmartContextMenuStyle.backgroundColor].
  static const CupertinoDynamicColor backgroundColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x42000000),
        darkColor: Color(0x66000000),
      );

  /// The default of [SmartContextMenuStyle.dividerColor].
  static const CupertinoDynamicColor dividerColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x999E9E9E),
        darkColor: Color(0x99545458),
      );

  // Opacities

  /// The background opacity of a tinted item in the light theme, see
  /// [SmartContextMenuItem.tintColor] and [SmartContextMenuItem.isDestructive].
  ///
  /// A tint fades on a light menu, so the light theme opacities are twice
  /// as high as the dark ones.
  static const double tintOpacity = 0.24;

  /// The background opacity of a tinted item in the dark theme.
  static const double darkTintOpacity = 0.12;

  /// The background opacity of a pressed tinted item in the light theme.
  static const double tintPressedOpacity = 0.48;

  /// The background opacity of a pressed tinted item in the dark theme.
  static const double darkTintPressedOpacity = 0.24;

  /// The title and icon opacity of a disabled tinted item.
  static const double tintDisabledTextOpacity = 0.5;

  /// The opacity of the title color in the press highlight of an item
  /// in the light theme.
  ///
  /// A dark highlight stands out more on a light menu, so it is lighter than
  /// [darkHighlightOpacity].
  static const double highlightOpacity = 0.06;

  /// The opacity of the title color in the press highlight of an item,
  /// including the back item, in the dark theme.
  static const double darkHighlightOpacity = 0.1;

  /// The opacity of the title color in the press highlight of the back item
  /// in the light theme.
  ///
  /// The back item has its own [menuColor] fill and is lighter than the menu,
  /// so its highlight is stronger than [highlightOpacity] to differ from
  /// the menu background.
  static const double backHighlightOpacity = 0.16;

  // Shadows

  /// The shadow under the menu.
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

  /// The default of [SmartContextMenuStyle.textStyle].
  ///
  /// Has no color, so [textColor] is used.
  static const TextStyle textStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  // Icons

  /// The default of [SmartContextMenuStyle.submenuIcon].
  static const IconData submenuIcon = CupertinoIcons.chevron_forward;

  /// The default of [SmartContextMenuStyle.backIcon].
  static const IconData backIcon = CupertinoIcons.chevron_back;

  /// The leading icon of a retry item shown after a failed load.
  static const IconData errorIcon = CupertinoIcons.exclamationmark_triangle;

  /// The trailing icon of a retry item shown after a failed load.
  static const IconData retryIcon = CupertinoIcons.refresh;
}
