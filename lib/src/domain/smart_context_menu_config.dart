import 'package:flutter/widgets.dart'
    show BorderRadiusGeometry, Color, Decoration, EdgeInsets, TextStyle;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_activation_mode.dart';
import 'smart_context_menu_blur.dart';
import 'smart_context_menu_labels.dart';

/// The behavior and appearance of a [SmartContextMenu].
///
/// Every field has a default, so set only what you need. Create the config
/// once, for example as a `const`, and reuse it to keep all menus in the app
/// consistent.
///
/// Colors may be [CupertinoDynamicColor]s, which are resolved for the
/// current theme brightness. A plain [Color] is used as is in both themes.
///
/// ```dart
/// const menuConfig = SmartContextMenuConfig(
///   menuWidth: 250,
///   menuBlur: SmartContextMenuBlur.small,
///   labels: SmartContextMenuLabels(retry: 'Retry'),
/// );
///
/// SmartContextMenu(
///   config: menuConfig,
///   items: items,
///   child: child,
/// )
/// ```
final class SmartContextMenuConfig {
  /// The strings shown by the menu itself.
  final SmartContextMenuLabels labels;

  /// Whether to play haptic feedback.
  ///
  /// Feedback plays when the menu opens on long press, an item is
  /// highlighted or tapped, and a submenu opens or closes.
  /// Defaults to true.
  final bool enableHaptics;

  /// Whether swiping back returns from a submenu.
  ///
  /// Not implemented yet and has no effect. Defaults to true.
  final bool enableSwipeBack;

  /// Whether tapping outside the menu and its preview closes the menu.
  ///
  /// Defaults to true.
  final bool barrierDismissible;

  /// How the menu opens.
  ///
  /// With [SmartContextMenuActivationMode.manual], the menu opens only via
  /// [SmartContextMenu.controller], which is then required.
  /// Defaults to [SmartContextMenuActivationMode.longPress].
  final SmartContextMenuActivationMode activationMode;

  /// The width of the menu.
  ///
  /// Defaults to 280.
  final double menuWidth;

  /// The maximum height of the menu as a fraction of the screen height.
  ///
  /// Items that do not fit are scrolled. Defaults to 0.6.
  final double menuHeightFactor;

  /// The minimum distance between the menu and the screen edges.
  ///
  /// Vertically, it is added to the safe area.
  /// Defaults to [SmartContextMenuDefaults.screenPadding].
  final EdgeInsets screenPadding;

  /// The gap between the preview and the menu.
  ///
  /// Defaults to [SmartContextMenuDefaults.menuGap].
  final double menuGap;

  /// The color that dims the screen behind the menu.
  ///
  /// Defaults to [SmartContextMenuDefaults.backgroundColor].
  final Color backgroundColor;

  /// The decoration of the menu.
  ///
  /// Replaces the default decoration built from [menuColor], [borderColor]
  /// and [borderRadius]. [menuColor] is still used for the back item of
  /// submenus.
  final Decoration? menuDecoration;

  /// The blur of the screen behind the menu.
  ///
  /// If null, the screen is not blurred.
  /// Defaults to [SmartContextMenuBlur.medium].
  final SmartContextMenuBlur? backgroundBlur;

  /// The blur behind the back item pinned to the top of a submenu.
  ///
  /// Visible when submenu items scroll under the back item. If null,
  /// they are not blurred. Defaults to [SmartContextMenuBlur.strong].
  final SmartContextMenuBlur? backButtonBlur;

  /// The blur behind the menu.
  ///
  /// If null, which is the default, the content behind the menu is not
  /// blurred.
  final SmartContextMenuBlur? menuBlur;

  /// The background color of the menu and the back item of submenus.
  ///
  /// Ignored for the menu itself when [menuDecoration] is set.
  /// Defaults to [SmartContextMenuDefaults.menuColor].
  final Color? menuColor;

  /// The color of the menu border.
  ///
  /// Ignored when [menuDecoration] is set.
  /// Defaults to [SmartContextMenuDefaults.borderColor].
  final Color? borderColor;

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

  /// The size of the icons drawn by the menu itself: the submenu chevron,
  /// the back icon and the error and retry icons.
  ///
  /// Does not affect [SmartContextMenuItem.leading] and
  /// [SmartContextMenuItem.trailing].
  /// Defaults to [SmartContextMenuDefaults.iconSize].
  final double defaultIconSize;

  /// The color of the submenu chevron and the back icon.
  ///
  /// If null, the color of the ambient [IconTheme] is used.
  final Color? defaultIconColor;

  /// The corner radius of the menu.
  ///
  /// Applied to the default decoration, the shadow and [menuBlur].
  /// Defaults to [SmartContextMenuDefaults.borderRadius].
  final BorderRadiusGeometry borderRadius;

  /// The corner radius of the back item pinned to the top of a submenu.
  ///
  /// Defaults to [SmartContextMenuDefaults.backButtonBorderRadius].
  final BorderRadiusGeometry backButtonBorderRadius;

  /// Creates a menu configuration.
  const SmartContextMenuConfig({
    this.labels = const SmartContextMenuLabels(),
    this.enableHaptics = true,
    this.enableSwipeBack = true,
    this.barrierDismissible = true,
    this.activationMode = SmartContextMenuActivationMode.longPress,
    this.menuWidth = 280,
    this.menuHeightFactor = 0.6,
    this.screenPadding = SmartContextMenuDefaults.screenPadding,
    this.menuGap = SmartContextMenuDefaults.menuGap,
    this.backgroundColor = SmartContextMenuDefaults.backgroundColor,
    this.menuDecoration,
    this.backgroundBlur = SmartContextMenuBlur.medium,
    this.backButtonBlur = SmartContextMenuBlur.strong,
    this.menuBlur,
    this.menuColor,
    this.borderColor,
    this.textStyle = SmartContextMenuDefaults.textStyle,
    this.secondaryTextColor = SmartContextMenuDefaults.secondaryTextColor,
    this.destructiveColor = SmartContextMenuDefaults.destructiveColor,
    this.disabledItemColor = SmartContextMenuDefaults.disabledItemColor,
    this.dividerColor = SmartContextMenuDefaults.dividerColor,
    this.defaultIconSize = SmartContextMenuDefaults.iconSize,
    this.defaultIconColor,
    this.borderRadius = SmartContextMenuDefaults.borderRadius,
    this.backButtonBorderRadius = SmartContextMenuDefaults.backButtonBorderRadius,
  });
}
