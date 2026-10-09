part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuContentItem] that runs [onTap] when tapped.
///
/// Create it with [SmartContextMenuItem.simple].
final class SmartContextMenuSimpleItem extends SmartContextMenuContentItem
    implements SmartContextMenuListenableResult {
  /// Called when the item is tapped.
  ///
  /// If [closeOnTap] is true, the menu starts closing first.
  final FutureOr<void> Function()? onTap;

  /// Whether the menu closes when the item is tapped.
  ///
  /// The menu starts closing before [onTap] is called. Defaults to true.
  final bool closeOnTap;

  /// The metadata of the next page, on the last item of a page loaded by
  /// a [SmartContextMenuPageLoader].
  ///
  /// Null there marks the last page, see [SmartContextMenuItem.pagingSubmenu].
  final SmartContextMenuPagingMetadata? pagingMetadata;

  const SmartContextMenuSimpleItem._({
    required super.id,
    required super.title,
    required super.titleStyle,
    required super.leading,
    required super.trailing,
    required super.isDestructive,
    required super.tintColor,
    required super.isDisabled,
    required super.customBuilder,
    required super.padding,
    required super.childrenGap,
    required this.onTap,
    required this.closeOnTap,
    required this.pagingMetadata,
  }) : super._();
}
