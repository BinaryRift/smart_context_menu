import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_config.dart';

/// Sets the [SmartContextMenuConfig] of the [SmartContextMenu]s below it.
///
/// Wrap the whole app to set the config once, for example in the `builder`
/// of [WidgetsApp]. Wrap a part of the tree to give it its own config: the
/// nearest theme wins. A [SmartContextMenu.config] replaces the theme for
/// that menu. Without a theme, menus use `const SmartContextMenuConfig()`.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => SmartContextMenuTheme(
///     config: const SmartContextMenuConfig(
///       style: SmartContextMenuStyle(menuBlur: SmartContextMenuBlur.small),
///     ),
///     child: child!,
///   ),
/// )
/// ```
///
/// To change a few settings for one menu, start from the theme:
///
/// ```dart
/// SmartContextMenu(
///   config: SmartContextMenuTheme.of(context).copyWith(
///     activationMode: SmartContextMenuActivationMode.manual,
///   ),
///   controller: controller,
///   items: items,
///   child: child,
/// )
/// ```
final class SmartContextMenuTheme extends InheritedWidget {
  /// The config of the menus below this widget.
  final SmartContextMenuConfig config;

  /// Creates a theme that sets [config] for the menus in [child].
  const SmartContextMenuTheme({
    super.key,
    required this.config,
    required super.child,
  });

  /// The config of the nearest [SmartContextMenuTheme] above [context],
  /// or `const SmartContextMenuConfig()` if there is none.
  static SmartContextMenuConfig of(BuildContext context) {
    return maybeOf(context) ?? const SmartContextMenuConfig();
  }

  /// The config of the nearest [SmartContextMenuTheme] above [context],
  /// or null if there is none.
  static SmartContextMenuConfig? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SmartContextMenuTheme>()
        ?.config;
  }

  @override
  bool updateShouldNotify(SmartContextMenuTheme oldWidget) {
    return !identical(config, oldWidget.config);
  }
}
