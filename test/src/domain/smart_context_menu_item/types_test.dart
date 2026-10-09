import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  final listenable = ChangeNotifier();

  tearDownAll(listenable.dispose);

  // The declared types check that each method returns its own subtype.
  final SmartContextMenuSimpleItem simple = SmartContextMenuItem.simple();
  final SmartContextMenuSubmenuItem submenu = SmartContextMenuItem.submenu(
    children: [],
  );
  final SmartContextMenuAsyncSubmenuItem asyncSubmenu =
      SmartContextMenuItem.asyncSubmenu(asyncChildren: () async => []);
  final SmartContextMenuPagingSubmenuItem pagingSubmenu =
      SmartContextMenuItem.pagingSubmenu(
        asyncPagingChildren: (_) async => [],
        initialMetadata: const SmartContextMenuPagingMetadata(),
      );
  final SmartContextMenuAsyncItem async = SmartContextMenuItem.async(
    asyncItem: () async => SmartContextMenuItem.simple(),
  );
  final SmartContextMenuListenableItem listenableItem =
      SmartContextMenuItem.listenable(
        listenable: listenable,
        builder: SmartContextMenuItem.simple,
      );
  final SmartContextMenuLoadingItem loading = SmartContextMenuItem.loading();
  final SmartContextMenuErrorItem error = SmartContextMenuItem.error();
  final SmartContextMenuEmptyItem empty = SmartContextMenuItem.empty();
  final SmartContextMenuSeparatorItem separator =
      SmartContextMenuItem.separator();

  test('actions and submenus are content items', () {
    for (final item in [simple, submenu, asyncSubmenu, pagingSubmenu]) {
      expect(item, isA<SmartContextMenuContentItem>());
    }
  });

  test('loading, error and empty items are status items', () {
    for (final item in [loading, error, empty]) {
      expect(item, isA<SmartContextMenuStatusItem>());
    }
  });

  test('the builder of a listenable item returns an action or a status', () {
    for (final item in [simple, loading, error, empty]) {
      expect(item, isA<SmartContextMenuListenableResult>());
    }
    for (final item in [
      submenu,
      asyncSubmenu,
      pagingSubmenu,
      async,
      listenableItem,
      separator,
    ]) {
      expect(item, isNot(isA<SmartContextMenuListenableResult>()));
    }
  });

  test('an async item loads an action, a submenu or a status', () {
    for (final item in [
      simple,
      submenu,
      asyncSubmenu,
      pagingSubmenu,
      loading,
      error,
      empty,
    ]) {
      expect(item, isA<SmartContextMenuAsyncResult>());
    }
    for (final item in [async, listenableItem, separator]) {
      expect(item, isNot(isA<SmartContextMenuAsyncResult>()));
    }
  });
}
