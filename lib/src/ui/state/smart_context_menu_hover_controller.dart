import 'package:flutter/widgets.dart' show ValueNotifier, Key;

/// Holds the key of the item under the pointer.
final class SmartContextMenuHoverController extends ValueNotifier<Key?> {
  SmartContextMenuHoverController() : super(null);

  bool isPointerReleased = false;

  /// Whether the item is under a cursor without a press.
  bool isPointerHover = false;

  /// Whether the item is under a cursor, pressed or not.
  bool isCursor = false;

  void update(Key? key, {bool isPointerHover = false, bool isCursor = false}) {
    isCursor = isPointerHover || isCursor;
    final isSameState =
        this.isPointerHover == isPointerHover && this.isCursor == isCursor;
    isPointerReleased = false;
    this.isPointerHover = isPointerHover;
    this.isCursor = isCursor;
    if (value != key) {
      value = key;
    } else if (!isSameState) {
      // A press on the hovered item keeps the key.
      notifyListeners();
    }
  }

  void setReleased() {
    if (value == null) return;
    isPointerReleased = true;
    notifyListeners();
  }
}
