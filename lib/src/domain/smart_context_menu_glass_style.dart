import 'package:flutter/widgets.dart' show BorderSide, Color, immutable;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_blur.dart';

/// The tint, border and optical effects of the Liquid Glass menu surface.
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

  /// The blur applied to the backdrop inside the glass before refraction.
  ///
  /// Defaults to a Gaussian sigma of 2. Use [SmartContextMenuBlur.none] to
  /// disable it. Non-finite strengths are treated as zero.
  final SmartContextMenuBlur blur;

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

  /// The border drawn over the glass and its contents.
  ///
  /// Defaults to [BorderSide.none]. Set a [BorderSide] to choose the color,
  /// width and stroke alignment. A `CupertinoDynamicColor` is resolved at the
  /// menu anchor when the menu opens.
  final BorderSide border;

  /// Creates a Liquid Glass style.
  const SmartContextMenuGlassStyle({
    this.tint = SmartContextMenuDefaults.glassTint,
    this.blur = const SmartContextMenuBlur(2),
    this.refraction = 1,
    this.edgeHighlight = 1,
    this.border = BorderSide.none,
  });

  /// Creates a copy with the given fields replaced.
  SmartContextMenuGlassStyle copyWith({
    Color? tint,
    SmartContextMenuBlur? blur,
    double? refraction,
    double? edgeHighlight,
    BorderSide? border,
  }) {
    return SmartContextMenuGlassStyle(
      tint: tint ?? this.tint,
      blur: blur ?? this.blur,
      refraction: refraction ?? this.refraction,
      edgeHighlight: edgeHighlight ?? this.edgeHighlight,
      border: border ?? this.border,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartContextMenuGlassStyle &&
          tint == other.tint &&
          blur.sigmaX == other.blur.sigmaX &&
          blur.sigmaY == other.blur.sigmaY &&
          refraction == other.refraction &&
          edgeHighlight == other.edgeHighlight &&
          border == other.border;

  @override
  int get hashCode => Object.hash(
    tint,
    blur.sigmaX,
    blur.sigmaY,
    refraction,
    edgeHighlight,
    border,
  );
}
