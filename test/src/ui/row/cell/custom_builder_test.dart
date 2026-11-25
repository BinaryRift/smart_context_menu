// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/view/item/smart_context_menu_item_view.dart';

import '../../../../helpers/row_tester.dart';

void main() {
  group('customBuilder', () {
    for (final size in SmartContextMenuRowSize.values) {
      testWidgets('gets the $size row size', (tester) async {
        SmartContextMenuRowSize? rowSize;
        await tester.pumpCells([
          SmartContextMenuItem.simple(
            customBuilder: (context, state) {
              rowSize = state.rowSize;
              return const SizedBox(height: 10);
            },
          ),
        ], size: size);

        expect(rowSize, size);
      });
    }

    testWidgets('gets no row size in a list', (tester) async {
      var rowSize = SmartContextMenuRowSize.small as SmartContextMenuRowSize?;
      await tester.pumpWidget(
        CupertinoApp(
          home: SmartContextMenuItemView(
            key: const ValueKey('item'),
            config: const SmartContextMenuConfig(),
            item: SmartContextMenuItem.simple(
              customBuilder: (context, state) {
                rowSize = state.rowSize;
                return const SizedBox(height: 10);
              },
            ),
          ),
        ),
      );

      expect(rowSize, isNull);
    });
  });
}
