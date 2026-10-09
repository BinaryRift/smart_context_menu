import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/listenable_item_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  late ItemNotifier notifier;

  setUp(() => notifier = ItemNotifier());
  tearDown(() => notifier.dispose());

  group('when the builder returns an error item', () {
    testWidgets('shows it, then the built item', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => notifier.hasFailed
                ? SmartContextMenuItem.error(title: 'Could not sync')
                : SmartContextMenuItem.simple(title: 'Synced'),
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('Could not sync'), findsOneWidget);
      expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsOneWidget);

      notifier.recover();
      await tester.settleMenu();

      expect(find.text('Could not sync'), findsNothing);
      expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsNothing);
      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('does not run anything on tap', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => notifier.hasFailed
                ? SmartContextMenuItem.error(title: 'Could not sync')
                : SmartContextMenuItem.simple(
                    title: 'Synced',
                    onTap: () => taps++,
                  ),
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('Could not sync'));
      await tester.settleMenu();

      expect(taps, 0);
      expect(find.text('Could not sync'), findsOneWidget);
    });
  });
}
