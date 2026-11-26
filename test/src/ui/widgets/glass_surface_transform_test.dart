import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_surface.dart';

void main() {
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
              tint: const Color(0x80FFFFFF),
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
