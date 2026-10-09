import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, CupertinoTheme;
import 'package:flutter/widgets.dart';

import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_item.dart';
import '../../domain/smart_context_menu_style.dart';

/// The colors of an item, resolved for the current theme.
final class SmartContextMenuItemColors {
  /// The color of the title and icons.
  final Color foreground;

  /// The background of the item: the press highlight, the tint of
  /// a tinted or destructive item, or the background of a disabled one.
  final Color overlay;

  const SmartContextMenuItemColors._({
    required this.foreground,
    required this.overlay,
  });

  /// Resolves the colors of [item] with [style].
  ///
  /// [isPressed] is true while the finger is over the item. [isBack] gives
  /// the back item its own press highlight in the light theme.
  factory SmartContextMenuItemColors.resolve(
    BuildContext context, {
    required SmartContextMenuItem item,
    required SmartContextMenuStyle style,
    required bool isPressed,
    bool isBack = false,
  }) {
    Color resolve(Color color) => CupertinoDynamicColor.resolve(color, context);

    // The same brightness that CupertinoDynamicColor.resolve uses.
    final isDark =
        (CupertinoTheme.maybeBrightnessOf(context) ?? Brightness.light) ==
        Brightness.dark;
    final baseForeground =
        style.titleStyle.color ?? SmartContextMenuDefaults.foregroundColor;
    final tintColor =
        item.tintColor ?? (item.isDestructive ? style.destructiveColor : null);

    final Color foreground;
    if (tintColor != null) {
      foreground = resolve(tintColor).withValues(
        alpha: item.isDisabled
            ? SmartContextMenuDefaults.tintDisabledForegroundOpacity
            : 1,
      );
    } else if (item.isDisabled) {
      foreground = resolve(style.disabledForegroundColor);
    } else {
      foreground = resolve(item.titleStyle?.color ?? baseForeground);
    }

    final Color overlay;
    if (item.isDisabled) {
      final disabledBackgroundColor = style.disabledBackgroundColor;
      overlay = disabledBackgroundColor == null
          ? const Color(0x00000000)
          : resolve(disabledBackgroundColor);
    } else if (tintColor != null) {
      overlay = resolve(tintColor).withValues(
        alpha: switch ((isPressed, isDark)) {
          (true, true) => SmartContextMenuDefaults.darkTintPressedOpacity,
          (true, false) => SmartContextMenuDefaults.tintPressedOpacity,
          (false, true) => SmartContextMenuDefaults.darkTintOpacity,
          (false, false) => SmartContextMenuDefaults.tintOpacity,
        },
      );
    } else if (!isPressed) {
      overlay = const Color(0x00000000);
    } else if (style.highlightColor case final highlightColor?) {
      overlay = resolve(highlightColor);
    } else {
      overlay = resolve(baseForeground).withValues(
        alpha: isDark
            ? SmartContextMenuDefaults.darkHighlightOpacity
            : isBack
            ? SmartContextMenuDefaults.backHighlightOpacity
            : SmartContextMenuDefaults.highlightOpacity,
      );
    }

    return SmartContextMenuItemColors._(
      foreground: foreground,
      overlay: overlay,
    );
  }
}
