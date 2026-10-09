import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('submenu keeps its children', () {
    final children = [SmartContextMenuItem.simple(title: 'Child')];
    final item = SmartContextMenuItem.submenu(
      title: 'More',
      children: children,
    );

    expect(item.children, same(children));
    expect(item.asyncChildren, isNull);
    expect(item.asyncPagingChildren, isNull);
    expect(item.showTransitionIcon, isTrue);
    expect(item.isInternalInteracted, isTrue);
  });

  test('asyncSubmenu keeps its loader and timeout', () {
    Future<List<SmartContextMenuItem>> loader() async => [];
    final item = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: loader,
      timeout: const Duration(seconds: 3),
    );

    expect(item.asyncChildren, loader);
    expect(item.loadingTimeout, const Duration(seconds: 3));
    expect(item.children, isNull);
    expect(item.asyncPagingChildren, isNull);
    expect(item.showTransitionIcon, isTrue);
    expect(item.isInternalInteracted, isTrue);
  });

  test('pagingSubmenu keeps its loader, timeout and first page metadata', () {
    Future<List<SmartContextMenuItem>> loader(
      SmartContextMenuPagingMetadata metadata,
    ) async => [];
    const metadata = SmartContextMenuPagingMetadata(limit: 10);
    final item = SmartContextMenuItem.pagingSubmenu(
      title: 'Pages',
      asyncPagingChildren: loader,
      initialMetadata: metadata,
      timeout: const Duration(seconds: 3),
    );

    expect(item.asyncPagingChildren, loader);
    expect(item.loadingTimeout, const Duration(seconds: 3));
    expect(item.pagingMetadata, metadata);
    expect(item.children, isNull);
    expect(item.asyncChildren, isNull);
    expect(item.showTransitionIcon, isTrue);
    expect(item.isInternalInteracted, isTrue);
  });

  test('async submenus use the default timeout', () {
    final async = SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () async => [],
    );
    final paging = SmartContextMenuItem.pagingSubmenu(
      asyncPagingChildren: (_) async => [],
      initialMetadata: const SmartContextMenuPagingMetadata(),
    );

    expect(async.loadingTimeout, SmartContextMenuDefaults.loadingTimeout);
    expect(paging.loadingTimeout, SmartContextMenuDefaults.loadingTimeout);
  });

  test('loading submenus keep their loading item', () {
    final loading = SmartContextMenuItem.loading(title: 'Loading');
    final async = SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () async => [],
      loading: loading,
    );
    final paging = SmartContextMenuItem.pagingSubmenu(
      asyncPagingChildren: (_) async => [],
      initialMetadata: const SmartContextMenuPagingMetadata(),
      loading: loading,
    );

    expect(async.loadingItem, same(loading));
    expect(paging.loadingItem, same(loading));
    expect(SmartContextMenuItem.submenu(children: []).loadingItem, isNull);
    expect(
      SmartContextMenuItem.asyncSubmenu(
        asyncChildren: () async => [],
      ).loadingItem,
      isNull,
    );
  });

  test('loading submenus keep their error item', () {
    final error = SmartContextMenuItem.error(title: 'Could not load');
    final async = SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () async => [],
      error: error,
    );
    final paging = SmartContextMenuItem.pagingSubmenu(
      asyncPagingChildren: (_) async => [],
      initialMetadata: const SmartContextMenuPagingMetadata(),
      error: error,
    );

    expect(async.errorItem, same(error));
    expect(paging.errorItem, same(error));
    expect(SmartContextMenuItem.submenu(children: []).errorItem, isNull);
    expect(
      SmartContextMenuItem.asyncSubmenu(
        asyncChildren: () async => [],
      ).errorItem,
      isNull,
    );
  });

  test('loading submenus keep their empty item', () {
    final empty = SmartContextMenuItem.empty(title: 'No files');
    final async = SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () async => [],
      empty: empty,
    );
    final paging = SmartContextMenuItem.pagingSubmenu(
      asyncPagingChildren: (_) async => [],
      initialMetadata: const SmartContextMenuPagingMetadata(),
      empty: empty,
    );

    expect(async.emptyItem, same(empty));
    expect(paging.emptyItem, same(empty));
    expect(SmartContextMenuItem.submenu(children: []).emptyItem, isNull);
    expect(
      SmartContextMenuItem.asyncSubmenu(
        asyncChildren: () async => [],
      ).emptyItem,
      isNull,
    );
  });
}
