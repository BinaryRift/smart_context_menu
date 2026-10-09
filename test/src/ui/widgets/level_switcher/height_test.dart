import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/level_switcher_tester.dart';

void main() {
  testWidgets('moves between the levels with a transition', (tester) async {
    await tester.pumpWidget(sizedSwitcher(depth: 1));
    expect(tester.switcherHeight, 100);

    await tester.pumpWidget(sizedSwitcher(depth: 2));
    await tester.pumpHalfway();
    expect(tester.switcherHeight, inExclusiveRange(100, 200));

    await tester.pumpAndSettle();
    expect(tester.switcherHeight, 200);
  });

  testWidgets('follows the finger during a swipe back', (tester) async {
    await tester.pumpWidget(sizedSwitcher(depth: 2));
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Level 2')),
    );
    await gesture.moveBy(const Offset(30, 0));
    await gesture.moveBy(const Offset(90, 0));
    await tester.pump();

    final progress = tester.slideOf('Level 2');
    expect(progress, greaterThan(0));
    expect(tester.switcherHeight, moreOrLessEquals(200 - 100 * progress));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.switcherHeight, 200);
  });

  testWidgets('is the parent height after a swipe back', (tester) async {
    await tester.pumpWidget(sizedSwitcher(depth: 2));
    await tester.slowSwipe('Level 2', 200);

    expect(find.text('Level 2'), findsNothing);
    expect(tester.switcherHeight, 100);
  });

  testWidgets('animates a change of height inside a level', (tester) async {
    await tester.pumpWidget(sizedSwitcher(depth: 1));
    await tester.pumpWidget(sizedSwitcher(depth: 1, height: 300));
    await tester.pumpHalfway();
    expect(tester.switcherHeight, inExclusiveRange(100, 300));

    await tester.pumpAndSettle();
    expect(tester.switcherHeight, 300);
  });
}
