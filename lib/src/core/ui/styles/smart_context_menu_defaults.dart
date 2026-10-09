import 'package:flutter/cupertino.dart';

/// Default values of the menu: layout, radii, colors, opacities, shadows,
/// text and icons.
///
/// Most of them are defaults of [SmartContextMenuConfig],
/// [SmartContextMenuStyle] and item fields. The rest, such
/// as the opacities, are fixed. All are public, so custom
/// content, for example from [SmartContextMenuContentItem.customBuilder], can match
/// the default look.
///
/// Colors are [CupertinoDynamicColor]s with light and dark variants.
/// Resolve them with [CupertinoDynamicColor.resolve] before use.
abstract final class SmartContextMenuDefaults {
  // Layout

  /// The default of [SmartContextMenuConfig.menuWidth].
  static const double menuWidth = 280;

  /// The default of [SmartContextMenuConfig.menuHeightFactor].
  static const double menuHeightFactor = 0.6;

  /// The default of [SmartContextMenuConfig.screenPadding].
  static const EdgeInsets screenPadding = EdgeInsets.all(16);

  /// The default of [SmartContextMenuConfig.menuGap].
  static const double menuGap = 12;

  /// The default of [SmartContextMenuStyle.itemChildrenGap].
  static const double itemChildrenGap = 12;

  /// The default of [SmartContextMenuStyle.itemPadding].
  static const EdgeInsets itemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// The default of [SmartContextMenuStyle.loaderVerticalPadding].
  static const double loaderVerticalPadding = 12;

  /// The radius of the activity indicator of a loading submenu or page
  /// without [SmartContextMenuStyle.loadingIndicator].
  static const double loaderIndicatorRadius = 12;

  /// The default of [SmartContextMenuStyle.defaultIconSize].
  static const double iconSize = 20;

  // Loading

  /// How long [SmartContextMenuItem.async] waits for its item,
  /// [SmartContextMenuItem.asyncSubmenu] for its items and
  /// [SmartContextMenuItem.pagingSubmenu] for each page.
  static const Duration loadingTimeout = Duration(seconds: 10);

  /// The default of [SmartContextMenuPagingMetadata.limit].
  static const int pageLimit = 20;

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

  /// The color of the title and icons of an enabled item that is not
  /// tinted, used when [SmartContextMenuStyle.titleStyle] has no color.
  static const CupertinoDynamicColor foregroundColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFF000000),
        darkColor: Color(0xFFFAFAFA),
      );

  /// The default of [SmartContextMenuStyle.disabledForegroundColor].
  static const CupertinoDynamicColor disabledForegroundColor =
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

  /// The default of [SmartContextMenuStyle.dividerThickness].
  static const double dividerThickness = 0.5;

  /// The default of [SmartContextMenuStyle.separatorHeight].
  static const double separatorHeight = 8;

  /// The default of [SmartContextMenuStyle.separatorColor].
  ///
  /// The colors of [dividerColor] at 40% opacity.
  static const CupertinoDynamicColor separatorColor =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x669E9E9E),
        darkColor: Color(0x66545458),
      );

  // Opacities

  /// The background opacity of a tinted item in the light theme, see
  /// [SmartContextMenuContentItem.tintColor] and
  /// [SmartContextMenuContentItem.isDestructive].
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
  static const double tintDisabledForegroundOpacity = 0.5;

  /// The opacity of the title color in the press highlight of an item
  /// in the light theme, used when [SmartContextMenuStyle.highlightColor]
  /// is null.
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

  /// The shadow under the menu, the default of
  /// [SmartContextMenuStyle.menuShadows].
  static const List<BoxShadow> menuShadows = [
    // Main soft shadow.
    BoxShadow(
      color: Color(0x42000000),
      blurRadius: 30,
      offset: Offset(0, 15),
      spreadRadius: -5,
    ),
    // Thin shadow for crisp edges.
    BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 5)),
  ];

  // Text

  /// The default of [SmartContextMenuStyle.titleStyle].
  ///
  /// Has no color, so [foregroundColor] is used.
  static const TextStyle titleStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  /// The default of [SmartContextMenuStyle.backButtonTitleStyle]: bold.
  static const TextStyle backButtonTitleStyle = TextStyle(
    fontWeight: FontWeight.w600,
  );

  /// The default of [SmartContextMenuStyle.titleMaxLines].
  static const int titleMaxLines = 2;

  /// The default of [SmartContextMenuStyle.statusTitleAlign].
  static const TextAlign statusTitleAlign = TextAlign.center;

  // Icons

  /// The default of [SmartContextMenuStyle.submenuIcon].
  static const IconData submenuIcon = CupertinoIcons.chevron_forward;

  /// The default of [SmartContextMenuStyle.backIcon].
  static const IconData backIcon = CupertinoIcons.chevron_back;

  /// The default of [SmartContextMenuStyle.errorIcon].
  static const IconData errorIcon = CupertinoIcons.exclamationmark_triangle;

  /// The default of [SmartContextMenuStyle.retryIcon].
  static const IconData retryIcon = CupertinoIcons.refresh;

  /// The default of [SmartContextMenuStyle.emptyIcon].
  static const IconData emptyIcon = CupertinoIcons.tray;
}
