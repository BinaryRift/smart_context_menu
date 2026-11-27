import 'dart:ui' show PointerDeviceKind;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
// ignore: implementation_imports
import 'package:smart_context_menu/src/ui/view/smart_context_menu_overlay.dart';
import 'package:smart_context_menu_example/core/data/demo_loader.dart';
import 'package:smart_context_menu_example/pages/appearance/ui/theme_styles.dart';

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
    ('Indigo', find.text('Rename')),
    ('Terminal', find.text('rm -rf')),
    ('Tiny', find.text('Duplicate')),
    ('Colorful', find.text('Favorite')),
    ('Paper', find.text('Rename')),
    ('Glow', find.text('Duplicate')),
    ('Editing rows', find.text('Cut')),
    ('Drawing toolbar', find.byIcon(CupertinoIcons.lasso)),
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

  testWidgets('Terminal switches surfaces and keeps its preset styles', (
    tester,
  ) async {
    await openAppearance(tester);
    final overlay = find.byType(SmartContextMenuOverlay);
    SmartContextMenuStyle menuStyle() =>
        tester.widget<SmartContextMenuOverlay>(overlay).config.style;

    Future<void> chooseSurface(String label) async {
      await tester.tap(find.byIcon(CupertinoIcons.gear));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    }

    for (final (surface, label) in [
      (SmartContextMenuSurface.standard, 'Standard'),
      (SmartContextMenuSurface.glass, 'Glass'),
    ]) {
      await chooseSurface(label);
      await openPreset(tester, 'Terminal');
      expect(menuStyle().surface, surface);
      expect(menuStyle().glassStyle, same(terminalStyle.glassStyle));
      expect(menuStyle().standardStyle, same(terminalStyle.standardStyle));
      Navigator.of(tester.element(overlay)).pop();
      await tester.pumpAndSettle();
    }
  });

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

  testWidgets('editing rows keep independent formatting selections', (
    tester,
  ) async {
    await openAppearance(tester);
    await openPreset(tester, 'Editing rows');

    final bold = find.text('B');
    final italic = find.text('I');
    final accent = editingRowsAccent.resolveFrom(tester.element(bold));
    Color? colorOf(Finder label) => tester.widget<Text>(label).style?.color;
    expect(colorOf(bold), accent);
    expect(colorOf(italic), isNot(accent));

    await tester.tap(italic);
    await tester.pumpAndSettle();

    expect(colorOf(bold), accent);
    expect(colorOf(italic), accent);
  });

  for (final (preset, icon, light, dark) in [
    (
      'Editing rows',
      CupertinoIcons.scissors,
      const Color(0xFFDC2858),
      const Color(0xFFFF718F),
    ),
    (
      'Drawing toolbar',
      CupertinoIcons.pencil,
      drawingToolbarAccent.color,
      drawingToolbarAccent.darkColor,
    ),
  ]) {
    testWidgets('$preset follows brightness changes while open', (
      tester,
    ) async {
      final dispatcher = tester.binding.platformDispatcher;
      dispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(dispatcher.clearPlatformBrightnessTestValue);
      await openAppearance(tester);
      await openPreset(tester, preset);

      int iconColor() =>
          tester.widget<Icon>(find.byIcon(icon)).color!.toARGB32();
      expect(iconColor(), light.toARGB32());

      dispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(iconColor(), dark.toARGB32());

      dispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(iconColor(), light.toARGB32());
    });
  }

  for (final (preset, label, accent, openShapes) in [
    ('Editing rows', 'Cut', editingRowsAccent, false),
    ('Drawing toolbar', 'Hexagon', drawingToolbarAccent, true),
  ]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '$preset changes the color of $label on hover in ${brightness.name}',
        (tester) async {
          final dispatcher = tester.binding.platformDispatcher;
          dispatcher.platformBrightnessTestValue = brightness;
          addTearDown(dispatcher.clearPlatformBrightnessTestValue);
          await openAppearance(tester);
          await openPreset(tester, preset);
          if (openShapes) {
            await tester.tap(find.byIcon(CupertinoIcons.square_on_circle));
            await tester.settleMenu();
          }

          final text = find.text(label);
          final hoverColor = accent.resolveFrom(tester.element(text));
          Color? colorOfLabel() => tester.widget<Text>(text).style?.color;
          final resting = colorOfLabel();
          expect(resting, isNot(hoverColor));

          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: tester.getCenter(text));
          addTearDown(mouse.removePointer);
          await tester.pump();
          expect(colorOfLabel(), hoverColor);

          await mouse.moveTo(Offset.zero);
          await tester.pump();
          expect(colorOfLabel(), resting);
        },
      );
    }
  }
}
