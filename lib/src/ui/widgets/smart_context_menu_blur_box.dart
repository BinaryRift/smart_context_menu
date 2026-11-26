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

  /// Optional clip for the backdrop filter alone.
  final CustomClipper<RRect>? backdropClipper;
  final Widget child;

  const SmartContextMenuBlurBox({
    super.key,
    required this.blur,
    required this.borderRadius,
    this.strength = 1,
    this.backdropClipper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final blur = this.blur;
    if (blur == null) return child;
    final clipper = backdropClipper;
    final filter = BackdropFilter(
      enabled: strength > 0,
      filter: ImageFilter.blur(
        sigmaX: blur.sigmaX * strength,
        sigmaY: blur.sigmaY * strength,
      ),
      child: clipper == null ? child : const SizedBox.expand(),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: clipper == null
          ? filter
          : Stack(
              fit: StackFit.passthrough,
              children: [
                Positioned.fill(
                  child: ClipRRect(clipper: clipper, child: filter),
                ),
                child,
              ],
            ),
    );
  }
}
