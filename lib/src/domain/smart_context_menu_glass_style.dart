import 'dart:ui' show Brightness, Offset;

import 'package:flutter/widgets.dart' show BorderSide, Color, immutable;
import 'package:meta/meta.dart' show internal;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_blur.dart';

/// The tint, border and optical effects of the Liquid Glass menu surface.
///
/// Pass it to [SmartContextMenuStyle.glassStyle]. The same style can be used for
/// one menu or shared through [SmartContextMenuTheme].
@immutable
final class SmartContextMenuGlassStyle {
  static const _lightBlur = SmartContextMenuBlur(2);
  static const _darkBlur = SmartContextMenuBlur(1.8);
  // Matches Impeller's Gaussian blur limit and bounds the capture expansion.
  static const _maxBlur = SmartContextMenuBlur(500);

  /// The tint of the glass. Its alpha sets the opacity of the tint.
  ///
  /// A `CupertinoDynamicColor` is resolved at the menu anchor when the menu
  /// opens. Channels are limited to 0–1 and non-finite channels become zero.
  /// Defaults to [SmartContextMenuDefaults.glassTint].
  final Color color;

  /// The blur applied to the backdrop inside the glass before refraction.
  ///
  /// With no explicit value, this getter returns a Gaussian sigma of 2 and
  /// the menu uses 1.8 when opened from a dark anchor. Use
  /// [SmartContextMenuBlur.none] to disable it. The renderer limits finite
  /// strengths to 500 and treats non-finite strengths as zero.
  SmartContextMenuBlur get blur => _blur ?? _lightBlur;
  final SmartContextMenuBlur? _blur;

  /// A multiplier for the displacement at the edge and the magnification
  /// through the pane.
  ///
  /// Defaults to 1. Use 0 for a flat tinted pane. Finite values above 1
  /// strengthen the effect, subject to the edge displacement limit.
  /// Negative and non-finite values are rendered as 0.
  final double refraction;

  /// A multiplier for the reflections along the edge of the glass.
  ///
  /// With no explicit value, this getter returns 1 and the menu uses 0.45
  /// when opened from a dark anchor. Use 0 to remove the edge highlight.
  /// Finite values above 1 strengthen it. Negative and non-finite values
  /// are rendered as 0.
  double get edgeHighlight => _edgeHighlight ?? 1;
  final double? _edgeHighlight;

  /// The width of the rim reflection in logical pixels. Defaults to 5.8.
  ///
  /// Zero, negative and non-finite values hide the rim reflection. The
  /// inner Fresnel reflection follows the [bevelWidth].
  final double rimWidth;

  /// The maximum width of the refracting bevel in logical pixels.
  /// Defaults to 24. The corner radii and panel geometry bound the bevel.
  ///
  /// Zero, negative and non-finite values disable refraction at the edge.
  /// Center magnification still follows [refraction].
  final double bevelWidth;

  /// The direction towards the light in screen coordinates. Positive x
  /// points right and positive y points down. Defaults to the upper left.
  ///
  /// The renderer normalizes the vector. [Offset.zero] and non-finite
  /// vectors leave only the ambient rim reflection.
  final Offset lightDirection;

  /// The border drawn over the glass and its contents.
  ///
  /// Defaults to [BorderSide.none]. Set a [BorderSide] to choose the color,
  /// width and stroke alignment. A `CupertinoDynamicColor` is resolved at the
  /// menu anchor when the menu opens. A border with invalid geometry is hidden.
  final BorderSide border;

  /// Creates a Liquid Glass style.
  const SmartContextMenuGlassStyle({
    this.color = SmartContextMenuDefaults.glassTint,
    SmartContextMenuBlur? blur,
    this.refraction = 1,
    double? edgeHighlight,
    this.rimWidth = 5.8,
    this.bevelWidth = 24,
    this.lightDirection = const Offset(-0.6, -0.8),
    this.border = BorderSide.none,
  }) : _blur = blur,
       _edgeHighlight = edgeHighlight;

  /// Resolves the local blur for the brightness at the menu anchor.
  @internal
  SmartContextMenuBlur resolveBlur(Brightness brightness) {
    final blur =
        _blur ?? (brightness == Brightness.dark ? _darkBlur : _lightBlur);
    final sigma = blur.sigmaX;
    if (!sigma.isFinite || sigma < 0) return SmartContextMenuBlur.none;
    return sigma > _maxBlur.sigmaX ? _maxBlur : blur;
  }

  /// Resolves the multiplier for the brightness at the menu anchor.
  @internal
  double resolveEdgeHighlight(Brightness brightness) =>
      _edgeHighlight ?? (brightness == Brightness.dark ? 0.45 : 1);

  /// Creates a copy with the given fields replaced.
  SmartContextMenuGlassStyle copyWith({
    Color? color,
    SmartContextMenuBlur? blur,
    double? refraction,
    double? edgeHighlight,
    double? rimWidth,
    double? bevelWidth,
    Offset? lightDirection,
    BorderSide? border,
  }) {
    return SmartContextMenuGlassStyle(
      color: color ?? this.color,
      blur: blur ?? _blur,
      refraction: refraction ?? this.refraction,
      edgeHighlight: edgeHighlight ?? _edgeHighlight,
      rimWidth: rimWidth ?? this.rimWidth,
      bevelWidth: bevelWidth ?? this.bevelWidth,
      lightDirection: lightDirection ?? this.lightDirection,
      border: border ?? this.border,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartContextMenuGlassStyle &&
          color == other.color &&
          _blur?.sigmaX == other._blur?.sigmaX &&
          _blur?.sigmaY == other._blur?.sigmaY &&
          refraction == other.refraction &&
          _edgeHighlight == other._edgeHighlight &&
          rimWidth == other.rimWidth &&
          bevelWidth == other.bevelWidth &&
          lightDirection == other.lightDirection &&
          border == other.border;

  @override
  int get hashCode => Object.hash(
    color,
    _blur?.sigmaX,
    _blur?.sigmaY,
    refraction,
    _edgeHighlight,
    rimWidth,
    bevelWidth,
    lightDirection,
    border,
  );
}
