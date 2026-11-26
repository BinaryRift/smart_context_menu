import 'dart:async';
import 'dart:ui' show FragmentProgram;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/state/smart_context_menu_glass_shader.dart';

const _shaderAsset = 'lib/src/ui/shaders/smart_context_menu_glass.frag';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('skips loading when filters are unsupported', () {
    var loads = 0;
    final shader = SmartContextMenuGlassShader(
      isSupported: () => false,
      load: () {
        loads++;
        return FragmentProgram.fromAsset(_shaderAsset);
      },
    );

    expect(shader.prepare(), isNull);
    expect(shader.program, isNull);
    expect(loads, 0);
  });

  test('shares the pending load and reuses the resulting program', () async {
    final program = await FragmentProgram.fromAsset(_shaderAsset);
    final load = Completer<FragmentProgram>();
    var loads = 0;
    final shader = SmartContextMenuGlassShader(
      isSupported: () => true,
      load: () {
        loads++;
        return load.future;
      },
    );

    final preparation = shader.prepare();
    expect(shader.prepare(), same(preparation));
    expect(shader.program, isNull);

    load.complete(program);
    await preparation;

    expect(shader.program, same(program));
    expect(shader.prepare(), isNull);
    expect(loads, 1);
  });

  test(
    'leaves the program unavailable on failure and allows another load',
    () async {
      var loads = 0;
      final shader = SmartContextMenuGlassShader(
        isSupported: () => true,
        load: () {
          loads++;
          if (loads == 1) throw StateError('Shader asset unavailable');
          return FragmentProgram.fromAsset(_shaderAsset);
        },
      );

      await shader.prepare();
      expect(shader.program, isNull);

      await shader.prepare();
      expect(shader.program, isNotNull);
      expect(loads, 2);
    },
  );

  testWidgets('selects ready Glass and resolves its tint at the anchor', (
    tester,
  ) async {
    const tint = CupertinoDynamicColor.withBrightness(
      color: Color(0x90FFFFFF),
      darkColor: Color(0x90123456),
    );
    const style = SmartContextMenuGlassStyle(
      tint: tint,
      blur: SmartContextMenuBlur(5),
      refraction: 2,
      edgeHighlight: 0,
    );
    const surface = SmartContextMenuSurface.glass(style);
    final program = await tester.runAsync(
      () => FragmentProgram.fromAsset(_shaderAsset),
    );
    final load = Completer<FragmentProgram>();
    var loadCount = 0;
    final shader = SmartContextMenuGlassShader(
      isSupported: () => true,
      load: () {
        loadCount++;
        return load.future;
      },
    );
    await tester.pumpWidget(
      const CupertinoTheme(
        data: CupertinoThemeData(brightness: Brightness.dark),
        child: SizedBox(),
      ),
    );
    final anchor = tester.element(find.byType(SizedBox));

    expect(shader.select(surface, anchor, highContrast: true), isNull);
    expect(
      shader.select(
        SmartContextMenuSurface.standard,
        anchor,
        highContrast: false,
      ),
      isNull,
    );
    expect(loadCount, 0);

    expect(shader.select(surface, anchor, highContrast: false), isNull);
    final ready = shader.prepare();
    load.complete(program!);
    await ready;

    expect(shader.select(surface, anchor, highContrast: true), isNull);
    expect(
      shader.select(
        SmartContextMenuSurface.standard,
        anchor,
        highContrast: false,
      ),
      isNull,
    );
    final selected = shader.select(surface, anchor, highContrast: false)!;
    expect(selected.program, same(program));
    expect(selected.style.tint, isSameColorAs(tint.darkColor));
    expect(selected.style.blur, same(style.blur));
    expect(selected.style.refraction, style.refraction);
    expect(selected.style.edgeHighlight, style.edgeHighlight);
    expect(loadCount, 1);
  });
}
