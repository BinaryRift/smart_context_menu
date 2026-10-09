import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('shows the empty label with the empty icon by default', (
    tester,
  ) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.empty()]);
    await tester.openMenu();

    expect(find.text(const SmartContextMenuLabels().empty), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.emptyIcon), findsOneWidget);
  });

  testWidgets('shows its title, leading and trailing', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.empty(
          title: 'No drafts',
          leading: const Icon(CupertinoIcons.doc),
          trailing: const Icon(CupertinoIcons.clock),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('No drafts'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.doc), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.emptyIcon), findsNothing);
  });

  testWidgets('gives its child the color of the item', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Enabled'),
        SmartContextMenuItem.empty(
          title: 'No drafts',
          child: const Row(
            children: [Text('Custom'), Icon(CupertinoIcons.clock)],
          ),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('No drafts'), findsNothing);
    final color = tester.titleStyleOf('Enabled').color;
    expect(
      DefaultTextStyle.of(tester.element(find.text('Custom'))).style.color,
      color,
    );
    expect(tester.iconColorOf(CupertinoIcons.clock), color);
  });

  testWidgets('is not dimmed', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Enabled'),
        SmartContextMenuItem.empty(title: 'No drafts'),
      ],
    );
    await tester.openMenu();

    expect(
      tester.titleStyleOf('No drafts').color,
      tester.titleStyleOf('Enabled').color,
    );
  });

  testWidgets('is not highlighted under the finger', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.empty(title: 'No drafts')],
    );
    await tester.openMenu();

    final gesture = await tester.pressAt(find.text('No drafts'));
    expect(
      tester.backgroundOf('No drafts'),
      isSameColorAs(const Color(0x00000000)),
    );

    await tester.releaseOutside(gesture);
  });

  testWidgets('keeps the menu open on tap', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.empty(title: 'No drafts')],
    );
    await tester.openMenu();

    await tester.tap(find.text('No drafts'));
    await tester.settleMenu();

    expect(find.text('No drafts'), findsOneWidget);
  });

  testWidgets('centers its title', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.empty(title: 'No drafts')],
    );
    await tester.openMenu();

    expect(
      tester.widget<Text>(find.text('No drafts')).textAlign,
      TextAlign.center,
    );
  });
}
