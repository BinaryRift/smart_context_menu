import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/overlay_controller_tester.dart';

void main() {
  const timeout = Duration(milliseconds: 1);
  Future<void> waitTimeout() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  test('fails an async submenu that loads too long', () async {
    final completer = Completer<List<SmartContextMenuItem>>();
    final submenu = SmartContextMenuItem.asyncSubmenu(
      timeout: timeout,
      asyncChildren: () => completer.future,
    );
    final controller = overlayController([submenu]);

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
    final controller = overlayController([submenu]);

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
    final controller = overlayController([paging]);

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
    final controller = overlayController([paging]);

    controller.handleItemTap(paging);
    await pumpEventQueue();
    final level = controller.currentLevel;
    await controller.handlePagination(level);

    expect(level.isPaginating, isFalse);
    expect(level.hasError, isTrue);
    expect(itemTitles(level.items), ['Page 1']);
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
    final controller = overlayController([paging]);

    controller.handleItemTap(paging);
    await pumpEventQueue();
    controller.popSubmenu();
    controller.handleItemTap(paging);
    final level = controller.currentLevel;
    await controller.handlePagination(level);

    expect(level.hasError, isTrue);
  });
}
