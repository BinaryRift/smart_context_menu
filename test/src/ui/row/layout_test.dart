// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';
import '../../../helpers/row_tester.dart';

void main() {
  group('layout', () {
    testWidgets('a lower cell is pressed over the full height of the row', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [rowCell('Copy'), rowCell('Add to Favorites and more')],
          ),
        ],
      );
      await tester.openMenu();

      final copy = tester.cellRectOf('Copy');
      final row = tester.getRect(rowLayouts);
      expect(copy.height, row.height);
      expect(
        copy.height,
        greaterThan(tester.getBottomLeft(find.text('Copy')).dy - copy.top),
      );

      // Below the title of the lower cell, still inside its frame.
      final gesture = await tester.startGesture(
        copy.bottomCenter - const Offset(0, 4),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
      expect(tester.backgroundOf('Copy'), isNot(isSameColorAs(transparent)));
      await tester.releaseOutside(gesture);
    });

    testWidgets('the gap between the cells is not highlighted', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            childrenGap: 20,
            children: [rowCell('Copy'), rowCell('Share')],
          ),
        ],
      );
      await tester.openMenu();

      final copy = tester.cellRectOf('Copy');
      final gesture = await tester.startGesture(
        copy.centerRight + const Offset(10, 0),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(1, 0));
      await tester.pump();
      expect(tester.backgroundOf('Copy'), isSameColorAs(transparent));
      expect(tester.backgroundOf('Share'), isSameColorAs(transparent));
      await tester.releaseOutside(gesture);
    });

    testWidgets('divides the width by flex', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              SmartContextMenuRowFlex(flex: 2, child: rowCell('Copy')),
              rowCell('Share'),
            ],
          ),
        ],
      );
      await tester.openMenu();

      final row = tester.getRect(rowLayouts);
      expect(tester.cellRectOf('Copy').width, closeTo(row.width * 2 / 3, 1e-6));
      expect(tester.cellRectOf('Share').width, closeTo(row.width / 3, 1e-6));
    });

    testWidgets('puts the first cell on the right in RTL', (tester) async {
      await tester.pumpMenu(
        textDirection: TextDirection.rtl,
        items: [
          SmartContextMenuItem.row(
            children: [rowCell('Copy'), rowCell('Share')],
          ),
        ],
      );
      await tester.openMenu();

      expect(
        tester.cellRectOf('Copy').left,
        greaterThan(tester.cellRectOf('Share').left),
      );
    });

    testWidgets('takes the padding and the gap of the row style', (
      tester,
    ) async {
      await tester.pumpMenu(
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            rowStyle: SmartContextMenuRowStyle(
              padding: EdgeInsets.all(6),
              childrenGap: 10,
            ),
          ),
        ),
        items: [
          SmartContextMenuItem.row(
            children: [rowCell('Copy'), rowCell('Share')],
          ),
        ],
      );
      await tester.openMenu();

      final row = tester.getRect(rowLayouts);
      final copy = tester.cellRectOf('Copy');
      final share = tester.cellRectOf('Share');
      expect(copy.topLeft - row.topLeft, const Offset(6, 6));
      expect(share.left - copy.right, 10);
    });
  });
}
