import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  group('colors', () {
    Color? titleColor(WidgetTester tester, String title) =>
        tester.widget<Text>(find.text(title)).style?.color;

    testWidgets('resolve light variants in light theme', (tester) async {
      await tester.pumpMenu(
        brightness: Brightness.light,
        items: [
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.simple(title: 'Delete', isDestructive: true),
        ],
      );
      await tester.openMenu();

      expect(
        titleColor(tester, 'Copy'),
        isSameColorAs(SmartContextMenuDefaults.foregroundColor.color),
      );
      expect(
        titleColor(tester, 'Delete'),
        isSameColorAs(SmartContextMenuDefaults.destructiveColor.color),
      );
    });

    testWidgets('resolve dark variants in dark theme', (tester) async {
      await tester.pumpMenu(
        brightness: Brightness.dark,
        items: [
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.simple(title: 'Delete', isDestructive: true),
        ],
      );
      await tester.openMenu();

      expect(
        titleColor(tester, 'Copy'),
        isSameColorAs(SmartContextMenuDefaults.foregroundColor.darkColor),
      );
      expect(
        titleColor(tester, 'Delete'),
        isSameColorAs(SmartContextMenuDefaults.destructiveColor.darkColor),
      );
    });

    testWidgets('resolve a dynamic color from titleStyle', (tester) async {
      const color = CupertinoDynamicColor.withBrightness(
        color: Color(0xFF0000FF),
        darkColor: Color(0xFF00FF00),
      );

      await tester.pumpMenu(
        brightness: Brightness.dark,
        items: [
          SmartContextMenuItem.simple(
            title: 'Copy',
            titleStyle: const TextStyle(color: color),
          ),
        ],
      );
      await tester.openMenu();

      expect(titleColor(tester, 'Copy'), isSameColorAs(color.darkColor));
    });

    testWidgets('keep a plain color from titleStyle as is', (tester) async {
      const color = Color(0xFF0000FF);

      await tester.pumpMenu(
        brightness: Brightness.dark,
        items: [
          SmartContextMenuItem.simple(
            title: 'Copy',
            titleStyle: const TextStyle(color: color),
          ),
        ],
      );
      await tester.openMenu();

      expect(titleColor(tester, 'Copy'), isSameColorAs(color));
    });

    testWidgets('resolve the divider color in dark theme', (tester) async {
      await tester.pumpMenu(
        brightness: Brightness.dark,
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(dividersBetweenItems: true),
        ),
        items: [
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.simple(title: 'Share'),
        ],
      );
      await tester.openMenu();

      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(
        divider.color,
        isSameColorAs(SmartContextMenuDefaults.dividerColor.darkColor),
      );
    });
  });

  group('barrierDismissible', () {
    testWidgets('closes the menu on a tap outside by default', (tester) async {
      await tester.pumpMenu(
        items: [SmartContextMenuItem.simple(title: 'Copy')],
      );
      await tester.openMenu();

      await tester.tapAt(const Offset(5, 5));
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
  });

  group('activation', () {
    Widget buildApp({
      required SmartContextMenuActivationMode mode,
      SmartContextMenuController? controller,
      VoidCallback? onTap,
      VoidCallback? onLongPress,
    }) {
      return CupertinoApp(
        home: Center(
          child: SmartContextMenu(
            config: SmartContextMenuConfig(activationMode: mode),
            controller: controller,
            items: [SmartContextMenuItem.simple(title: 'Copy')],
            child: GestureDetector(
              onTap: onTap,
              onLongPress: onLongPress,
              child: const Text(menuTargetText),
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
  });
}
