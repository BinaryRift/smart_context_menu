import 'package:flutter/widgets.dart' show immutable;

import 'smart_context_menu_glass_style.dart';

/// The surface of a [SmartContextMenuStyle].
///
/// The default is [SmartContextMenuSurface.glass]. Use [standard] to always
/// show the standard panel. This choice is shared through [SmartContextMenuTheme]
/// as part of the style. [SmartContextMenuStyle.copyWith] replaces it as a whole.
@immutable
sealed class SmartContextMenuSurface {
  const SmartContextMenuSurface._();

  /// Selects the standard panel styled by [SmartContextMenuStyle].
  static const SmartContextMenuSurface standard = _StandardSurface();

  /// Selects Liquid Glass with the supplied [style].
  ///
  /// The menu opens as [standard] while the shader is unavailable or when the
  /// anchor requests high contrast. The surface is chosen on each opening.
  const factory SmartContextMenuSurface.glass([
    SmartContextMenuGlassStyle style,
  ]) = _GlassSurface;
}

final class _StandardSurface extends SmartContextMenuSurface {
  const _StandardSurface() : super._();
}

final class _GlassSurface extends SmartContextMenuSurface {
  final SmartContextMenuGlassStyle style;

  const _GlassSurface([this.style = const SmartContextMenuGlassStyle()])
    : super._();

  @override
  bool operator ==(Object other) =>
      other is _GlassSurface && style == other.style;

  @override
  int get hashCode => Object.hash(_GlassSurface, style);
}

extension SmartContextMenuSurfaceDetails on SmartContextMenuSurface {
  SmartContextMenuGlassStyle? get glassStyle => switch (this) {
    _GlassSurface(:final style) => style,
    _StandardSurface() => null,
  };
}
