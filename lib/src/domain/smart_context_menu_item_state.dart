import 'package:flutter/widgets.dart' show Color;
import 'package:meta/meta.dart' show internal;

/// The current state of an item, passed to its builders.
///
/// Received by [SmartContextMenuContentItem.customBuilder]. Created by the menu.
final class SmartContextMenuItemState {
  /// Whether the finger is over the item and releasing it will tap the item.
  ///
  /// Always false for disabled and loading items.
  final bool isPressed;

  /// Whether the item is disabled, see
  /// [SmartContextMenuContentItem.isDisabled].
  final bool isDisabled;

  /// Whether the item is destructive, see
  /// [SmartContextMenuContentItem.isDestructive].
  final bool isDestructive;

  /// The color of the title and icons for the current state, resolved for
  /// the current theme.
  ///
  /// Depends on [isDisabled], [isDestructive],
  /// [SmartContextMenuContentItem.tintColor], the color of
  /// [SmartContextMenuContentItem.titleStyle] and [SmartContextMenuStyle].
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
