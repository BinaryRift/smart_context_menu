import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  group('id', () {
    test('is generated unique for each item', () {
      final ids = {
        SmartContextMenuItem.simple(title: 'Edit').id,
        SmartContextMenuItem.simple(title: 'Edit').id,
        SmartContextMenuItem.submenu(children: []).id,
        SmartContextMenuItem.asyncSubmenu(asyncChildren: () async => []).id,
        SmartContextMenuItem.pagingSubmenu(
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ).id,
        SmartContextMenuItem.async(
          asyncItem: () async => SmartContextMenuItem.simple(),
        ).id,
        SmartContextMenuItem.listenable(
          listenable: ChangeNotifier(),
          builder: SmartContextMenuItem.simple,
        ).id,
        SmartContextMenuItem.loading().id,
        SmartContextMenuItem.separator().id,
      };

      expect(ids, hasLength(9));
    });

    test('keeps the given value', () {
      final items = [
        SmartContextMenuItem.simple(id: 'a'),
        SmartContextMenuItem.submenu(id: 'a', children: []),
        SmartContextMenuItem.asyncSubmenu(
          id: 'a',
          asyncChildren: () async => [],
        ),
        SmartContextMenuItem.pagingSubmenu(
          id: 'a',
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ),
        SmartContextMenuItem.async(
          id: 'a',
          asyncItem: () async => SmartContextMenuItem.simple(),
        ),
        SmartContextMenuItem.listenable(
          id: 'a',
          listenable: ChangeNotifier(),
          builder: SmartContextMenuItem.simple,
        ),
        SmartContextMenuItem.loading(id: 'a'),
        SmartContextMenuItem.separator(id: 'a'),
      ];

      for (final item in items) {
        expect(item.id, 'a');
      }
    });
  });

  group('padding', () {
    test('keeps the given value', () {
      const padding = EdgeInsets.all(2);
      final items = [
        SmartContextMenuItem.simple(padding: padding),
        SmartContextMenuItem.submenu(padding: padding, children: []),
        SmartContextMenuItem.asyncSubmenu(
          padding: padding,
          asyncChildren: () async => [],
        ),
        SmartContextMenuItem.pagingSubmenu(
          padding: padding,
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ),
        SmartContextMenuItem.loading(padding: padding),
      ];

      for (final item in items) {
        expect(item.padding, padding);
      }
    });

    // The style padding is applied when the item is shown.
    test('is null when not given', () {
      expect(SmartContextMenuItem.simple().padding, isNull);
    });
  });
}
