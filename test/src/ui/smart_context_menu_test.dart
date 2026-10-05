import 'package:flutter/cupertino.dart';
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
        isSameColorAs(SmartContextMenuDefaults.textColor.color),
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
        isSameColorAs(SmartContextMenuDefaults.textColor.darkColor),
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
  });
}
