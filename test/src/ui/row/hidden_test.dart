// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';
import '../../../helpers/row_tester.dart';

void main() {
  group('a row without cells', () {
    testWidgets('is not shown, nor a row of separators', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(children: []),
          rowCell('Copy'),
          SmartContextMenuItem.row(
            children: [
              SmartContextMenuItem.separator(),
              SmartContextMenuItem.separator(),
            ],
          ),
        ],
      );
      await tester.openMenu();

      expect(rowLayouts, findsNothing);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('leaves no separator or divider at the edge', (tester) async {
      await tester.pumpMenu(
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(dividersBetweenItems: true),
        ),
        items: [
          rowCell('Copy'),
          rowCell('Share'),
          SmartContextMenuItem.separator(),
          SmartContextMenuItem.row(children: []),
        ],
      );
      await tester.openMenu();

      final band = find.byWidgetPredicate(
        (widget) => widget is Container && isSeparatorColor(widget.color),
      );
      expect(band, findsNothing);
      expect(dividers, findsOneWidget);
    });

    testWidgets('does not split two separators around it', (tester) async {
      await tester.pumpMenu(
        items: [
          rowCell('Copy'),
          SmartContextMenuItem.separator(),
          SmartContextMenuItem.row(children: []),
          SmartContextMenuItem.separator(),
          rowCell('Share'),
        ],
      );
      await tester.openMenu();

      expect(
        tester.cellRectOf('Share').top - tester.cellRectOf('Copy').bottom,
        defaultStyle.separatorThickness,
      );
    });
  });
}
