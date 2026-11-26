import 'package:flutter/widgets.dart';

/// Enables the internal glass style for the Lab.
final class SmartContextMenuGlassScope extends InheritedWidget {
  final bool enabled;

  const SmartContextMenuGlassScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  static bool isEnabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<SmartContextMenuGlassScope>()
          ?.enabled ??
      false;

  @override
  bool updateShouldNotify(SmartContextMenuGlassScope oldWidget) =>
      enabled != oldWidget.enabled;
}
