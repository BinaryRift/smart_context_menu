import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/view/item/smart_context_menu_item_view.dart';

import '../../../helpers/listenable_item_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  late ItemNotifier notifier;

  setUp(() => notifier = ItemNotifier());
  tearDown(() => notifier.dispose());

  testWidgets('stops listening when the menu closes', (tester) async {
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
    expect(notifier.isListened, isTrue);

    await tester.tapAt(const Offset(1, 1));
    await tester.settleMenu();
    expect(find.text('0 views'), findsNothing);

    expect(notifier.isListened, isFalse);
    notifier.increment();
    await tester.pump();
  });

  testWidgets('listens to the new listenable when it is replaced', (
    tester,
  ) async {
    final other = ItemNotifier();
    addTearDown(other.dispose);

    Future<void> pumpItem(ItemNotifier listenable) {
      return tester.pumpWidget(
        CupertinoApp(
          home: SmartContextMenuItemView(
            key: const ValueKey('item'),
            config: const SmartContextMenuConfig(),
            item: SmartContextMenuItem.listenable(
              listenable: listenable,
              builder: () => SmartContextMenuItem.simple(
                title: '${listenable.count} views',
              ),
            ),
          ),
        ),
      );
    }

    await pumpItem(notifier);
    await pumpItem(other);

    expect(notifier.isListened, isFalse);
    expect(other.isListened, isTrue);

    other.increment();
    await tester.pump();
    expect(find.text('1 views'), findsOneWidget);
  });
}
