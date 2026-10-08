import 'package:flutter/widgets.dart' show EdgeInsets;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_activation_mode.dart';
import 'smart_context_menu_labels.dart';
import 'smart_context_menu_style.dart';

/// The behavior and appearance of a [SmartContextMenu].
///
/// Every field has a default, so set only what you need. The appearance is
/// set by [style].
///
/// To use one config for all menus in the app or in a part of the tree, set
/// it with a [SmartContextMenuTheme]. Pass it to [SmartContextMenu.config]
/// to set it for one menu: it replaces the theme then.
///
/// ```dart
/// const menuConfig = SmartContextMenuConfig(
///   menuWidth: 250,
///   labels: SmartContextMenuLabels(retry: 'Retry'),
///   style: SmartContextMenuStyle(menuBlur: SmartContextMenuBlur.small),
/// );
///
/// SmartContextMenuTheme(
///   config: menuConfig,
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

  /// Whether swiping right on a submenu returns to the parent level.
  ///
  /// The submenu follows the finger and slides back in place if the swipe
  /// is short and slow. The back item works either way. Defaults to true.
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

  /// Whether the widget and the menu move back down when the menu gets
  /// shorter, for example after returning from a submenu.
  ///
  /// The widget moves up when the menu grows and does not fit below it.
  /// With this flag, it also moves back down as the menu shrinks, but never
  /// below its place and never while the widget and the menu scroll.
  /// Defaults to `false`, so the menu stays under the finger: after tapping
  /// the back item, the parent menu starts where the back item was.
  final bool moveBackDown;

  /// The appearance of the menu.
  ///
  /// Defaults to `const SmartContextMenuStyle()`.
  final SmartContextMenuStyle style;

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
    this.moveBackDown = false,
    this.style = const SmartContextMenuStyle(),
  });

  /// Creates a copy of this config with the given fields replaced.
  ///
  /// ```dart
  /// final manualConfig = menuConfig.copyWith(
  ///   activationMode: SmartContextMenuActivationMode.manual,
  /// );
  /// ```
  SmartContextMenuConfig copyWith({
    SmartContextMenuLabels? labels,
    bool? enableHaptics,
    bool? enableSwipeBack,
    bool? barrierDismissible,
    SmartContextMenuActivationMode? activationMode,
    double? menuWidth,
    double? menuHeightFactor,
    EdgeInsets? screenPadding,
    double? menuGap,
    bool? moveBackDown,
    SmartContextMenuStyle? style,
  }) {
    return SmartContextMenuConfig(
      labels: labels ?? this.labels,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      enableSwipeBack: enableSwipeBack ?? this.enableSwipeBack,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      activationMode: activationMode ?? this.activationMode,
      menuWidth: menuWidth ?? this.menuWidth,
      menuHeightFactor: menuHeightFactor ?? this.menuHeightFactor,
      screenPadding: screenPadding ?? this.screenPadding,
      menuGap: menuGap ?? this.menuGap,
      moveBackDown: moveBackDown ?? this.moveBackDown,
      style: style ?? this.style,
    );
  }
}
