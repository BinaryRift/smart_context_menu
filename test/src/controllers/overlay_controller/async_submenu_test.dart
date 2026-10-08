import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/overlay_controller_tester.dart';

void main() {
  test('loading belongs to the level being loaded', () async {
    final completer = Completer<List<SmartContextMenuItem>>();
    final submenu = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: () => completer.future,
    );
    final controller = overlayController([submenu]);
    final root = controller.currentLevel;

    controller.handleItemTap(submenu);
    final level = controller.currentLevel;
    expect(level.isLoading, isTrue);
    expect(root.isLoading, isFalse);

    completer.complete([SmartContextMenuItem.simple(title: 'Loaded')]);
    await pumpEventQueue();
    expect(level.isLoading, isFalse);
    expect(itemTitles(level.items), ['Loaded']);
  });

  test('a load finished after popping does not reach the parent', () async {
    final completer = Completer<List<SmartContextMenuItem>>();
    final submenu = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: () => completer.future,
    );
    final controller = overlayController([submenu]);
    final root = controller.currentLevel;

    controller.handleItemTap(submenu);
    controller.popSubmenu();
    completer.complete([SmartContextMenuItem.simple(title: 'Loaded')]);
    await pumpEventQueue();

    expect(itemTitles(root.items), ['More']);
    expect(root.isLoading, isFalse);
  });

  test('onRetryLoad retries the load of the given level', () async {
    var calls = 0;
    final submenu = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: () async {
        calls++;
        if (calls == 1) throw Exception('Failed');
        return [SmartContextMenuItem.simple(title: 'Loaded')];
      },
    );
    final controller = overlayController([submenu]);

    controller.handleItemTap(submenu);
    await pumpEventQueue();
    final level = controller.currentLevel;
    expect(level.hasError, isTrue);

    controller.onRetryLoad(level);
    expect(level.isLoading, isTrue);
    await pumpEventQueue();

    expect(level.hasError, isFalse);
    expect(level.isLoading, isFalse);
    expect(itemTitles(level.items), ['Loaded']);
  });

  test('reopens a loaded async submenu without loading', () async {
    var calls = 0;
    final submenu = SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () async {
        calls++;
        return [SmartContextMenuItem.simple(title: 'Loaded')];
      },
    );
    final controller = overlayController([submenu]);

    controller.handleItemTap(submenu);
    await pumpEventQueue();
    controller.popSubmenu();
    controller.handleItemTap(submenu);

    expect(calls, 1);
    expect(controller.currentLevel.isLoading, isFalse);
    expect(itemTitles(controller.currentLevel.items), ['Loaded']);
  });
}
