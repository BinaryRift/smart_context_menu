import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/core/ui/gestures/gesture_thresholds.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('closes the menu on a tap outside by default', (tester) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Copy')]);
    await tester.openMenu();

    await tester.tapAt(const Offset(5, 5));
    await tester.settleMenu();

    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('closes the menu on a secondary click outside', (tester) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Copy')]);
    await tester.openMenu();

    final gesture = await tester.startGesture(
      const Offset(5, 5),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await gesture.up();
    await tester.settleMenu();

    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('keeps the menu open when false', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(barrierDismissible: false),
      items: [SmartContextMenuItem.simple(title: 'Copy')],
    );
    await tester.openMenu();

    await tester.tapAt(const Offset(5, 5));
    await tester.settleMenu();

    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('closes on a touch that moves less than the tap slop', (
    tester,
  ) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Copy')]);
    await tester.openMenu();

    await tester.dragFrom(
      const Offset(5, 5),
      const Offset(GestureThresholds.tapSlop - 1, 0),
    );
    await tester.settleMenu();

    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('stays open on a drag over the background', (tester) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Copy')]);
    await tester.openMenu();

    await tester.dragFrom(
      const Offset(5, 5),
      const Offset(GestureThresholds.tapSlop + 1, 0),
    );
    await tester.settleMenu();

    expect(find.text('Copy'), findsOneWidget);
  });
}
