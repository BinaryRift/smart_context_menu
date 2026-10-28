import 'package:flutter/widgets.dart' show ValueNotifier, Key;

final class SmartContextMenuHoverController extends ValueNotifier<Key?> {
  SmartContextMenuHoverController() : super(null);

  bool isPointerReleased = false;
  bool isPointerHover = false;

  void update(Key? key, {bool isPointerHover = false}) {
    isPointerReleased = false;
    this.isPointerHover = isPointerHover;
    value = key;
  }

  void setReleased() {
    if (value == null) return;
    isPointerReleased = true;
    notifyListeners();
  }
}
