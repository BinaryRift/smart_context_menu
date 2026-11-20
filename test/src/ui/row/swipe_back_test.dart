import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';
import '../../../helpers/row_tester.dart';

const _back = SmartContextMenuLabels();

extension on WidgetTester {
  /// Drags from [from] by [distance] to the right slowly, with no release
  /// speed, and lifts the finger there.
  Future<void> slowDrag(Offset from, double distance) async {
    final gesture = await startGesture(from);
    for (var moved = 0.0; moved < distance; moved += 20) {
      await gesture.moveBy(const Offset(20, 0));
      await pump(const Duration(milliseconds: 50));
    }
    await pump(const Duration(milliseconds: 300));
    await gesture.up();
    await settleMenu();
  }
}

void main() {
  final taps = <String>[];

  setUp(taps.clear);

  /// Opens a submenu with a row of Copy, Share and Pin and an item below.
  Future<void> openSubmenu(
    WidgetTester tester, {
    bool enableSwipeBack = false,
    double childrenGap = 0,
  }) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.submenu(
          title: 'More',
          children: [
            SmartContextMenuItem.row(
              enableSwipeBack: enableSwipeBack,
              childrenGap: childrenGap,
              children: [
                rowCell('Copy', taps: taps),
                rowCell('Share', taps: taps),
                rowCell('Pin', taps: taps),
              ],
            ),
            rowCell('Reply', taps: taps),
          ],
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Copy'), findsOneWidget);
  }

  bool isInSubmenu() => find.text('Copy').evaluate().isNotEmpty;

  group('without enableSwipeBack', () {
    testWidgets('a horizontal drag on the row selects the cells', (
      tester,
    ) async {
      await openSubmenu(tester);
      final copy = tester.getCenter(find.text('Copy'));
      final share = tester.getCenter(find.text('Share'));

      await tester.slowDrag(copy, share.dx - copy.dx);

      expect(isInSubmenu(), isTrue);
      expect(taps, ['Share']);
    });

    testWidgets('a drag in the gap between the cells does not swipe back', (
      tester,
    ) async {
      await openSubmenu(tester, childrenGap: 20);
      final gap = tester.cellRectOf('Copy').centerRight + const Offset(10, 0);

      await tester.slowDrag(gap, 200);

      expect(isInSubmenu(), isTrue);
    });

    testWidgets('a swipe on an item below the row returns', (tester) async {
      await openSubmenu(tester);

      await tester.slowDrag(tester.getCenter(find.text('Reply')), 200);

      expect(isInSubmenu(), isFalse);
      expect(find.text('More'), findsOneWidget);
      expect(taps, isEmpty);
    });

    testWidgets('a swipe on the back item returns', (tester) async {
      await openSubmenu(tester);

      await tester.slowDrag(tester.getCenter(find.text(_back.back).last), 200);

      expect(isInSubmenu(), isFalse);
    });
  });

  testWidgets('with enableSwipeBack a swipe on the row returns', (
    tester,
  ) async {
    await openSubmenu(tester, enableSwipeBack: true);

    await tester.slowDrag(tester.getCenter(find.text('Copy')), 200);

    expect(isInSubmenu(), isFalse);
    expect(taps, isEmpty);
  });

  testWidgets('without the swipe back of the menu a drag selects the cells', (
    tester,
  ) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(enableSwipeBack: false),
      items: [
        SmartContextMenuItem.submenu(
          title: 'More',
          children: [
            SmartContextMenuItem.row(
              enableSwipeBack: true,
              children: [
                rowCell('Copy', taps: taps),
                rowCell('Share', taps: taps),
              ],
            ),
          ],
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();
    final copy = tester.getCenter(find.text('Copy'));
    final share = tester.getCenter(find.text('Share'));

    await tester.slowDrag(copy, share.dx - copy.dx);

    expect(isInSubmenu(), isTrue);
    expect(taps, ['Share']);
  });
}
