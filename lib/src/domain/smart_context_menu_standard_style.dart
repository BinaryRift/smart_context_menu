import 'package:flutter/widgets.dart'
    show BorderSide, Color, Decoration, Offset, immutable;
import 'package:meta/meta.dart' show internal;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_blur.dart';

/// The appearance of the standard panel, including when Glass falls back to it.
@immutable
final class SmartContextMenuStandardStyle {
  /// The color of the panel and the default fill of its pinned Back item.
  ///
  /// The alpha controls the opacity. A [decoration] supplies its own fill
  /// for the panel. A Back item can also have its own color or decoration.
  final Color color;

  /// The uniform border drawn over the panel and its contents.
  ///
  /// Defaults to [BorderSide.none]. Set a [BorderSide] to choose the color,
  /// width and stroke alignment. A [decoration] supplies its own outline.
  BorderSide get border => _border ?? BorderSide.none;
  final BorderSide? _border;

  /// The blur of the backdrop within the panel's outline. Defaults to null.
  final SmartContextMenuBlur? blur;

  /// Whether to draw a directional highlight along the panel's outline.
  ///
  /// Defaults to true and applies to the built-in appearance. With a visible
  /// [border], the highlight uses its width, alignment and opacity. Otherwise
  /// it draws a one-logical-pixel highlight inside the outline.
  final bool showEdgeHighlight;

  /// The direction towards the highlight in the panel's coordinates.
  ///
  /// Positive x points right and positive y points down. The relative
  /// components place the bright end of the gradient along the panel's bounds.
  /// Defaults to the upper left, also used for zero and non-finite vectors.
  final Offset lightDirection;

  /// A complete replacement for the built-in panel fill, border and highlight.
  ///
  /// The decoration also determines how the contents are clipped. The local
  /// [blur], menu shadows and Back item keep their own settings.
  final Decoration? decoration;

  /// Creates a standard panel style.
  const SmartContextMenuStandardStyle({
    this.color = SmartContextMenuDefaults.menuColor,
    BorderSide? border,
    this.blur,
    this.showEdgeHighlight = true,
    this.lightDirection = const Offset(-1, -1),
    this.decoration,
  }) : _border = border;

  /// Uses the legacy one-pixel border when only a border color was supplied.
  @internal
  BorderSide borderWithLegacyColor(Color color) =>
      _border?.copyWith(color: color) ?? BorderSide(color: color);

  /// Creates a copy with the given fields replaced.
  ///
  /// Null arguments keep the current values. To clear a nullable field,
  /// create a new style with that field omitted.
  SmartContextMenuStandardStyle copyWith({
    Color? color,
    BorderSide? border,
    SmartContextMenuBlur? blur,
    bool? showEdgeHighlight,
    Offset? lightDirection,
    Decoration? decoration,
  }) {
    return SmartContextMenuStandardStyle(
      color: color ?? this.color,
      border: border ?? _border,
      blur: blur ?? this.blur,
      showEdgeHighlight: showEdgeHighlight ?? this.showEdgeHighlight,
      lightDirection: lightDirection ?? this.lightDirection,
      decoration: decoration ?? this.decoration,
    );
  }
}
