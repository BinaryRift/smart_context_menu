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
    var readyNotifications = 0;
    final ready = shader.ready.listen((_) => readyNotifications++);
    final notificationsDone = ready.asFuture<void>();
    addTearDown(ready.cancel);

    final preparation = shader.prepare();
    expect(shader.prepare(), same(preparation));
    expect(shader.program, isNull);
    expect(readyNotifications, 0);

    load.complete(program);
    await preparation;
    await notificationsDone;

    expect(shader.program, same(program));
    expect(shader.prepare(), isNull);
    expect(loads, 1);
    expect(readyNotifications, 1);
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

  testWidgets('selects ready Glass and resolves colors at the anchor', (
    tester,
  ) async {
    const tint = CupertinoDynamicColor.withBrightness(
      color: Color(0x90FFFFFF),
      darkColor: Color(0x90123456),
    );
    const borderColor = CupertinoDynamicColor.withBrightness(
      color: Color(0x6633FF99),
      darkColor: Color(0x9933FF99),
    );
    const style = SmartContextMenuGlassStyle(
      color: tint,
      blur: SmartContextMenuBlur(5),
      refraction: 2,
      edgeHighlight: 0,
      rimWidth: 3,
      bevelWidth: 12,
      lightDirection: Offset(1, 2),
      border: BorderSide(
        color: borderColor,
        width: 2,
        strokeAlign: BorderSide.strokeAlignCenter,
      ),
    );
    const glass = SmartContextMenuStyle(glassStyle: style);
    final standard = glass.copyWith(surface: SmartContextMenuSurface.standard);
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

    expect(shader.select(glass, anchor, highContrast: true), isNull);
    expect(shader.select(standard, anchor, highContrast: false), isNull);
    expect(loadCount, 0);

    expect(shader.select(glass, anchor, highContrast: false), isNull);
    final ready = shader.prepare();
    load.complete(program!);
    await ready;

    expect(shader.select(glass, anchor, highContrast: true), isNull);
    expect(shader.select(standard, anchor, highContrast: false), isNull);
    final selected = shader.select(glass, anchor, highContrast: false)!;
    expect(selected.program, same(program));
    expect(selected.style.color, isSameColorAs(tint.darkColor));
    expect(selected.style.blur, same(style.blur));
    expect(selected.style.refraction, style.refraction);
    expect(selected.style.edgeHighlight, style.edgeHighlight);
    expect(selected.style.rimWidth, 3);
    expect(selected.style.bevelWidth, 12);
    expect(selected.style.lightDirection, const Offset(1, 2));
    expect(selected.style.border.color, isSameColorAs(borderColor.darkColor));
    expect(selected.style.border.width, style.border.width);
    expect(selected.style.border.strokeAlign, style.border.strokeAlign);

    const defaults = SmartContextMenuStyle();
    final darkGlass = shader.select(defaults, anchor, highContrast: false)!;
    expect(darkGlass.style.color, isSameColorAs(const Color(0x862C2D30)));
    expect(darkGlass.style.edgeHighlight, 0.45);
    expect(darkGlass.style.blur.sigmaX, 1.8);
    expect(darkGlass.style.blur.sigmaY, 1.8);
    final explicitBlur = defaults.glassStyle.copyWith(
      blur: const SmartContextMenuBlur(2),
    );
    expect(explicitBlur, isNot(defaults.glassStyle));
    final custom = defaults.copyWith(
      glassStyle: explicitBlur.copyWith(edgeHighlight: 1),
    );
    final customGlass = shader.select(custom, anchor, highContrast: false)!;
    expect(customGlass.style.edgeHighlight, 1);
    expect(customGlass.style.blur.sigmaX, 2);

    const extremeStyle = SmartContextMenuGlassStyle(
      color: Color.from(alpha: 2, red: double.nan, green: -1, blue: 2),
      blur: SmartContextMenuBlur(double.maxFinite),
      border: BorderSide(
        color: Color.from(alpha: double.infinity, red: 1, green: 0, blue: 0),
      ),
    );
    final bounded = shader.select(
      const SmartContextMenuStyle(glassStyle: extremeStyle),
      anchor,
      highContrast: false,
    )!;
    expect(bounded.style.color, isSameColorAs(const Color(0xFF0000FF)));
    expect(bounded.style.border.color, isSameColorAs(const Color(0x00FF0000)));
    expect(bounded.style.blur.sigmaX, 500);
    expect(bounded.style.blur.sigmaY, 500);

    final withoutBlur = shader.select(
      defaults.copyWith(
        glassStyle: defaults.glassStyle.copyWith(
          blur: const SmartContextMenuBlur(double.infinity),
        ),
      ),
      anchor,
      highContrast: false,
    )!;
    expect(withoutBlur.style.blur, same(SmartContextMenuBlur.none));

    await tester.pumpWidget(
      const CupertinoTheme(
        data: CupertinoThemeData(brightness: Brightness.light),
        child: SizedBox(),
      ),
    );
    final lightGlass = shader.select(
      defaults,
      tester.element(find.byType(SizedBox)),
      highContrast: false,
    )!;
    expect(lightGlass.style.color, isSameColorAs(const Color(0x92F7FAFF)));
    expect(lightGlass.style.edgeHighlight, 1);
    expect(lightGlass.style.blur.sigmaX, 2);
    expect(loadCount, 1);
  });
}
