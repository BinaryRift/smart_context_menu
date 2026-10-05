import 'dart:ui' as ui;
import 'package:flutter/widgets.dart' show NavigatorState;
import '../routes/smart_context_menu_route.dart';

enum _SmartContextMenuLifecycleState { idle, opening, open, closing }

final class SmartContextMenuSession {
  SmartContextMenuRoute? _activeRoute;
  NavigatorState? _activeNavigator;
  ui.Image? _snapshot;
  int? _activeSessionId;
  int _nextSessionId = 0;
  Future<void>? _sessionFuture;
  _SmartContextMenuLifecycleState _lifecycleState =
      _SmartContextMenuLifecycleState.idle;

  SmartContextMenuRoute? get activeRoute => _activeRoute;
  NavigatorState? get activeNavigator => _activeNavigator;
  ui.Image? get snapshot => _snapshot;
  Future<void>? get sessionFuture => _sessionFuture;

  bool get hasActiveSession =>
      _lifecycleState != _SmartContextMenuLifecycleState.idle;
  bool get isMenuVisible =>
      _activeRoute != null &&
      (_lifecycleState == _SmartContextMenuLifecycleState.open ||
          _lifecycleState == _SmartContextMenuLifecycleState.closing);
  bool get isClosing =>
      _lifecycleState == _SmartContextMenuLifecycleState.closing;

  int begin() {
    final sessionId = ++_nextSessionId;
    _activeSessionId = sessionId;
    _lifecycleState = _SmartContextMenuLifecycleState.opening;
    return sessionId;
  }

  void bind(Future<void> future) {
    _sessionFuture = future;
  }

  void setSnapshot(ui.Image snapshot) {
    _snapshot = snapshot;
  }

  bool canContinueOpening(int sessionId, {required bool mounted}) {
    return mounted &&
        _isCurrentSession(sessionId) &&
        _lifecycleState == _SmartContextMenuLifecycleState.opening;
  }

  void attachRoute({
    required int sessionId,
    required SmartContextMenuRoute route,
    required NavigatorState navigator,
  }) {
    if (!_isCurrentSession(sessionId)) return;
    _activeRoute = route;
    _activeNavigator = navigator;
  }

  bool markOpen(int sessionId) {
    if (!_isCurrentSession(sessionId) ||
        _lifecycleState != _SmartContextMenuLifecycleState.opening) {
      return false;
    }

    _lifecycleState = _SmartContextMenuLifecycleState.open;
    return true;
  }

  bool startClosing() {
    if (_lifecycleState == _SmartContextMenuLifecycleState.idle ||
        _lifecycleState == _SmartContextMenuLifecycleState.closing) {
      return false;
    }

    _lifecycleState = _SmartContextMenuLifecycleState.closing;
    return true;
  }

  bool finishIfCurrent(int sessionId) {
    if (!_isCurrentSession(sessionId)) return false;
    _clear();
    return true;
  }

  void invalidate() {
    _clear();
  }

  bool _isCurrentSession(int sessionId) {
    return _activeSessionId == sessionId;
  }

  void _clear() {
    _activeRoute = null;
    _activeNavigator = null;
    _activeSessionId = null;
    _snapshot = null;
    _sessionFuture = null;
    _lifecycleState = _SmartContextMenuLifecycleState.idle;
  }
}
