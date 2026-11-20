// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';
import '../../../helpers/row_tester.dart';

void main() {
  group('separator', () {
    testWidgets('is a band as tall as the row', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              rowCell('Copy'),
              SmartContextMenuItem.separator(),
              rowCell('Share'),
            ],
          ),
        ],
      );
      await tester.openMenu();

      final copy = tester.cellRectOf('Copy');
      final share = tester.cellRectOf('Share');
      expect(share.left - copy.right, defaultStyle.separatorThickness);
      final band = find.descendant(
        of: rowLayouts,
        matching: find.byWidgetPredicate(
          (widget) => widget is ColoredBox && isSeparatorColor(widget.color),
        ),
      );
      expect(
        tester.getSize(band),
        Size(defaultStyle.separatorThickness, copy.height),
      );
    });

    testWidgets('is not shown at the edges and only once in a row', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              SmartContextMenuItem.separator(),
              rowCell('Copy'),
              SmartContextMenuItem.separator(),
              SmartContextMenuItem.separator(),
              rowCell('Share'),
              SmartContextMenuItem.separator(),
            ],
          ),
        ],
      );
      await tester.openMenu();

      final row = tester.getRect(rowLayouts);
      final copy = tester.cellRectOf('Copy');
      final share = tester.cellRectOf('Share');
      expect(copy.left, row.left);
      expect(share.right, row.right);
      expect(share.left - copy.right, defaultStyle.separatorThickness);
    });

    testWidgets('shows a title at the start but not at the end', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              SmartContextMenuItem.separator(child: const Text('Speed')),
              rowCell('Slow'),
              rowCell('Fast'),
              SmartContextMenuItem.separator(child: const Text('End')),
            ],
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('End'), findsNothing);
      final row = tester.getRect(rowLayouts);
      expect(tester.getTopLeft(find.text('Speed')).dx, row.left);
      expect(tester.cellRectOf('Fast').right, row.right);
    });

    testWidgets('a row with a title only is not shown', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.row(
            children: [
              SmartContextMenuItem.separator(child: const Text('Speed')),
            ],
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('Speed'), findsNothing);
      expect(rowLayouts, findsNothing);
    });

    testWidgets('shows its child as tall as the row', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              rowCell('Copy'),
              SmartContextMenuItem.separator(child: const Text('or')),
              rowCell('Share'),
            ],
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('or'), findsOneWidget);
      expect(
        tester.cellRectOf('Share').left - tester.cellRectOf('Copy').right,
        tester.getSize(find.text('or')).width,
      );
    });
  });

  group('dividers between cells', () {
    testWidgets('are drawn with dividersBetweenChildren', (tester) async {
      await tester.pumpMenu(
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            rowStyle: SmartContextMenuRowStyle(
              dividerIndent: 4,
              dividerEndIndent: 6,
            ),
          ),
        ),
        items: [
          SmartContextMenuItem.row(
            dividersBetweenChildren: true,
            children: [rowCell('Copy'), rowCell('Share'), rowCell('Pin')],
          ),
        ],
      );
      await tester.openMenu();

      expect(rowDividers, findsNWidgets(2));
      final line = tester.getRect(
        find.descendant(
          of: rowDividers.first,
          matching: find.byType(ColoredBox),
        ),
      );
      final row = tester.getRect(rowLayouts);
      expect(line.width, defaultStyle.dividerThickness);
      expect(line.top - row.top, 4);
      expect(row.bottom - line.bottom, 6);
      expect(line.left, tester.cellRectOf('Copy').right);
    });

    testWidgets('are not drawn next to a separator', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            dividersBetweenChildren: true,
            children: [
              rowCell('Copy'),
              SmartContextMenuItem.separator(),
              rowCell('Share'),
              rowCell('Pin'),
            ],
          ),
        ],
      );
      await tester.openMenu();

      expect(rowDividers, findsOneWidget);
    });

    testWidgets('follow dividersBetweenItems by default', (tester) async {
      await tester.pumpMenu(
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(dividersBetweenItems: true),
        ),
        items: [
          SmartContextMenuItem.row(
            children: [rowCell('Copy'), rowCell('Share')],
          ),
          SmartContextMenuItem.row(
            dividersBetweenChildren: false,
            children: [rowCell('Pin'), rowCell('Reply')],
          ),
        ],
      );
      await tester.openMenu();

      expect(rowDividers, findsOneWidget);
      expect(tester.getRect(rowDividers).left, tester.cellRectOf('Copy').right);
      // The rows are divided from each other as items.
      expect(dividers, findsOneWidget);
    });
  });
}
