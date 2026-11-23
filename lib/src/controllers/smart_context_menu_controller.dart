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

  /// Binds the controller to the menu [owner]. Called by [SmartContextMenu].
  @internal
  void attach({
    required Object owner,
    required Future<void> Function() open,
    required Future<void> Function() close,
    required bool isOpen,
  }) {
    _binding = _SmartContextMenuBinding(owner: owner, open: open, close: close);
    syncVisibility(owner, isOpen);
  }

  /// Unbinds the controller from the menu [owner]. Called by
  /// [SmartContextMenu].
  ///
  /// Does nothing if the controller is bound to another menu by now.
  @internal
  void detach(Object owner) {
    if (!identical(_binding?.owner, owner)) return;
    _binding = null;
    _setOpen(false);
  }

  /// Updates [isOpen] from the menu [owner] and notifies listeners on change.
  /// Called by [SmartContextMenu].
  ///
  /// Does nothing if the controller is not bound to [owner].
  @internal
  void syncVisibility(Object owner, bool isOpen) {
    if (!identical(_binding?.owner, owner)) return;
    _setOpen(isOpen);
  }

  void _setOpen(bool isOpen) {
    if (_isOpen == isOpen) return;
    _isOpen = isOpen;
    notifyListeners();
  }
}

final class _SmartContextMenuBinding {
  final Object owner;
  final _SmartContextMenuAction open;
  final _SmartContextMenuAction close;

  const _SmartContextMenuBinding({
    required this.owner,
    required this.open,
    required this.close,
  });
}
