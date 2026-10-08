import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/overlay_controller_tester.dart';

void main() {
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
    final controller = overlayController([paging]);

    controller.handleItemTap(paging);
    await pumpEventQueue();
    final pagesLevel = controller.currentLevel;

    controller.handleItemTap(child);
    final childLevel = controller.currentLevel;
    expect(controller.previousLevel, same(pagesLevel));

    await controller.handlePagination(pagesLevel);

    expect(requested, [1, 2]);
    expect(itemTitles(pagesLevel.items), ['Child menu', 'Page 1', 'Page 2']);
    expect(itemTitles(childLevel.items), ['Grandchild']);
  });

  test('does nothing after the last page', () async {
    final requested = <int>[];
    final paging = SmartContextMenuItem.pagingSubmenu(
      initialMetadata: const SmartContextMenuPagingMetadata(),
      asyncPagingChildren: (metadata) async {
        requested.add(metadata.page);
        return [SmartContextMenuItem.simple(title: 'Page ${metadata.page}')];
      },
    );
    final controller = overlayController([paging]);

    controller.handleItemTap(paging);
    await pumpEventQueue();
    final level = controller.currentLevel;
    expect(level.hasPaging, isFalse);

    await controller.handlePagination(level);
    expect(requested, [1]);
    expect(itemTitles(level.items), ['Page 1']);
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
    final controller = overlayController([paging]);

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
    expect(itemTitles(level.items), ['Page 1', 'Page 2']);
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
    final controller = overlayController([paging]);

    controller.handleItemTap(paging);
    await pumpEventQueue();
    await controller.handlePagination(controller.currentLevel);
    controller.popSubmenu();
    controller.handleItemTap(paging);
    final level = controller.currentLevel;

    expect(requested, [1, 2]);
    expect(itemTitles(level.items), ['Page 1', 'Page 2']);
    expect(level.nextMetadata?.page, 3);

    await controller.handlePagination(level);
    expect(requested, [1, 2, 3]);
    expect(itemTitles(level.items), ['Page 1', 'Page 2', 'Page 3']);
  });
}
