import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/core/ui/motion/tokens/motion_durations.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_level_switcher.dart';

import '../../../../helpers/level_switcher_tester.dart';

void main() {
  testWidgets('a submenu slides in from the right '
      'and the parent leaves to the left', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pumpHalfway();

    expect(tester.slideOf('Submenu'), greaterThan(0));
    expect(tester.slideOf('Root'), lessThan(0));
  });

  testWidgets(
    'in RTL a submenu enters from the left and the parent moves right',
    (tester) async {
      await tester.pumpWidget(
        levelSwitcher(
          'Root',
          isForward: true,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpWidget(
        levelSwitcher(
          'Submenu',
          isForward: true,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpHalfway();

      expect(tester.slideOf('Submenu'), lessThan(0));
      expect(tester.slideOf('Root'), greaterThan(0));

      final clip = tester.clipOf('Root');
      final width = tester
          .getSize(find.byType(SmartContextMenuLevelSwitcher))
          .width;
      final rect = clip.clipper!.getClip(clip.size);
      expect(rect.width, moreOrLessEquals(-tester.slideOf('Submenu') * width));
      expect(rect.right, width);
    },
  );

  testWidgets('a nested submenu pushes its parent to the left', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(levelSwitcher('Nested', isForward: true));
    await tester.pumpHalfway();

    expect(tester.slideOf('Nested'), greaterThan(0));
    expect(tester.slideOf('Submenu'), lessThan(0));
  });

  testWidgets('going back, the submenu leaves to the right '
      'and the parent comes from the left', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(levelSwitcher('Root', isForward: false));
    await tester.pumpHalfway();

    expect(tester.slideOf('Submenu'), greaterThan(0));
    expect(tester.slideOf('Root'), lessThan(0));

    await tester.pumpAndSettle();
    expect(find.text('Submenu'), findsNothing);
    expect(tester.slideOf('Root'), 0);
  });

  testWidgets(
    'in RTL going back moves the submenu left and parent in from right',
    (tester) async {
      await tester.pumpWidget(
        levelSwitcher(
          'Root',
          isForward: true,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpWidget(
        levelSwitcher(
          'Submenu',
          isForward: true,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        levelSwitcher(
          'Root',
          isForward: false,
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpHalfway();

      expect(tester.slideOf('Submenu'), lessThan(0));
      expect(tester.slideOf('Root'), greaterThan(0));
    },
  );

  testWidgets('a submenu covers its parent: the parent shows only to its '
      'left, and the submenu does not fade', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pumpHalfway();

    final width = tester.getSize(find.byType(SmartContextMenuLevelSwitcher));
    expect(
      tester.visibleWidthOf('Root'),
      moreOrLessEquals(width.width * tester.slideOf('Submenu')),
    );
    expect(tester.visibleWidthOf('Submenu'), isNull);
    expect(tester.opacityOf('Submenu'), 1);

    await tester.pumpAndSettle();
    expect(tester.visibleWidthOf('Submenu'), isNull);
  });

  testWidgets('going back, the parent shows only to the left '
      'of the leaving submenu', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(levelSwitcher('Root', isForward: false));
    await tester.pumpHalfway();

    final width = tester.getSize(find.byType(SmartContextMenuLevelSwitcher));
    expect(
      tester.visibleWidthOf('Root'),
      moreOrLessEquals(width.width * tester.slideOf('Submenu')),
    );
    expect(tester.opacityOf('Submenu'), 1);

    await tester.pumpAndSettle();
    expect(tester.visibleWidthOf('Root'), isNull);
  });

  testWidgets('keeps only the new level after the transition', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
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
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pumpHalfway();
    final slide = tester.slideOf('Submenu');

    await tester.pumpWidget(levelSwitcher('Root', isForward: false));
    expect(tester.slideOf('Submenu'), moreOrLessEquals(slide));

    await tester.pumpAndSettle();
    expect(find.text('Submenu'), findsNothing);
    expect(tester.slideOf('Root'), 0);
  });

  testWidgets('a level interrupted halfway by a submenu '
      'turns to the left without a jump', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pumpHalfway();
    final slide = tester.slideOf('Submenu');

    await tester.pumpWidget(levelSwitcher('Nested', isForward: true));
    expect(tester.slideOf('Submenu'), moreOrLessEquals(slide));

    await tester.pump(MotionDurations.standard * 0.4);
    expect(tester.slideOf('Submenu'), lessThan(0));
  });

  testWidgets('quick switches leave only the last level', (tester) async {
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
    await tester.pumpWidget(levelSwitcher('Submenu', isForward: true));
    await tester.pump(MotionDurations.standard * 0.2);
    await tester.pumpWidget(levelSwitcher('Root', isForward: false));
    await tester.pump(MotionDurations.standard * 0.2);
    await tester.pumpWidget(levelSwitcher('Other', isForward: true));
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
    await tester.pumpWidget(levelSwitcher('Root', isForward: true));
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
}
