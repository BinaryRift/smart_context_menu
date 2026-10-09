part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuContentItem] that opens a submenu with items loaded
/// by [asyncChildren].
///
/// Create it with [SmartContextMenuItem.asyncSubmenu].
final class SmartContextMenuAsyncSubmenuItem
    extends SmartContextMenuContentItem {
  /// Loads the items of the submenu opened by this item.
  final SmartContextMenuSubmenuLoader asyncChildren;

  /// How long [asyncChildren] may take before it fails.
  final Duration timeout;

  /// The item shown while [asyncChildren] is loading.
  ///
  /// If null, the submenu shows an activity indicator in the middle, see
  /// [SmartContextMenuStyle.loaderVerticalPadding].
  final SmartContextMenuLoadingItem? loading;

  /// The item shown after [asyncChildren] has failed to load.
  ///
  /// Tapping it retries loading. Without its own title and trailing, it
  /// shows [SmartContextMenuLabels.retry] and
  /// [SmartContextMenuStyle.retryIcon]. If null, it is a default
  /// [SmartContextMenuItem.error].
  final SmartContextMenuErrorItem? error;

  /// The item shown when [asyncChildren] has loaded no items.
  ///
  /// If null, it is a default [SmartContextMenuItem.empty].
  final SmartContextMenuEmptyItem? empty;

  const SmartContextMenuAsyncSubmenuItem._({
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
    required this.asyncChildren,
    required this.timeout,
    required this.loading,
    required this.error,
    required this.empty,
  }) : super._();
}
