import 'dart:ui' show PointerDeviceKind;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  Widget buildApp({
    SmartContextMenuActivationMode innerMode =
        SmartContextMenuActivationMode.longPress,
    SmartContextMenuController? innerController,
  }) {
    return CupertinoApp(
      home: Center(
        child: SmartContextMenu(
          items: [SmartContextMenuItem.simple(title: 'Outer item')],
          child: Container(
            width: 300,
            height: 300,
            color: const Color(0xFFFFFFFF),
            child: Align(
              alignment: Alignment.topLeft,
              child: SmartContextMenu(
                config: SmartContextMenuConfig(activationMode: innerMode),
                controller: innerController,
                items: [SmartContextMenuItem.simple(title: 'Inner item')],
                child: const SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Inner'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> secondaryClickAt(WidgetTester tester, Offset position) async {
    final gesture = await tester.startGesture(
      position,
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await gesture.up();
    await tester.settleMenu();
  }

  Offset outerOnly(WidgetTester tester) =>
      tester.getBottomRight(find.byType(SmartContextMenu).first) -
      const Offset(10, 10);

  testWidgets('a secondary click opens only the innermost menu', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await secondaryClickAt(tester, tester.getCenter(find.text('Inner')));

    expect(find.text('Inner item'), findsOneWidget);
    expect(find.text('Outer item'), findsNothing);
  });

  testWidgets('a secondary click outside the inner menu opens the outer', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await secondaryClickAt(tester, outerOnly(tester));

    expect(find.text('Outer item'), findsOneWidget);
    expect(find.text('Inner item'), findsNothing);
  });

  testWidgets('the next secondary click opens the inner menu again', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());

    await secondaryClickAt(tester, tester.getCenter(find.text('Inner')));
    await tester.tapAt(const Offset(5, 5));
    await tester.settleMenu();
    expect(find.text('Inner item'), findsNothing);

    await secondaryClickAt(tester, tester.getCenter(find.text('Inner')));
    expect(find.text('Inner item'), findsOneWidget);
    expect(find.text('Outer item'), findsNothing);
  });

  testWidgets('a manual inner menu leaves the secondary click to the outer', (
    tester,
  ) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildApp(
        innerMode: SmartContextMenuActivationMode.manual,
        innerController: controller,
      ),
    );

    await secondaryClickAt(tester, tester.getCenter(find.text('Inner')));

    expect(find.text('Outer item'), findsOneWidget);
    expect(find.text('Inner item'), findsNothing);
  });
}
