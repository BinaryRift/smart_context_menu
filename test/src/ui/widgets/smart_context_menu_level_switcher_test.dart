import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/core/ui/motion/tokens/motion_durations.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_level_switcher.dart';

Widget _switcher(String level, {required bool isForward}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SmartContextMenuLevelSwitcher(
      isForward: isForward,
      child: Text(level, key: ValueKey(level)),
    ),
  );
}

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
          child: Text('Updated', key: const ValueKey('Root')),
        ),
      ),
    );

    expect(find.text('Updated'), findsOneWidget);
    expect(find.byType(SlideTransition), findsOneWidget);
    expect(tester.slideOf('Updated'), 0);
  });
}
