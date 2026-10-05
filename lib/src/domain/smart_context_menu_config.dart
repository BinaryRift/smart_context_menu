import 'package:flutter/widgets.dart'
    show BorderRadiusGeometry, Color, Decoration, EdgeInsets;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import '../core/ui/motion/tokens/smart_context_menu_blur.dart';
import 'smart_context_menu_activation_mode.dart';
import 'smart_context_menu_labels.dart';

final class SmartContextMenuConfig {
  final SmartContextMenuLabels labels;
  final bool enableHaptics;
  final bool enableSwipeBack;
  final bool barrierDismissible;
  final SmartContextMenuActivationMode activationMode;
  final double maxMenuWidth;
  final double menuHeightFactor;
  final EdgeInsets screenPadding;
  final double menuGap;
  final double subMenuOffset;
  final Color backgroundColor;
  final Decoration? menuDecoration;
  final SmartContextMenuBlur? backgroundBlur;
  final SmartContextMenuBlur? backButtonBlur;
  final SmartContextMenuBlur? menuBlur;
  final Color? menuColor;
  final Color? borderColor;
  final double defaultIconSize;
  final Color? defaultIconColor;
  final BorderRadiusGeometry borderRadius;
  final BorderRadiusGeometry backButtonBorderRadius;

  const SmartContextMenuConfig({
    this.labels = const SmartContextMenuLabels(),
    this.enableHaptics = true,
    this.enableSwipeBack = true,
    this.barrierDismissible = true,
    this.activationMode = SmartContextMenuActivationMode.longPress,
    this.maxMenuWidth = 280,
    this.menuHeightFactor = 0.6,
    this.screenPadding = MenuDefaults.screenPadding,
    this.menuGap = MenuDefaults.menuGap,
    this.subMenuOffset = MenuDefaults.subMenuOffset,
    this.backgroundColor = MenuDefaults.backgroundColor,
    this.menuDecoration,
    this.backgroundBlur = SmartContextMenuBlur.medium,
    this.backButtonBlur = SmartContextMenuBlur.strong,
    this.menuBlur,
    this.menuColor,
    this.borderColor,
    this.defaultIconSize = MenuDefaults.iconSize,
    this.defaultIconColor,
    this.borderRadius = MenuDefaults.borderRadius,
    this.backButtonBorderRadius = MenuDefaults.backButtonBorderRadius,
  });
}
