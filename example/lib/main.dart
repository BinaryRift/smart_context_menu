import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'core/settings/example_settings.dart';
import 'core/settings/settings_scope.dart';
import 'core/ui/demo_notice.dart';
import 'core/ui/touch_indicator.dart';
import 'pages/tabs/ui/tabs_page.dart';
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
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(brightness: _settings.brightness),
          builder: (context, child) => Directionality(
            textDirection: _settings.useRtl
                ? TextDirection.rtl
                : Directionality.of(context),
            child: TouchIndicator(
              enabled: _settings.showTouches,
              // One config for all menus of the app.
              child: SmartContextMenuTheme(
                config: _settings.menuConfig(appMenuConfig),
                child: DemoNotice(child: child!),
              ),
            ),
          ),
          home: const TabsPage(),
        ),
      ),
    );
  }
}
