import 'dart:async';
import 'dart:ui' show FragmentProgram;

import 'package:flutter_test/flutter_test.dart';
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
}
