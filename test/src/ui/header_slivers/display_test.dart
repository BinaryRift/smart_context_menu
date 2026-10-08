import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/header_slivers_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('shows the slivers above the preview', (tester) async {
    await tester.pumpWidget(headerMenu());
    await tester.openMenu();

    expect(find.text(headerText), findsOneWidget);
    expect(
      tester.getBottomLeft(headerFinder).dy,
      moreOrLessEquals(tester.getTopLeft(previewFinder).dy),
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
      await tester.pumpWidget(headerMenu(alignment: alignment));
      await tester.openMenu();

      final preview = tester.getRect(previewFinder);
      final header = tester.getRect(headerFinder);
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
    await tester.pumpWidget(headerMenu(onHeader: (value) => header = value));
    await tester.openMenu();

    var isClosed = false;
    header.close().then((_) => isClosed = true);
    await tester.settleMenu();

    expect(isClosed, isTrue);
    expect(find.text('Copy'), findsNothing);
    expect(find.text(headerText), findsNothing);
  });

  testWidgets('closing twice keeps the page below the menu', (tester) async {
    late SmartContextMenuHeaderDetails header;
    await tester.pumpWidget(const CupertinoApp(home: Text('Home')));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      CupertinoPageRoute<void>(
        builder: (_) => headerMenu(onHeader: (value) => header = value),
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
