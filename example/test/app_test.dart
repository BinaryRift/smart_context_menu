import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu_example/main.dart';
import 'package:smart_context_menu_example/pages/lab/ui/lab_page.dart';

import 'helpers/menu_tester.dart';

void main() {
  /// Opens the settings sheet from the gear of the current page.
  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byIcon(CupertinoIcons.gear));
    await tester.pumpAndSettle();
  }

  Finder switchOf(String title) => find.descendant(
    of: find.widgetWithText(CupertinoListTile, title),
    matching: find.byType(CupertinoSwitch),
  );

  testWidgets('the gear opens the settings and Done closes them', (
    tester,
  ) async {
    await tester.pumpWidget(const ExampleApp());

    await openSettings(tester);
    expect(find.text('Haptics'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Haptics'), findsNothing);
  });

  testWidgets('the settings change the config of all menus', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    SmartContextMenuConfig config() =>
        SmartContextMenuTheme.of(tester.element(find.byType(LabPage)));
    expect(config().enableHaptics, isTrue);
    expect(config().enableSwipeBack, isTrue);
    expect(config().moveBackDown, isFalse);

    await openSettings(tester);
    await tester.tap(switchOf('Haptics'));
    await tester.tap(switchOf('Swipe back'));
    await tester.tap(switchOf('Move back down'));
    await tester.pumpAndSettle();

    expect(config().enableHaptics, isFalse);
    expect(config().enableSwipeBack, isFalse);
    expect(config().moveBackDown, isTrue);
    // The base config of the app stays.
    expect(config().style.menuBlur, SmartContextMenuBlur.small);
  });

  testWidgets('the theme setting changes the brightness', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    Brightness brightness() =>
        CupertinoTheme.brightnessOf(tester.element(find.byType(LabPage)));
    expect(brightness(), Brightness.light);

    await openSettings(tester);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(brightness(), Brightness.dark);
  });

  testWidgets('a Lab card opens its menu', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    await tester.openMenu(find.text('All submenu types'));

    expect(find.text('Recent files'), findsOneWidget);
  });
}
