part of '../smart_context_menu_item.dart';

/// An entry of [SmartContextMenuItem.row]: an item shown as a cell or
/// a [SmartContextMenuRowFlex].
///
/// Every item type is an entry except [SmartContextMenuRowItem], so a row
/// cannot contain another row.
sealed class SmartContextMenuRowEntry {}

/// Sets the share of the row width that [child] takes in
/// [SmartContextMenuItem.row].
///
/// The width of a row is divided between its cells by their [flex].
/// A cell without this wrapper has a flex of 1, so a cell with `flex: 2` is
/// twice as wide as it. The id, the action and the look stay on [child].
///
/// ```dart
/// SmartContextMenuItem.row(
///   children: [
///     SmartContextMenuItem.simple(title: 'Copy', onTap: copy),
///     SmartContextMenuRowFlex(
///       flex: 2,
///       child: SmartContextMenuItem.simple(title: 'Share', onTap: share),
///     ),
///   ],
/// )
/// ```
final class SmartContextMenuRowFlex implements SmartContextMenuRowEntry {
  /// The share of the row width that [child] takes, relative to the flex of
  /// the other cells. Must be positive.
  final int flex;

  /// The item shown in the cell.
  ///
  /// Must not be a [SmartContextMenuRowFlex] or
  /// a [SmartContextMenuSeparatorItem]: a separator has no content that
  /// needs a share of the width.
  final SmartContextMenuRowEntry child;

  /// Creates a cell of [child] that takes [flex] shares of the row width.
  const SmartContextMenuRowFlex({required this.flex, required this.child})
    : assert(flex > 0, 'The flex of a row cell must be positive.'),
      assert(
        child is! SmartContextMenuRowFlex,
        'A SmartContextMenuRowFlex cannot wrap another '
        'SmartContextMenuRowFlex. Set the flex on a single wrapper.',
      ),
      assert(
        child is! SmartContextMenuSeparatorItem,
        'A SmartContextMenuRowFlex cannot wrap a separator: a separator '
        'takes only its own width. Put the separator in the row as it is.',
      );
}
