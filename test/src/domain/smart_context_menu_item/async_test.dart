import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  Future<SmartContextMenuAsyncResult> loader() async =>
      SmartContextMenuItem.simple(title: 'Loaded');

  test('keeps the loader, the timeout, the loading and the error item', () {
    final loading = SmartContextMenuItem.loading(title: 'Checking');
    final error = SmartContextMenuItem.error(title: 'Could not check');
    final item = SmartContextMenuItem.async(
      asyncItem: loader,
      timeout: const Duration(seconds: 3),
      loading: loading,
      error: error,
    );

    expect(item.asyncItem, loader);
    expect(item.timeout, const Duration(seconds: 3));
    expect(item.loading, same(loading));
    expect(item.error, same(error));
  });

  test('has a default loading item, error item and timeout', () {
    final item = SmartContextMenuItem.async(asyncItem: loader);

    expect(item.loading.title, isNull);
    expect(item.loading.padding, isNull);
    expect(item.error.title, isNull);
    expect(item.timeout, SmartContextMenuDefaults.loadingTimeout);
  });
}
