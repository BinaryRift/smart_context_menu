import 'dart:ui' show PointerDeviceKind;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart' show kSecondaryButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  Widget buildApp({
    required SmartContextMenuActivationMode mode,
    SmartContextMenuController? controller,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onSecondaryTap,
    VoidCallback? onSecondaryPointerDown,
  }) {
    return CupertinoApp(
      home: Center(
        child: SmartContextMenu(
          config: SmartContextMenuConfig(activationMode: mode),
          controller: controller,
          items: [SmartContextMenuItem.simple(title: 'Copy')],
          child: Listener(
            onPointerDown: onSecondaryPointerDown == null
                ? null
                : (event) {
                    if (event.buttons == kSecondaryButton) {
                      onSecondaryPointerDown();
                    }
                  },
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              onSecondaryTap: onSecondaryTap,
              child: const Text(menuTargetText),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('longPress keeps taps of the child', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.longPress,
        onTap: () => taps++,
      ),
    );

    await tester.tap(find.text(menuTargetText));
    await tester.settleMenu();

    expect(taps, 1);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('longPress takes the long press of the child', (tester) async {
    var longPresses = 0;
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.longPress,
        onLongPress: () => longPresses++,
      ),
    );

    await tester.openMenu();

    expect(longPresses, 0);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('secondary click opens without tapping the child', (
    tester,
  ) async {
    var taps = 0;
    var longPresses = 0;
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.longPress,
        onTap: () => taps++,
        onLongPress: () => longPresses++,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(menuTargetText)),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await gesture.up();
    await tester.settleMenu();

    expect(taps, 0);
    expect(longPresses, 0);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('secondary click also reaches the child pointer listener', (
    tester,
  ) async {
    var clicks = 0;
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.longPress,
        onSecondaryPointerDown: () => clicks++,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(menuTargetText)),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await tester.settleMenu();
    await gesture.up();
    await tester.pump();

    expect(clicks, 1);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('manual leaves the secondary click to the child', (tester) async {
    var clicks = 0;
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.manual,
        controller: controller,
        onSecondaryTap: () => clicks++,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text(menuTargetText)),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await gesture.up();
    await tester.settleMenu();

    expect(clicks, 1);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('manual leaves the long press to the child', (tester) async {
    var longPresses = 0;
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.manual,
        controller: SmartContextMenuController(),
        onLongPress: () => longPresses++,
      ),
    );

    await tester.longPress(find.text(menuTargetText));
    await tester.settleMenu();

    expect(longPresses, 1);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('manual opens and closes from the controller', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildApp(
        mode: SmartContextMenuActivationMode.manual,
        controller: controller,
      ),
    );

    controller.open();
    await tester.settleMenu();
    expect(find.text('Copy'), findsOneWidget);
    expect(controller.isOpen, isTrue);

    controller.close();
    await tester.settleMenu();
    expect(find.text('Copy'), findsNothing);
    expect(controller.isOpen, isFalse);
  });

  testWidgets('does not open without items', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    await tester.pumpMenu(items: [], controller: controller);

    await tester.openMenu();
    expect(controller.isOpen, isFalse);

    controller.open();
    await tester.settleMenu();
    expect(controller.isOpen, isFalse);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });
}
