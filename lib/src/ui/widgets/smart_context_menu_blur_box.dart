import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_blur.dart';

/// Blurs what is behind [child] within [borderRadius].
///
/// Without [blur], shows [child] as is.
final class SmartContextMenuBlurBox extends StatelessWidget {
  final SmartContextMenuBlur? blur;
  final BorderRadiusGeometry borderRadius;

  /// Multiplier applied to both blur sigmas.
  final double strength;
  final Widget child;

  const SmartContextMenuBlurBox({
    super.key,
    required this.blur,
    required this.borderRadius,
    this.strength = 1,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final blur = this.blur;
    if (blur == null) return child;

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        enabled: strength > 0,
        filter: ImageFilter.blur(
          sigmaX: blur.sigmaX * strength,
          sigmaY: blur.sigmaY * strength,
        ),
        child: child,
      ),
    );
  }
}
