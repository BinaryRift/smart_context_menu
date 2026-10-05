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
  testWidgets('a submenu slides in from the right', (tester) async {
    await tester.pumpWidget(_switcher('Root', isForward: true));
    await tester.pumpWidget(_switcher('Submenu', isForward: true));
    await tester.pumpHalfway();

    expect(tester.slideOf('Submenu'), greaterThan(0));
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
}
