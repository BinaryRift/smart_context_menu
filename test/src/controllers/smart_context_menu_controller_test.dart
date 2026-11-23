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
        owner: _menu,
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
      ..attach(
        owner: _menu,
        open: () async {},
        close: () async {},
        isOpen: true,
      );

    expect(controller.isOpen, isTrue);
    expect(controller.isClosed, isFalse);
  });

  test('syncVisibility notifies listeners only on change', () {
    var notifications = 0;
    final controller = SmartContextMenuController()
      ..attach(
        owner: _menu,
        open: () async {},
        close: () async {},
        isOpen: false,
      )
      ..addListener(() => notifications++);

    controller.syncVisibility(_menu, true);
    controller.syncVisibility(_menu, true);
    expect(controller.isOpen, isTrue);
    expect(notifications, 1);

    controller.syncVisibility(_menu, false);
    expect(controller.isOpen, isFalse);
    expect(notifications, 2);
  });

  test('detach closes and unbinds the menu', () async {
    var calls = 0;
    final controller = SmartContextMenuController()
      ..attach(
        owner: _menu,
        open: () async => calls++,
        close: () async => calls++,
        isOpen: true,
      );

    controller.detach(_menu);
    await controller.open();
    await controller.close();

    expect(controller.isOpen, isFalse);
    expect(calls, 0);
  });

  test('detach and syncVisibility from another menu are ignored', () async {
    final calls = <String>[];
    final controller = SmartContextMenuController()
      ..attach(
        owner: _menu,
        open: () async => calls.add('open'),
        close: () async {},
        isOpen: true,
      );

    controller.syncVisibility(_otherMenu, false);
    controller.detach(_otherMenu);
    await controller.open();

    expect(controller.isOpen, isTrue);
    expect(calls, ['open']);
  });
}

final _menu = Object();
final _otherMenu = Object();
