import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('shows its title with an activity indicator in the menu', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.loading(title: 'Syncing')],
    );
    await tester.openMenu();

    expect(find.text('Syncing'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('shows its trailing instead of the activity indicator', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.loading(
          title: 'Syncing',
          trailing: const Icon(CupertinoIcons.clock),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Syncing'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('is not highlighted under the finger', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.loading(title: 'Syncing')],
    );
    await tester.openMenu();

    final gesture = await tester.pressAt(find.text('Syncing'));
    expect(
      tester.backgroundOf('Syncing'),
      isSameColorAs(const Color(0x00000000)),
    );

    await tester.releaseOutside(gesture);
  });

  testWidgets('shows its title with an activity indicator in a submenu', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.submenu(
          title: 'More',
          children: [SmartContextMenuItem.loading(title: 'Syncing')],
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();

    expect(find.text('Syncing'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('gives its child the color of the item', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Enabled'),
        SmartContextMenuItem.loading(
          child: const Row(
            children: [Text('Custom'), Icon(CupertinoIcons.clock)],
          ),
        ),
      ],
    );
    await tester.openMenu();

    final color = tester.titleStyleOf('Enabled').color;
    expect(
      DefaultTextStyle.of(tester.element(find.text('Custom'))).style.color,
      color,
    );
    expect(tester.iconColorOf(CupertinoIcons.clock), color);
  });

  testWidgets('centers its title, unlike an action', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.loading(title: 'Syncing'),
      ],
    );
    await tester.openMenu();

    expect(
      tester.widget<Text>(find.text('Syncing')).textAlign,
      TextAlign.center,
    );
    expect(tester.widget<Text>(find.text('Copy')).textAlign, TextAlign.start);
  });
}
