import 'dart:async' show unawaited;
import 'dart:ui' as ui;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart' show BuildContext;

import '../../domain/smart_context_menu_glass_style.dart';
import '../../domain/smart_context_menu_surface.dart';

/// The shader program and resolved style for one menu opening.
typedef SmartContextMenuResolvedGlass = ({
  ui.FragmentProgram program,
  SmartContextMenuGlassStyle style,
});

/// Shares the pending load and the resulting program across menu openings.
final class SmartContextMenuGlassShader {
  static const _asset =
      'packages/smart_context_menu/lib/src/ui/shaders/smart_context_menu_glass.frag';

  final bool Function() _isSupported;
  final Future<ui.FragmentProgram> Function() _load;

  Future<void>? _pending;
  ui.FragmentProgram? _program;

  SmartContextMenuGlassShader({
    bool Function()? isSupported,
    Future<ui.FragmentProgram> Function()? load,
  }) : _isSupported = isSupported ?? _supportsShaderFilter,
       _load = load ?? _loadAsset;

  ui.FragmentProgram? get program => _isSupported() ? _program : null;

  /// Selects Glass only if its program is ready when the menu opens.
  /// A load started here can make Glass available on a later opening.
  SmartContextMenuResolvedGlass? select(
    SmartContextMenuSurface surface,
    BuildContext anchorContext, {
    required bool highContrast,
  }) {
    final style = surface.glassStyle;
    if (style == null || highContrast) return null;

    final readyProgram = program;
    unawaited(prepare());
    if (readyProgram == null) return null;

    final tint = CupertinoDynamicColor.resolve(style.tint, anchorContext);
    final border = style.border.copyWith(
      color: CupertinoDynamicColor.resolve(style.border.color, anchorContext),
    );
    return (
      program: readyProgram,
      style: style.copyWith(tint: tint, border: border),
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
  }

  static bool _supportsShaderFilter() => ui.ImageFilter.isShaderFilterSupported;

  static Future<ui.FragmentProgram> _loadAsset() =>
      ui.FragmentProgram.fromAsset(_asset);
}
