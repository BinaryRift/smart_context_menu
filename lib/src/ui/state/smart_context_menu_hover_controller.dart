import 'package:flutter/widgets.dart' show ValueNotifier, Key;

/// Holds the key of the item under the pointer.
///
/// During a press it is the item under the pressed pointer, otherwise
/// the item under a cursor.
final class SmartContextMenuHoverController extends ValueNotifier<Key?> {
  SmartContextMenuHoverController() : super(null);

  bool isPointerReleased = false;

  /// Whether the item is under a cursor without a press.
  bool isPointerHover = false;

  /// Whether the item is under a cursor, pressed or not.
  bool isCursor = false;

  bool _isPressing = false;

  /// The item that reported the cursor over it. Items of different levels
  /// may share a key, such as the back item, so the owner tells them apart.
  Object? _cursorOwner;
  Key? _cursorKey;

  /// Reports that the cursor is over the item with [key] of [owner].
  void hover(Object owner, Key key) {
    _cursorOwner = owner;
    _cursorKey = key;
    if (!_isPressing) _update(key, isPointerHover: true, isCursor: true);
  }

  /// Reports that the cursor left the item of [owner].
  void unhover(Object owner) {
    if (!identical(_cursorOwner, owner)) return;
    _forget();
    if (!_isPressing) _update(null);
  }

  /// Forgets the item of [owner] without notifying, for an item that
  /// leaves the tree: the cursor reports the item under it after the frame.
  void forget(Object owner) {
    if (identical(_cursorOwner, owner)) _forget();
  }

  /// Reports the item under a pressed pointer, or `null` when the press
  /// does not select an item.
  void press(Key? key, {required bool isMouse}) {
    _isPressing = true;
    _update(key, isCursor: isMouse);
  }

  void setReleased() {
    if (value == null) return;
    isPointerReleased = true;
    notifyListeners();
  }

  /// Ends the press and returns the highlight to the item under the cursor.
  void endPress() {
    _isPressing = false;
    final key = _cursorKey;
    _update(key, isPointerHover: key != null, isCursor: key != null);
  }

  void _forget() {
    _cursorOwner = null;
    _cursorKey = null;
  }

  void _update(Key? key, {bool isPointerHover = false, bool isCursor = false}) {
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
}
