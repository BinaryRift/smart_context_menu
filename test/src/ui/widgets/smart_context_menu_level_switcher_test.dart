import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/core/ui/motion/tokens/motion_durations.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_level_switcher.dart';

Widget _switcher(String level, {required bool isForward}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SmartContextMenuLevelSwitcher(
      isForward: isForward,
      onSwipeBack: () {},
      child: Text(level, key: ValueKey(level)),
    ),
  );
}

/// Levels named by their depth; a swipe back goes one level up.
Widget _swipeable({int depth = 2, bool enableSwipeBack = true}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: StatefulBuilder(
      builder: (context, setState) => SmartContextMenuLevelSwitcher(
        isForward: false,
        enableSwipeBack: enableSwipeBack,
        onSwipeBack: () => setState(() => depth--),
        previous: depth > 1 ? _level(depth - 1) : null,
        child: _level(depth),
      ),
    ),
  );
}

Widget _level(int depth) =>
    Text('Level $depth', key: ValueKey('Level $depth'));

extension on WidgetTester {
  double slideOf(String level) {
    final slide = widget<SlideTransition>(
      find.ancestor(
        of: find.text(level),
        matching: find.byType(SlideTransition),
      ),
    );
    return slide.position.value.dx;
  }

  Future<void> pumpHalfway() => pump(MotionDurations.standard * 0.5);

  /// Drags [level] right by [distance] slowly, so the release has no speed.
  Future<void> slowSwipe(String level, double distance) async {
    final gesture = await startGesture(getCenter(find.text(level)));
    const step = 50.0;
    for (var moved = 0.0; moved < distance; moved += step) {
      await gesture.moveBy(const Offset(step, 0));
      await pump(const Duration(milliseconds: 50));
    }
    await pump(const Duration(milliseconds: 300));
    await gesture.up();
    await pumpAndSettle();
  }
}

void main() {
  testWidgets('a submenu slides in from the right '
      'and the parent leaves to the left', (tester) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pumpHalfway();

    expect(tester.slideOf('Submenu'), greaterThan(0));
    expect(tester.slideOf('Root'), lessThan(0));
  });

  testWidgets('a nested submenu pushes its parent to the left', (
    tester,
  ) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_switcher('Nested', isForward: true));
    await tester.pumpHalfway();

    expect(tester.slideOf('Nested'), greaterThan(0));
    expect(tester.slideOf('Submenu'), lessThan(0));
  });

  testWidgets('going back, the submenu leaves to the right '
      'and the parent comes from the left', (tester) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_switcher('Root', isForward: false));
    await tester.pumpHalfway();

    expect(tester.slideOf('Submenu'), greaterThan(0));
    expect(tester.slideOf('Root'), lessThan(0));

    await tester.pumpAndSettle();
    expect(find.text('Submenu'), findsNothing);
    expect(tester.slideOf('Root'), 0);
  });

  testWidgets('keeps only the new level after the transition', (
    tester,
  ) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pumpHalfway();
    expect(find.text('Root'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Root'), findsNothing);
    expect(find.text('Submenu'), findsOneWidget);
    expect(find.byType(SlideTransition), findsOneWidget);
  });

  testWidgets('a level interrupted halfway leaves from where it is', (
    tester,
  ) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pumpHalfway();
    final slide = tester.slideOf('Submenu');

    await tester.pumpWidget(_switcher('Root', isForward: false));
    expect(tester.slideOf('Submenu'), moreOrLessEquals(slide));

    await tester.pumpAndSettle();
    expect(find.text('Submenu'), findsNothing);
    expect(tester.slideOf('Root'), 0);
  });

  testWidgets('a level interrupted halfway by a submenu '
      'turns to the left without a jump', (tester) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pumpHalfway();
    final slide = tester.slideOf('Submenu');

    await tester.pumpWidget(_switcher('Nested', isForward: true));
    expect(tester.slideOf('Submenu'), moreOrLessEquals(slide));

    await tester.pump(MotionDurations.standard * 0.4);
    expect(tester.slideOf('Submenu'), lessThan(0));
  });

  testWidgets('quick switches leave only the last level', (tester) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pump(MotionDurations.standard * 0.2);
    await tester.pumpWidget(_switcher('Root', isForward: false));
    await tester.pump(MotionDurations.standard * 0.2);
    await tester.pumpWidget(_switcher('Other', isForward: true));
    await tester.pump(MotionDurations.standard * 0.2);

    await tester.pumpAndSettle();
    expect(find.text('Root'), findsNothing);
    expect(find.text('Submenu'), findsNothing);
    expect(find.text('Other'), findsOneWidget);
    expect(find.byType(SlideTransition), findsOneWidget);
  });

  testWidgets('a level with the same key is updated without a transition', (
    tester,
  ) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SmartContextMenuLevelSwitcher(
          isForward: true,
          onSwipeBack: () {},
          child: Text('Updated', key: const ValueKey('Root')),
        ),
      ),
    );

    expect(find.text('Updated'), findsOneWidget);
    expect(find.byType(SlideTransition), findsOneWidget);
    expect(tester.slideOf('Updated'), 0);
  });

  group('swipe back', () {
    testWidgets('drags the level with the finger and reveals the parent', (
      tester,
    ) async {
      await tester.pumpWidget(_swipeable());
      expect(find.text('Level 1'), findsNothing);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Level 2')),
      );
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();
      final start = tester.slideOf('Level 2');

      await gesture.moveBy(const Offset(80, 0));
      await tester.pump();

      final width = tester.getSize(find.byType(Stack)).width;
      expect(tester.slideOf('Level 2') - start, moreOrLessEquals(80 / width));
      expect(tester.slideOf('Level 1'), lessThan(0));

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('returns to the parent past half of the width', (
      tester,
    ) async {
      await tester.pumpWidget(_swipeable());
      await tester.slowSwipe('Level 2', 500);

      expect(find.text('Level 2'), findsNothing);
      expect(tester.slideOf('Level 1'), 0);
    });

    testWidgets('a short swipe returns the level in place', (tester) async {
      await tester.pumpWidget(_swipeable());
      await tester.slowSwipe('Level 2', 200);

      expect(find.text('Level 1'), findsNothing);
      expect(tester.slideOf('Level 2'), 0);
    });

    testWidgets('a fast short swipe returns to the parent', (tester) async {
      await tester.pumpWidget(_swipeable());
      await tester.fling(find.text('Level 2'), const Offset(150, 0), 1500);
      await tester.pumpAndSettle();

      expect(find.text('Level 2'), findsNothing);
      expect(tester.slideOf('Level 1'), 0);
    });

    testWidgets('a swipe back is followed by the next one', (tester) async {
      await tester.pumpWidget(_swipeable(depth: 3));
      await tester.slowSwipe('Level 3', 500);
      await tester.slowSwipe('Level 2', 500);

      expect(find.text('Level 3'), findsNothing);
      expect(find.text('Level 2'), findsNothing);
      expect(tester.slideOf('Level 1'), 0);
    });

    testWidgets('does nothing when disabled', (tester) async {
      await tester.pumpWidget(_swipeable(enableSwipeBack: false));
      await tester.slowSwipe('Level 2', 500);

      expect(find.text('Level 1'), findsNothing);
      expect(tester.slideOf('Level 2'), 0);
    });

    testWidgets('does nothing without a parent level', (tester) async {
      await tester.pumpWidget(_swipeable(depth: 1));
      await tester.slowSwipe('Level 1', 500);

      expect(tester.slideOf('Level 1'), 0);
    });
  });
}
