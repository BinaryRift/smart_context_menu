import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/listenable_item_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  late ItemNotifier notifier;

  setUp(() => notifier = ItemNotifier());
  tearDown(() => notifier.dispose());

  testWidgets('a tap runs onTap of the last built item', (tester) async {
    final taps = <int>[];
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () {
            final count = notifier.count;
            return SmartContextMenuItem.simple(
              title: 'Count',
              closeOnTap: false,
              onTap: () => taps.add(count),
            );
          },
        ),
      ],
    );
    await tester.openMenu();

    notifier.increment();
    await tester.settleMenu();
    await tester.tap(find.text('Count'));
    await tester.settleMenu();

    expect(taps, [1]);
  });

  testWidgets('a toggle stays in the open menu', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () => SmartContextMenuItem.simple(
            title: notifier.isOn ? 'Turn off' : 'Turn on',
            closeOnTap: false,
            onTap: notifier.toggle,
          ),
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Turn on'));
    await tester.settleMenu();
    expect(find.text('Turn off'), findsOneWidget);

    await tester.tap(find.text('Turn off'));
    await tester.settleMenu();
    expect(find.text('Turn on'), findsOneWidget);
  });

  testWidgets('the built item closes the menu on tap', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () =>
              SmartContextMenuItem.simple(title: 'Edit', onTap: () => taps++),
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Edit'));
    await tester.settleMenu();

    expect(taps, 1);
    expect(find.text('Edit'), findsNothing);
  });
}
