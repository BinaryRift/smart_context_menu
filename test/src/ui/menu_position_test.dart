import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

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
}
