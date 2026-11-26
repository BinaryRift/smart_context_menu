import 'package:flutter/widgets.dart' show Color, immutable;

import '../core/ui/styles/smart_context_menu_defaults.dart';

/// The tint and optical effects of the Liquid Glass menu surface.
///
/// Pass it to [SmartContextMenuSurface.glass]. The same style can be used for
/// one menu or shared through [SmartContextMenuTheme].
@immutable
final class SmartContextMenuGlassStyle {
  /// The tint of the glass. Its alpha sets the opacity of the tint.
  ///
  /// A `CupertinoDynamicColor` is resolved at the menu anchor when the menu
  /// opens. Defaults to [SmartContextMenuDefaults.glassTint].
  final Color tint;

  /// A multiplier for the displacement at the edge and the magnification
  /// through the pane.
  ///
  /// Defaults to 1. Use 0 for a flat tinted pane. Finite values above 1
  /// strengthen the effect, subject to the edge displacement limit.
  /// Negative and non-finite values are rendered as 0.
  final double refraction;

  /// A multiplier for the reflections along the edge of the glass.
  ///
  /// Defaults to 1. Use 0 to remove the edge highlight. Finite values above 1
  /// strengthen it. Negative and non-finite values are rendered as 0.
  final double edgeHighlight;

  /// Creates a Liquid Glass style.
  const SmartContextMenuGlassStyle({
    this.tint = SmartContextMenuDefaults.glassTint,
    this.refraction = 1,
    this.edgeHighlight = 1,
  });

  /// Creates a copy with the given fields replaced.
  SmartContextMenuGlassStyle copyWith({
    Color? tint,
    double? refraction,
    double? edgeHighlight,
  }) {
    return SmartContextMenuGlassStyle(
      tint: tint ?? this.tint,
      refraction: refraction ?? this.refraction,
      edgeHighlight: edgeHighlight ?? this.edgeHighlight,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartContextMenuGlassStyle &&
          tint == other.tint &&
          refraction == other.refraction &&
          edgeHighlight == other.edgeHighlight;

  @override
  int get hashCode => Object.hash(tint, refraction, edgeHighlight);
}
