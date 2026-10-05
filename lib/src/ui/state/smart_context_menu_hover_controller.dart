import 'package:flutter/widgets.dart' show ValueNotifier, Key;

final class SmartContextMenuHoverController extends ValueNotifier<Key?> {
  SmartContextMenuHoverController() : super(null);

  bool isPointerReleased = false;

  void update(Key? key) {
    isPointerReleased = false;
    value = key;
  }

  void setReleased() {
    if (value == null) return; 
    isPointerReleased = true;
    notifyListeners();
  }
}
