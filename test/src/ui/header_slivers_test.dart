import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

const _headerText = 'Header';

final _items = [SmartContextMenuItem.simple(title: 'Copy')];
final _preview = find.byType(RawImage).last;
final _header = find.byKey(const ValueKey(_headerText));

/// A menu for a 100x40 widget placed by [alignment], with a 60x20 header
/// lined up by [SmartContextMenuHeaderDetails.alignment].
Widget _menu({
  Alignment alignment = Alignment.center,
  ValueChanged<SmartContextMenuHeaderDetails>? onHeader,
}) {
  return CupertinoApp(
    home: Padding(
      padding: const EdgeInsets.all(30),
      child: Align(
        alignment: alignment,
        child: SmartContextMenu(
          items: _items,
          headerSliversBuilder: (context, header) {
            onHeader?.call(header);
            return [
              SliverToBoxAdapter(
                child: Align(
                  alignment: header.alignment,
                  child: const SizedBox(
                    key: ValueKey(_headerText),
                    width: 60,
                    height: 20,
                    child: Text(_headerText),
                  ),
                ),
              ),
            ];
          },
          child: const SizedBox(
            width: 100,
            height: 40,
            child: Text(menuTargetText),
          ),
        ),
      ),
    ),
  );
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
