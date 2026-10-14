import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:meta/meta.dart' show internal;

typedef _SmartContextMenuAction = Future<void> Function();

/// Opens and closes a [SmartContextMenu] programmatically
/// and reports whether it is currently open.
///
/// Required when [SmartContextMenuConfig.activationMode] is
/// [SmartContextMenuActivationMode.manual]. Can also be used with
/// long-press activation to close the menu from code.
///
/// Listeners are notified when the menu opens or closes.
///
/// A controller can be attached to only one [SmartContextMenu] at a time.
final class SmartContextMenuController extends ChangeNotifier {
  _SmartContextMenuBinding? _binding;
  bool _isOpen = false;

  /// Creates a controller for opening and closing one [SmartContextMenu].
  ///
  /// [isOpen] is initially false. Dispose the controller when it is no longer
  /// needed.
  SmartContextMenuController();

  /// Whether the menu is currently open.
  bool get isOpen => _isOpen;

  /// Whether the menu is currently closed.
  bool get isClosed => !isOpen;

  /// Opens the menu.
  ///
  /// Does nothing if the controller is not attached to a [SmartContextMenu].
  /// Completes when the menu is closed.
  Future<void> open() async {
    final binding = _binding;
    if (binding == null) return;
    await binding.open();
  }

  /// Closes the menu.
  ///
  /// Does nothing if the controller is not attached to a [SmartContextMenu].
  /// Completes when the closing animation finishes.
  Future<void> close() async {
    final binding = _binding;
    if (binding == null) return;
    await binding.close();
  }

  /// Binds the controller to a menu. Called by [SmartContextMenu].
  @internal
  void attach({
    required Future<void> Function() open,
    required Future<void> Function() close,
    required bool isOpen,
  }) {
    _binding = _SmartContextMenuBinding(open: open, close: close);
    syncVisibility(isOpen);
  }

  /// Unbinds the controller from its menu. Called by [SmartContextMenu].
  @internal
  void detach() {
    _binding = null;
    syncVisibility(false);
  }

  /// Updates [isOpen] and notifies listeners on change.
  /// Called by [SmartContextMenu].
  @internal
  void syncVisibility(bool isOpen) {
    if (_isOpen == isOpen) return;
    _isOpen = isOpen;
    notifyListeners();
  }
}

final class _SmartContextMenuBinding {
  final _SmartContextMenuAction open;
  final _SmartContextMenuAction close;

  const _SmartContextMenuBinding({required this.open, required this.close});
}
