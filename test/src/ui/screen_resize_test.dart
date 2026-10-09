import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('closes without an action when the screen turns', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++)],
    );
    await tester.openMenu();
    expect(find.text('Copy'), findsOneWidget);

    tester.view.physicalSize = Size(
      tester.view.physicalSize.height,
      tester.view.physicalSize.width,
    );
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pump();
    await tester.settleMenu();

    expect(find.text('Copy'), findsNothing);
    expect(taps, 0);
  });

  testWidgets('stays open when only the insets change', (tester) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Copy')]);
    await tester.openMenu();

    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    await tester.settleMenu();

    expect(find.text('Copy'), findsOneWidget);
  });
}
