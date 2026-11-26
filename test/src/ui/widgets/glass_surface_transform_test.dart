import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_surface.dart';

void main() {
  test('aligns backdrop capture to physical pixels after stretch', () {
    final clip = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 250, 265),
      const Radius.circular(16),
    );
    const origin = Offset(228.672, 904.147);
    const scale = Offset(3.0192, 3.0022);
    final aligned = glassBackdropClip(clip, origin: origin, scale: scale);

    void expectAligned(double original, double adjusted) {
      final pixel = original.roundToDouble();
      expect(adjusted, greaterThan(pixel));
      expect(adjusted, closeTo(pixel, 0.03));
    }

    expectAligned(origin.dx, origin.dx + aligned.left * scale.dx);
    expectAligned(origin.dy, origin.dy + aligned.top * scale.dy);
    expectAligned(
      origin.dx + clip.right * scale.dx,
      origin.dx + aligned.right * scale.dx,
    );
    expectAligned(
      origin.dy + clip.bottom * scale.dy,
      origin.dy + aligned.bottom * scale.dy,
    );
    expect(aligned.tlRadius, clip.tlRadius);
  });

  test('glass shader multipliers fit a nonnegative float32', () {
    for (final value in [
      -1.0,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(glassShaderMultiplier(value), 0);
    }
    expect(glassShaderMultiplier(0), 0);
    expect(glassShaderMultiplier(1), 1);
    expect(glassShaderMultiplier(3), 3);
    final largest = Float32List.fromList([
      glassShaderMultiplier(double.maxFinite),
    ]).single;
    expect(largest.isFinite, isTrue);
    expect(largest, greaterThan(3.4e38));
  });

  testWidgets('keeps content visible when a filter cannot be applied', (
    tester,
  ) async {
    final program = await tester.runAsync(
      () => ui.FragmentProgram.fromAsset(
        'lib/src/ui/shaders/smart_context_menu_glass.frag',
      ),
    );
    Widget build(double angle) => Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Transform.rotate(
          angle: angle,
          child: SizedBox(
            width: 200,
            height: 100,
            child: SmartContextMenuGlassSurface(
              program: program!,
              opacity: const AlwaysStoppedAnimation(1),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              shadows: const [],
              style: const SmartContextMenuGlassStyle(tint: Color(0x80FFFFFF)),
              child: const Text('Content'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(build(0.3));
    expect(tester.takeException(), isNull);
    expect(find.text('Content'), findsOneWidget);

    // Mounting the surface directly bypasses the loader's support check.
    await tester.pumpWidget(build(0));
    expect(tester.takeException(), isNull);
    expect(find.text('Content'), findsOneWidget);
  });
}
