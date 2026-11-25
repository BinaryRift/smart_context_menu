import 'dart:ui' show PointerDeviceKind;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart'
    show kMiddleMouseButton, kPrimaryButton, kSecondaryMouseButton;
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

  Future<TestGesture> mouseAt(
    WidgetTester tester,
    Finder target, {
    int buttons = kPrimaryButton,
  }) async {
    final mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: buttons,
    );
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

  for (final (name, buttons) in [
    ('secondary', kSecondaryMouseButton),
    ('middle', kMiddleMouseButton),
  ]) {
    testWidgets('a $name click does not select the hovered item', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpMenu(
        config: config,
        items: [
          SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++),
        ],
      );
      await tester.openMenu();

      final mouse = await mouseAt(tester, find.text('Copy'), buttons: buttons);
      await mouse.down(tester.getCenter(find.text('Copy')));
      await tester.pump();
      await mouse.up();
      await tester.pumpAndSettle();

      expect(taps, 0);
      expect(find.text('Copy'), findsOneWidget);
      expect(tester.backgroundOf('Copy'), isSameColorAs(highlight));

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  }

  testWidgets('hover follows the cursor while a secondary button is held', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpMenu(
      config: config,
      items: [
        SmartContextMenuItem.simple(title: 'First', onTap: () => taps++),
        SmartContextMenuItem.simple(title: 'Second', onTap: () => taps++),
      ],
    );
    await tester.openMenu();

    final mouse = await mouseAt(
      tester,
      find.text('First'),
      buttons: kSecondaryMouseButton,
    );
    await mouse.down(tester.getCenter(find.text('First')));
    await mouse.moveTo(tester.getCenter(find.text('Second')));
    await tester.pump();
    expect(tester.backgroundOf('First'), isSameColorAs(transparent));
    expect(tester.backgroundOf('Second'), isSameColorAs(highlight));

    await mouse.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
    expect(tester.backgroundOf('Second'), isSameColorAs(highlight));
  });

  testWidgets('a stylus tap selects the item', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++)],
    );
    await tester.openMenu();

    await tester.tap(find.text('Copy'), kind: PointerDeviceKind.stylus);
    await tester.pumpAndSettle();
    expect(taps, 1);
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

  group('a stationary cursor', () {
    /// Expects only the item under [cursor] of [titles] to be highlighted
    /// and exactly one of them to be under it.
    void expectHoverAt(
      WidgetTester tester,
      Offset cursor,
      List<String> titles,
    ) {
      var itemsUnderCursor = 0;
      for (final title in titles) {
        final text = find.text(title).hitTestable();
        if (text.evaluate().isEmpty) continue;
        final item = find
            .ancestor(of: text.first, matching: find.byType(AnimatedContainer))
            .first;
        final isUnderCursor = tester.getRect(item).contains(cursor);
        if (isUnderCursor) itemsUnderCursor++;
        expect(
          tester.backgroundAt(text.first),
          isSameColorAs(isUnderCursor ? highlight : transparent),
          reason: title,
        );
      }
      expect(itemsUnderCursor, 1);
    }

    testWidgets('follows the items as the whole content scrolls', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const titles = ['First', 'Second', 'Third'];

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SmartContextMenu(
              config: config,
              items: [
                for (final title in titles)
                  SmartContextMenuItem.simple(title: title),
              ],
              child: const SizedBox(height: 700, child: Text(menuTargetText)),
            ),
          ),
        ),
      );
      await tester.openMenu();

      await mouseAt(tester, find.text('First'));
      final cursor = tester.getCenter(find.text('First'));
      expect(tester.backgroundOf('First'), isSameColorAs(highlight));

      final itemHeight =
          tester.getCenter(find.text('Second')).dy -
          tester.getCenter(find.text('First')).dy;
      final content = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(content.position.maxScrollExtent, greaterThan(itemHeight));
      content.position.jumpTo(content.position.pixels + itemHeight);
      await tester.pump();
      await tester.pump();

      expect(tester.backgroundOf('First'), isSameColorAs(transparent));
      expect(tester.backgroundOf('Second'), isSameColorAs(highlight));
      expectHoverAt(tester, cursor, titles);
    });

    testWidgets('follows the level after a click on a submenu and back', (
      tester,
    ) async {
      final back = const SmartContextMenuLabels().back;
      final titles = ['Copy', 'More', 'Paste', back, 'Child 1', 'Child 2'];
      await tester.pumpMenu(
        config: config,
        items: [
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.submenu(
            title: 'More',
            children: [
              SmartContextMenuItem.simple(title: 'Child 1'),
              SmartContextMenuItem.simple(title: 'Child 2'),
            ],
          ),
          SmartContextMenuItem.simple(title: 'Paste'),
        ],
      );
      await tester.openMenu();

      final mouse = await mouseAt(tester, find.text('More'));
      final cursor = tester.getCenter(find.text('More'));
      await mouse.down(cursor);
      await mouse.up();
      await tester.settleMenu();
      expect(find.text('Child 1'), findsOneWidget);
      expectHoverAt(tester, cursor, titles);

      final target = find.text(back).hitTestable().first;
      final backCursor = tester.getCenter(target);
      await mouse.moveTo(backCursor);
      await tester.pump();
      await mouse.down(backCursor);
      await mouse.up();
      await tester.settleMenu();
      expect(find.text('Child 1'), findsNothing);
      expectHoverAt(tester, backCursor, titles);
    });

    testWidgets('keeps the pinned back item over the scrolled items', (
      tester,
    ) async {
      final back = const SmartContextMenuLabels().back;
      await tester.pumpMenu(
        config: config,
        items: [
          SmartContextMenuItem.submenu(
            title: 'More',
            children: [
              for (var i = 1; i <= 20; i++)
                SmartContextMenuItem.simple(title: 'Child $i'),
            ],
          ),
        ],
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();

      final pinnedBack = find.text(back).last;
      await mouseAt(tester, pinnedBack);
      final cursor = tester.getCenter(pinnedBack);
      final scrollable = tester.state<ScrollableState>(
        find
            .ancestor(
              of: find.text('Child 1'),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      scrollable.position.jumpTo(100);
      await tester.pump();
      await tester.pump();

      expect(tester.backgroundAt(pinnedBack), isSameColorAs(highlight));
      var childrenUnderBack = 0;
      for (var i = 1; i <= 20; i++) {
        final child = find.text('Child $i');
        if (child.evaluate().isEmpty) continue;
        final item = find
            .ancestor(of: child, matching: find.byType(AnimatedContainer))
            .first;
        if (tester.getRect(item).contains(cursor)) childrenUnderBack++;
        expect(
          tester.backgroundAt(child),
          isSameColorAs(transparent),
          reason: 'Child $i',
        );
      }
      expect(childrenUnderBack, 1);
    });

    testWidgets('follows an item that changes its height', (tester) async {
      final isTall = ValueNotifier(false);
      addTearDown(isTall.dispose);
      const titles = ['Status', 'Copy', 'Paste'];
      await tester.pumpMenu(
        config: config,
        items: [
          SmartContextMenuItem.listenable(
            listenable: isTall,
            builder: () => SmartContextMenuItem.simple(
              title: 'Status',
              padding: EdgeInsets.symmetric(
                vertical: isTall.value ? 40 : 10,
                horizontal: 16,
              ),
            ),
          ),
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.simple(title: 'Paste'),
        ],
      );
      await tester.openMenu();

      await mouseAt(tester, find.text('Copy'));
      final cursor = tester.getCenter(find.text('Copy'));
      expect(tester.backgroundOf('Copy'), isSameColorAs(highlight));

      isTall.value = true;
      await tester.pumpAndSettle();

      expect(tester.getRect(find.text('Copy')).contains(cursor), isFalse);
      expectHoverAt(tester, cursor, titles);
    });
  });
}
