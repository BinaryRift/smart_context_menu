import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'core/settings/example_settings.dart';
import 'core/settings/settings_scope.dart';
import 'pages/lab/ui/lab_page.dart';
import 'resources/app_theme/menu_config.dart';

void main() => runApp(const ExampleApp());

final class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

final class _ExampleAppState extends State<ExampleApp> {
  final _settings = ExampleSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: _settings,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => CupertinoApp(
          title: 'smart_context_menu',
          theme: CupertinoThemeData(brightness: _settings.brightness),
          // One config for all menus of the app.
          builder: (context, child) => SmartContextMenuTheme(
            config: _settings.menuConfig(appMenuConfig),
            child: child!,
          ),
          home: const LabPage(),
        ),
      ),
    );
  }
}
