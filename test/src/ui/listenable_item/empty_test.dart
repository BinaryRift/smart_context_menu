import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/listenable_item_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  late ItemNotifier notifier;

  setUp(() => notifier = ItemNotifier());
  tearDown(() => notifier.dispose());

  group('when the builder returns an empty item', () {
    testWidgets('shows it, then the built item', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => notifier.count == 0
                ? SmartContextMenuItem.empty(title: 'No drafts')
                : SmartContextMenuItem.simple(
                    title: 'Drafts: ${notifier.count}',
                  ),
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('No drafts'), findsOneWidget);
      expect(find.byIcon(SmartContextMenuDefaults.emptyIcon), findsOneWidget);

      notifier.increment();
      await tester.settleMenu();

      expect(find.text('No drafts'), findsNothing);
      expect(find.byIcon(SmartContextMenuDefaults.emptyIcon), findsNothing);
      expect(find.text('Drafts: 1'), findsOneWidget);
    });
  });
}
