import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu_example/core/data/demo_loader.dart';

import '../helpers/menu_tester.dart';

void main() {
  Future<void> openAppearance(WidgetTester tester) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
  }

  /// Scrolls to the card of [preset] and opens its menu.
  Future<void> openPreset(WidgetTester tester, String preset) async {
    await tester.scrollUntilVisible(find.text(preset), 200);
    await tester.openMenu(find.text(preset));
  }

  for (final (preset, item) in [
    ('Default', 'Copy'),
    ('Brand', 'Copy'),
    ('Solid', 'Copy'),
    ('Compact', 'Copy'),
    ('Dividers', 'Copy'),
    ('Inset dividers', 'Copy'),
    ('Custom content', 'Organize'),
    ('Localized', 'Копировать'),
    ('Status items', 'Syncing'),
  ]) {
    testWidgets('$preset opens its menu', (tester) async {
      await openAppearance(tester);

      await openPreset(tester, preset);

      expect(find.text(item), findsOneWidget);
      // Lets the items that load finish.
      await tester.pump(demoLoadDelay);
      await tester.settleMenu();
    });
  }

  testWidgets('Localized shows the strings of the menu in Russian', (
    tester,
  ) async {
    await openAppearance(tester);
    await openPreset(tester, 'Localized');
    expect(find.text('Загрузка…'), findsOneWidget);

    // The first load fails.
    await tester.pump(demoLoadDelay);
    await tester.settleMenu();
    expect(find.text('Повторить'), findsOneWidget);

    await tester.tap(find.text('Архив'));
    await tester.pump(demoLoadDelay);
    await tester.settleMenu();
    expect(find.text('Назад'), findsWidgets);
    expect(find.text('Пусто'), findsOneWidget);
  });

  testWidgets('a color in Custom content is picked without closing the menu', (
    tester,
  ) async {
    await openAppearance(tester);
    await openPreset(tester, 'Custom content');

    await tester.tap(find.byKey(const ValueKey(CupertinoColors.systemRed)));
    await tester.pump();

    expect(find.text('Version history'), findsOneWidget);
    final red = tester.widget<Container>(
      find.byKey(const ValueKey(CupertinoColors.systemRed)),
    );
    expect((red.decoration! as BoxDecoration).border, isNotNull);
  });
}
