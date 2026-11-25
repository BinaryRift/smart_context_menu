part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuItem] that shows [children] as compact cells side by
/// side in one line.
///
/// Create it with [SmartContextMenuItem.row].
final class SmartContextMenuRowItem extends SmartContextMenuItem {
  /// The cells of the row.
  ///
  /// Each cell keeps the action, the state, the colors and the id of its
  /// item. See [SmartContextMenuItem.row].
  final List<SmartContextMenuRowEntry> children;

  /// The size of the cells.
  final SmartContextMenuRowSize size;

  /// Whether vertical lines are drawn between the cells.
  ///
  /// If null, [SmartContextMenuStyle.dividersBetweenItems] is used. No line
  /// is drawn next to a [SmartContextMenuItem.separator].
  final bool? dividersBetweenChildren;

  /// Whether a horizontal drag that starts on the row returns to the parent
  /// menu.
  ///
  /// If false, the drag selects the cells under the finger instead. Has no
  /// effect without [SmartContextMenuConfig.enableSwipeBack].
  final bool enableSwipeBack;

  /// The padding around the cells.
  ///
  /// If null, [SmartContextMenuRowStyle.padding] is used.
  final EdgeInsets? padding;

  /// The gap between the cells.
  ///
  /// If null, [SmartContextMenuRowStyle.childrenGap] is used. The gap belongs
  /// to no cell: a finger over it removes the highlight.
  final double? childrenGap;

  /// The metadata of the next page, on the last item of a page loaded by
  /// a [SmartContextMenuPageLoader].
  ///
  /// Null there marks the last page, see [SmartContextMenuItem.pagingSubmenu].
  /// The metadata of the cells does not describe the next page.
  final SmartContextMenuPagingMetadata? pagingMetadata;

  const SmartContextMenuRowItem._({
    required super.id,
    required this.children,
    required this.size,
    required this.dividersBetweenChildren,
    required this.enableSwipeBack,
    required this.padding,
    required this.childrenGap,
    required this.pagingMetadata,
  }) : super._();
}
