import 'package:flutter/widgets.dart' show EdgeInsets;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_activation_mode.dart';
import 'smart_context_menu_labels.dart';
import 'smart_context_menu_style.dart';

/// The behavior and appearance of a [SmartContextMenu].
///
/// Every field has a default, so set only what you need. Create the config
/// once, for example as a `const`, and reuse it to keep all menus in the app
/// consistent. The appearance is set by [style].
///
/// ```dart
/// const menuConfig = SmartContextMenuConfig(
///   menuWidth: 250,
///   labels: SmartContextMenuLabels(retry: 'Retry'),
///   style: SmartContextMenuStyle(menuBlur: SmartContextMenuBlur.small),
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
      style: style ?? this.style,
    );
  }
}
