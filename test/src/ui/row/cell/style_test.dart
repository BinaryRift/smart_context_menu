// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../../helpers/appearance_tester.dart';
import '../../../../helpers/row_tester.dart';

void main() {
  group('title style', () {
    testWidgets('merges the row title style over the title style', (
      tester,
    ) async {
      await tester.pumpCells([
        SmartContextMenuItem.simple(
          title: 'Copy',
          titleStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        SmartContextMenuItem.simple(title: 'Share'),
      ]);

      final own = tester.titleStyleOf('Copy');
      expect(own.fontSize, SmartContextMenuDefaults.rowTitleStyle.fontSize);
      expect(own.fontWeight, FontWeight.w600);
      expect(
        tester.titleStyleOf('Share').fontSize,
        SmartContextMenuDefaults.rowTitleStyle.fontSize,
      );
    });

    testWidgets('takes the row title style from the style', (tester) async {
      await tester.pumpCells(
        [SmartContextMenuItem.simple(title: 'Copy')],
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            rowStyle: SmartContextMenuRowStyle(
              titleStyle: TextStyle(fontSize: 10),
            ),
          ),
        ),
      );

      expect(tester.titleStyleOf('Copy').fontSize, 10);
    });
  });

  group('padding and gap', () {
    testWidgets('of the item take precedence over the style', (tester) async {
      const padding = EdgeInsets.all(3);
      await tester.pumpCells([
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(copyIcon),
          padding: padding,
          childrenGap: 9,
        ),
      ]);

      expect(tester.itemPaddingOf('Copy'), padding);
      expect(
        tester.getTopLeft(find.text('Copy')).dy -
            tester.getBottomLeft(find.byIcon(copyIcon)).dy,
        9,
      );
    });

    testWidgets('come from the style of each size', (tester) async {
      const small = EdgeInsets.all(1);
      const medium = EdgeInsets.all(2);
      const config = SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          rowStyle: SmartContextMenuRowStyle(
            smallItemPadding: small,
            mediumItemPadding: medium,
            itemChildrenGap: 7,
          ),
        ),
      );

      await tester.pumpCells(
        [SmartContextMenuItem.simple(title: 'Copy')],
        size: SmartContextMenuRowSize.small,
        config: config,
      );
      expect(tester.itemPaddingOf('Copy'), small);

      await tester.pumpCells([
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(copyIcon),
        ),
      ], config: config);
      expect(tester.itemPaddingOf('Copy'), medium);
      expect(
        tester.getTopLeft(find.text('Copy')).dy -
            tester.getBottomLeft(find.byIcon(copyIcon)).dy,
        7,
      );
    });
  });
}
