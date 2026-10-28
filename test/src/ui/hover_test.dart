import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  const highlight = Color(0x33000001);
  const transparent = Color(0x00000000);
  const config = SmartContextMenuConfig(
    style: SmartContextMenuStyle(highlightColor: highlight),
  );

  Future<TestGesture> mouseAt(WidgetTester tester, Finder target) async {
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(target));
    await tester.pump();
    return mouse;
  }

  testWidgets('highlights available items on hover without selecting them', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpMenu(
      config: config,
      items: [
        SmartContextMenuItem.simple(
          title: 'First',
          closeOnTap: false,
          onTap: () => taps++,
        ),
        SmartContextMenuItem.simple(
          title: 'Second',
          closeOnTap: false,
          onTap: () => taps++,
        ),
      ],
    );
    await tester.openMenu();

    final mouse = await mouseAt(tester, find.text('First'));
    expect(tester.backgroundOf('First'), isSameColorAs(highlight));
    expect(tester.backgroundOf('Second'), isSameColorAs(transparent));
    expect(taps, 0);

    await mouse.moveTo(tester.getCenter(find.text('Second')));
    await tester.pump();
    expect(tester.backgroundOf('First'), isSameColorAs(transparent));
    expect(tester.backgroundOf('Second'), isSameColorAs(highlight));

    await mouse.moveTo(const Offset(1, 1));
    await tester.pump();
    expect(tester.backgroundOf('Second'), isSameColorAs(transparent));
    expect(taps, 0);
  });

  testWidgets('does not highlight disabled or noninteractive items', (
    tester,
  ) async {
    await tester.pumpMenu(
      config: config,
      items: [
        SmartContextMenuItem.simple(title: 'Disabled', isDisabled: true),
        SmartContextMenuItem.simple(title: 'No action', closeOnTap: false),
        SmartContextMenuItem.simple(title: 'Enabled'),
      ],
    );
    await tester.openMenu();

    final mouse = await mouseAt(tester, find.text('Disabled'));
    expect(tester.backgroundOf('Disabled'), isSameColorAs(transparent));

    await mouse.moveTo(tester.getCenter(find.text('No action')));
    await tester.pump();
    expect(tester.backgroundOf('No action'), isSameColorAs(transparent));

    await mouse.moveTo(tester.getCenter(find.text('Enabled')));
    await tester.pump();
    expect(tester.backgroundOf('Enabled'), isSameColorAs(highlight));
  });

  testWidgets('leaves an interactive child to handle its own hover', (
    tester,
  ) async {
    await tester.pumpMenu(
      config: config,
      items: [
        SmartContextMenuItem.simple(
          title: 'Menu',
          onTap: () {},
          customBuilder: (context, state) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Menu'),
              GestureDetector(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Button'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    await tester.openMenu();

    final mouse = await mouseAt(tester, find.text('Button'));
    expect(tester.backgroundOf('Menu'), isSameColorAs(transparent));

    await mouse.moveTo(tester.getCenter(find.text('Menu')));
    await tester.pump();
    expect(tester.backgroundOf('Menu'), isSameColorAs(highlight));
  });

  testWidgets('clicks the hovered item once and keeps hover afterward', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpMenu(
      config: config,
      items: [
        SmartContextMenuItem.simple(
          title: 'Copy',
          closeOnTap: false,
          onTap: () => taps++,
        ),
      ],
    );
    await tester.openMenu();

    final mouse = await mouseAt(tester, find.text('Copy'));
    await mouse.down(tester.getCenter(find.text('Copy')));
    await tester.pump();
    await mouse.up();
    await tester.pump();
    await tester.pump();

    expect(taps, 1);
    expect(tester.backgroundOf('Copy'), isSameColorAs(highlight));
  });

  testWidgets('highlights the back item of a submenu', (tester) async {
    await tester.pumpMenu(items: submenuItems(), config: config);
    await tester.openSubmenu();

    await mouseAt(tester, find.text(const SmartContextMenuLabels().back).last);
    expect(
      tester.backgroundAt(find.text(const SmartContextMenuLabels().back).last),
      isSameColorAs(highlight),
    );
    expect(find.text('Child'), findsOneWidget);
  });

  testWidgets('updates hover when items scroll under a stationary cursor', (
    tester,
  ) async {
    await tester.pumpMenu(
      config: config,
      items: [
        for (var i = 1; i <= 20; i++)
          SmartContextMenuItem.simple(title: 'Item $i'),
      ],
    );
    await tester.openMenu();

    await mouseAt(tester, find.text('Item 5'));
    expect(tester.backgroundOf('Item 5'), isSameColorAs(highlight));

    final itemHeight =
        tester.getCenter(find.text('Item 6')).dy -
        tester.getCenter(find.text('Item 5')).dy;
    final scrollable = tester.state<ScrollableState>(
      find
          .ancestor(of: find.text('Item 5'), matching: find.byType(Scrollable))
          .first,
    );
    scrollable.position.jumpTo(itemHeight);
    await tester.pump();
    await tester.pump();

    expect(tester.backgroundOf('Item 5'), isSameColorAs(transparent));
    expect(tester.backgroundOf('Item 6'), isSameColorAs(highlight));
  });

  testWidgets('resumes hover after a touch scroll', (tester) async {
    await tester.pumpMenu(
      config: config,
      items: [
        for (var i = 1; i <= 20; i++)
          SmartContextMenuItem.simple(title: 'Item $i'),
      ],
    );
    await tester.openMenu();

    await tester.drag(find.text('Item 5'), const Offset(0, -100));
    await tester.pumpAndSettle();

    await mouseAt(tester, find.text('Item 6'));
    expect(tester.backgroundOf('Item 6'), isSameColorAs(highlight));
  });
}
