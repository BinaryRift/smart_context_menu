import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  Future<SmartContextMenuItem> loader() async =>
      SmartContextMenuItem.simple(title: 'Loaded');

  test('keeps the loader, the loading item and the error item', () {
    final loading = SmartContextMenuItem.loading(title: 'Checking');
    final error = SmartContextMenuItem.error(title: 'Could not check');
    final item = SmartContextMenuItem.async(
      asyncItem: loader,
      timeout: const Duration(seconds: 3),
      loading: loading,
      error: error,
    );

    expect(item.asyncItem, loader);
    expect(item.loadingTimeout, const Duration(seconds: 3));
    expect(item.loadingItem, same(loading));
    expect(item.errorItem, same(error));
  });

  test('shows a default loading item and a default error item', () {
    final item = SmartContextMenuItem.async(asyncItem: loader);

    expect(item.loadingItem!.isLoading, isTrue);
    expect(item.loadingItem!.title, isNull);
    expect(item.errorItem, isNotNull);
    expect(item.errorItem!.title, isNull);
    expect(item.title, isNull);
    expect(item.padding, isNull);
  });

  test('stays open on tap and uses the default timeout', () {
    final item = SmartContextMenuItem.async(asyncItem: loader);

    expect(item.loadingTimeout, SmartContextMenuDefaults.loadingTimeout);
    expect(item.closeOnTap, isFalse);
    expect(item.showTransitionIcon, isFalse);
    expect(item.isInternalInteracted, isTrue);
  });
}
