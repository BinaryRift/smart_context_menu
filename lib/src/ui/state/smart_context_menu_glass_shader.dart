import 'dart:async' show StreamController, unawaited;
import 'dart:ui' as ui;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show CupertinoDynamicColor, CupertinoTheme;
import 'package:flutter/widgets.dart' show BuildContext;

import '../../domain/smart_context_menu_glass_style.dart';
import '../../domain/smart_context_menu_style.dart';
import '../../domain/smart_context_menu_surface.dart';

/// The shader program and resolved style for one menu opening.
typedef SmartContextMenuResolvedGlass = ({
  ui.FragmentProgram program,
  SmartContextMenuGlassStyle style,
});

/// Shares the pending load and the resulting program across panels.
final class SmartContextMenuGlassShader {
  static final shared = SmartContextMenuGlassShader();

  static const _asset =
      'packages/smart_context_menu/lib/src/ui/shaders/smart_context_menu_glass.frag';

  final bool Function() _isSupported;
  final Future<ui.FragmentProgram> Function() _load;
  final _ready = StreamController<void>.broadcast();

  Future<void>? _pending;
  ui.FragmentProgram? _program;

  SmartContextMenuGlassShader({
    bool Function()? isSupported,
    Future<ui.FragmentProgram> Function()? load,
  }) : _isSupported = isSupported ?? _supportsShaderFilter,
       _load = load ?? _loadAsset;

  ui.FragmentProgram? get program => _isSupported() ? _program : null;

  /// Emits once when the program becomes ready, including after a retry.
  Stream<void> get ready => _ready.stream;

  /// Selects Glass only if its program is ready when the menu opens.
  /// A load started here can make Glass available on a later opening.
  SmartContextMenuResolvedGlass? select(
    SmartContextMenuStyle menuStyle,
    BuildContext anchorContext, {
    required bool highContrast,
  }) {
    if (menuStyle.surface != SmartContextMenuSurface.glass || highContrast) {
      return null;
    }

    final glass = resolveReady(menuStyle.glassStyle, anchorContext);
    unawaited(prepare());
    return glass;
  }

  /// Resolves the glass style if the program is already available.
  SmartContextMenuResolvedGlass? resolveReady(
    SmartContextMenuGlassStyle style,
    BuildContext context,
  ) {
    final readyProgram = program;
    if (readyProgram == null) return null;

    final color = _resolveColor(style.color, context);
    final brightness =
        CupertinoTheme.maybeBrightnessOf(context) ?? ui.Brightness.light;
    final border = style.border.copyWith(
      color: _resolveColor(style.border.color, context),
    );
    return (
      program: readyProgram,
      style: style.copyWith(
        color: color,
        border: border,
        blur: style.resolveBlur(brightness),
        edgeHighlight: style.resolveEdgeHighlight(brightness),
      ),
    );
  }

  static ui.Color _resolveColor(ui.Color color, BuildContext context) {
    final resolved = CupertinoDynamicColor.resolve(color, context);
    double channel(double value) => value.isFinite ? value.clamp(0.0, 1.0) : 0;

    final red = channel(resolved.r);
    final green = channel(resolved.g);
    final blue = channel(resolved.b);
    final alpha = channel(resolved.a);
    if (red == resolved.r &&
        green == resolved.g &&
        blue == resolved.b &&
        alpha == resolved.a) {
      return resolved;
    }
    return resolved.withValues(
      red: red,
      green: green,
      blue: blue,
      alpha: alpha,
    );
  }

  Future<void>? prepare() {
    if (!_isSupported() || _program != null) return null;
    return _pending ??= _loadProgram();
  }

  Future<void> _loadProgram() async {
    try {
      _program = await Future<ui.FragmentProgram>.sync(_load);
    } catch (_) {
      // The standard menu remains available. Another opening can retry.
    } finally {
      _pending = null;
    }
    if (_program != null) {
      _ready.add(null);
      unawaited(_ready.close());
    }
  }

  static bool _supportsShaderFilter() => ui.ImageFilter.isShaderFilterSupported;

  static Future<ui.FragmentProgram> _loadAsset() =>
      ui.FragmentProgram.fromAsset(_asset);
}
