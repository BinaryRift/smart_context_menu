import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';
import '../../../core/ui/demo_card.dart';
import '../../settings/ui/widgets/settings_button.dart';
import '../domain/appearance_items.dart';
import 'appearance_styles.dart';

/// Cards with menus of different looks, one preset each.
///
/// Every card has its own [SmartContextMenuTheme] built from the config of
/// the app, so the settings of the app apply to all of them.
final class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

final class _AppearancePageState extends State<AppearancePage> {
  final _loader = DemoLoader();
  final _russianLoader = DemoLoader()..failEveryOther = true;
  final _statusLoader = DemoLoader()..failEveryOther = true;
  final _tagColor = ValueNotifier<Color>(CupertinoColors.systemBlue);

  @override
  void dispose() {
    _tagColor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Appearance'),
        trailing: SettingsButton(),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _buildPreset(
              title: 'Default',
              subtitle: 'The config of the app',
              config: (app) => app,
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Brand',
              subtitle: 'Own colors and corners, no blur',
              config: (app) => app.copyWith(style: brandStyle),
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Solid',
              subtitle: 'An opaque menu',
              config: (app) => app.copyWith(style: solidStyle),
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Compact',
              subtitle: 'Smaller text, tighter items, a narrower menu',
              config: (app) => app.copyWith(
                menuWidth: compactMenuWidth,
                style: compactStyle,
              ),
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Dividers',
              subtitle: 'Lines between items, under the titles',
              config: (app) => app.copyWith(style: dividersStyle),
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Custom content',
              subtitle: 'A row of colors, two lines of text, tinted items',
              config: (app) => app,
              items: customContentItems(_tagColor),
            ),
            _buildPreset(
              title: 'Localized',
              subtitle: 'The strings of the menu in Russian',
              config: (app) => app.copyWith(labels: russianLabels),
              items: russianItems(_russianLoader),
            ),
            _buildPreset(
              title: 'Status items',
              subtitle: 'Own loading, error and empty signs',
              config: (app) => app.copyWith(style: statusStyle),
              items: statusItems(_statusLoader),
            ),
          ],
        ),
      ),
    );
  }

  /// A card with [items] in a menu of the [config] made from the config
  /// of the app.
  Widget _buildPreset({
    required String title,
    required String subtitle,
    required SmartContextMenuConfig Function(SmartContextMenuConfig app) config,
    required List<SmartContextMenuItem> items,
  }) {
    final app = SmartContextMenuTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SmartContextMenuTheme(
        config: config(app),
        child: SmartContextMenu(
          items: items,
          child: DemoCard(title: title, subtitle: subtitle),
        ),
      ),
    );
  }
}
