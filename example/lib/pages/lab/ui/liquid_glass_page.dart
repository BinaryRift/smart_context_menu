import 'dart:ui' show FragmentProgram, ImageFilter;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
// The Lab opts in through the package's internal prototype.
// ignore: implementation_imports
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_prototype.dart';

import '../../settings/ui/widgets/settings_button.dart';

enum _Surface { current, glass, wholeFade }

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

  late final Future<FragmentProgram>? _program;
  _Surface _surface = _Surface.current;
  bool _useSoftBackground = false;

  @override
  void initState() {
    super.initState();
    _program = ImageFilter.isShaderFilterSupported
        ? FragmentProgram.fromAsset(SmartContextMenuGlassPrototype.shaderAsset)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Liquid Glass'),
        trailing: SettingsButton(),
      ),
      child: FutureBuilder<FragmentProgram>(
        future: _program,
        builder: (context, snapshot) {
          final program = snapshot.data;
          return Stack(
            fit: StackFit.expand,
            children: [
              const CustomPaint(painter: _ContrastPattern()),
              SafeArea(
                minimum: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    if (program != null)
                      CupertinoSlidingSegmentedControl<_Surface>(
                        groupValue: _surface,
                        onValueChanged: (value) {
                          if (value != null) setState(() => _surface = value);
                        },
                        children: const {
                          _Surface.current: Text('Current'),
                          _Surface.glass: Text('Glass'),
                          _Surface.wholeFade: Text('Whole fade'),
                        },
                      )
                    else
                      Text(
                        _program == null
                            ? 'Glass requires Impeller'
                            : snapshot.hasError
                            ? 'Could not load the glass shader'
                            : 'Loading the glass shader…',
                      ),
                    CupertinoListSection.insetGrouped(
                      margin: const EdgeInsets.only(top: 12),
                      children: [
                        CupertinoListTile.notched(
                          title: const Text('Half dimming + blur'),
                          trailing: CupertinoSwitch(
                            value: _useSoftBackground,
                            onChanged: (value) =>
                                setState(() => _useSoftBackground = value),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Align(
                        alignment: const AlignmentDirectional(1, 0.12),
                        child: _buildMenu(context, program),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenu(BuildContext context, FragmentProgram? program) {
    final theme = SmartContextMenuTheme.of(context);
    final menu = SmartContextMenu(
      config: theme.copyWith(
        style: SmartContextMenuStyle(
          menuBlur: SmartContextMenuBlur.small,
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

    if (program == null || _surface == _Surface.current) return menu;
    return SmartContextMenuGlassPrototype(
      program: program,
      fadeWholeMenu: _surface == _Surface.wholeFade,
      child: menu,
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
      final y = size.height * (0.36 + i * 0.115);
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
