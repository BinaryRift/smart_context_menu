import 'package:flutter/foundation.dart' show ChangeNotifier;

typedef SmartContextMenuAction = Future<void> Function();

final class SmartContextMenuController extends ChangeNotifier {
  _SmartContextMenuBinding? _binding;
  bool _isOpen = false;

  bool get isOpen => _isOpen;
  bool get isClosed => !isOpen;

  Future<void> open() async {
    final binding = _binding;
    if (binding == null) return;
    await binding.open();
  }

  Future<void> close() async {
    final binding = _binding;
    if (binding == null) return;
    await binding.close();
  }

  void attach({
    required SmartContextMenuAction open,
    required SmartContextMenuAction close,
    required bool isOpen,
  }) {
    _binding = _SmartContextMenuBinding(
      open: open,
      close: close,
    );
    syncVisibility(isOpen);
  }

  void detach() {
    _binding = null;
    syncVisibility(false);
  }

  void syncVisibility(bool isOpen) {
    if (_isOpen == isOpen) return;
    _isOpen = isOpen;
    notifyListeners();
  }
}

final class _SmartContextMenuBinding {
  final SmartContextMenuAction open;
  final SmartContextMenuAction close;

  const _SmartContextMenuBinding({
    required this.open,
    required this.close,
  });
}
