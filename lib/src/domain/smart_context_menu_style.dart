import 'package:flutter/widgets.dart'
    show BorderRadiusGeometry, Color, Decoration, IconData, TextStyle;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_blur.dart';

/// The appearance of a [SmartContextMenu]: colors, blurs, radii, text
/// and icons.
///
/// Set it as [SmartContextMenuConfig.style]. Every field has a default, so
/// set only what you need.
///
/// Colors may be [CupertinoDynamicColor]s, which are resolved for the
/// current theme brightness. A plain [Color] is used as is in both themes.
///
/// ```dart
/// const menuConfig = SmartContextMenuConfig(
///   style: SmartContextMenuStyle(
///     menuBlur: SmartContextMenuBlur.small,
///     textStyle: TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
///   ),
/// );
/// ```
final class SmartContextMenuStyle {
  // Menu

  /// The background color of the menu and the back item of submenus.
  ///
  /// Ignored for the menu itself when [menuDecoration] is set.
  /// Defaults to [SmartContextMenuDefaults.menuColor].
  final Color menuColor;

  /// The color of the menu border.
  ///
  /// Ignored when [menuDecoration] is set.
  /// Defaults to [SmartContextMenuDefaults.borderColor].
  final Color borderColor;

  /// The corner radius of the menu.
  ///
  /// Applied to the default decoration, the shadow and [menuBlur].
  /// Defaults to [SmartContextMenuDefaults.borderRadius].
  final BorderRadiusGeometry borderRadius;

  /// The decoration of the menu.
  ///
  /// Replaces the default decoration built from [menuColor], [borderColor]
  /// and [borderRadius]. [menuColor] is still used for the back item of
  /// submenus.
  final Decoration? menuDecoration;

  /// The blur behind the menu.
  ///
  /// If null, which is the default, the content behind the menu is not
  /// blurred.
  final SmartContextMenuBlur? menuBlur;

  // Background

  /// The color that dims the screen behind the menu.
  ///
  /// Defaults to [SmartContextMenuDefaults.backgroundColor].
  final Color backgroundColor;

  /// The blur of the screen behind the menu.
  ///
  /// If null, the screen is not blurred.
  /// Defaults to [SmartContextMenuBlur.medium].
  final SmartContextMenuBlur? backgroundBlur;

  // Back item

  /// The blur behind the back item pinned to the top of a submenu.
  ///
  /// Visible when submenu items scroll under the back item. If null,
  /// they are not blurred. Defaults to [SmartContextMenuBlur.strong].
  final SmartContextMenuBlur? backButtonBlur;

  /// The corner radius of the back item pinned to the top of a submenu.
  ///
  /// Defaults to [SmartContextMenuDefaults.backButtonBorderRadius].
  final BorderRadiusGeometry backButtonBorderRadius;

  /// The title and icon color of the back item in a submenu.
  ///
  /// If null, the title uses the color of [textStyle] and the icon uses
  /// [defaultIconColor].
  final Color? backButtonColor;

  // Items

  /// The base style of item titles.
  ///
  /// Used for items without [SmartContextMenuItem.titleStyle] and for the
  /// back, retry and loading items. Its color is used only while an item is
  /// enabled and not destructive, and also tints the press highlight. If the
  /// style has no color, [SmartContextMenuDefaults.textColor] is used.
  /// Defaults to [SmartContextMenuDefaults.textStyle].
  final TextStyle textStyle;

  /// The title and submenu chevron color of a disabled item.
  ///
  /// Defaults to [SmartContextMenuDefaults.secondaryTextColor].
  final Color secondaryTextColor;

  /// The title and press highlight color of a destructive item.
  ///
  /// Defaults to [SmartContextMenuDefaults.destructiveColor].
  final Color destructiveColor;

  /// The background of a disabled item.
  ///
  /// Defaults to [SmartContextMenuDefaults.disabledItemColor].
  final Color disabledItemColor;

  /// The color of the divider between items.
  ///
  /// Does not affect [SmartContextMenuItem.customDivider].
  /// Defaults to [SmartContextMenuDefaults.dividerColor].
  final Color dividerColor;

  // Icons

  /// The size of the icons drawn by the menu itself: the submenu chevron,
  /// the back icon and the error and retry icons.
  ///
  /// Does not affect [SmartContextMenuItem.leading] and
  /// [SmartContextMenuItem.trailing].
  /// Defaults to [SmartContextMenuDefaults.iconSize].
  final double defaultIconSize;

  /// The color of the submenu chevron and the back icon.
  ///
  /// [backButtonColor] takes precedence for the back icon. If null, the
  /// icons take the title color of their item.
  final Color? defaultIconColor;

  /// The chevron of an item that opens a submenu.
  ///
  /// Defaults to [SmartContextMenuDefaults.submenuIcon].
  final IconData submenuIcon;

  /// The icon of the back item in a submenu.
  ///
  /// Defaults to [SmartContextMenuDefaults.backIcon].
  final IconData backIcon;

  // Loader

  /// The vertical padding around the activity indicator of a loading
  /// submenu or page.
  ///
  /// Defaults to [SmartContextMenuDefaults.loaderVerticalPadding].
  final double loaderVerticalPadding;

  /// Creates a menu style.
  const SmartContextMenuStyle({
    this.menuColor = SmartContextMenuDefaults.menuColor,
    this.borderColor = SmartContextMenuDefaults.borderColor,
    this.borderRadius = SmartContextMenuDefaults.borderRadius,
    this.menuDecoration,
    this.menuBlur,
    this.backgroundColor = SmartContextMenuDefaults.backgroundColor,
    this.backgroundBlur = SmartContextMenuBlur.medium,
    this.backButtonBlur = SmartContextMenuBlur.strong,
    this.backButtonBorderRadius =
        SmartContextMenuDefaults.backButtonBorderRadius,
    this.backButtonColor,
    this.textStyle = SmartContextMenuDefaults.textStyle,
    this.secondaryTextColor = SmartContextMenuDefaults.secondaryTextColor,
    this.destructiveColor = SmartContextMenuDefaults.destructiveColor,
    this.disabledItemColor = SmartContextMenuDefaults.disabledItemColor,
    this.dividerColor = SmartContextMenuDefaults.dividerColor,
    this.defaultIconSize = SmartContextMenuDefaults.iconSize,
    this.defaultIconColor,
    this.submenuIcon = SmartContextMenuDefaults.submenuIcon,
    this.backIcon = SmartContextMenuDefaults.backIcon,
    this.loaderVerticalPadding = SmartContextMenuDefaults.loaderVerticalPadding,
  });

  /// Creates a copy of this style with the given fields replaced.
  ///
  /// Null arguments keep the current values, so nullable fields such as
  /// [menuBlur] cannot be reset to null with it.
  SmartContextMenuStyle copyWith({
    Color? menuColor,
    Color? borderColor,
    BorderRadiusGeometry? borderRadius,
    Decoration? menuDecoration,
    SmartContextMenuBlur? menuBlur,
    Color? backgroundColor,
    SmartContextMenuBlur? backgroundBlur,
    SmartContextMenuBlur? backButtonBlur,
    BorderRadiusGeometry? backButtonBorderRadius,
    Color? backButtonColor,
    TextStyle? textStyle,
    Color? secondaryTextColor,
    Color? destructiveColor,
    Color? disabledItemColor,
    Color? dividerColor,
    double? defaultIconSize,
    Color? defaultIconColor,
    IconData? submenuIcon,
    IconData? backIcon,
    double? loaderVerticalPadding,
  }) {
    return SmartContextMenuStyle(
      menuColor: menuColor ?? this.menuColor,
      borderColor: borderColor ?? this.borderColor,
      borderRadius: borderRadius ?? this.borderRadius,
      menuDecoration: menuDecoration ?? this.menuDecoration,
      menuBlur: menuBlur ?? this.menuBlur,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      backButtonBlur: backButtonBlur ?? this.backButtonBlur,
      backButtonBorderRadius:
          backButtonBorderRadius ?? this.backButtonBorderRadius,
      backButtonColor: backButtonColor ?? this.backButtonColor,
      textStyle: textStyle ?? this.textStyle,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      destructiveColor: destructiveColor ?? this.destructiveColor,
      disabledItemColor: disabledItemColor ?? this.disabledItemColor,
      dividerColor: dividerColor ?? this.dividerColor,
      defaultIconSize: defaultIconSize ?? this.defaultIconSize,
      defaultIconColor: defaultIconColor ?? this.defaultIconColor,
      submenuIcon: submenuIcon ?? this.submenuIcon,
      backIcon: backIcon ?? this.backIcon,
      loaderVerticalPadding:
          loaderVerticalPadding ?? this.loaderVerticalPadding,
    );
  }
}
