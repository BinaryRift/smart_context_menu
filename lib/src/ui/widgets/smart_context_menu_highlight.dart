import 'dart:math' as math;
import 'dart:ui' as ui show Brightness;

import 'package:flutter/widgets.dart';

/// Paints a directional highlight along the standard panel's outline.
final class SmartContextMenuHighlightPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final BorderSide border;
  final ui.Brightness brightness;
  final Offset lightDirection;

  const SmartContextMenuHighlightPainter({
    required this.borderRadius,
    required this.border,
    required this.brightness,
    required this.lightDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const white = Color(0xFFFFFFFF);
    final strength =
        border.color.a * (brightness == ui.Brightness.dark ? 0.62 : 1);
    final contour = borderRadius.toRRect(Offset.zero & size).scaleRadii();
    final extent = math.max(lightDirection.dx.abs(), lightDirection.dy.abs());
    final start = extent.isFinite && extent > 0
        ? Alignment(lightDirection.dx / extent, lightDirection.dy / extent)
        : Alignment.topLeft;
    final gradient = LinearGradient(
      begin: start,
      end: Alignment(-start.x, -start.y),
      colors: [
        white.withValues(alpha: 0.78 * strength),
        white.withValues(alpha: 0.28 * strength),
        white.withValues(alpha: 0),
      ],
    );
    final paint = Paint()..shader = gradient.createShader(contour.outerRect);
    if (border.width == 0) {
      canvas.drawRRect(contour, paint..style = PaintingStyle.stroke);
      return;
    }
    canvas.drawDRRect(
      contour.inflate(border.strokeOutset),
      contour.deflate(border.strokeInset),
      paint,
    );
  }

  @override
  bool shouldRepaint(SmartContextMenuHighlightPainter oldDelegate) =>
      borderRadius != oldDelegate.borderRadius ||
      border != oldDelegate.border ||
      brightness != oldDelegate.brightness ||
      lightDirection != oldDelegate.lightDirection;
}
