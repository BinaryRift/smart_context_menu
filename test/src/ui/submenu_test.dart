import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('back item does not trigger an item with the same id', (
    tester,
  ) async {
    var collidingTaps = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.submenu(
          title: 'More',
          children: [
            SmartContextMenuItem.simple(
              id: 'back_button',
              title: 'Colliding',
              closeOnTap: false,
              onTap: () => collidingTaps++,
            ),
          ],
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Colliding'), findsOneWidget);

    await tester.tap(find.text(const SmartContextMenuLabels().back).last);
    await tester.settleMenu();

    expect(collidingTaps, 0);
    expect(find.text('More'), findsOneWidget);
    expect(find.text('Colliding'), findsNothing);
  });

  group('blur', () {
    Finder blurOf(SmartContextMenuBlur blur) => find.byWidgetPredicate(
      (widget) =>
          widget is BackdropFilter &&
          widget.filter ==
              ImageFilter.blur(sigmaX: blur.sigmaX, sigmaY: blur.sigmaY),
    );

    Future<void> openSubmenu(
      WidgetTester tester, {
      required SmartContextMenuBlur? backButtonBlur,
    }) async {
      await tester.pumpMenu(
        config: SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            backgroundBlur: null,
            menuBlur: SmartContextMenuBlur.small,
            backButtonBlur: backButtonBlur,
          ),
        ),
        items: [
          SmartContextMenuItem.submenu(
            title: 'More',
            children: [SmartContextMenuItem.simple(title: 'Child')],
          ),
        ],
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();
    }

    testWidgets('blurs the menu and the back item', (tester) async {
      await openSubmenu(tester, backButtonBlur: SmartContextMenuBlur.strong);

      expect(find.byType(BackdropFilter), findsNWidgets(2));
      expect(blurOf(SmartContextMenuBlur.small), findsOneWidget);
      expect(blurOf(SmartContextMenuBlur.strong), findsOneWidget);
    });

    testWidgets('does not blur the back item without backButtonBlur', (
      tester,
    ) async {
      await openSubmenu(tester, backButtonBlur: null);

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(blurOf(SmartContextMenuBlur.small), findsOneWidget);
    });
  });
}
