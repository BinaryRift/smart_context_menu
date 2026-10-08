import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/header_slivers_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('a tap on a widget in the slivers keeps the menu open', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(headerMenu(onHeaderTap: () => taps++));
    await tester.openMenuForPointers();

    await tester.tap(headerFinder);
    await tester.settleMenu();

    expect(taps, 1);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('a tap next to the widgets in the slivers closes the menu', (
    tester,
  ) async {
    await tester.pumpWidget(headerMenu());
    await tester.openMenuForPointers();

    await tester.tapAt(tester.getCenter(headerFinder) + const Offset(150, 0));
    await tester.settleMenu();

    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('a tap next to the slivers keeps a non-dismissible menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      headerMenu(
        config: const SmartContextMenuConfig(barrierDismissible: false),
      ),
    );
    await tester.openMenuForPointers();

    await tester.tapAt(tester.getCenter(headerFinder) + const Offset(150, 0));
    await tester.settleMenu();

    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('a drag from the slivers does not select an item', (
    tester,
  ) async {
    var copies = 0;
    await tester.pumpWidget(
      headerMenu(
        items: [
          SmartContextMenuItem.simple(title: 'Copy', onTap: () => copies++),
        ],
      ),
    );
    await tester.openMenuForPointers();

    final gesture = await tester.startGesture(tester.getCenter(headerFinder));
    await gesture.moveTo(tester.getCenter(find.text('Copy')));
    await tester.pump();
    await gesture.up();
    await tester.settleMenu();

    expect(copies, 0);
    expect(find.text('Copy'), findsOneWidget);
  });
}
