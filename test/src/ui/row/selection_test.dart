import 'dart:ui' show PointerDeviceKind;

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';
import '../../../helpers/row_tester.dart';

void main() {
  group('drag-to-select', () {
    testWidgets('the highlight follows the finger from cell to cell', (
      tester,
    ) async {
      final taps = <String>[];
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              rowCell('Copy', taps: taps),
              rowCell('Share', taps: taps),
            ],
          ),
        ],
      );
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Copy'));
      expect(tester.backgroundOf('Copy'), isNot(isSameColorAs(transparent)));
      expect(tester.backgroundOf('Share'), isSameColorAs(transparent));

      await gesture.moveTo(tester.getCenter(find.text('Share')));
      await tester.pump();
      expect(tester.backgroundOf('Copy'), isSameColorAs(transparent));
      expect(tester.backgroundOf('Share'), isNot(isSameColorAs(transparent)));

      await gesture.up();
      await tester.settleMenu();
      expect(taps, ['Share']);
    });

    testWidgets('moves between a row and the items of the level', (
      tester,
    ) async {
      final taps = <String>[];
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.row(
            children: [
              rowCell('Copy', taps: taps),
              rowCell('Share', taps: taps),
            ],
          ),
          rowCell('Reply', taps: taps),
        ],
      );
      await tester.openMenu();

      await tester.dragTo(find.text('Copy'), find.text('Reply'));
      expect(taps, ['Reply']);

      await tester.dragTo(find.text('Reply'), find.text('Share'));
      expect(taps, ['Reply', 'Share']);
    });
  });

  testWidgets('a cursor highlights the cells one by one', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.row(children: [rowCell('Copy'), rowCell('Share')]),
      ],
    );
    await tester.openMenu();

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Copy')));
    await tester.pump();
    expect(tester.backgroundOf('Copy'), isNot(isSameColorAs(transparent)));

    await mouse.moveTo(tester.getCenter(find.text('Share')));
    await tester.pump();
    expect(tester.backgroundOf('Copy'), isSameColorAs(transparent));
    expect(tester.backgroundOf('Share'), isNot(isSameColorAs(transparent)));
  });
}
