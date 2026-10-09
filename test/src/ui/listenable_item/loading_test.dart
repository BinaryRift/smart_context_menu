import 'dart:async';

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

  group('when the builder returns a loading item', () {
    testWidgets('shows its title, then the built item', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => notifier.isLoading
                ? SmartContextMenuItem.loading(title: 'Syncing')
                : SmartContextMenuItem.simple(title: 'Synced'),
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('Syncing'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      notifier.finishLoading();
      await tester.settleMenu();

      expect(find.text('Syncing'), findsNothing);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.text('Synced'), findsOneWidget);
    });

    testWidgets('shows the loading label without a title', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: SmartContextMenuItem.loading,
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text(const SmartContextMenuLabels().loading), findsOneWidget);
    });

    testWidgets('uses its child', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => SmartContextMenuItem.loading(
              title: 'Syncing',
              child: const Text('Custom loading'),
            ),
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('Custom loading'), findsOneWidget);
      expect(find.text('Syncing'), findsNothing);
    });

    testWidgets('uses its padding', (tester) async {
      const padding = EdgeInsets.all(24);
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => SmartContextMenuItem.loading(
              title: 'Syncing',
              padding: padding,
            ),
          ),
        ],
      );
      await tester.openMenu();

      expect(tester.itemPaddingOf('Syncing'), padding);
    });

    testWidgets('changes its title while loading', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () =>
                SmartContextMenuItem.loading(title: 'Step ${notifier.count}'),
          ),
        ],
      );
      await tester.openMenu();
      expect(find.text('Step 0'), findsOneWidget);

      notifier.increment();
      await tester.settleMenu();

      expect(find.text('Step 0'), findsNothing);
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('looks like the loading of an async item', (tester) async {
      final completer = Completer<SmartContextMenuAsyncResult>();
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.async(
            loading: SmartContextMenuItem.loading(title: 'Async'),
            asyncItem: () => completer.future,
          ),
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => SmartContextMenuItem.loading(title: 'Listenable'),
          ),
        ],
      );
      await tester.openMenu();

      expect(
        tester.titleStyleOf('Listenable').color,
        tester.titleStyleOf('Async').color,
      );

      // Completes the load so that its timeout timer does not stay pending.
      completer.complete(SmartContextMenuItem.simple(title: 'Loaded'));
      await tester.settleMenu();
    });

    testWidgets('is not highlighted under the finger', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => SmartContextMenuItem.loading(title: 'Syncing'),
          ),
        ],
      );
      await tester.openMenu();

      final gesture = await tester.pressAt(find.text('Syncing'));
      expect(
        tester.backgroundOf('Syncing'),
        isSameColorAs(const Color(0x00000000)),
      );

      await tester.releaseOutside(gesture);
    });
  });
}
