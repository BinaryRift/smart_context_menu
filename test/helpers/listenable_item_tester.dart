import 'package:flutter/foundation.dart';

/// The state of the app that a listenable item is built from.
final class ItemNotifier extends ChangeNotifier {
  int count = 0;
  bool isLoading = true;
  bool hasFailed = true;
  bool isOn = false;

  bool get isListened => hasListeners;

  void increment() {
    count++;
    notifyListeners();
  }

  void finishLoading() {
    isLoading = false;
    notifyListeners();
  }

  void recover() {
    hasFailed = false;
    notifyListeners();
  }

  void toggle() {
    isOn = !isOn;
    notifyListeners();
  }
}
