import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  Future<SmartContextMenuItem> loader() async =>
      SmartContextMenuItem.simple(title: 'Loaded');

  test('keeps the loader, the loading item and the error builder', () {
    Widget errorBuilder(
      BuildContext context,
      SmartContextMenuItemState state,
    ) => const SizedBox();
    final loading = SmartContextMenuItem.loading(title: 'Checking');
    final item = SmartContextMenuItem.async(
      asyncItem: loader,
      timeout: const Duration(seconds: 3),
      loading: loading,
      errorBuilder: errorBuilder,
    );

    expect(item.asyncItem, loader);
    expect(item.loadingTimeout, const Duration(seconds: 3));
    expect(item.loadingItem, same(loading));
    expect(item.errorBuilder, errorBuilder);
  });

  test('shows a default loading item', () {
    final item = SmartContextMenuItem.async(asyncItem: loader);

    expect(item.loadingItem!.isLoading, isTrue);
    expect(item.loadingItem!.title, isNull);
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
