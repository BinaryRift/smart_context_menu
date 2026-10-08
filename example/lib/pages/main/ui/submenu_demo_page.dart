import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../demo_items.dart';
import 'widgets/demo_card.dart';
import 'widgets/tap_empty_area.dart';

/// Menus for checking submenus and swiping back.
final class SubmenuDemoPage extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SubmenuDemoPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<SubmenuDemoPage> createState() => _SubmenuDemoPageState();
}

final class _SubmenuDemoPageState extends State<SubmenuDemoPage> {
  final _loader = DemoLoader();
  final _buttonMenuController = SmartContextMenuController();
  final _tapAreaMenuController = SmartContextMenuController();
  bool _swipeBack = true;
  bool _haptics = true;
  bool _moveBackDown = false;
  bool _slowAnimations = false;
  bool _dividersBetweenItems = false;

  SmartContextMenuConfig get _config => SmartContextMenuConfig(
    enableSwipeBack: _swipeBack,
    enableHaptics: _haptics,
    moveBackDown: _moveBackDown,
    style: SmartContextMenuStyle(dividersBetweenItems: _dividersBetweenItems),
  );

  @override
  void dispose() {
    _buttonMenuController.dispose();
    _tapAreaMenuController.dispose();
    timeDilation = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Smart Context Menu'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSettings(),
                  _buildMenu(
                    title: 'All submenu types',
                    subtitle: 'Static, async, paginated and nested',
                    items: allSubmenuTypes(_loader),
                  ),
                  _buildManualMenu(
                    controller: _buttonMenuController,
                    title: 'Opens from the button',
                    subtitle: 'All submenu types, no long press',
                    items: allSubmenuTypes(_loader),
                    trailing: CupertinoButton(
                      onPressed: _buttonMenuController.open,
                      child: const Icon(CupertinoIcons.ellipsis_circle),
                    ),
                  ),
                  _buildManualMenu(
                    controller: _tapAreaMenuController,
                    title: 'Opens from the empty area',
                    subtitle: 'All submenu types, no long press',
                    items: allSubmenuTypes(_loader),
                    leading: TapEmptyArea(
                      onDoubleTap: _tapAreaMenuController.open,
                    ),
                  ),
                  _buildMenu(
                    title: 'Nested levels',
                    subtitle: 'Share → Messages',
                    items: nestedLevels(),
                  ),
                  _buildMenu(
                    title: 'Short root, long submenu',
                    subtitle: 'The submenu scrolls vertically',
                    items: shortRootLongSubmenu(),
                  ),
                  _buildMenu(
                    title: 'Long root, short submenu',
                    subtitle: 'The menu shrinks in the submenu',
                    items: longRootShortSubmenu(),
                  ),
                ],
              ),
            ),
            _buildMenu(
              title: 'Near the bottom edge',
              subtitle: 'The menu moves up when the submenu is taller',
              items: shortRootLongSubmenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Settings'),
      children: [
        CupertinoListTile(
          title: const Text('Theme'),
          trailing: CupertinoSlidingSegmentedControl<ThemeMode>(
            groupValue: widget.themeMode,
            onValueChanged: (mode) {
              if (mode != null) widget.onThemeModeChanged(mode);
            },
            children: const {
              ThemeMode.system: Text('System'),
              ThemeMode.light: Text('Light'),
              ThemeMode.dark: Text('Dark'),
            },
          ),
        ),
        _buildSwitch(
          title: 'Swipe back',
          value: _swipeBack,
          onChanged: (value) => setState(() => _swipeBack = value),
        ),
        _buildSwitch(
          title: 'Haptics',
          value: _haptics,
          onChanged: (value) => setState(() => _haptics = value),
        ),
        _buildSwitch(
          title: 'Move back down',
          value: _moveBackDown,
          onChanged: (value) => setState(() => _moveBackDown = value),
        ),
        _buildSwitch(
          title: 'Dividers between items',
          value: _dividersBetweenItems,
          onChanged: (value) => setState(() => _dividersBetweenItems = value),
        ),
        _buildSwitch(
          title: 'Slow animations',
          value: _slowAnimations,
          onChanged: (value) {
            setState(() => _slowAnimations = value);
            timeDilation = value ? 5 : 1;
          },
        ),
        _buildSwitch(
          title: 'Every other load fails',
          value: _loader.failEveryOther,
          onChanged: (value) => setState(() => _loader.failEveryOther = value),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CupertinoListTile(
      title: Text(title),
      trailing: CupertinoSwitch(value: value, onChanged: onChanged),
    );
  }

  /// A menu that opens only from code, with [leading] and [trailing]
  /// next to the card to open it.
  Widget _buildManualMenu({
    required SmartContextMenuController controller,
    required String title,
    required String subtitle,
    required List<SmartContextMenuItem> items,
    Widget? leading,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?leading,
            Expanded(
              child: SmartContextMenu(
                controller: controller,
                config: _config.copyWith(
                  activationMode: SmartContextMenuActivationMode.manual,
                ),
                items: items,
                child: DemoCard(title: title, subtitle: subtitle),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildMenu({
    required String title,
    required String subtitle,
    required List<SmartContextMenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SmartContextMenu(
        config: _config,
        items: items,
        onPreviewTap: () => debugPrint('Preview tapped: $title'),
        child: DemoCard(title: title, subtitle: subtitle),
      ),
    );
  }
}
