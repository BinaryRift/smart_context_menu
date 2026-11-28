import 'dart:ui' as ui show Brightness;

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show
        CupertinoIcons,
        CupertinoListTile,
        CupertinoModalPopupRoute,
        CupertinoSlider,
        CupertinoSwitch,
        CupertinoTextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
// ignore: implementation_imports
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_surface.dart';
// ignore: implementation_imports
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_highlight.dart';
import 'package:smart_context_menu_example/core/ui/reactions_bar.dart';
import 'package:smart_context_menu_example/pages/lab/ui/liquid_glass_settings_sheet.dart';
import 'package:smart_context_menu_example/pages/settings/ui/settings_sheet.dart';

import '../helpers/menu_tester.dart';

void main() {
  final highlight = find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint &&
        widget.foregroundPainter is SmartContextMenuHighlightPainter,
  );

  testWidgets('Glass falls back to Standard with a scrollable submenu', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    expect(find.text('Rendering'), findsOneWidget);

    await tester.tap(find.text('Liquid Glass'));
    await tester.pumpAndSettle();
    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.gear));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(CupertinoListTile, 'Background blur'),
        matching: find.byType(CupertinoSwitch),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.byType(SettingsSheet),
        matching: find.text('Standard'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final preview = tester.element(find.text('Open menu'));
    final menu = preview.findAncestorWidgetOfExactType<SmartContextMenu>()!;
    final appStyle = SmartContextMenuTheme.of(preview).style;
    expect(appStyle.surface, SmartContextMenuSurface.standard);
    expect(appStyle.backgroundBlur, SmartContextMenuBlur.medium);
    expect(menu.config!.style.surface, SmartContextMenuSurface.glass);
    expect(menu.config!.style.backgroundBlur, isNull);

    await tester.tap(find.text('Open menu'));
    await tester.settleMenu();
    final glass = find.byType(SmartContextMenuGlassSurface);
    expect(glass, findsNothing);
    final surface = tester.element(highlight);
    await tester.tap(find.text('Browse folders'));
    await tester.pumpAndSettle();
    expect(tester.element(highlight), same(surface));
    expect(find.text('Project 1'), findsOneWidget);
    expect(find.text('Project 18').hitTestable(), findsNothing);

    await tester.fling(find.text('Project 1'), const Offset(0, -420), 1300);
    await tester.pumpAndSettle();
    expect(find.text('Project 18').hitTestable(), findsOneWidget);

    Navigator.of(surface).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open menu'));
    await tester.settleMenu();
    expect(find.text('Browse folders'), findsOneWidget);
    expect(glass, findsNothing);
    expect(highlight, findsOneWidget);
  });

  testWidgets('Standard can show its highlight above both menu levels', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liquid Glass'));
    await tester.pumpAndSettle();

    final toggle = find.descendant(
      of: find.widgetWithText(CupertinoListTile, 'Edge highlight'),
      matching: find.byType(CupertinoSwitch),
    );
    expect(toggle, findsNothing);
    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();

    expect(tester.widget<CupertinoSwitch>(toggle).value, isTrue);
    await tester.tap(find.text('Open menu'));
    await tester.settleMenu();
    final painter = tester.element(highlight);
    await tester.tap(find.text('Browse folders'));
    await tester.pumpAndSettle();

    expect(tester.element(highlight), same(painter));
    expect(
      find.descendant(of: highlight, matching: find.text('Back').hitTestable()),
      findsOneWidget,
    );

    Navigator.of(painter).pop();
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open menu'));
    await tester.settleMenu();
    expect(find.text('Browse folders'), findsOneWidget);
    expect(highlight, findsNothing);
  });

  testWidgets('Glass settings apply to the preview and reset to defaults', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = ui.Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liquid Glass'));
    await tester.pumpAndSettle();

    SmartContextMenuGlassStyle previewStyle() {
      final button = tester.element(find.text('Open menu'));
      return button
          .findAncestorWidgetOfExactType<SmartContextMenu>()!
          .config!
          .style
          .glassStyle;
    }

    final defaults = previewStyle();
    Future<void> openSettings() async {
      await tester.tap(find.text('Glass settings'));
      await tester.pumpAndSettle();
      final route = ModalRoute.of(tester.element(find.text('Apply')));
      expect(route, isA<CupertinoModalPopupRoute<dynamic>>());
      expect(find.text('Open menu'), findsOneWidget);
      expect(find.text('Open menu').hitTestable(), findsNothing);
    }

    await openSettings();
    final slider = find.descendant(
      of: find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'Refraction',
      ),
      matching: find.byType(CupertinoSlider),
    );
    expect(tester.widget<CupertinoSlider>(slider).value, defaults.refraction);
    final size = tester.getSize(slider);
    await tester.dragFrom(
      tester.getTopLeft(slider) + Offset(size.width / 3, size.height / 2),
      const Offset(75, 0),
    );
    await tester.pumpAndSettle();
    final editedRefraction = tester.widget<CupertinoSlider>(slider).value;
    expect(editedRefraction, greaterThan(defaults.refraction));

    final tint = find.byType(CupertinoTextField);
    await tester.ensureVisible(tint);
    int tintRgb() => int.parse(
      tester.widget<CupertinoTextField>(tint).controller!.text,
      radix: 16,
    );
    final defaultTint = SmartContextMenuDefaults.glassTint;
    expect(tintRgb(), defaultTint.color.toARGB32() & 0xFFFFFF);
    tester.platformDispatcher.platformBrightnessTestValue = ui.Brightness.dark;
    await tester.pumpAndSettle();
    expect(tintRgb(), defaultTint.darkColor.toARGB32() & 0xFFFFFF);

    await tester.enterText(tint, '2299CC');
    tester.view.viewInsets = const FakeViewPadding(bottom: 780);
    await tester.pumpAndSettle();
    final apply = find.text('Apply').hitTestable();
    expect(apply, findsOneWidget);
    await tester.tap(apply);
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(previewStyle().refraction, editedRefraction);
    expect(previewStyle().color.toARGB32() & 0xFFFFFF, 0x2299CC);
    expect(
      previewStyle().copyWith(
        color: defaults.color,
        refraction: defaults.refraction,
      ),
      defaults,
    );

    await tester.tap(find.text('Standard'));
    await tester.pumpAndSettle();
    expect(find.text('Glass settings'), findsNothing);
    await tester.tap(find.text('Glass'));
    await tester.pumpAndSettle();
    expect(previewStyle().refraction, editedRefraction);

    Future<void> resetSettings() async {
      final reset = find.text('Reset');
      final scrollable = find
          .descendant(
            of: find.byType(LiquidGlassSettingsSheet),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(reset, 150, scrollable: scrollable);
      await tester.pumpAndSettle();
      await tester.tap(reset);
      await tester.pumpAndSettle();
    }

    await openSettings();
    await resetSettings();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(previewStyle().refraction, editedRefraction);
    expect(previewStyle().color.toARGB32() & 0xFFFFFF, 0x2299CC);

    await openSettings();
    await resetSettings();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(previewStyle(), defaults);
  });

  testWidgets('a reaction in the Lab shows feedback immediately', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bar'));
    await tester.pumpAndSettle();
    await tester.openMenu(find.text('All submenu types'));

    await tester.tap(find.text('❤️'));
    await tester.pump();

    expect(
      find.text('Reaction ❤️ on All submenu types (demo only)'),
      findsOneWidget,
    );
    await tester.settleMenu();
    expect(find.byType(ReactionsBar), findsNothing);
  });

  testWidgets('a long press on the photo opens only its menu', (tester) async {
    await tester.pumpPhoneApp();
    await tester.tap(find.text('Lab'));
    await tester.pumpAndSettle();
    final card = find.text('Menu inside a menu');
    await tester.scrollUntilVisible(card, 200);
    await tester.pumpAndSettle();

    await tester.openMenu(
      find.descendant(
        of: find.ancestor(of: card, matching: find.byType(Row)),
        matching: find.byType(Image),
      ),
    );

    expect(find.text('Save photo'), findsOneWidget);
    expect(find.text('Pin'), findsNothing);
  });
}
