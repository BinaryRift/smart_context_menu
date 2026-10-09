import 'package:flutter/widgets.dart' show ValueKey;

/// Key of a state of the item content, switched by the item view.
final class ItemContentKey extends ValueKey<String> {
  const ItemContentKey._(super.value);

  /// The placeholder while an async item loads.
  static const loading = ItemContentKey._("loading");

  /// The content of a failed load: the retry content or an error item.
  static const error = ItemContentKey._("error");

  /// The content of an empty item.
  static const empty = ItemContentKey._("empty");

  /// The content of a loaded or plain item.
  static const content = ItemContentKey._("content");
}
