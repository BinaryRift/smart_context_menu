import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/view/smart_context_menu_view.dart';

import '../../helpers/menu_tester.dart';

const _back = SmartContextMenuLabels();

/// A menu for a widget near the bottom edge, with a submenu of
/// [submenuLength] items.
Widget _bottomMenu({
  required int submenuLength,
  double targetHeight = 20,
  bool moveBackDown = false,
}) {
  return CupertinoApp(
    home: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: SmartContextMenu(
          config: SmartContextMenuConfig(moveBackDown: moveBackDown),
          items: [
            SmartContextMenuItem.submenu(
              title: 'More',
              children: [
                for (var i = 1; i <= submenuLength; i++)
                  SmartContextMenuItem.simple(title: 'Child $i'),
              ],
            ),
            SmartContextMenuItem.simple(title: 'Root item'),
          ],
          child: SizedBox(
            width: 200,
            height: targetHeight,
            child: const Text(menuTargetText),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('by default the menu stays under the finger after going back', (
    tester,
  ) async {
    await tester.pumpWidget(_bottomMenu(submenuLength: 6));
    await tester.openMenu();
    final rootTop = tester.getTopLeft(find.text('More')).dy;

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    final backTop = tester.getTopLeft(find.text(_back.back).last).dy;
    expect(backTop, lessThan(rootTop));

    await tester.tap(find.text(_back.back).last);
    await tester.settleMenu();
    // The pinned back item is shifted up by half a pixel.
    expect(tester.getTopLeft(find.text('More')).dy, closeTo(backTop, 1));
  });

  testWidgets('with moveBackDown the menu moves back down when shorter', (
    tester,
  ) async {
    await tester.pumpWidget(_bottomMenu(submenuLength: 6, moveBackDown: true));
    await tester.openMenu();
    final rootTop = tester.getTopLeft(find.text('More')).dy;

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(tester.getTopLeft(find.text('Child 1')).dy, lessThan(rootTop));

    await tester.tap(find.text(_back.back).last);
    await tester.settleMenu();
    expect(tester.getTopLeft(find.text('More')).dy, moreOrLessEquals(rootTop));
  });

  testWidgets('with moveBackDown the menu moves back down smoothly '
      'after a scrolled submenu', (tester) async {
    // The tall widget and the long submenu do not fit together, so the
    // submenu scrolls; the root menu fits without scrolling.
    await tester.pumpWidget(
      _bottomMenu(submenuLength: 20, targetHeight: 250, moveBackDown: true),
    );
    await tester.openMenu();
    final rootTop = tester.getTopLeft(find.text('More')).dy;

    await tester.tap(find.text('More'));
    await tester.settleMenu(frames: 10);
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.pixels, greaterThan(0));

    await tester.tap(find.text(_back.back).last);
    final tops = <double>[];
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final more = find.text('More');
      if (more.evaluate().isNotEmpty) {
        tops.add(tester.getTopLeft(more.first).dy);
      }
    }
    await tester.settleMenu();

    expect(tester.getTopLeft(find.text('More')).dy, moreOrLessEquals(rootTop));
    for (var i = 1; i < tops.length; i++) {
      expect(tops[i], greaterThanOrEqualTo(tops[i - 1]), reason: 'frame $i');
    }
  });

  group('horizontally', () {
    /// Opens the menu of a 20-wide widget at [left] on a [screenWidth]-wide
    /// screen and returns the menu bounds.
    Future<Rect> openMenuAt(
      WidgetTester tester, {
      required double left,
      double screenWidth = 390,
      FakeViewPadding padding = FakeViewPadding.zero,
    }) async {
      tester.view.physicalSize = Size(screenWidth, 800);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = padding;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        CupertinoApp(
          home: Stack(
            children: [
              Positioned(
                left: left,
                top: 100,
                child: SmartContextMenu(
                  items: [SmartContextMenuItem.simple(title: 'Copy')],
                  child: const SizedBox(
                    width: 20,
                    height: 40,
                    child: Text(menuTargetText),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.openMenu();
      return tester.getRect(find.byType(SmartContextMenuView));
    }

    const menuWidth = 250.0;
    const padding = 16.0;

    testWidgets('lines up with the widget edge when the menu fits', (
      tester,
    ) async {
      final menu = await openMenuAt(tester, left: 40);

      expect(menu.left, 40);
      expect(menu.width, menuWidth);
    });

    testWidgets('moves to keep its width and the screen padding', (
      tester,
    ) async {
      final menu = await openMenuAt(tester, left: 150);

      expect(menu.width, menuWidth);
      expect(menu.right, 390 - padding);
    });

    testWidgets('moves to keep its width on the right too', (tester) async {
      final menu = await openMenuAt(tester, left: 220);

      expect(menu.width, menuWidth);
      expect(menu.left, padding);
    });

    testWidgets('gets narrower on a screen narrower than the menu', (
      tester,
    ) async {
      final menu = await openMenuAt(tester, left: 40, screenWidth: 240);

      expect(menu.left, padding);
      expect(menu.right, 240 - padding);
    });

    const notch = FakeViewPadding(left: 47, right: 47);

    testWidgets('keeps the screen padding outside the left safe area', (
      tester,
    ) async {
      final menu = await openMenuAt(tester, left: 0, padding: notch);

      expect(menu.left, 47 + padding);
    });

    testWidgets('keeps the screen padding outside the right safe area', (
      tester,
    ) async {
      final menu = await openMenuAt(tester, left: 370, padding: notch);

      expect(menu.right, 390 - 47 - padding);
    });
  });
}
