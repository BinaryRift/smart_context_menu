import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

Type _staticType<T>(T _) => T;

void main() {
  // Each declared type is a compile-time check of the inferred one; the
  // expectations check that it is not wider.
  group('list type inference', () {
    test('items and a separator are menu items', () {
      final items = [
        SmartContextMenuItem.simple(),
        SmartContextMenuItem.separator(),
      ];
      final List<SmartContextMenuItem> menuItems = items;

      expect(_staticType(menuItems), List<SmartContextMenuItem>);
      expect(_staticType(items), List<SmartContextMenuItem>);
    });

    test('an action and a submenu are content items', () {
      final items = [
        SmartContextMenuItem.simple(),
        SmartContextMenuItem.submenu(children: []),
      ];
      final List<SmartContextMenuItem> menuItems = items;

      expect(menuItems, hasLength(2));
      expect(_staticType(items), List<SmartContextMenuContentItem>);
    });

    test('statuses and a separator are menu items', () {
      final items = [
        SmartContextMenuItem.loading(),
        SmartContextMenuItem.separator(),
        SmartContextMenuItem.async(
          asyncItem: () async => SmartContextMenuItem.simple(),
        ),
      ];

      expect(_staticType(items), List<SmartContextMenuItem>);
    });

    test('items and a row are menu items', () {
      final items = [
        SmartContextMenuItem.simple(),
        SmartContextMenuItem.row(children: []),
      ];
      final List<SmartContextMenuItem> menuItems = items;

      expect(_staticType(menuItems), List<SmartContextMenuItem>);
      expect(_staticType(items), List<SmartContextMenuItem>);
    });

    test('an item and a flex are row entries', () {
      final cells = [
        SmartContextMenuItem.simple(),
        SmartContextMenuRowFlex(flex: 2, child: SmartContextMenuItem.simple()),
      ];
      final row = SmartContextMenuItem.row(children: cells);

      expect(_staticType(cells), List<SmartContextMenuRowEntry>);
      expect(row.children, same(cells));
    });
  });

  group('row', () {
    test('has medium cells and no own values by default', () {
      final item = SmartContextMenuItem.row(children: []);

      expect(item.size, SmartContextMenuRowSize.medium);
      expect(item.dividersBetweenChildren, isNull);
      expect(item.enableSwipeBack, isFalse);
      expect(item.padding, isNull);
      expect(item.childrenGap, isNull);
      expect(item.pagingMetadata, isNull);
    });

    test('keeps the given values', () {
      final children = <SmartContextMenuRowEntry>[
        SmartContextMenuItem.simple(),
        SmartContextMenuItem.separator(),
      ];
      const padding = EdgeInsets.all(2);
      const metadata = SmartContextMenuPagingMetadata(page: 2);
      final item = SmartContextMenuItem.row(
        children: children,
        size: SmartContextMenuRowSize.small,
        dividersBetweenChildren: true,
        enableSwipeBack: true,
        padding: padding,
        childrenGap: 4,
        pagingMetadata: metadata,
      );

      expect(item.children, same(children));
      expect(item.size, SmartContextMenuRowSize.small);
      expect(item.dividersBetweenChildren, isTrue);
      expect(item.enableSwipeBack, isTrue);
      expect(item.padding, padding);
      expect(item.childrenGap, 4);
      expect(item.pagingMetadata, metadata);
    });

    test('rejects a separator with paging metadata', () {
      expect(
        () => SmartContextMenuItem.row(
          children: [
            SmartContextMenuItem.simple(),
            SmartContextMenuItem.separator(
              pagingMetadata: const SmartContextMenuPagingMetadata(page: 2),
            ),
          ],
        ),
        throwsAssertionError,
      );
    });
  });

  group('flex', () {
    test('keeps the given flex and child', () {
      final child = SmartContextMenuItem.simple();
      final flex = SmartContextMenuRowFlex(flex: 2, child: child);

      expect(flex.flex, 2);
      expect(flex.child, same(child));
    });

    test('rejects a flex that is not positive', () {
      expect(
        () => SmartContextMenuRowFlex(
          flex: 0,
          child: SmartContextMenuItem.simple(),
        ),
        throwsAssertionError,
      );
    });

    test('rejects a flex in a flex', () {
      expect(
        () => SmartContextMenuRowFlex(
          flex: 2,
          child: SmartContextMenuRowFlex(
            flex: 2,
            child: SmartContextMenuItem.simple(),
          ),
        ),
        throwsA(
          isA<AssertionError>().having(
            (error) => error.message,
            'message',
            contains('cannot wrap another SmartContextMenuRowFlex'),
          ),
        ),
      );
    });

    test('rejects a separator', () {
      expect(
        () => SmartContextMenuRowFlex(
          flex: 2,
          child: SmartContextMenuItem.separator(),
        ),
        throwsAssertionError,
      );
    });
  });
}
