import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'helpers/menu_tester.dart';

void main() {
  testWidgets('renders child without opening the menu', (tester) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Copy')]);

    expect(find.text(menuTargetText), findsOneWidget);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('opens the menu on long press', (tester) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Copy')]);

    await tester.openMenu();

    expect(find.text('Copy'), findsOneWidget);
  });
}
