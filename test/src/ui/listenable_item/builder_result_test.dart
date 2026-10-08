import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/listenable_item_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  late ItemNotifier notifier;

  setUp(() => notifier = ItemNotifier());
  tearDown(() => notifier.dispose());

  group('the builder must return a simple or a loading item', () {
    final invalidItems = <String, SmartContextMenuItem Function()>{
      'separator': SmartContextMenuItem.separator,
      'submenu': () => SmartContextMenuItem.submenu(children: []),
      'async item': () => SmartContextMenuItem.async(
        asyncItem: () => Completer<SmartContextMenuItem>().future,
      ),
      'listenable item': () => SmartContextMenuItem.listenable(
        listenable: notifier,
        builder: SmartContextMenuItem.simple,
      ),
    };

    for (final MapEntry(key: name, value: invalidItem)
        in invalidItems.entries) {
      testWidgets('asserts on a $name', (tester) async {
        await tester.pumpMenu(
          items: [
            SmartContextMenuItem.listenable(
              listenable: notifier,
              builder: invalidItem,
            ),
          ],
        );
        await tester.openMenu();

        expect(tester.takeException(), isAssertionError);
      });
    }
  });
}
