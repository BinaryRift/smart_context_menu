import 'package:flutter/widgets.dart' show ValueKey;

/// Key of a menu-owned row such as the back item, the retry item
/// or a loader.
///
/// Its own type keeps it from being equal to `ValueKey(item.id)`
/// of a user item, even when the id has the same string.
final class ServiceItemKey extends ValueKey<String> {
  const ServiceItemKey._(super.value);

  /// The trigger that loads the next page after [itemsCount] items.
  ///
  /// A new page gives the trigger a new key, so it loads again
  /// when it becomes visible.
  factory ServiceItemKey.pagingTrigger(int itemsCount) =>
      ServiceItemKey._("paging_trigger_$itemsCount");

  /// The back item pinned to the top of a submenu.
  static const back = ServiceItemKey._("back");

  /// The invisible copy of the back item that reserves its space
  /// at the top of the submenu list.
  static const backPlaceholder = ServiceItemKey._("back_placeholder");

  /// The item that retries a failed submenu load.
  static const retry = ServiceItemKey._("retry");

  /// The loader shown while a submenu loads its first items.
  static const loader = ServiceItemKey._("loader");
}
