import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:smart_context_menu/smart_context_menu.dart';

import 'demo_items.dart';

/// Menus for checking submenus and swiping back.
class SubmenuDemoPage extends StatefulWidget {
  const SubmenuDemoPage({super.key});

  @override
  State<SubmenuDemoPage> createState() => _SubmenuDemoPageState();
}

class _SubmenuDemoPageState extends State<SubmenuDemoPage> {
  final _loader = DemoLoader();
  bool _swipeBack = true;
  bool _haptics = true;
  bool _slowAnimations = false;

  SmartContextMenuConfig get _config => SmartContextMenuConfig(
    enableSwipeBack: _swipeBack,
    enableHaptics: _haptics,
  );

  @override
  void dispose() {
    timeDilation = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text('Submenus')),
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
        child: _DemoCard(title: title, subtitle: subtitle),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _DemoCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.textStyle),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: textTheme.textStyle.copyWith(
              fontSize: 13,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel,
                context,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
