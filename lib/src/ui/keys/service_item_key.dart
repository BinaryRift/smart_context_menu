import 'package:flutter/widgets.dart' show ValueKey;

/// Key of a menu-owned item such as the back or retry item.
///
/// Its own type keeps it from being equal to `ValueKey(item.id)`
/// of a user item, even when the id has the same string.
final class ServiceItemKey extends ValueKey<String> {
  const ServiceItemKey._(super.value);

  /// The back item pinned to the top of a submenu.
  static const back = ServiceItemKey._("back");

  /// The invisible copy of the back item that reserves its space
  /// at the top of the submenu list.
  static const backPlaceholder = ServiceItemKey._("back_placeholder");

  /// The item that retries a failed submenu load.
  static const retry = ServiceItemKey._("retry");
}
