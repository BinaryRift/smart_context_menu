import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('keeps the given fields', () {
    const leading = SizedBox();
    const titleStyle = TextStyle(fontSize: 20);
    Widget loadingBuilder(
      BuildContext context,
      SmartContextMenuItemState state,
    ) => const SizedBox();
    final item = SmartContextMenuItem.loading(
      title: 'Syncing',
      titleStyle: titleStyle,
      leading: leading,
      loadingBuilder: loadingBuilder,
      childrenGap: 4,
    );

    expect(item.title, 'Syncing');
    expect(item.titleStyle, titleStyle);
    expect(item.leading, same(leading));
    expect(item.loadingBuilder, loadingBuilder);
    expect(item.childrenGap, 4);
  });

  test('is loading and has no actions', () {
    final item = SmartContextMenuItem.loading();

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
        builder: () => null,
      ),
      SmartContextMenuItem.separator(),
    ];

    for (final item in items) {
      expect(item.isLoading, isFalse);
    }
  });
}
