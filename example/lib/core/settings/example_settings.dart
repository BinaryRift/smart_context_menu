import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:smart_context_menu/smart_context_menu.dart';

/// The settings of the app that apply to all menus.
final class ExampleSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _enableHaptics = true;
  bool _enableSwipeBack = true;
  bool _moveBackDown = false;
  bool _slowAnimations = false;
  bool _showTouches = false;
  bool _useRtl = false;

  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) => _update(() => _themeMode = value);

  bool get enableHaptics => _enableHaptics;
  set enableHaptics(bool value) => _update(() => _enableHaptics = value);

  bool get enableSwipeBack => _enableSwipeBack;
  set enableSwipeBack(bool value) => _update(() => _enableSwipeBack = value);

  bool get moveBackDown => _moveBackDown;
  set moveBackDown(bool value) => _update(() => _moveBackDown = value);

  /// Whether all animations of the app run five times slower.
  bool get slowAnimations => _slowAnimations;
  set slowAnimations(bool value) => _update(() {
    _slowAnimations = value;
    timeDilation = value ? 5 : 1;
  });

  /// Whether a circle is shown under every finger, for screen recordings.
  bool get showTouches => _showTouches;
  set showTouches(bool value) => _update(() => _showTouches = value);

  /// Whether the example app uses right-to-left layout.
  bool get useRtl => _useRtl;
  set useRtl(bool value) => _update(() => _useRtl = value);

  /// The brightness of the app theme, `null` to follow the system.
  Brightness? get brightness => switch (_themeMode) {
    ThemeMode.system => null,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };

  /// [config] with these settings.
  SmartContextMenuConfig menuConfig(SmartContextMenuConfig config) {
    return config.copyWith(
      enableHaptics: _enableHaptics,
      enableSwipeBack: _enableSwipeBack,
      moveBackDown: _moveBackDown,
    );
  }

  void _update(VoidCallback change) {
    change();
    notifyListeners();
  }

  @override
  void dispose() {
    timeDilation = 1;
    super.dispose();
  }
}
