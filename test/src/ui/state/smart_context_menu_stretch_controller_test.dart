import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/state/smart_context_menu_stretch_controller.dart';

const _menuSize = Size(200, 100);

void main() {
  late SmartContextMenuStretchController controller;

  setUp(() => controller = SmartContextMenuStretchController());
  tearDown(() => controller.dispose());

  test('starts without a stretch', () {
    expect(controller.translation, Offset.zero);
    expect(controller.transform, Matrix4.identity());
  });

  test('stretches in proportion to the pointer offset', () {
    controller.stretch(const Offset(50, 25), _menuSize);

    expect(controller.translation, const Offset(2, 2));
    expect(controller.transform.entry(0, 0), closeTo(1.0125, 1e-9));
    expect(controller.transform.entry(1, 1), closeTo(1.01, 1e-9));
  });

  test('limits the stretch to the menu size', () {
    controller.stretch(const Offset(1000, -1000), _menuSize);

    expect(controller.translation, const Offset(8, -8));
    expect(controller.transform.entry(0, 0), closeTo(1.05, 1e-9));
    expect(controller.transform.entry(1, 1), closeTo(1.04, 1e-9));
  });

  test('reset removes the stretch and notifies only once', () {
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.stretch(const Offset(50, 25), _menuSize);
    controller.reset();
    controller.reset();

    expect(notifications, 2);
    expect(controller.translation, Offset.zero);
    expect(controller.transform, Matrix4.identity());
  });
}
