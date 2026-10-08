import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  final items = [SmartContextMenuItem.simple(title: 'Copy')];
  final preview = find.byType(RawImage);

  // The route ignores pointers until its transition ends.
  Future<void> openMenu(WidgetTester tester) async {
    await tester.openMenu();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('closes the menu and calls onPreviewTap', (tester) async {
    var taps = 0;
    await tester.pumpMenu(items: items, onPreviewTap: () => taps++);
    await openMenu(tester);

    await tester.tap(preview);
    await tester.settleMenu();

    expect(taps, 1);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('calls onPreviewTap once for several taps', (tester) async {
    var taps = 0;
    await tester.pumpMenu(items: items, onPreviewTap: () => taps++);
    await openMenu(tester);

    await tester.tap(preview);
    await tester.pump();
    await tester.tap(preview, warnIfMissed: false);
    await tester.settleMenu();

    expect(taps, 1);
  });

  testWidgets('does not call onPreviewTap on a drag', (tester) async {
    var taps = 0;
    await tester.pumpMenu(items: items, onPreviewTap: () => taps++);
    await openMenu(tester);

    await tester.drag(preview, const Offset(0, 60));
    await tester.settleMenu();

    expect(taps, 0);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('keeps the menu open without onPreviewTap', (tester) async {
    await tester.pumpMenu(items: items);
    await openMenu(tester);

    await tester.tap(preview);
    await tester.settleMenu();

    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('works when the barrier is not dismissible', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: items,
      config: const SmartContextMenuConfig(barrierDismissible: false),
      onPreviewTap: () => taps++,
    );
    await openMenu(tester);

    await tester.tap(preview);
    await tester.settleMenu();

    expect(taps, 1);
  });
}
