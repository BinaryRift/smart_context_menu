import 'dart:ui' as ui show Brightness;

import 'package:flutter/widgets.dart';

/// Paints a directional highlight over the standard border.
final class SmartContextMenuHighlightPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final double borderOpacity;
  final ui.Brightness brightness;

  const SmartContextMenuHighlightPainter({
    required this.borderRadius,
    required this.borderOpacity,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const white = Color(0xFFFFFFFF);
    final strength =
        borderOpacity * (brightness == ui.Brightness.dark ? 0.62 : 1);
    final contour = borderRadius.toRRect(Offset.zero & size).scaleRadii();
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        white.withValues(alpha: 0.78 * strength),
        white.withValues(alpha: 0.28 * strength),
        white.withValues(alpha: 0),
      ],
    );
    // Keep only the inner pixel of the stroke over the existing border.
    canvas
      ..save()
      ..clipRRect(contour)
      ..drawRRect(
        contour,
        Paint()
          ..shader = gradient.createShader(contour.outerRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(SmartContextMenuHighlightPainter oldDelegate) =>
      borderRadius != oldDelegate.borderRadius ||
      borderOpacity != oldDelegate.borderOpacity ||
      brightness != oldDelegate.brightness;
}
