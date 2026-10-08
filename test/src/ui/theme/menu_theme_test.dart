import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  const themeColor = Color(0xFFFF0000);
  const configColor = Color(0xFF0000FF);

  const themeConfig = SmartContextMenuConfig(
    style: SmartContextMenuStyle(titleStyle: TextStyle(color: themeColor)),
  );
  const manualConfig = SmartContextMenuConfig(
    activationMode: SmartContextMenuActivationMode.manual,
  );

  Widget buildMenu({
    SmartContextMenuConfig? config,
    SmartContextMenuController? controller,
  }) {
    return Center(
      child: SmartContextMenu(
        config: config,
        controller: controller,
        items: [SmartContextMenuItem.simple(title: 'Copy')],
        child: const Text(menuTargetText),
      ),
    );
  }

  Widget buildApp({
    required SmartContextMenuConfig theme,
    SmartContextMenuConfig? config,
    SmartContextMenuController? controller,
  }) {
    return CupertinoApp(
      home: SmartContextMenuTheme(
        config: theme,
        child: buildMenu(config: config, controller: controller),
      ),
    );
  }

  Color? titleColor(WidgetTester tester) =>
      tester.widget<Text>(find.text('Copy')).style?.color;

  testWidgets('uses the config of a theme below the navigator', (tester) async {
    await tester.pumpWidget(buildApp(theme: themeConfig));
    await tester.openMenu();

    expect(titleColor(tester), isSameColorAs(themeColor));
  });

  testWidgets('uses the config of a theme in the app builder', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        builder: (context, child) =>
            SmartContextMenuTheme(config: themeConfig, child: child!),
        home: buildMenu(),
      ),
    );
    await tester.openMenu();

    expect(titleColor(tester), isSameColorAs(themeColor));
  });

  testWidgets('uses the labels of the theme', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: SmartContextMenuTheme(
          config: const SmartContextMenuConfig(
            labels: SmartContextMenuLabels(back: 'Return'),
          ),
          child: Center(
            child: SmartContextMenu(
              items: [
                SmartContextMenuItem.submenu(
                  title: 'More',
                  children: [SmartContextMenuItem.simple(title: 'Copy')],
                ),
              ],
              child: const Text(menuTargetText),
            ),
          ),
        ),
      ),
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();

    expect(find.text('Return'), findsWidgets);
    expect(find.text(const SmartContextMenuLabels().back), findsNothing);
  });

  testWidgets('the config of the menu replaces the theme', (tester) async {
    await tester.pumpWidget(
      buildApp(
        theme: themeConfig,
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            titleStyle: TextStyle(color: configColor),
          ),
        ),
      ),
    );
    await tester.openMenu();

    expect(titleColor(tester), isSameColorAs(configColor));
  });

  testWidgets('manual activation of the theme turns off the long press', (
    tester,
  ) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildApp(theme: manualConfig, controller: controller),
    );

    await tester.longPress(find.text(menuTargetText));
    await tester.settleMenu();
    expect(find.text('Copy'), findsNothing);

    controller.open();
    await tester.settleMenu();
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('a new theme switches the activation', (tester) async {
    final controller = SmartContextMenuController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      buildApp(theme: manualConfig, controller: controller),
    );
    await tester.pumpWidget(
      buildApp(theme: const SmartContextMenuConfig(), controller: controller),
    );

    await tester.openMenu();

    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('manual activation of the theme requires a controller', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(theme: manualConfig));

    expect(tester.takeException(), isAssertionError);
  });
}
