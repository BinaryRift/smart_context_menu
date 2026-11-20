// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../../helpers/appearance_tester.dart';
import '../../../../helpers/row_tester.dart';

void main() {
  group('submenu icon', () {
    for (final size in SmartContextMenuRowSize.values) {
      testWidgets('is in the top end corner of a $size cell', (tester) async {
        await tester.pumpCells([
          SmartContextMenuItem.submenu(
            title: 'More',
            leading: const Icon(copyIcon),
            children: [],
          ),
        ], size: size);

        final icon = find.byIcon(defaultStyle.submenuIcon);
        final cell = tester.cellFrameOf(find.byIcon(copyIcon));
        expect(
          tester.getSize(icon),
          Size.square(defaultStyle.defaultIconSize / 2),
        );
        expect(tester.getRect(icon).top - cell.top, 6);
        expect(cell.right - tester.getRect(icon).right, 6);
        expect(tester.getRect(find.byIcon(copyIcon)).center.dx, cell.center.dx);
      });
    }

    testWidgets('is in the top left corner in RTL', (tester) async {
      await tester.pumpCells([
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          leading: const Icon(copyIcon),
          asyncChildren: () async => [],
        ),
      ], textDirection: TextDirection.rtl);

      final icon = find.byIcon(CupertinoIcons.chevron_back);
      final cell = tester.cellFrameOf(find.byIcon(copyIcon));
      expect(tester.getRect(icon).top - cell.top, 6);
      expect(tester.getRect(icon).left - cell.left, 6);
    });

    testWidgets('is dimmed on a disabled cell', (tester) async {
      await tester.pumpCells([
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          isDisabled: true,
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ),
      ]);

      expect(
        tester.widget<Icon>(find.byIcon(defaultStyle.submenuIcon)).color,
        isSameColorAs(light(SmartContextMenuDefaults.disabledForegroundColor)),
      );
    });

    testWidgets('is not shown on an action', (tester) async {
      await tester.pumpCells([SmartContextMenuItem.simple(title: 'Copy')]);

      expect(find.byIcon(defaultStyle.submenuIcon), findsNothing);
    });
  });
}
