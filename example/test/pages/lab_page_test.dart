// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart'
    show CupertinoIcons, CupertinoListTile, CupertinoSwitch;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
// ignore: implementation_imports
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_glass_surface.dart';
// ignore: implementation_imports
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_highlight.dart';
import 'package:smart_context_menu_example/core/ui/reactions_bar.dart';
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
        of: find.byType(SettingsSheet),
        matching: find.text('Standard'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    final preview = tester.element(find.text('Open menu'));
    final menu = preview.findAncestorWidgetOfExactType<SmartContextMenu>()!;
    expect(
      SmartContextMenuTheme.of(preview).style.surface,
      SmartContextMenuSurface.standard,
    );
    expect(menu.config!.style.surface, SmartContextMenuSurface.glass);

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
