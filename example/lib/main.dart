import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:smart_context_menu/smart_context_menu.dart';

import 'pages/main/ui/submenu_demo_page.dart';

void main() => runApp(const ExampleApp());

/// The config of all menus in the app.
const _menuConfig = SmartContextMenuConfig(
  style: SmartContextMenuStyle(menuBlur: SmartContextMenuBlur.small),
);

final class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

final class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  Brightness? get _brightness => switch (_themeMode) {
    ThemeMode.system => null,
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'smart_context_menu',
      theme: CupertinoThemeData(brightness: _brightness),
      builder: (context, child) =>
          SmartContextMenuTheme(config: _menuConfig, child: child!),
      home: SubmenuDemoPage(
        themeMode: _themeMode,
        onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
      ),
    );
  }
}
