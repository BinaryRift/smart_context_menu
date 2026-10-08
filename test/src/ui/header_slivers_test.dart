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
  VoidCallback? onHeaderTap,
  SmartContextMenuConfig config = const SmartContextMenuConfig(),
  List<SmartContextMenuItem>? items,
  bool fadeHeaderSlivers = true,
}) {
  return CupertinoApp(
    home: Padding(
      padding: const EdgeInsets.all(30),
      child: Align(
        alignment: alignment,
        child: SmartContextMenu(
          items: items ?? _items,
          config: config,
          fadeHeaderSlivers: fadeHeaderSlivers,
          headerSliversBuilder: headerHeight == null
              ? null
              : (context, header) {
                  onHeader?.call(header);
                  return [
                    SliverToBoxAdapter(
                      child: Align(
                        alignment: header.alignment,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onHeaderTap,
                          child: SizedBox(
                            key: const ValueKey(_headerText),
                            width: 60,
                            height: headerHeight,
                            child: const Text(_headerText),
                          ),
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

/// Opens the menu and waits until it takes pointers.
Future<void> _openMenu(WidgetTester tester) async {
  await tester.openMenu();
  // The route ignores pointers until its transition ends.
  await tester.pump(const Duration(milliseconds: 100));
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

  group('taps', () {
    testWidgets('a tap on a widget in the slivers keeps the menu open', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(_menu(onHeaderTap: () => taps++));
      await _openMenu(tester);

      await tester.tap(_header);
      await tester.settleMenu();

      expect(taps, 1);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('a tap next to the widgets in the slivers closes the menu', (
      tester,
    ) async {
      await tester.pumpWidget(_menu());
      await _openMenu(tester);

      await tester.tapAt(tester.getCenter(_header) + const Offset(150, 0));
      await tester.settleMenu();

      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('a tap next to the slivers keeps a non-dismissible menu', (
      tester,
    ) async {
      await tester.pumpWidget(
        _menu(config: const SmartContextMenuConfig(barrierDismissible: false)),
      );
      await _openMenu(tester);

      await tester.tapAt(tester.getCenter(_header) + const Offset(150, 0));
      await tester.settleMenu();

      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('a drag from the slivers does not select an item', (
      tester,
    ) async {
      var copies = 0;
      await tester.pumpWidget(
        _menu(
          items: [
            SmartContextMenuItem.simple(title: 'Copy', onTap: () => copies++),
          ],
        ),
      );
      await _openMenu(tester);

      final gesture = await tester.startGesture(tester.getCenter(_header));
      await gesture.moveTo(tester.getCenter(find.text('Copy')));
      await tester.pump();
      await gesture.up();
      await tester.settleMenu();

      expect(copies, 0);
      expect(find.text('Copy'), findsOneWidget);
    });
  });

  group('motion', () {
    /// How far the header and the preview have moved from [header] and
    /// [preview].
    (Offset, Offset) moved(WidgetTester tester, Offset header, Offset preview) {
      return (
        tester.getTopLeft(_header) - header,
        tester.getTopLeft(_preview) - preview,
      );
    }

    testWidgets('the slivers move with the dragged preview', (tester) async {
      await tester.pumpWidget(_menu());
      await _openMenu(tester);
      final header = tester.getTopLeft(_header);
      final preview = tester.getTopLeft(_preview);

      final gesture = await tester.startGesture(tester.getCenter(_preview));
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, 10));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      final (headerShift, previewShift) = moved(tester, header, preview);
      expect(previewShift.dy, greaterThan(0));
      expect(headerShift, previewShift);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(moved(tester, header, preview), (Offset.zero, Offset.zero));
    });

    testWidgets('the slivers move with the stretched menu', (tester) async {
      await tester.pumpWidget(
        _menu(
          items: [
            SmartContextMenuItem.simple(
              title: 'Copy',
              closeOnTap: false,
              onTap: () {},
            ),
          ],
        ),
      );
      await _openMenu(tester);
      final header = tester.getTopLeft(_header);
      final preview = tester.getTopLeft(_preview);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Copy')),
      );
      await tester.pump();
      await gesture.moveBy(const Offset(40, 0));
      await tester.pumpAndSettle();
      final (headerShift, previewShift) = moved(tester, header, preview);
      expect(previewShift.dx, greaterThan(0));
      expect(headerShift, previewShift);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('animation', () {
    testWidgets('runs to 1 as the menu opens and back to 0 as it closes', (
      tester,
    ) async {
      late SmartContextMenuHeaderDetails header;
      await tester.pumpWidget(_menu(onHeader: (value) => header = value));
      await tester.openMenu();
      final animation = header.animation;
      expect(animation.value, 1);

      header.close();
      await tester.pump();
      expect(animation.status, AnimationStatus.reverse);

      await tester.settleMenu();
      expect(animation.value, 0);
    });

    testWidgets('the slivers fade with the menu by default', (tester) async {
      await tester.pumpWidget(_menu());
      await tester.openMenu();

      expect(
        find.ancestor(of: _header, matching: find.byType(SliverFadeTransition)),
        findsOneWidget,
      );
    });

    testWidgets('the slivers do not fade with fadeHeaderSlivers off', (
      tester,
    ) async {
      await tester.pumpWidget(_menu(fadeHeaderSlivers: false));
      await tester.openMenu();

      expect(
        find.ancestor(of: _header, matching: find.byType(SliverFadeTransition)),
        findsNothing,
      );
    });
  });
}
