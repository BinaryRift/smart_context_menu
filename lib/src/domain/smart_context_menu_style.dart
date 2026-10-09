import 'package:flutter/widgets.dart'
    show
        BorderRadiusGeometry,
        BoxShadow,
        Color,
        Decoration,
        EdgeInsets,
        IconData,
        TextStyle;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_blur.dart';

/// The appearance of a [SmartContextMenu]: colors, blurs, radii, text
/// and icons.
///
/// Set it as [SmartContextMenuConfig.style], in a [SmartContextMenuTheme]
/// or for one menu. Every field has a default, so set only what you need.
///
/// Colors may be [CupertinoDynamicColor]s, which are resolved for the
/// current theme brightness. A plain [Color] is used as is in both themes.
///
/// ```dart
/// const menuConfig = SmartContextMenuConfig(
///   style: SmartContextMenuStyle(
///     menuBlur: SmartContextMenuBlur.small,
///     titleStyle: TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
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
  /// Applied to the default decoration, [menuShadows] and [menuBlur].
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

  /// The shadows under the menu.
  ///
  /// Drawn with a custom [menuDecoration] too. Pass an empty list to remove
  /// them. Defaults to [SmartContextMenuDefaults.menuShadows].
  final List<BoxShadow> menuShadows;

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
  /// If null, the title uses the color of [titleStyle] and the icon uses
  /// [defaultIconColor].
  final Color? backButtonColor;

  /// The style of the back item title, merged over [titleStyle].
  ///
  /// [backButtonColor] takes precedence over its color.
  /// Defaults to [SmartContextMenuDefaults.backButtonTitleStyle].
  final TextStyle backButtonTitleStyle;

  // Items

  /// The padding around the content of items without their own
  /// [SmartContextMenuItem.padding].
  ///
  /// Also used by the back and retry items.
  /// Defaults to [SmartContextMenuDefaults.itemPadding].
  final EdgeInsets itemPadding;

  /// The gap between the parts of items without their own
  /// [SmartContextMenuItem.childrenGap].
  ///
  /// Also used by the back and retry items.
  /// Defaults to [SmartContextMenuDefaults.itemChildrenGap].
  final double itemChildrenGap;

  /// The base style of item titles.
  ///
  /// Used for items without [SmartContextMenuItem.titleStyle] and for the
  /// retry and loading items. The back item merges [backButtonTitleStyle]
  /// over it. Its color is used only while an item is
  /// enabled, not destructive and has no [SmartContextMenuItem.tintColor],
  /// and also tints the press highlight unless [highlightColor] is set.
  /// If the style has no color, [SmartContextMenuDefaults.foregroundColor] is used.
  /// Defaults to [SmartContextMenuDefaults.titleStyle].
  final TextStyle titleStyle;

  /// The maximum number of lines of an item title.
  ///
  /// Longer titles are truncated with an ellipsis.
  /// Defaults to [SmartContextMenuDefaults.titleMaxLines].
  final int titleMaxLines;

  /// The color of the title, icons and submenu chevron of a disabled item.
  ///
  /// Defaults to [SmartContextMenuDefaults.disabledForegroundColor].
  final Color disabledForegroundColor;

  /// The color of the title, icons and background tint of a destructive
  /// item.
  ///
  /// [SmartContextMenuItem.tintColor] takes precedence over it.
  /// Defaults to [SmartContextMenuDefaults.destructiveColor].
  final Color destructiveColor;

  /// The background of a disabled item, including a tinted one.
  ///
  /// If null, which is the default, disabled items have no background.
  final Color? disabledBackgroundColor;

  /// The background of a pressed item, including the back item.
  ///
  /// Tinted and destructive items keep their own pressed tint. If null,
  /// which is the default, the color of [titleStyle] is used with
  /// [SmartContextMenuDefaults.highlightOpacity] in the light theme and
  /// [SmartContextMenuDefaults.darkHighlightOpacity] in the dark one.
  final Color? highlightColor;

  /// The color of the dividers, see [dividersBetweenItems].
  ///
  /// Defaults to [SmartContextMenuDefaults.dividerColor].
  final Color dividerColor;

  /// The thickness of the divider, which is also the space it takes.
  ///
  /// Defaults to [SmartContextMenuDefaults.dividerThickness].
  final double dividerThickness;

  /// The empty space before the divider, on the left in left-to-right text.
  ///
  /// Defaults to 0.
  final double dividerIndent;

  /// The empty space after the divider, on the right in left-to-right text.
  ///
  /// Defaults to 0.
  final double dividerEndIndent;

  /// Whether to draw a divider between every two adjacent items, as in iOS.
  ///
  /// No divider is drawn next to a [SmartContextMenuItem.separator]. The back
  /// item of a submenu always has a divider below it. Defaults to false.
  final bool dividersBetweenItems;

  /// The height of a [SmartContextMenuItem.separator] without a child.
  ///
  /// Defaults to [SmartContextMenuDefaults.separatorHeight].
  final double separatorHeight;

  /// The color of a [SmartContextMenuItem.separator] without a child.
  ///
  /// Defaults to [SmartContextMenuDefaults.separatorColor].
  final Color separatorColor;

  // Icons

  /// The size of the icons drawn by the menu itself: the submenu chevron,
  /// the back icon and the error, retry and empty icons.
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
    this.menuShadows = SmartContextMenuDefaults.menuShadows,
    this.backgroundColor = SmartContextMenuDefaults.backgroundColor,
    this.backgroundBlur = SmartContextMenuBlur.medium,
    this.backButtonBlur = SmartContextMenuBlur.strong,
    this.backButtonBorderRadius =
        SmartContextMenuDefaults.backButtonBorderRadius,
    this.backButtonColor,
    this.backButtonTitleStyle = SmartContextMenuDefaults.backButtonTitleStyle,
    this.itemPadding = SmartContextMenuDefaults.itemPadding,
    this.itemChildrenGap = SmartContextMenuDefaults.itemChildrenGap,
    this.titleStyle = SmartContextMenuDefaults.titleStyle,
    this.titleMaxLines = SmartContextMenuDefaults.titleMaxLines,
    this.disabledForegroundColor =
        SmartContextMenuDefaults.disabledForegroundColor,
    this.destructiveColor = SmartContextMenuDefaults.destructiveColor,
    this.disabledBackgroundColor,
    this.highlightColor,
    this.dividerColor = SmartContextMenuDefaults.dividerColor,
    this.dividerThickness = SmartContextMenuDefaults.dividerThickness,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
    this.dividersBetweenItems = false,
    this.separatorHeight = SmartContextMenuDefaults.separatorHeight,
    this.separatorColor = SmartContextMenuDefaults.separatorColor,
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
    List<BoxShadow>? menuShadows,
    Color? backgroundColor,
    SmartContextMenuBlur? backgroundBlur,
    SmartContextMenuBlur? backButtonBlur,
    BorderRadiusGeometry? backButtonBorderRadius,
    Color? backButtonColor,
    TextStyle? backButtonTitleStyle,
    EdgeInsets? itemPadding,
    double? itemChildrenGap,
    TextStyle? titleStyle,
    int? titleMaxLines,
    Color? disabledForegroundColor,
    Color? destructiveColor,
    Color? disabledBackgroundColor,
    Color? highlightColor,
    Color? dividerColor,
    double? dividerThickness,
    double? dividerIndent,
    double? dividerEndIndent,
    bool? dividersBetweenItems,
    double? separatorHeight,
    Color? separatorColor,
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
      menuShadows: menuShadows ?? this.menuShadows,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      backButtonBlur: backButtonBlur ?? this.backButtonBlur,
      backButtonBorderRadius:
          backButtonBorderRadius ?? this.backButtonBorderRadius,
      backButtonColor: backButtonColor ?? this.backButtonColor,
      backButtonTitleStyle: backButtonTitleStyle ?? this.backButtonTitleStyle,
      itemPadding: itemPadding ?? this.itemPadding,
      itemChildrenGap: itemChildrenGap ?? this.itemChildrenGap,
      titleStyle: titleStyle ?? this.titleStyle,
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      destructiveColor: destructiveColor ?? this.destructiveColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      highlightColor: highlightColor ?? this.highlightColor,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      dividerIndent: dividerIndent ?? this.dividerIndent,
      dividerEndIndent: dividerEndIndent ?? this.dividerEndIndent,
      dividersBetweenItems: dividersBetweenItems ?? this.dividersBetweenItems,
      separatorHeight: separatorHeight ?? this.separatorHeight,
      separatorColor: separatorColor ?? this.separatorColor,
      defaultIconSize: defaultIconSize ?? this.defaultIconSize,
      defaultIconColor: defaultIconColor ?? this.defaultIconColor,
      submenuIcon: submenuIcon ?? this.submenuIcon,
      backIcon: backIcon ?? this.backIcon,
      loaderVerticalPadding:
          loaderVerticalPadding ?? this.loaderVerticalPadding,
    );
  }
}
