import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../core/data/demo_loader.dart';
import '../../../core/ui/demo_card.dart';
import '../../settings/ui/widgets/settings_button.dart';
import '../domain/lab_items.dart';
import 'widgets/reactions_bar.dart';
import 'widgets/tap_empty_area.dart';

/// Content shown above the preview.
enum _Header { none, short, tall }

/// Menus for checking edge cases: all item types, levels of different
/// heights, tall widgets and a widget near the bottom edge.
final class LabPage extends StatefulWidget {
  const LabPage({super.key});

  @override
  State<LabPage> createState() => _LabPageState();
}

final class _LabPageState extends State<LabPage> {
  final _loader = DemoLoader();
  final _favorite = DemoFavorite();
  final _isMuted = ValueNotifier(false);
  final _download = DemoDownload();
  final _buttonMenuController = SmartContextMenuController();
  final _tapAreaMenuController = SmartContextMenuController();
  bool _dividersBetweenItems = false;
  _Header _header = _Header.none;
  bool _pinHeader = false;

  /// The config of the app theme with the settings of this page.
  SmartContextMenuConfig _menuConfig(BuildContext context) {
    final theme = SmartContextMenuTheme.of(context);
    return theme.copyWith(
      style: theme.style.copyWith(dividersBetweenItems: _dividersBetweenItems),
    );
  }

  @override
  void dispose() {
    _buttonMenuController.dispose();
    _tapAreaMenuController.dispose();
    _favorite.dispose();
    _isMuted.dispose();
    _download.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartContextMenuTheme(
      config: _menuConfig(context),
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lab'),
        trailing: SettingsButton(),
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
                    title: 'Listenable items',
                    subtitle: 'Change while the menu is open',
                    items: listenableItems(
                      favorite: _favorite,
                      isMuted: _isMuted,
                      download: _download,
                    ),
                  ),
                  _buildMenu(
                    title: 'Status items',
                    subtitle: 'Loading, error and empty, retry on tap',
                    items: statusItems(),
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
                  _buildMenu(
                    title: 'Tall widget',
                    subtitle: 'Short root, long submenu',
                    items: shortRootLongSubmenu(),
                    height: 420,
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
      header: const Text('Options'),
      children: [
        CupertinoListTile(
          title: const Text('Header'),
          trailing: CupertinoSlidingSegmentedControl<_Header>(
            groupValue: _header,
            onValueChanged: (header) {
              if (header != null) setState(() => _header = header);
            },
            children: const {
              _Header.none: Text('Off'),
              _Header.short: Text('Bar'),
              _Header.tall: Text('Tall'),
            },
          ),
        ),
        _buildSwitch(
          title: 'Pinned header',
          value: _pinHeader,
          onChanged: (value) => setState(() => _pinHeader = value),
        ),
        _buildSwitch(
          title: 'Dividers between items',
          value: _dividersBetweenItems,
          onChanged: (value) => setState(() => _dividersBetweenItems = value),
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
              // The theme of the page is below the context of the state.
              child: Builder(
                builder: (context) => SmartContextMenu(
                  controller: controller,
                  config: SmartContextMenuTheme.of(context).copyWith(
                    activationMode: SmartContextMenuActivationMode.manual,
                  ),
                  items: items,
                  headerSliversBuilder: _headerBuilder(title),
                  child: DemoCard(title: title, subtitle: subtitle),
                ),
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
    double? height,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SmartContextMenu(
        items: items,
        onPreviewTap: () => debugPrint('Preview tapped: $title'),
        headerSliversBuilder: _headerBuilder(title),
        child: DemoCard(title: title, subtitle: subtitle, height: height),
      ),
    );
  }

  /// Reactions above the preview that scale in from its edge; the tall
  /// header adds a 240-tall block below them, so the header does not fit
  /// above most widgets. With [_pinHeader], the reactions stay at the top
  /// while a tall widget and its menu scroll.
  SmartContextMenuHeaderBuilder? _headerBuilder(String title) {
    if (_header == _Header.none) return null;

    return (context, header) {
      final reactions = Align(
        alignment: header.alignment,
        child: ScaleTransition(
          scale: header.animation.drive(CurveTween(curve: Curves.easeOutBack)),
          // Grows from the bottom edge, next to the preview.
          alignment: Alignment(header.alignment.x, 1),
          child: ReactionsBar(
            onSelected: (reaction) async {
              await header.close();
              debugPrint('Reaction $reaction: $title');
            },
          ),
        ),
      );

      return [
        if (_pinHeader)
          PinnedHeaderSliver(child: reactions)
        else
          SliverToBoxAdapter(child: reactions),
        if (_header == _Header.tall)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: header.alignment,
                child: const SizedBox(
                  width: 240,
                  height: 240,
                  child: DemoCard(
                    title: 'Tall header',
                    subtitle: 'A sliver above the preview',
                  ),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
      ];
    };
  }
}
