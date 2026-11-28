// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_highlight.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  const left = Offset(-1, 0);
  const right = Offset(1, 0);
  const themeStyle = SmartContextMenuStyle(
    surface: SmartContextMenuSurface.standard,
    standardStyle: SmartContextMenuStandardStyle(lightDirection: left),
  );

  Finder highlightWithin(Finder panel) => find.descendant(
    of: panel,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.foregroundPainter is SmartContextMenuHighlightPainter,
    ),
  );

  SmartContextMenuHighlightPainter painter(WidgetTester tester, Finder panel) =>
      tester.widget<CustomPaint>(highlightWithin(panel)).foregroundPainter!
          as SmartContextMenuHighlightPainter;

  testWidgets('uses the theme or an explicit style and keeps the child state', (
    tester,
  ) async {
    Widget app({SmartContextMenuStyle? style}) => CupertinoApp(
      home: SmartContextMenuTheme(
        config: const SmartContextMenuConfig(style: themeStyle),
        child: Center(
          child: SmartContextMenuPanel(
            style: style,
            width: 180,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: const CupertinoTextField(),
          ),
        ),
      ),
    );

    final editor = find.byType(EditableText);
    final panel = find.byType(SmartContextMenuPanel);
    await tester.pumpWidget(app());
    await tester.enterText(editor, 'Draft');
    final editorState = tester.state(editor);
    final previousPainter = painter(tester, panel);
    expect(previousPainter.lightDirection, left);
    expect(tester.getSize(panel).width, 180);

    // Request Glass so the standalone loader and fallback path are exercised.
    await tester.pumpWidget(
      app(
        style: const SmartContextMenuStyle(
          standardStyle: SmartContextMenuStandardStyle(lightDirection: right),
        ),
      ),
    );

    final nextPainter = painter(tester, panel);
    expect(nextPainter.lightDirection, right);
    expect(nextPainter.borderRadius, BorderRadius.circular(24));
    expect(nextPainter.shouldRepaint(previousPainter), isTrue);
    expect(tester.state(editor), same(editorState));
    expect(tester.widget<EditableText>(editor).controller.text, 'Draft');
  });

  testWidgets('header and menu panels share the style of the opening', (
    tester,
  ) async {
    const headerKey = ValueKey('header panel');
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: SmartContextMenu(
            config: const SmartContextMenuConfig(style: themeStyle),
            items: [SmartContextMenuItem.simple(title: 'Copy')],
            fadeHeaderSlivers: false,
            headerSliversBuilder: (context, header) => [
              SliverToBoxAdapter(
                child: Center(
                  child: SmartContextMenuPanel(
                    key: headerKey,
                    opacity: header.animation,
                    child: const Text('Header'),
                  ),
                ),
              ),
            ],
            child: const Text(menuTargetText),
          ),
        ),
      ),
    );
    await tester.openMenu();

    final panels = find.byType(SmartContextMenuPanel);
    expect(panels, findsNWidgets(2));
    final painters = tester.widgetList<CustomPaint>(highlightWithin(panels));
    expect(
      painters.map(
        (paint) =>
            (paint.foregroundPainter! as SmartContextMenuHighlightPainter)
                .lightDirection,
      ),
      [left, left],
    );
    expect(find.byKey(headerKey), findsOneWidget);
  });
}
