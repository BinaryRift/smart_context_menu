import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('open and close do nothing when not attached', () async {
    final controller = SmartContextMenuController();

    await controller.open();
    await controller.close();

    expect(controller.isOpen, isFalse);
  });

  test('open and close call the attached menu', () async {
    final calls = <String>[];
    final controller = SmartContextMenuController()
      ..attach(
        open: () async => calls.add('open'),
        close: () async => calls.add('close'),
        isOpen: false,
      );

    await controller.open();
    await controller.close();

    expect(calls, ['open', 'close']);
  });

  test('attach takes the visibility of the menu', () {
    final controller = SmartContextMenuController()
      ..attach(open: () async {}, close: () async {}, isOpen: true);

    expect(controller.isOpen, isTrue);
    expect(controller.isClosed, isFalse);
  });

  test('syncVisibility notifies listeners only on change', () {
    var notifications = 0;
    final controller = SmartContextMenuController()
      ..addListener(() => notifications++);

    controller.syncVisibility(true);
    controller.syncVisibility(true);
    expect(controller.isOpen, isTrue);
    expect(notifications, 1);

    controller.syncVisibility(false);
    expect(controller.isOpen, isFalse);
    expect(notifications, 2);
  });

  test('detach closes and unbinds the menu', () async {
    var calls = 0;
    final controller = SmartContextMenuController()
      ..attach(
        open: () async => calls++,
        close: () async => calls++,
        isOpen: true,
      );

    controller.detach();
    await controller.open();
    await controller.close();

    expect(controller.isOpen, isFalse);
    expect(calls, 0);
  });
}
