import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_level_switcher.dart';

import '../../../../helpers/level_switcher_tester.dart';

void main() {
  testWidgets('drags the level with the finger and reveals the parent', (
    tester,
  ) async {
    await tester.pumpWidget(swipeableSwitcher());
    expect(find.text('Level 1'), findsNothing);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Level 2')),
    );
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    final start = tester.slideOf('Level 2');

    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    final width = tester
        .getSize(find.byType(SmartContextMenuLevelSwitcher))
        .width;
    expect(tester.slideOf('Level 2') - start, moreOrLessEquals(80 / width));
    expect(tester.slideOf('Level 1'), lessThan(0));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('shows the parent only left of the swiped level', (tester) async {
    await tester.pumpWidget(swipeableSwitcher());
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Level 2')),
    );
    await gesture.moveBy(const Offset(30, 0));
    await gesture.moveBy(const Offset(120, 0));
    await tester.pump();

    final parentClip = tester.clipOf('Level 1');
    final width = tester
        .getSize(find.byType(SmartContextMenuLevelSwitcher))
        .width;
    expect(parentClip.clipBehavior, Clip.hardEdge);
    expect(
      parentClip.clipper!.getClip(parentClip.size).width,
      moreOrLessEquals(tester.slideOf('Level 2') * width),
    );
    expect(tester.clipOf('Level 2').clipBehavior, Clip.none);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.clipOf('Level 2').clipBehavior, Clip.none);
  });

  testWidgets('returns to the parent past half of the width', (tester) async {
    await tester.pumpWidget(swipeableSwitcher());
    await tester.slowSwipe('Level 2', 500);

    expect(find.text('Level 2'), findsNothing);
    expect(tester.slideOf('Level 1'), 0);
  });

  testWidgets('a short swipe returns the level in place', (tester) async {
    await tester.pumpWidget(swipeableSwitcher());
    await tester.slowSwipe('Level 2', 200);

    expect(find.text('Level 1'), findsNothing);
    expect(tester.slideOf('Level 2'), 0);
  });

  testWidgets('a fast short swipe returns to the parent', (tester) async {
    await tester.pumpWidget(swipeableSwitcher());
    await tester.fling(find.text('Level 2'), const Offset(150, 0), 1500);
    await tester.pumpAndSettle();

    expect(find.text('Level 2'), findsNothing);
    expect(tester.slideOf('Level 1'), 0);
  });

  testWidgets('a swipe back is followed by the next one', (tester) async {
    await tester.pumpWidget(swipeableSwitcher(depth: 3));
    await tester.slowSwipe('Level 3', 500);
    await tester.slowSwipe('Level 2', 500);

    expect(find.text('Level 3'), findsNothing);
    expect(find.text('Level 2'), findsNothing);
    expect(tester.slideOf('Level 1'), 0);
  });

  testWidgets('does nothing when disabled', (tester) async {
    await tester.pumpWidget(swipeableSwitcher(enableSwipeBack: false));
    await tester.slowSwipe('Level 2', 500);

    expect(find.text('Level 1'), findsNothing);
    expect(tester.slideOf('Level 2'), 0);
  });

  testWidgets('does nothing without a parent level', (tester) async {
    await tester.pumpWidget(swipeableSwitcher(depth: 1));
    await tester.slowSwipe('Level 1', 500);

    expect(tester.slideOf('Level 1'), 0);
  });
}
