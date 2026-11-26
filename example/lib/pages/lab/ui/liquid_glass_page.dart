import 'dart:ui' show FragmentProgram, ImageFilter;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
// The Lab opts in before the glass style is available in the public API.
// ignore: implementation_imports
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_scope.dart';

import '../../settings/ui/widgets/settings_button.dart';

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

  late final Future<FragmentProgram>? _program;
  _Surface _surface = _Surface.glass;
  bool _useSoftBackground = false;

  @override
  void initState() {
    super.initState();
    _program = ImageFilter.isShaderFilterSupported
        ? FragmentProgram.fromAsset(SmartContextMenuGlassScope.shaderAsset)
        : null;
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
        child: FutureBuilder<FragmentProgram>(
          future: _program,
          builder: (context, snapshot) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildOptions(snapshot)),
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
                child: _buildPreview(context, snapshot.data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, FragmentProgram? program) {
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
                child: _buildMenu(context, program),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(AsyncSnapshot<FragmentProgram> snapshot) {
    final glassAvailable = snapshot.hasData;
    final String? status = glassAvailable
        ? null
        : _program == null
        ? 'Liquid Glass requires Impeller.'
        : snapshot.hasError
        ? 'Could not load the glass shader.'
        : 'Loading the glass shader…';

    return CupertinoListSection.insetGrouped(
      header: const Text('Options'),
      footer: status == null ? null : Text(status),
      children: [
        CupertinoListTile.notched(
          title: const Text('Surface'),
          trailing: CupertinoSlidingSegmentedControl<_Surface>(
            groupValue: glassAvailable ? _surface : _Surface.standard,
            disabledChildren: glassAvailable
                ? const {}
                : const {_Surface.glass},
            onValueChanged: (value) {
              if (value != null) setState(() => _surface = value);
            },
            children: const {
              _Surface.standard: Text('Standard'),
              _Surface.glass: Text('Glass'),
            },
          ),
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

    if (program == null || _surface == _Surface.standard) return menu;
    return SmartContextMenuGlassScope(program: program, child: menu);
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
