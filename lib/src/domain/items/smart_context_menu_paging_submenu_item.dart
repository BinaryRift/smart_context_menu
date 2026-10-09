part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuContentItem] that opens a submenu with items loaded
/// page by page by [asyncPagingChildren].
///
/// Create it with [SmartContextMenuItem.pagingSubmenu].
final class SmartContextMenuPagingSubmenuItem
    extends SmartContextMenuContentItem {
  /// Loads one page of the submenu opened by this item.
  final SmartContextMenuPageLoader asyncPagingChildren;

  /// The metadata of the first page.
  ///
  /// The next pages are described by the last item of the previous page,
  /// see [SmartContextMenuSimpleItem.pagingMetadata].
  final SmartContextMenuPagingMetadata initialMetadata;

  /// How long each page of [asyncPagingChildren] may take before it fails.
  final Duration timeout;

  /// The item shown after the loaded items while a page is loading.
  ///
  /// If null, the submenu shows an activity indicator in the middle, see
  /// [SmartContextMenuStyle.loaderVerticalPadding].
  final SmartContextMenuLoadingItem? loading;

  /// The item shown after the loaded items when a page has failed to load.
  ///
  /// Tapping it retries loading the page. Without its own title and
  /// trailing, it shows [SmartContextMenuLabels.retry] and
  /// [SmartContextMenuStyle.retryIcon]. If null, it is a default
  /// [SmartContextMenuItem.error].
  final SmartContextMenuErrorItem? error;

  /// The item shown when the first page has no items.
  ///
  /// If null, it is a default [SmartContextMenuItem.empty].
  final SmartContextMenuEmptyItem? empty;

  const SmartContextMenuPagingSubmenuItem._({
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
    required this.asyncPagingChildren,
    required this.initialMetadata,
    required this.timeout,
    required this.loading,
    required this.error,
    required this.empty,
  }) : super._();
}
