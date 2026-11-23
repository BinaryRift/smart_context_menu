// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  /// Two menus, A and B, each with the controller given to it.
  Widget buildApp({
    bool showsA = true,
    SmartContextMenuController? controllerA,
    SmartContextMenuController? controllerB,
  }) {
    return CupertinoApp(
      home: Column(
        children: [
          if (showsA)
            SmartContextMenu(
              key: const ValueKey('A'),
              controller: controllerA,
              items: [SmartContextMenuItem.simple(title: 'Item A')],
              child: const Text('A'),
            ),
          SmartContextMenu(
            key: const ValueKey('B'),
            controller: controllerB,
            items: [SmartContextMenuItem.simple(title: 'Item B')],
            child: const Text('B'),
          ),
        ],
      ),
    );
  }

  Future<void> expectOpensB(
    WidgetTester tester,
    SmartContextMenuController controller,
  ) async {
    controller.open();
    await tester.settleMenu();
    expect(find.text('Item B'), findsOneWidget);
    expect(controller.isOpen, isTrue);

    controller.close();
    await tester.settleMenu();
    expect(find.text('Item B'), findsNothing);
    expect(controller.isOpen, isFalse);
  }

  testWidgets('a controller moved to another menu stays bound when the '
      'old menu is removed', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildApp(controllerA: controller));
    await tester.pumpWidget(buildApp(showsA: false, controllerB: controller));

    await expectOpensB(tester, controller);
  });

  testWidgets('a controller moved to another menu stays bound when the '
      'old menu lets it go', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildApp(controllerA: controller));
    await tester.pumpWidget(buildApp(controllerB: controller));

    await expectOpensB(tester, controller);
  });

  testWidgets('a controller let go by its menu does nothing', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildApp(controllerB: controller));
    await tester.pumpWidget(buildApp());

    controller.open();
    await tester.settleMenu();
    expect(find.text('Item B'), findsNothing);
    expect(controller.isOpen, isFalse);
  });

  testWidgets('a controller let go while its menu is open reports it '
      'closed', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(buildApp(controllerB: controller));
    controller.open();
    await tester.settleMenu();
    expect(controller.isOpen, isTrue);

    await tester.pumpWidget(buildApp());
    expect(controller.isOpen, isFalse);
  });
}
