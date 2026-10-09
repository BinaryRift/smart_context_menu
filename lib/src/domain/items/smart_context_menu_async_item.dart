part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuItem] that shows a placeholder and replaces it with
/// the item loaded by [asyncItem].
///
/// Create it with [SmartContextMenuItem.async].
final class SmartContextMenuAsyncItem extends SmartContextMenuItem {
  /// Loads the item shown in place of this placeholder.
  final SmartContextMenuItemLoader asyncItem;

  /// How long [asyncItem] may take before it fails.
  final Duration timeout;

  /// The item shown while [asyncItem] is loading.
  final SmartContextMenuLoadingItem loading;

  /// The item shown after [asyncItem] has failed to load.
  ///
  /// Tapping it retries loading. Without its own title and trailing, it
  /// shows [SmartContextMenuLabels.retry] and
  /// [SmartContextMenuStyle.retryIcon]. Without its own padding, it keeps
  /// the padding of [loading].
  final SmartContextMenuErrorItem error;

  const SmartContextMenuAsyncItem._({
    required super.id,
    required this.asyncItem,
    required this.timeout,
    required this.loading,
    required this.error,
  }) : super._();
}
