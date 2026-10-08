import 'package:flutter/widgets.dart' show Color;
import 'package:meta/meta.dart' show internal;

/// The current state of an item, passed to its builders.
///
/// Received by [SmartContextMenuItem.customBuilder] and
/// [SmartContextMenuItem.errorBuilder]. Created by the menu.
final class SmartContextMenuItemState {
  /// Whether the finger is over the item and releasing it will tap the item.
  ///
  /// Always false for disabled and loading items.
  final bool isPressed;

  /// Whether the item is disabled, see [SmartContextMenuItem.isDisabled].
  final bool isDisabled;

  /// Whether the item is destructive, see [SmartContextMenuItem.isDestructive].
  final bool isDestructive;

  /// The color of the title and icons for the current state, resolved for
  /// the current theme.
  ///
  /// Depends on [isDisabled], [isDestructive],
  /// [SmartContextMenuItem.tintColor], the color of
  /// [SmartContextMenuItem.titleStyle] and [SmartContextMenuStyle].
  final Color foregroundColor;

  /// Creates an item state. Used by the menu.
  @internal
  const SmartContextMenuItemState({
    required this.isPressed,
    required this.isDisabled,
    required this.isDestructive,
    required this.foregroundColor,
  });
}
