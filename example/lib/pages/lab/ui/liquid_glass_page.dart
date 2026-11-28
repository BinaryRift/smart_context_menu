// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../settings/ui/widgets/settings_button.dart';
import 'liquid_glass_settings_sheet.dart';

enum _Surface { standard, glass }

/// Compares the same menu and background in the real overlay.
final class LiquidGlassPage extends StatefulWidget {
  const LiquidGlassPage({super.key});

  @override
  State<LiquidGlassPage> createState() => _LiquidGlassPageState();
}

final class _LiquidGlassPageState extends State<LiquidGlassPage> {
  static const _standardDimming = SmartContextMenuDefaults.backgroundColor;
  static final _halfDimming = CupertinoDynamicColor.withBrightness(
    color: _standardDimming.color.withValues(
      alpha: _standardDimming.color.a / 2,
    ),
    darkColor: _standardDimming.darkColor.withValues(
      alpha: _standardDimming.darkColor.a / 2,
    ),
  );

  _Surface _surface = _Surface.glass;
  bool _highlightStandard = true;
  bool _useSoftBackground = false;
  var _glassSettings = defaultGlassPreviewSettings;

  Future<void> _editGlass() async {
    final settings = await showCupertinoModalPopup<GlassPreviewSettings>(
      context: context,
      builder: (_) => LiquidGlassSettingsSheet(settings: _glassSettings),
    );
    if (mounted && settings != null) {
      setState(() => _glassSettings = settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Liquid Glass'),
        trailing: SettingsButton(),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildOptions()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Semantics(
                  header: true,
                  child: Text(
                    'Preview',
                    style: CupertinoTheme.of(
                      context,
                    ).textTheme.navTitleTextStyle,
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildPreview(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: const _ContrastPattern(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 320),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: _buildMenu(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Options'),
      footer: kIsWeb
          ? const Text(
              'Liquid Glass is unavailable on the web. '
              'The preview uses Standard.',
            )
          : null,
      children: [
        CupertinoListTile.notched(
          title: const Text('Surface'),
          trailing: CupertinoSlidingSegmentedControl<_Surface>(
            groupValue: _surface,
            onValueChanged: (value) {
              if (value != null) setState(() => _surface = value);
            },
            children: const {
              _Surface.standard: Text('Standard'),
              _Surface.glass: Text('Glass'),
            },
          ),
        ),
        if (_surface == _Surface.standard)
          CupertinoListTile.notched(
            title: const Text('Edge highlight'),
            trailing: CupertinoSwitch(
              value: _highlightStandard,
              onChanged: (value) => setState(() => _highlightStandard = value),
            ),
          ),
        if (_surface == _Surface.glass && !kIsWeb)
          CupertinoListTile.notched(
            title: const Text('Glass settings'),
            trailing: const CupertinoListTileChevron(),
            onTap: _editGlass,
          ),
        CupertinoListTile.notched(
          title: const Text('Half dimming + blur'),
          trailing: CupertinoSwitch(
            value: _useSoftBackground,
            onChanged: (value) => setState(() => _useSoftBackground = value),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    final theme = SmartContextMenuTheme.of(context);
    return SmartContextMenu(
      config: theme.copyWith(
        style: SmartContextMenuStyle(
          surface: _surface == _Surface.glass
              ? SmartContextMenuSurface.glass
              : SmartContextMenuSurface.standard,
          glassStyle: _glassSettings.style.copyWith(
            blur: _glassSettings.blur,
            edgeHighlight: _glassSettings.edgeHighlight,
          ),
          standardStyle: SmartContextMenuStandardStyle(
            blur: SmartContextMenuBlur.small,
            showEdgeHighlight: _surface == _Surface.glass || _highlightStandard,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          backgroundColor: _useSoftBackground ? _halfDimming : _standardDimming,
          backgroundBlur: _useSoftBackground
              ? const SmartContextMenuBlur(1.15)
              : null,
        ),
      ),
      items: [
        _command('Copy', CupertinoIcons.doc_on_doc),
        _command('Duplicate', CupertinoIcons.plus_square_on_square),
        SmartContextMenuItem.submenu(
          title: 'Move to',
          leading: const Icon(CupertinoIcons.folder),
          children: [
            _command('Recents', CupertinoIcons.clock),
            _command('Projects', CupertinoIcons.folder),
            _command('Shared', CupertinoIcons.person_2),
            _command('Archive', CupertinoIcons.archivebox),
            _command('Downloads', CupertinoIcons.arrow_down_circle),
          ],
        ),
        SmartContextMenuItem.submenu(
          title: 'Browse folders',
          leading: const Icon(CupertinoIcons.folder_open),
          children: [
            for (var i = 1; i <= 18; i++)
              _command('Project $i', CupertinoIcons.folder),
          ],
        ),
      ],
      child: Builder(
        builder: (context) => CupertinoButton.filled(
          onPressed: () => SmartContextMenu.of(context).open(),
          child: const Text('Open menu'),
        ),
      ),
    );
  }

  SmartContextMenuItem _command(String title, IconData icon) =>
      SmartContextMenuItem.simple(title: title, leading: Icon(icon));
}

/// The diagonal stripes make small edge displacements easy to see. Different
/// colors and grid marks above and below the menu expose a flipped texture.
final class _ContrastPattern extends CustomPainter {
  const _ContrastPattern();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEDF3F7), Color(0xFF499AB1), Color(0xFF232149)],
        ).createShader(bounds),
    );

    const bands = [
      Color(0xFFF2C35D),
      Color(0xFF1A434D),
      Color(0xFFE88C73),
      Color(0xFF5B4EC0),
      Color(0xFF8AD8CF),
    ];
    final stripe = Paint()..strokeWidth = 23;
    for (var i = 0; i < bands.length; i++) {
      final y = size.height * (0.24 + i * 0.145);
      canvas.drawLine(
        Offset(0, y + size.width * 0.25),
        Offset(size.width, y),
        stripe..color = bands[i],
      );
    }

    final grid = Paint()
      ..color = const Color(0x8CEEF8FC)
      ..strokeWidth = 1;
    for (var x = 20.0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 20.0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(_ContrastPattern oldDelegate) => false;
}
