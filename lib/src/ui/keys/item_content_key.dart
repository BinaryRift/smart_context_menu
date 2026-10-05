import 'package:flutter/widgets.dart' show ValueKey;

/// Key of a state of the item content, switched by the item view.
final class ItemContentKey extends ValueKey<String> {
  const ItemContentKey._(super.value);

  /// The placeholder while an async item loads.
  static const loading = ItemContentKey._("loading");

  /// The retry content after a load fails.
  static const error = ItemContentKey._("error");

  /// The content of a loaded or plain item.
  static const content = ItemContentKey._("content");
}
