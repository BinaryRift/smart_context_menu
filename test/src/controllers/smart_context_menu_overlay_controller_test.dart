import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/controllers/smart_context_menu_overlay_controller.dart';
import 'package:smart_context_menu/src/domain/smart_context_menu_navigator.dart';

final class _Navigator implements SmartContextMenuNavigator {
  int dismissals = 0;

  @override
  Future<void> dismissWithDelay() async => dismissals++;
}

SmartContextMenuOverlayController _controller(
  List<SmartContextMenuItem> items, {
  _Navigator? navigator,
}) {
  // Loads apply their results only while the controller has listeners.
  return SmartContextMenuOverlayController(
    navigator: navigator ?? _Navigator(),
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

  test('popSubmenu on the root level does nothing', () {
    var notifications = 0;
    final controller = _controller([SmartContextMenuItem.simple(title: 'Edit')])
      ..addListener(() => notifications++);
    final root = controller.currentLevel;

    controller.popSubmenu();

    expect(controller.stackLength, 1);
    expect(controller.currentLevel, same(root));
    expect(notifications, 0);
  });

  group('handleItemTap', () {
    test('runs onTap and closes the menu', () async {
      final navigator = _Navigator();
      var taps = 0;
      final item = SmartContextMenuItem.simple(onTap: () => taps++);
      final controller = _controller([item], navigator: navigator);

      controller.handleItemTap(item);
      await pumpEventQueue();

      expect(taps, 1);
      expect(navigator.dismissals, 1);
    });

    test('keeps the menu open when closeOnTap is false', () async {
      final navigator = _Navigator();
      var taps = 0;
      final item = SmartContextMenuItem.simple(
        closeOnTap: false,
        onTap: () => taps++,
      );
      final controller = _controller([item], navigator: navigator);

      controller.handleItemTap(item);
      await pumpEventQueue();

      expect(taps, 1);
      expect(navigator.dismissals, 0);
    });

    test('ignores a disabled item', () async {
      final navigator = _Navigator();
      var taps = 0;
      final item = SmartContextMenuItem.simple(
        isDisabled: true,
        onTap: () => taps++,
      );
      final controller = _controller([item], navigator: navigator);

      controller.handleItemTap(item);
      await pumpEventQueue();

      expect(taps, 0);
      expect(navigator.dismissals, 0);
    });

    test('ignores taps while the level loads', () async {
      final completer = Completer<List<SmartContextMenuItem>>();
      final navigator = _Navigator();
      var taps = 0;
      final item = SmartContextMenuItem.simple(onTap: () => taps++);
      final submenu = SmartContextMenuItem.asyncSubmenu(
        asyncChildren: () => completer.future,
      );
      final controller = _controller([submenu], navigator: navigator);

      controller.handleItemTap(submenu);
      controller.handleItemTap(item);
      await pumpEventQueue();

      expect(taps, 0);
      expect(navigator.dismissals, 0);
    });
  });

  group('cache', () {
    test('reopens a loaded async submenu without loading', () async {
      var calls = 0;
      final submenu = SmartContextMenuItem.asyncSubmenu(
        asyncChildren: () async {
          calls++;
          return [SmartContextMenuItem.simple(title: 'Loaded')];
        },
      );
      final controller = _controller([submenu]);

      controller.handleItemTap(submenu);
      await pumpEventQueue();
      controller.popSubmenu();
      controller.handleItemTap(submenu);

      expect(calls, 1);
      expect(controller.currentLevel.isLoading, isFalse);
      expect(_titles(controller.currentLevel.items), ['Loaded']);
    });

    test('reopens a paging submenu with its loaded pages', () async {
      final requested = <int>[];
      final paging = SmartContextMenuItem.pagingSubmenu(
        initialMetadata: const SmartContextMenuPagingMetadata(),
        asyncPagingChildren: (metadata) async {
          requested.add(metadata.page);
          return [
            SmartContextMenuItem.simple(
              title: 'Page ${metadata.page}',
              pagingMetadata: metadata.copyWith(page: metadata.page + 1),
            ),
          ];
        },
      );
      final controller = _controller([paging]);

      controller.handleItemTap(paging);
      await pumpEventQueue();
      await controller.handlePagination(controller.currentLevel);
      controller.popSubmenu();
      controller.handleItemTap(paging);
      final level = controller.currentLevel;

      expect(requested, [1, 2]);
      expect(_titles(level.items), ['Page 1', 'Page 2']);
      expect(level.nextMetadata?.page, 3);

      await controller.handlePagination(level);
      expect(requested, [1, 2, 3]);
      expect(_titles(level.items), ['Page 1', 'Page 2', 'Page 3']);
    });
  });

  group('handlePagination', () {
    test('does nothing after the last page', () async {
      final requested = <int>[];
      final paging = SmartContextMenuItem.pagingSubmenu(
        initialMetadata: const SmartContextMenuPagingMetadata(),
        asyncPagingChildren: (metadata) async {
          requested.add(metadata.page);
          return [SmartContextMenuItem.simple(title: 'Page ${metadata.page}')];
        },
      );
      final controller = _controller([paging]);

      controller.handleItemTap(paging);
      await pumpEventQueue();
      final level = controller.currentLevel;
      expect(level.hasPaging, isFalse);

      await controller.handlePagination(level);
      expect(requested, [1]);
      expect(_titles(level.items), ['Page 1']);
    });

    test('does not repeat a page that is loading', () async {
      final requested = <int>[];
      final pages = <int, Completer<List<SmartContextMenuItem>>>{};
      final paging = SmartContextMenuItem.pagingSubmenu(
        initialMetadata: const SmartContextMenuPagingMetadata(),
        asyncPagingChildren: (metadata) {
          requested.add(metadata.page);
          return (pages[metadata.page] = Completer()).future;
        },
      );
      final controller = _controller([paging]);

      controller.handleItemTap(paging);
      pages[1]!.complete([
        SmartContextMenuItem.simple(
          title: 'Page 1',
          pagingMetadata: const SmartContextMenuPagingMetadata(page: 2),
        ),
      ]);
      await pumpEventQueue();
      final level = controller.currentLevel;

      final first = controller.handlePagination(level);
      final second = controller.handlePagination(level);
      expect(level.isPaginating, isTrue);
      pages[2]!.complete([SmartContextMenuItem.simple(title: 'Page 2')]);
      await Future.wait([first, second]);

      expect(requested, [1, 2]);
      expect(_titles(level.items), ['Page 1', 'Page 2']);
    });
  });

  group('loading timeout', () {
    const timeout = Duration(milliseconds: 1);
    Future<void> waitTimeout() =>
        Future<void>.delayed(const Duration(milliseconds: 20));

    test('fails an async submenu that loads too long', () async {
      final completer = Completer<List<SmartContextMenuItem>>();
      final submenu = SmartContextMenuItem.asyncSubmenu(
        timeout: timeout,
        asyncChildren: () => completer.future,
      );
      final controller = _controller([submenu]);

      controller.handleItemTap(submenu);
      final level = controller.currentLevel;
      await waitTimeout();
      expect(level.isLoading, isFalse);
      expect(level.hasError, isTrue);

      completer.complete([SmartContextMenuItem.simple(title: 'Late')]);
      await pumpEventQueue();
      expect(level.items, isEmpty);
    });

    test('limits the retry of an async submenu', () async {
      var calls = 0;
      final submenu = SmartContextMenuItem.asyncSubmenu(
        timeout: timeout,
        asyncChildren: () {
          calls++;
          return Completer<List<SmartContextMenuItem>>().future;
        },
      );
      final controller = _controller([submenu]);

      controller.handleItemTap(submenu);
      final level = controller.currentLevel;
      await waitTimeout();
      controller.onRetryLoad(level);
      expect(level.isLoading, isTrue);
      await waitTimeout();

      expect(calls, 2);
      expect(level.isLoading, isFalse);
      expect(level.hasError, isTrue);
    });

    test('fails the first page that loads too long', () async {
      final paging = SmartContextMenuItem.pagingSubmenu(
        timeout: timeout,
        initialMetadata: const SmartContextMenuPagingMetadata(),
        asyncPagingChildren: (_) =>
            Completer<List<SmartContextMenuItem>>().future,
      );
      final controller = _controller([paging]);

      controller.handleItemTap(paging);
      final level = controller.currentLevel;
      await waitTimeout();

      expect(level.isLoading, isFalse);
      expect(level.hasError, isTrue);
    });

    test('fails a next page that loads too long', () async {
      final paging = SmartContextMenuItem.pagingSubmenu(
        timeout: timeout,
        initialMetadata: const SmartContextMenuPagingMetadata(),
        asyncPagingChildren: (metadata) async {
          if (metadata.page == 1) {
            return [
              SmartContextMenuItem.simple(
                title: 'Page 1',
                pagingMetadata: metadata.copyWith(page: 2),
              ),
            ];
          }
          return Completer<List<SmartContextMenuItem>>().future;
        },
      );
      final controller = _controller([paging]);

      controller.handleItemTap(paging);
      await pumpEventQueue();
      final level = controller.currentLevel;
      await controller.handlePagination(level);

      expect(level.isPaginating, isFalse);
      expect(level.hasError, isTrue);
      expect(_titles(level.items), ['Page 1']);
    });

    test('limits a page of a reopened paging submenu', () async {
      final paging = SmartContextMenuItem.pagingSubmenu(
        timeout: timeout,
        initialMetadata: const SmartContextMenuPagingMetadata(),
        asyncPagingChildren: (metadata) async {
          if (metadata.page == 1) {
            return [
              SmartContextMenuItem.simple(
                title: 'Page 1',
                pagingMetadata: metadata.copyWith(page: 2),
              ),
            ];
          }
          return Completer<List<SmartContextMenuItem>>().future;
        },
      );
      final controller = _controller([paging]);

      controller.handleItemTap(paging);
      await pumpEventQueue();
      controller.popSubmenu();
      controller.handleItemTap(paging);
      final level = controller.currentLevel;
      await controller.handlePagination(level);

      expect(level.hasError, isTrue);
    });
  });
}
