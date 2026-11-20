// ignore: deprecated_member_use
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

  /// Scrolls the card of [preset] to the middle of the screen, clear of
  /// the tab bar, and opens its menu.
  Future<void> openPreset(WidgetTester tester, String preset) async {
    await tester.scrollUntilVisible(find.text(preset), 200);
    await Scrollable.ensureVisible(
      tester.element(find.text(preset)),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.openMenu(find.text(preset));
  }

  for (final (preset, item) in [
    ('Default', find.text('Copy')),
    ('Brand', find.text('Copy')),
    ('Solid', find.text('Copy')),
    ('Compact', find.text('Copy')),
    ('Dividers', find.text('Copy')),
    ('Inset dividers', find.text('Copy')),
    ('Custom content', find.text('Organize')),
    ('Localized', find.text('Копировать')),
    ('Status items', find.text('Syncing')),
    ('Quick actions', find.text('Copy')),
    ('Only rows', find.text('Cut')),
    ('Styled rows', find.text('Inbox')),
    // Small cells show only their icons.
    ('Wide row', find.byIcon(CupertinoIcons.lasso)),
  ]) {
    testWidgets('$preset opens its menu', (tester) async {
      await openAppearance(tester);

      await openPreset(tester, preset);

      expect(item, findsOneWidget);
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

  testWidgets('a color in Styled rows is picked without closing the menu', (
    tester,
  ) async {
    await openAppearance(tester);
    await openPreset(tester, 'Styled rows');
    final colors = find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          (widget.icon == CupertinoIcons.circle_fill ||
              widget.icon == CupertinoIcons.checkmark_circle_fill),
    );
    IconData? iconAt(int index) => tester.widget<Icon>(colors.at(index)).icon;
    // Blue, the fourth color, is picked at the start.
    expect(iconAt(3), CupertinoIcons.checkmark_circle_fill);

    await tester.tap(colors.first);
    await tester.pump();

    expect(find.text('Inbox'), findsOneWidget);
    expect(iconAt(0), CupertinoIcons.checkmark_circle_fill);
    expect(iconAt(3), CupertinoIcons.circle_fill);
  });

  testWidgets('Wide row keeps its cells wider than 44 on a narrow phone', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    tester.view.physicalSize = const Size(1080, 2340);
    await tester.pump();
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await openPreset(tester, 'Wide row');

    final scribble = tester.getCenter(find.byIcon(CupertinoIcons.scribble));
    final lasso = tester.getCenter(find.byIcon(CupertinoIcons.lasso));
    expect(lasso.dx - scribble.dx, greaterThanOrEqualTo(44));
  });

  testWidgets('Shapes in Wide row opens a row of medium cells', (tester) async {
    await openAppearance(tester);
    await openPreset(tester, 'Wide row');

    await tester.tap(find.byIcon(CupertinoIcons.square_on_circle));
    await tester.settleMenu();

    expect(find.text('Back'), findsWidgets);
    expect(find.text('Hexagon'), findsOneWidget);
  });
}
