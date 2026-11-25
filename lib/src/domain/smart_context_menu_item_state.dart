import 'package:flutter/widgets.dart' show Color;
import 'package:meta/meta.dart' show internal;

import 'smart_context_menu_row_size.dart';

/// The current state of an item, passed to its builders.
///
/// Received by [SmartContextMenuContentItem.customBuilder]. Created by the menu.
final class SmartContextMenuItemState {
  /// Whether a finger, a stylus or a mouse button is pressed on the item,
  /// so releasing it there will tap the item.
  ///
  /// Always false for disabled and loading items.
  final bool isPressed;

  /// Whether a cursor is over the item on desktop and web, pressed or not.
  /// Hovering alone does not tap the item.
  ///
  /// Always false for disabled and loading items.
  final bool isHovered;

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

  /// The size of the cell if the item is shown in a
  /// [SmartContextMenuItem.row], or null elsewhere.
  ///
  /// Lets a custom builder fit its content to a cell, for example show only
  /// an icon in a [SmartContextMenuRowSize.small] cell.
  final SmartContextMenuRowSize? rowSize;

  /// Creates an item state. Used by the menu.
  @internal
  const SmartContextMenuItemState({
    required this.isPressed,
    required this.isHovered,
    required this.isDisabled,
    required this.isDestructive,
    required this.foregroundColor,
    this.rowSize,
  });
}
