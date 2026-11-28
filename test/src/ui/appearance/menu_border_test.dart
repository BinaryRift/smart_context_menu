// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_blur_box.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_highlight.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  final highlight = find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint &&
        widget.foregroundPainter is SmartContextMenuHighlightPainter,
  );

  List<DecoratedBox> foregroundsOf(WidgetTester tester) => [
    for (final box in tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    ))
      if (box.position == DecorationPosition.foreground) box,
  ];

  testWidgets('paints only the highlight by default in Standard fallback', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      brightness: Brightness.light,
    );
    await tester.openMenu();

    expect(foregroundsOf(tester), isEmpty);
    expect(highlight, findsOneWidget);
    expect(
      find.descendant(of: highlight, matching: find.text('Enabled')),
      findsOneWidget,
    );
  });

  testWidgets('keeps an outside border above the local blur clip', (
    tester,
  ) async {
    const border = BorderSide(
      color: Color(0xFF123456),
      width: 3,
      strokeAlign: BorderSide.strokeAlignOutside,
    );
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          surface: SmartContextMenuSurface.standard,
          standardStyle: SmartContextMenuStandardStyle(
            border: border,
            blur: SmartContextMenuBlur.small,
          ),
        ),
      ),
    );
    await tester.openMenu();

    final outline = foregroundsOf(tester).single;
    expect(
      (outline.decoration as BoxDecoration).border,
      Border.fromBorderSide(border),
    );
    expect(outline.child, isA<ClipRRect>());
    final blurBox = find.byType(SmartContextMenuBlurBox);
    expect(
      tester.widget<SmartContextMenuBlurBox>(blurBox).blur,
      SmartContextMenuBlur.small,
    );
    final stack = tester
        .element(blurBox)
        .findAncestorWidgetOfExactType<Stack>()!;
    expect(
      find.descendant(
        of: find.byWidget(stack.children.last),
        matching: find.byWidget(outline),
      ),
      findsOneWidget,
    );
    final painter = tester.widget<CustomPaint>(highlight).foregroundPainter;
    expect((painter! as SmartContextMenuHighlightPainter).border, border);
  });

  testWidgets('is not added to a custom decoration', (tester) async {
    await tester.pumpMenu(
      items: appearanceItems(),
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          standardStyle: SmartContextMenuStandardStyle(
            decoration: BoxDecoration(color: Color(0xFF000001)),
          ),
        ),
      ),
    );
    await tester.openMenu();

    expect(foregroundsOf(tester), isEmpty);
    expect(highlight, findsNothing);
  });

  for (final (name, border, showHighlight, hasBorder) in const [
    ('only the highlight with BorderSide.none', BorderSide.none, true, false),
    (
      'only the highlight with a transparent border',
      BorderSide(color: Color(0x00FF0000)),
      true,
      false,
    ),
    ('only the border when the highlight is off', BorderSide(), false, true),
    ('no outline when both are off', BorderSide.none, false, false),
  ]) {
    testWidgets('paints $name', (tester) async {
      await tester.pumpMenu(
        items: appearanceItems(),
        config: SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            surface: SmartContextMenuSurface.standard,
            standardStyle: SmartContextMenuStandardStyle(
              border: border,
              showEdgeHighlight: showHighlight,
            ),
          ),
        ),
      );
      await tester.openMenu();

      expect(foregroundsOf(tester), hasLength(hasBorder ? 1 : 0));
      expect(highlight, showHighlight ? findsOneWidget : findsNothing);
      if (showHighlight) {
        final painter =
            tester.widget<CustomPaint>(highlight).foregroundPainter!
                as SmartContextMenuHighlightPainter;
        expect(painter.border.width, 1);
        expect(painter.border.strokeAlign, BorderSide.strokeAlignInside);
      }
    });
  }
}
