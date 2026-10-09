import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('submenu keeps its children', () {
    final children = [SmartContextMenuItem.simple(title: 'Child')];
    final item = SmartContextMenuItem.submenu(
      title: 'More',
      children: children,
    );

    expect(item.title, 'More');
    expect(item.children, same(children));
  });

  test('asyncSubmenu keeps its loader and timeout', () {
    Future<List<SmartContextMenuItem>> loader() async => [];
    final item = SmartContextMenuItem.asyncSubmenu(
      title: 'More',
      asyncChildren: loader,
      timeout: const Duration(seconds: 3),
    );

    expect(item.title, 'More');
    expect(item.asyncChildren, loader);
    expect(item.timeout, const Duration(seconds: 3));
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

    expect(item.title, 'Pages');
    expect(item.asyncPagingChildren, loader);
    expect(item.timeout, const Duration(seconds: 3));
    expect(item.initialMetadata, metadata);
  });

  group('async submenus', () {
    SmartContextMenuAsyncSubmenuItem async({
      SmartContextMenuLoadingItem? loading,
      SmartContextMenuErrorItem? error,
      SmartContextMenuEmptyItem? empty,
    }) => SmartContextMenuItem.asyncSubmenu(
      asyncChildren: () async => [],
      loading: loading,
      error: error,
      empty: empty,
    );

    SmartContextMenuPagingSubmenuItem paging({
      SmartContextMenuLoadingItem? loading,
      SmartContextMenuErrorItem? error,
      SmartContextMenuEmptyItem? empty,
    }) => SmartContextMenuItem.pagingSubmenu(
      asyncPagingChildren: (_) async => [],
      initialMetadata: const SmartContextMenuPagingMetadata(),
      loading: loading,
      error: error,
      empty: empty,
    );

    test('use the default timeout', () {
      expect(async().timeout, SmartContextMenuDefaults.loadingTimeout);
      expect(paging().timeout, SmartContextMenuDefaults.loadingTimeout);
    });

    // The submenu shows its default states when they are null.
    test('have no loading, error and empty items by default', () {
      for (final (loading, error, empty) in [
        (async().loading, async().error, async().empty),
        (paging().loading, paging().error, paging().empty),
      ]) {
        expect(loading, isNull);
        expect(error, isNull);
        expect(empty, isNull);
      }
    });

    test('keep their loading, error and empty items', () {
      final loading = SmartContextMenuItem.loading(title: 'Loading');
      final error = SmartContextMenuItem.error(title: 'Could not load');
      final empty = SmartContextMenuItem.empty(title: 'No files');
      final asyncItem = async(loading: loading, error: error, empty: empty);
      final pagingItem = paging(loading: loading, error: error, empty: empty);

      expect(asyncItem.loading, same(loading));
      expect(asyncItem.error, same(error));
      expect(asyncItem.empty, same(empty));
      expect(pagingItem.loading, same(loading));
      expect(pagingItem.error, same(error));
      expect(pagingItem.empty, same(empty));
    });
  });
}
