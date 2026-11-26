import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_surface.dart';

void main() {
  const size = Size(250, 120);

  test('maps translation and per-axis scale to backdrop pixels', () {
    final transform = Matrix4.translationValues(30, 40, 0)
      ..scaleByDouble(1.5, 0.75, 1, 1);

    final mapping = glassBackdropMapping(transform, size, 2)!;
    expect(mapping.origin, const Offset(60, 80));
    expect(mapping.scale, const Offset(3, 1.5));
  });

  test('ignores rounding noise in an axis-aligned transform', () {
    final transform = Matrix4.identity()
      ..setEntry(0, 1, 1e-9)
      ..setEntry(3, 3, 1 + 1e-9);

    expect(glassBackdropMapping(transform, size, 3), isNotNull);
  });

  test('rejects transforms the contour cannot follow', () {
    final transforms = {
      'rotation': Matrix4.rotationZ(math.pi / 12),
      'skew': Matrix4.skewX(0.2),
      'perspective': Matrix4.identity()..setEntry(3, 0, 0.001),
      'mirror': Matrix4.diagonal3Values(-1, 1, 1),
      'collapsed axis': Matrix4.diagonal3Values(1, 0, 1),
      'infinite offset': Matrix4.translationValues(double.infinity, 0, 0),
      'NaN scale': Matrix4.diagonal3Values(double.nan, 1, 1),
    };

    for (final MapEntry(:key, :value) in transforms.entries) {
      expect(glassBackdropMapping(value, size, 2), isNull, reason: key);
    }
  });

  test('rejects invalid sizes and pixel ratios', () {
    final transform = Matrix4.identity();

    for (final invalid in const [
      Size.zero,
      Size(0, 40),
      Size(double.infinity, 40),
      Size(40, double.nan),
    ]) {
      expect(glassBackdropMapping(transform, invalid, 2), isNull);
    }
    for (final ratio in const [0.0, -1.0, double.nan, double.infinity]) {
      expect(glassBackdropMapping(transform, size, ratio), isNull);
    }
  });
}
