import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/core/ui/motion/tokens/motion_scales.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_press_detector.dart';

void main() {
  const target = Key('target');

  Future<void> pumpDetector(
    WidgetTester tester, {
    bool enabled = true,
    bool isMenuActive = false,
    VoidCallback? onLongPress,
  }) {
    return tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SmartContextMenuPressDetector(
            enabled: enabled,
            isMenuActive: isMenuActive,
            onLongPress: onLongPress ?? () {},
            child: const SizedBox(
              key: target,
              width: 100,
              height: 100,
              child: ColoredBox(color: Color(0xFF000000)),
            ),
          ),
        ),
      ),
    );
  }

  Finder scaleOfTarget() => find.ancestor(
    of: find.byKey(target),
    matching: find.byType(ScaleTransition),
  );

  double scale(WidgetTester tester) =>
      tester.widget<ScaleTransition>(scaleOfTarget()).scale.value;

  testWidgets('shrinks the child while pressed', (tester) async {
    await pumpDetector(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(target)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(tester), lessThan(MotionScale.none.value));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(scale(tester), MotionScale.none.value);
  });

  testWidgets('calls onLongPress at full size after a long press', (
    tester,
  ) async {
    var longPresses = 0;
    double? scaleOnLongPress;
    await pumpDetector(
      tester,
      onLongPress: () {
        longPresses++;
        scaleOnLongPress = scale(tester);
      },
    );

    await tester.longPress(find.byKey(target));
    await tester.pumpAndSettle();

    expect(longPresses, 1);
    expect(scaleOnLongPress, MotionScale.none.value);
  });

  testWidgets('returns the child as is when disabled', (tester) async {
    var longPresses = 0;
    await pumpDetector(
      tester,
      enabled: false,
      onLongPress: () => longPresses++,
    );

    await tester.longPress(find.byKey(target));
    await tester.pumpAndSettle();

    expect(scaleOfTarget(), findsNothing);
    expect(longPresses, 0);
  });

  testWidgets('ignores presses while the menu is active', (tester) async {
    var longPresses = 0;
    await pumpDetector(
      tester,
      isMenuActive: true,
      onLongPress: () => longPresses++,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(target)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    expect(scale(tester), MotionScale.none.value);

    await tester.pump(const Duration(seconds: 1));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(longPresses, 0);
  });
}
