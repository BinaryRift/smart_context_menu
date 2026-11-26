import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_surface.dart';

void main() {
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

  testWidgets('paints content without glass under a rotation and resumes', (
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

    await tester.pumpWidget(build(0));
    // The test engine rejects shader filters, so the error shows that the
    // glass is requested again.
    final error = tester.takeException();
    if (ui.ImageFilter.isShaderFilterSupported) {
      expect(error, isNull);
    } else {
      expect(error, isUnsupportedError);
    }
  });
}
