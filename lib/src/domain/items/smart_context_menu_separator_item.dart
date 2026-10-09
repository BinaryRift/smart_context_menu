part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuItem] that separates groups of items.
///
/// Create it with [SmartContextMenuItem.separator].
final class SmartContextMenuSeparatorItem extends SmartContextMenuItem {
  /// The content shown instead of the default band.
  final Widget? child;

  /// The metadata of the next page, on the last item of a page loaded by
  /// a [SmartContextMenuPageLoader].
  ///
  /// Null there marks the last page, see [SmartContextMenuItem.pagingSubmenu].
  final SmartContextMenuPagingMetadata? pagingMetadata;

  const SmartContextMenuSeparatorItem._({
    required super.id,
    required this.child,
    required this.pagingMetadata,
  }) : super._();
}
