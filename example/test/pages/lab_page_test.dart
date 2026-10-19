import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu_example/core/ui/reactions_bar.dart';

import '../helpers/menu_tester.dart';

void main() {
  testWidgets('a reaction in the Lab shows feedback immediately', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bar'));
    await tester.pumpAndSettle();
    await tester.openMenu(find.text('All submenu types'));

    await tester.tap(find.text('❤️'));
    await tester.pump();

    expect(
      find.text('Reaction ❤️ on All submenu types (demo only)'),
      findsOneWidget,
    );
    await tester.settleMenu();
    expect(find.byType(ReactionsBar), findsNothing);
  });
}
