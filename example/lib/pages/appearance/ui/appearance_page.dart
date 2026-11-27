// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';
import '../../../core/ui/demo_card.dart';
import '../../settings/ui/widgets/settings_button.dart';
import '../domain/appearance_items.dart';
import '../domain/row_theme_items.dart';
import '../domain/theme_items.dart';
import 'appearance_styles.dart';
import 'theme_styles.dart';

/// Preset cards for menu styles, row layouts and customization.
///
/// Each card builds its [SmartContextMenuTheme] from the app configuration.
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
  final _rowTagColor = ValueNotifier<Color>(CupertinoColors.systemBlue);
  final _formatting = ValueNotifier<Set<String>>({'Bold'});
  final _alignment = ValueNotifier('Align Left');
  final _drawingTool = ValueNotifier('Brush');

  @override
  void dispose() {
    _tagColor.dispose();
    _rowTagColor.dispose();
    _formatting.dispose();
    _alignment.dispose();
    _drawingTool.dispose();
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
            _buildGroupHeader('Styles'),
            _buildPreset(
              title: 'Default',
              subtitle: 'The config of the app',
              config: (app) => app,
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Compact',
              subtitle: 'Five small cells in a narrow menu',
              config: (app) => app.copyWith(
                menuWidth: compactMenuWidth,
                style: compactStyle,
              ),
              items: compactItems(),
            ),
            _buildPreset(
              title: 'Inset dividers',
              subtitle: 'Lines between items, inset on both sides',
              config: (app) => app.copyWith(style: insetDividersStyle),
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Colorful',
              subtitle: 'Icons in colored squares, as in Settings',
              config: (app) => app.copyWith(style: colorfulStyle),
              items: colorfulItems(),
            ),
            _buildPreset(
              title: 'Brand',
              subtitle: 'Indigo, white text and rounder corners',
              config: (app) => app.copyWith(style: brandStyle),
              items: sampleItems(_loader),
            ),
            _buildPreset(
              title: 'Terminal',
              subtitle: 'Monospaced text and a green glow',
              config: (app) => app.copyWith(style: terminalStyle),
              items: terminalItems(),
            ),
            _buildPreset(
              title: 'Glow',
              subtitle: 'Text-only commands and a cyan glow',
              config: (app) =>
                  app.copyWith(menuWidth: glowMenuWidth, style: glowStyle),
              items: glowItems(),
            ),
            _buildGroupHeader('Rows'),
            _buildPreset(
              title: 'Quick actions',
              subtitle: 'A row of medium cells above the list',
              config: (app) => app,
              items: quickActionItems(),
            ),
            _buildPreset(
              title: 'Only rows',
              subtitle: 'Small and medium cells, a separator',
              config: (app) => app,
              items: onlyRowItems(),
            ),
            _buildPreset(
              title: 'Wide row',
              subtitle: 'Seven small cells in a wider menu',
              config: (app) => app.copyWith(menuWidth: wideRowMenuWidth),
              items: wideRowItems(),
            ),
            _buildPreset(
              title: 'Editing rows',
              subtitle: 'Formatting, alignment and clipboard actions',
              config: (app) => app.copyWith(style: editingRowsStyle),
              items: editingRowsItems(_formatting, _alignment),
            ),
            _buildPreset(
              title: 'Drawing toolbar',
              subtitle: 'Color-coded tools and a Shapes submenu',
              config: (app) => app.copyWith(
                menuWidth: wideRowMenuWidth,
                style: drawingToolbarStyle,
              ),
              items: drawingToolbarItems(_drawingTool),
            ),
            _buildGroupHeader('Customization'),
            _buildPreset(
              title: 'Custom content',
              subtitle: 'Own rows, tinted items, dividers, a titled separator',
              config: (app) => app.copyWith(
                style: app.style.copyWith(dividersBetweenItems: true),
              ),
              items: customContentItems(_tagColor),
            ),
            _buildPreset(
              title: 'Styled rows',
              subtitle: 'Bold titles, gaps, dividers, a badge, colors',
              config: (app) => app.copyWith(
                style: app.style.copyWith(
                  dividersBetweenItems: true,
                  rowStyle: styledRowStyle,
                ),
              ),
              items: styledRowItems(_rowTagColor),
            ),
            _buildPreset(
              title: 'Paper',
              subtitle: 'Warm colors and a serif font · Standard surface',
              config: (app) => app.copyWith(style: paperStyle),
              items: paperItems(),
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
              config: (app) => app.copyWith(style: statusItemsStyle),
              items: statusItems(_statusLoader),
            ),
          ],
        ),
      ),
    );
  }

  /// The title of a group of cards, as in a grouped list of iOS.
  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 16, 36, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondaryLabel,
            context,
          ),
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
    final preset = config(app);
    // A preset's explicit Standard surface takes precedence.
    final surface = app.style.surface == SmartContextMenuSurface.standard
        ? SmartContextMenuSurface.standard
        : preset.style.surface;
    final effectiveConfig = preset.copyWith(
      style: preset.style.copyWith(
        surface: surface,
        backgroundBlur: app.style.backgroundBlur,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SmartContextMenuTheme(
        config: effectiveConfig,
        child: SmartContextMenu(
          items: items,
          child: DemoCard(title: title, subtitle: subtitle),
        ),
      ),
    );
  }
}
