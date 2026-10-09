import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('shows the error label with the error icon by default', (
    tester,
  ) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.error()]);
    await tester.openMenu();

    expect(find.text(const SmartContextMenuLabels().error), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsNothing);
  });

  testWidgets('shows its title, leading and trailing', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.error(
          title: 'Could not sync',
          leading: const Icon(CupertinoIcons.cloud),
          trailing: const Icon(CupertinoIcons.clock),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Could not sync'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.cloud), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsNothing);
  });

  testWidgets('gives its child the color of the item', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Enabled'),
        SmartContextMenuItem.error(
          title: 'Could not sync',
          child: const Row(
            children: [Text('Custom'), Icon(CupertinoIcons.clock)],
          ),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Could not sync'), findsNothing);
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
        SmartContextMenuItem.error(title: 'Could not sync'),
      ],
    );
    await tester.openMenu();

    expect(
      tester.titleStyleOf('Could not sync').color,
      tester.titleStyleOf('Enabled').color,
    );
  });

  testWidgets('is not highlighted under the finger', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.error(title: 'Could not sync')],
    );
    await tester.openMenu();

    final gesture = await tester.pressAt(find.text('Could not sync'));
    expect(
      tester.backgroundOf('Could not sync'),
      isSameColorAs(const Color(0x00000000)),
    );

    await tester.releaseOutside(gesture);
  });

  testWidgets('keeps the menu open on tap', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.error(title: 'Could not sync')],
    );
    await tester.openMenu();

    await tester.tap(find.text('Could not sync'));
    await tester.settleMenu();

    expect(find.text('Could not sync'), findsOneWidget);
  });

  testWidgets('lets a button in its child handle the tap', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.error(
          child: Row(
            children: [
              const Expanded(child: Text('Could not sync')),
              CupertinoButton(
                onPressed: () => taps++,
                child: const Text('Fix'),
              ),
            ],
          ),
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Fix'));
    await tester.settleMenu();

    expect(taps, 1);
    expect(find.text('Could not sync'), findsOneWidget);
  });
}
