import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('keeps the given fields', () {
    const leading = SizedBox();
    const trailing = SizedBox();
    const child = SizedBox();
    const titleStyle = TextStyle(fontSize: 20);
    final item = SmartContextMenuItem.loading(
      title: 'Syncing',
      titleStyle: titleStyle,
      leading: leading,
      trailing: trailing,
      child: child,
      childrenGap: 4,
    );

    expect(item.title, 'Syncing');
    expect(item.titleStyle, titleStyle);
    expect(item.leading, same(leading));
    expect(item.trailing, same(trailing));
    expect(item.child, same(child));
    expect(item.childrenGap, 4);
  });

  test('is loading and has no actions', () {
    // The declared type checks that the item is a loading item.
    final SmartContextMenuLoadingItem item = SmartContextMenuItem.loading();

    expect(item, isA<SmartContextMenuStatusItem>());
    expect(item.isLoading, isTrue);
    expect(item.title, isNull);
    expect(item.closeOnTap, isFalse);
    expect(item.onTap, isNull);
    expect(item.isSeparator, isFalse);
    expect(item.isInternalInteracted, isFalse);
  });

  test('is the only loading item', () {
    final listenable = ChangeNotifier();
    addTearDown(listenable.dispose);
    final items = [
      SmartContextMenuItem.simple(),
      SmartContextMenuItem.submenu(children: []),
      SmartContextMenuItem.asyncSubmenu(asyncChildren: () async => []),
      SmartContextMenuItem.pagingSubmenu(
        asyncPagingChildren: (_) async => [],
        initialMetadata: const SmartContextMenuPagingMetadata(),
      ),
      SmartContextMenuItem.async(
        asyncItem: () async => SmartContextMenuItem.simple(),
      ),
      SmartContextMenuItem.listenable(
        listenable: listenable,
        builder: SmartContextMenuItem.simple,
      ),
      SmartContextMenuItem.separator(),
      SmartContextMenuItem.error(),
      SmartContextMenuItem.empty(),
    ];

    for (final item in items) {
      expect(item.isLoading, isFalse);
    }
  });
}
