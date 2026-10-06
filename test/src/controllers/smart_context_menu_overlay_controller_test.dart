import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/controllers/smart_context_menu_overlay_controller.dart';
import 'package:smart_context_menu/src/domain/smart_context_menu_navigator.dart';

final class _Navigator implements SmartContextMenuNavigator {
  @override
  Future<void> dismissWithDelay() async {}
}

SmartContextMenuOverlayController _controller(
  List<SmartContextMenuItem> items,
) {
  // Loads apply their results only while the controller has listeners.
  return SmartContextMenuOverlayController(
    navigator: _Navigator(),
    initialItems: items,
    enableHaptics: false,
  )..addListener(() {});
}

List<String?> _titles(List<SmartContextMenuItem> items) => [
  for (final item in items) item.title,
];

void main() {
  test('previousLevel is null on the root and the parent in a submenu', () {
    final submenu = SmartContextMenuItem.submenu(
      title: 'More',
      children: [SmartContextMenuItem.simple(title: 'Child')],
    );
    final controller = _controller([submenu]);
    final root = controller.currentLevel;
    expect(controller.previousLevel, isNull);

    controller.handleItemTap(submenu);
    expect(controller.previousLevel, same(root));

    controller.popSubmenu();
    expect(controller.previousLevel, isNull);
  });

  test('loading belongs to the level being loaded', () async {
    final completer = Completer<List<SmartContextMenuItem>>();
    final submenu = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: () => completer.future,
    );
    final controller = _controller([submenu]);
    final root = controller.currentLevel;

    controller.handleItemTap(submenu);
    final level = controller.currentLevel;
    expect(level.isLoading, isTrue);
    expect(root.isLoading, isFalse);

    completer.complete([SmartContextMenuItem.simple(title: 'Loaded')]);
    await pumpEventQueue();
    expect(level.isLoading, isFalse);
    expect(_titles(level.items), ['Loaded']);
  });

  test('a load finished after popping does not reach the parent', () async {
    final completer = Completer<List<SmartContextMenuItem>>();
    final submenu = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: () => completer.future,
    );
    final controller = _controller([submenu]);
    final root = controller.currentLevel;

    controller.handleItemTap(submenu);
    controller.popSubmenu();
    completer.complete([SmartContextMenuItem.simple(title: 'Loaded')]);
    await pumpEventQueue();

    expect(_titles(root.items), ['More']);
    expect(root.isLoading, isFalse);
  });

  test('handlePagination loads the next page into the given level', () async {
    final requested = <int>[];
    final child = SmartContextMenuItem.submenu(
      title: 'Child menu',
      children: [SmartContextMenuItem.simple(title: 'Grandchild')],
    );
    final paging = SmartContextMenuItem.pagingSubmenu(
      title: 'Pages',
      initialMetadata: const SmartContextMenuPagingMetadata(),
      asyncPagingChildren: (metadata) async {
        requested.add(metadata.page);
        return [
          if (metadata.page == 1) child,
          SmartContextMenuItem.simple(
            title: 'Page ${metadata.page}',
            pagingMetadata: metadata.page == 1
                ? metadata.copyWith(page: 2)
                : null,
          ),
        ];
      },
    );
    final controller = _controller([paging]);

    controller.handleItemTap(paging);
    await pumpEventQueue();
    final pagesLevel = controller.currentLevel;

    controller.handleItemTap(child);
    final childLevel = controller.currentLevel;
    expect(controller.previousLevel, same(pagesLevel));

    await controller.handlePagination(pagesLevel);

    expect(requested, [1, 2]);
    expect(_titles(pagesLevel.items), ['Child menu', 'Page 1', 'Page 2']);
    expect(_titles(childLevel.items), ['Grandchild']);
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
    final controller = _controller([submenu]);

    controller.handleItemTap(submenu);
    await pumpEventQueue();
    final level = controller.currentLevel;
    expect(level.hasError, isTrue);

    controller.onRetryLoad(level);
    expect(level.isLoading, isTrue);
    await pumpEventQueue();

    expect(level.hasError, isFalse);
    expect(level.isLoading, isFalse);
    expect(_titles(level.items), ['Loaded']);
  });
}
