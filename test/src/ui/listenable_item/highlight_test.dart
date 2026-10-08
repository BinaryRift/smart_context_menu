import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/listenable_item_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  late ItemNotifier notifier;

  setUp(() => notifier = ItemNotifier());
  tearDown(() => notifier.dispose());

  group('under the finger', () {
    const transparent = Color(0x00000000);

    testWidgets('is not highlighted while loading', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            loadingTitle: 'Loading',
            builder: () => notifier.isOn
                ? null
                : SmartContextMenuItem.simple(
                    title: 'Edit',
                    closeOnTap: false,
                    onTap: () => taps++,
                  ),
          ),
        ],
      );
      await tester.openMenu();
      final gesture = await tester.pressAt(find.text('Edit'));
      expect(tester.backgroundOf('Edit'), isNot(isSameColorAs(transparent)));

      notifier.toggle();
      await tester.pump();
      expect(tester.backgroundOf('Loading'), isSameColorAs(transparent));

      await gesture.up();
      await tester.settleMenu();
      expect(taps, 0);
    });

    testWidgets('is highlighted again once it can be tapped', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => SmartContextMenuItem.simple(
              title: 'Edit',
              isDisabled: notifier.isOn,
              closeOnTap: false,
              onTap: () => taps++,
            ),
          ),
        ],
      );
      await tester.openMenu();
      final gesture = await tester.pressAt(find.text('Edit'));

      notifier.toggle();
      await tester.pump();
      notifier.toggle();
      await tester.pump();
      expect(tester.backgroundOf('Edit'), isNot(isSameColorAs(transparent)));

      await gesture.up();
      await tester.settleMenu();
      expect(taps, 1);
    });

    testWidgets('a disabled item is not tapped on release', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => SmartContextMenuItem.simple(
              title: 'Edit',
              isDisabled: notifier.isOn,
              closeOnTap: false,
              onTap: () => taps++,
            ),
          ),
        ],
      );
      await tester.openMenu();
      final gesture = await tester.pressAt(find.text('Edit'));

      notifier.toggle();
      await tester.pump();
      await gesture.up();
      await tester.settleMenu();

      expect(taps, 0);
    });
  });
}
