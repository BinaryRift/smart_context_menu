import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

const _headerText = 'Header';

final _items = [SmartContextMenuItem.simple(title: 'Copy')];
final _preview = find.byType(RawImage).last;
final _header = find.byKey(const ValueKey(_headerText));

final _screenPadding = const SmartContextMenuConfig().screenPadding;

/// A menu for a 100-wide widget placed by [alignment], with a 60-wide header
/// lined up by [SmartContextMenuHeaderDetails.alignment].
Widget _menu({
  Alignment alignment = Alignment.center,
  double targetHeight = 40,
  double? headerHeight = 20,
  ValueChanged<SmartContextMenuHeaderDetails>? onHeader,
}) {
  return CupertinoApp(
    home: Padding(
      padding: const EdgeInsets.all(30),
      child: Align(
        alignment: alignment,
        child: SmartContextMenu(
          items: _items,
          headerSliversBuilder: headerHeight == null
              ? null
              : (context, header) {
                  onHeader?.call(header);
                  return [
                    SliverToBoxAdapter(
                      child: Align(
                        alignment: header.alignment,
                        child: SizedBox(
                          key: const ValueKey(_headerText),
                          width: 60,
                          height: headerHeight,
                          child: const Text(_headerText),
                        ),
                      ),
                    ),
                  ];
                },
          child: SizedBox(
            width: 100,
            height: targetHeight,
            child: const Text(menuTargetText),
          ),
        ),
      ),
    ),
  );
}

ScrollPosition _scrollPosition(WidgetTester tester) {
  return tester.state<ScrollableState>(find.byType(Scrollable).first).position;
}

void main() {
  testWidgets('shows the slivers above the preview', (tester) async {
    await tester.pumpWidget(_menu());
    await tester.openMenu();

    expect(find.text(_headerText), findsOneWidget);
    expect(
      tester.getBottomLeft(_header).dy,
      moreOrLessEquals(tester.getTopLeft(_preview).dy),
    );
  });

  testWidgets('keeps the preview in place when the slivers fit above it', (
    tester,
  ) async {
    await tester.pumpWidget(_menu());
    final targetTop = tester.getTopLeft(find.text(menuTargetText)).dy;
    await tester.openMenu();

    expect(tester.getTopLeft(_preview).dy, moreOrLessEquals(targetTop));
    expect(tester.getBottomLeft(_header).dy, moreOrLessEquals(targetTop));
  });

  testWidgets('moves the preview down when the slivers do not fit above it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _menu(alignment: Alignment.topCenter, headerHeight: 60),
    );
    final targetTop = tester.getTopLeft(find.text(menuTargetText)).dy;
    await tester.openMenu();

    expect(tester.getTopLeft(_header).dy, moreOrLessEquals(_screenPadding.top));
    expect(
      tester.getTopLeft(_preview).dy,
      moreOrLessEquals(_screenPadding.top + 60),
    );
    expect(tester.getTopLeft(_preview).dy, greaterThan(targetTop));
  });

  // The 420-tall widget and the menu fit on the 600-tall screen alone,
  // but not with a 150-tall header.
  testWidgets('does not scroll a widget that fits without slivers', (
    tester,
  ) async {
    await tester.pumpWidget(_menu(targetHeight: 420, headerHeight: null));
    await tester.openMenu();

    expect(_scrollPosition(tester).maxScrollExtent, 0);
  });

  testWidgets('scrolls the slivers out at the top when they do not fit', (
    tester,
  ) async {
    await tester.pumpWidget(_menu(targetHeight: 420, headerHeight: 150));
    await tester.openMenu();

    // The menu is at the bottom edge, the preview right above it.
    final position = _scrollPosition(tester);
    expect(position.maxScrollExtent, greaterThan(0));
    expect(position.pixels, position.maxScrollExtent);
    expect(tester.getTopLeft(_header).dy, lessThan(_screenPadding.top));

    // The route ignores pointers until its transition ends.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(_header, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(_scrollPosition(tester).pixels, 0);
    expect(tester.getTopLeft(_header).dy, moreOrLessEquals(_screenPadding.top));
  });

  testWidgets('keeps the menu at the bottom edge for a tall widget', (
    tester,
  ) async {
    // The 530-tall widget and the menu do not fit even without the header.
    await tester.pumpWidget(_menu(targetHeight: 530, headerHeight: 60));
    await tester.openMenu();

    final position = _scrollPosition(tester);
    expect(position.pixels, position.maxScrollExtent);
    expect(tester.getBottomLeft(find.text('Copy')).dy, lessThan(600));
    // Scrolled out of the viewport, so the default finder skips it.
    final header = find.byKey(const ValueKey(_headerText), skipOffstage: false);
    expect(tester.getBottomLeft(header).dy, lessThan(0));

    // Both the preview and the menu block drags, so scroll from code.
    position.jumpTo(0);
    await tester.pump();
    expect(tester.getTopLeft(_header).dy, moreOrLessEquals(_screenPadding.top));
  });

  for (final (alignment, name) in [
    (Alignment.centerLeft, 'left'),
    (Alignment.center, 'center'),
    (Alignment.centerRight, 'right'),
  ]) {
    testWidgets('lines the slivers up with the preview on the $name', (
      tester,
    ) async {
      await tester.pumpWidget(_menu(alignment: alignment));
      await tester.openMenu();

      final preview = tester.getRect(_preview);
      final header = tester.getRect(_header);
      switch (name) {
        case 'left':
          expect(header.left, moreOrLessEquals(preview.left));
        case 'center':
          expect(header.center.dx, moreOrLessEquals(preview.center.dx));
        case 'right':
          expect(header.right, moreOrLessEquals(preview.right));
      }
    });
  }

  testWidgets('close closes the menu and completes', (tester) async {
    late SmartContextMenuHeaderDetails header;
    await tester.pumpWidget(_menu(onHeader: (value) => header = value));
    await tester.openMenu();

    var isClosed = false;
    header.close().then((_) => isClosed = true);
    await tester.settleMenu();

    expect(isClosed, isTrue);
    expect(find.text('Copy'), findsNothing);
    expect(find.text(_headerText), findsNothing);
  });

  testWidgets('closing twice keeps the page below the menu', (tester) async {
    late SmartContextMenuHeaderDetails header;
    await tester.pumpWidget(const CupertinoApp(home: Text('Home')));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      CupertinoPageRoute<void>(
        builder: (_) => _menu(onHeader: (value) => header = value),
      ),
    );
    await tester.pumpAndSettle();
    await tester.openMenu();

    header.close();
    header.close();
    await tester.settleMenu();

    expect(find.text('Copy'), findsNothing);
    expect(navigator.canPop(), isTrue);
  });
}
