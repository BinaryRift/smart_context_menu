import 'package:flutter/widgets.dart'
    show BorderSide, Color, Decoration, immutable;

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
  /// A [BorderSide] sets the color, width and stroke alignment. Use
  /// [BorderSide.none] to hide it. A [decoration] supplies its own outline.
  final BorderSide border;

  /// The blur of the backdrop within the panel's outline. Defaults to null.
  final SmartContextMenuBlur? blur;

  /// Whether to draw a directional highlight over the standard border.
  ///
  /// Defaults to true. The highlight requires a visible [border] and applies
  /// to the built-in appearance.
  final bool showEdgeHighlight;

  /// A complete replacement for the built-in panel fill, border and highlight.
  ///
  /// The decoration also determines how the contents are clipped. The local
  /// [blur], menu shadows and Back item keep their own settings.
  final Decoration? decoration;

  /// Creates a standard panel style.
  const SmartContextMenuStandardStyle({
    this.color = SmartContextMenuDefaults.menuColor,
    this.border = const BorderSide(color: SmartContextMenuDefaults.borderColor),
    this.blur,
    this.showEdgeHighlight = true,
    this.decoration,
  });

  /// Creates a copy with the given fields replaced.
  ///
  /// Null arguments keep the current values. To clear a nullable field,
  /// create a new style with that field omitted.
  SmartContextMenuStandardStyle copyWith({
    Color? color,
    BorderSide? border,
    SmartContextMenuBlur? blur,
    bool? showEdgeHighlight,
    Decoration? decoration,
  }) {
    return SmartContextMenuStandardStyle(
      color: color ?? this.color,
      border: border ?? this.border,
      blur: blur ?? this.blur,
      showEdgeHighlight: showEdgeHighlight ?? this.showEdgeHighlight,
      decoration: decoration ?? this.decoration,
    );
  }
}
