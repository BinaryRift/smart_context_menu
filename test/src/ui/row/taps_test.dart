// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';
import '../../../helpers/row_tester.dart';

void main() {
  group('taps', () {
    testWidgets('a cell runs its action and closes the menu by its rule', (
      tester,
    ) async {
      final taps = <String>[];
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              rowCell('Copy', taps: taps),
              rowCell('Delete', taps: taps, closeOnTap: true),
            ],
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('Copy'));
      await tester.settleMenu();
      expect(taps, ['Copy']);
      expect(find.text('Copy'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.settleMenu();
      expect(taps, ['Copy', 'Delete']);
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('a submenu cell opens its submenu with items as usual', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              rowCell('Copy'),
              SmartContextMenuItem.submenu(
                title: 'More',
                children: [SmartContextMenuItem.simple(title: 'Archive')],
              ),
            ],
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('More'));
      await tester.settleMenu();

      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Copy'), findsNothing);
      expect(rowLayouts, findsNothing);
    });

    testWidgets('a disabled cell is not tapped and not highlighted', (
      tester,
    ) async {
      final taps = <String>[];
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [rowCell('Edit', taps: taps, isDisabled: true)],
          ),
        ],
      );
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Edit'));
      expect(tester.backgroundOf('Edit'), isSameColorAs(transparent));
      await gesture.up();
      await tester.settleMenu();

      expect(taps, isEmpty);
    });

    testWidgets('a destructive cell is tinted as in a list', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [rowCell('Delete', isDestructive: true)],
          ),
          rowCell('Remove', isDestructive: true),
        ],
      );
      await tester.openMenu();

      expect(
        tester.backgroundOf('Delete'),
        isSameColorAs(tester.backgroundOf('Remove')!),
      );
      expect(tester.backgroundOf('Delete'), isNot(isSameColorAs(transparent)));
    });
  });

  group('async cell', () {
    testWidgets('loads its item, keeps it cached and stays compact', (
      tester,
    ) async {
      var loads = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            size: SmartContextMenuRowSize.small,
            children: [
              SmartContextMenuItem.async(
                asyncItem: () async {
                  loads++;
                  return SmartContextMenuItem.simple(title: 'Pin');
                },
              ),
              SmartContextMenuItem.submenu(
                title: 'More',
                leading: const Icon(CupertinoIcons.ellipsis),
                children: [SmartContextMenuItem.simple(title: 'Archive')],
              ),
            ],
          ),
        ],
      );
      await tester.openMenu();
      expect(find.text('Pin'), findsOneWidget);
      expect(loads, 1);

      await tester.tap(find.byIcon(CupertinoIcons.ellipsis));
      await tester.settleMenu();
      await tester.tap(find.text(const SmartContextMenuLabels().back).last);
      await tester.settleMenu();

      expect(find.text('Pin'), findsOneWidget);
      expect(loads, 1);
    });

    testWidgets('retries after a failed load', (tester) async {
      var loads = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              rowCell('Copy'),
              SmartContextMenuItem.async(
                asyncItem: () async {
                  if (++loads == 1) throw Exception('Failed');
                  return SmartContextMenuItem.simple(title: 'Pin');
                },
              ),
            ],
          ),
        ],
      );
      await tester.openMenu();
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.settleMenu();

      expect(loads, 2);
      expect(find.text('Pin'), findsOneWidget);
    });
  });
}
