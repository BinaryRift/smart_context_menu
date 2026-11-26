import 'dart:ui' as ui;

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
