import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/overlay_controller_tester.dart';

void main() {
  test('runs onTap and closes the menu', () async {
    final navigator = FakeMenuNavigator();
    var taps = 0;
    final item = SmartContextMenuItem.simple(onTap: () => taps++);
    final controller = overlayController([item], navigator: navigator);

    controller.handleItemTap(item);
    await pumpEventQueue();

    expect(taps, 1);
    expect(navigator.dismissals, 1);
  });

  test('keeps the menu open when closeOnTap is false', () async {
    final navigator = FakeMenuNavigator();
    var taps = 0;
    final item = SmartContextMenuItem.simple(
      closeOnTap: false,
      onTap: () => taps++,
    );
    final controller = overlayController([item], navigator: navigator);

    controller.handleItemTap(item);
    await pumpEventQueue();

    expect(taps, 1);
    expect(navigator.dismissals, 0);
  });

  test('ignores a disabled item', () async {
    final navigator = FakeMenuNavigator();
    var taps = 0;
    final item = SmartContextMenuItem.simple(
      isDisabled: true,
      onTap: () => taps++,
    );
    final controller = overlayController([item], navigator: navigator);

    controller.handleItemTap(item);
    await pumpEventQueue();

    expect(taps, 0);
    expect(navigator.dismissals, 0);
  });

  test('ignores taps while the level loads', () async {
    final completer = Completer<List<SmartContextMenuItem>>();
    final navigator = FakeMenuNavigator();
    var taps = 0;
    final item = SmartContextMenuItem.simple(onTap: () => taps++);
    final submenu = SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () => completer.future,
    );
    final controller = overlayController([submenu], navigator: navigator);

    controller.handleItemTap(submenu);
    controller.handleItemTap(item);
    await pumpEventQueue();

    expect(taps, 0);
    expect(navigator.dismissals, 0);
  });
}
