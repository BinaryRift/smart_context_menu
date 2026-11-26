import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu_example/core/ui/reactions_bar.dart';

import '../helpers/menu_tester.dart';

void main() {
  testWidgets('Liquid Glass opens a comparison with a scrollable submenu', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    expect(find.text('Rendering'), findsOneWidget);

    await tester.tap(find.text('Liquid Glass'));
    await tester.pumpAndSettle();
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);

    await tester.tap(find.text('Open menu'));
    await tester.settleMenu();
    await tester.tap(find.text('Browse folders'));
    await tester.pumpAndSettle();
    expect(find.text('Project 1'), findsOneWidget);
    expect(find.text('Project 18').hitTestable(), findsNothing);

    await tester.fling(find.text('Project 1'), const Offset(0, -420), 1300);
    await tester.pumpAndSettle();
    expect(find.text('Project 18').hitTestable(), findsOneWidget);
  });

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

  testWidgets('a long press on the photo opens only its menu', (tester) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    final card = find.text('Menu inside a menu');
    await tester.scrollUntilVisible(card, 200);
    await tester.pumpAndSettle();

    await tester.openMenu(
      find.descendant(
        of: find.ancestor(of: card, matching: find.byType(Row)),
        matching: find.byType(Image),
      ),
    );

    expect(find.text('Save photo'), findsOneWidget);
    expect(find.text('Pin'), findsNothing);
  });
}
