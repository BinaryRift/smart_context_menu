import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('back item does not trigger an item with the same id', (
    tester,
  ) async {
    var collidingTaps = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.submenu(
          title: 'More',
          children: [
            SmartContextMenuItem.simple(
              id: 'back_button',
              title: 'Colliding',
              closeOnTap: false,
              onTap: () => collidingTaps++,
            ),
          ],
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Colliding'), findsOneWidget);

    await tester.tap(find.text(const SmartContextMenuLabels().back).last);
    await tester.settleMenu();

    expect(collidingTaps, 0);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Colliding'), findsNothing);
  });
}
