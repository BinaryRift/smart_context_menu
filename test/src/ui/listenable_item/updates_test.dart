import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/view/smart_context_menu_view.dart';

import '../../../helpers/listenable_item_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  late ItemNotifier notifier;

  setUp(() => notifier = ItemNotifier());
  tearDown(() => notifier.dispose());

  testWidgets('rebuilds the item in the open menu', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () =>
              SmartContextMenuItem.simple(title: '${notifier.count} views'),
        ),
      ],
    );
    await tester.openMenu();
    expect(find.text('0 views'), findsOneWidget);

    notifier.increment();
    await tester.settleMenu();

    expect(find.text('0 views'), findsNothing);
    expect(find.text('1 views'), findsOneWidget);
  });

  testWidgets('the menu grows with the built item', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () => notifier.isLoading
              ? SmartContextMenuItem.loading()
              : SmartContextMenuItem.simple(
                  title: 'Loaded',
                  padding: const EdgeInsets.all(40),
                ),
        ),
        SmartContextMenuItem.simple(title: 'Last'),
      ],
    );
    await tester.openMenu();
    final menu = find.byType(SmartContextMenuView);
    final heightWhileLoading = tester.getSize(menu).height;

    notifier.finishLoading();
    await tester.settleMenu();

    expect(tester.getSize(menu).height, greaterThan(heightWhileLoading));
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(tester.getRect(find.text('Last')).bottom, lessThan(screen.height));
  });
}
