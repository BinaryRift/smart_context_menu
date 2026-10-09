import 'package:flutter/widgets.dart';

import 'example_settings.dart';

/// Provides [ExampleSettings] to the app and rebuilds dependents
/// when they change.
final class SettingsScope extends InheritedNotifier<ExampleSettings> {
  const SettingsScope({
    super.key,
    required ExampleSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static ExampleSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'No SettingsScope above this context');
    return scope!.notifier!;
  }
}
