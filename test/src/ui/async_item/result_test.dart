import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  final loadedItem = SmartContextMenuItem.simple(title: 'Loaded');

  testWidgets('shows a loading item returned by asyncItem', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(title: 'Checking'),
          asyncItem: () async => SmartContextMenuItem.loading(title: 'Waiting'),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Checking'), findsNothing);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('keeps the loaded item after returning from a submenu', (
    tester,
  ) async {
    var calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          asyncItem: () async {
            calls++;
            return loadedItem;
          },
        ),
        SmartContextMenuItem.submenu(
          title: 'More',
          children: [SmartContextMenuItem.simple(title: 'Child')],
        ),
      ],
    );
    await tester.openMenu();
    expect(find.text('Loaded'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Loaded'), findsNothing);

    await tester.tap(find.text(const SmartContextMenuLabels().back).last);
    await tester.settleMenu();

    expect(calls, 1);
    expect(find.text('Loaded'), findsOneWidget);
    expect(find.text(const SmartContextMenuLabels().loading), findsNothing);
  });

  group('returning a submenu', () {
    Future<void> openLoadedSubmenu(WidgetTester tester) async {
      await tester.openMenu();
      expect(find.text('Views: 120'), findsOneWidget);

      await tester.tap(find.text('Views: 120'));
      await tester.settleMenu();
    }

    Future<void> goBack(WidgetTester tester) async {
      await tester.tap(find.text(const SmartContextMenuLabels().back).last);
      await tester.settleMenu();
    }

    testWidgets('opens a submenu and keeps it after returning', (tester) async {
      var calls = 0;

      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.async(
            asyncItem: () async {
              calls++;
              return SmartContextMenuItem.submenu(
                title: 'Views: 120',
                children: [SmartContextMenuItem.simple(title: 'Anna')],
              );
            },
          ),
        ],
      );
      await openLoadedSubmenu(tester);
      expect(find.text('Anna'), findsOneWidget);

      await goBack(tester);

      expect(calls, 1);
      expect(find.text('Views: 120'), findsOneWidget);
      expect(find.text('Anna'), findsNothing);
    });

    testWidgets('opens an async submenu that loads its items', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.async(
            asyncItem: () async => SmartContextMenuItem.asyncSubmenu(
              title: 'Views: 120',
              asyncChildren: () async => [
                SmartContextMenuItem.simple(title: 'Anna'),
              ],
            ),
          ),
        ],
      );
      await openLoadedSubmenu(tester);
      expect(find.text('Anna'), findsOneWidget);

      await goBack(tester);
      expect(find.text('Views: 120'), findsOneWidget);
    });

    testWidgets('opens a paginated submenu that loads its first page', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.async(
            asyncItem: () async => SmartContextMenuItem.pagingSubmenu(
              title: 'Views: 120',
              initialMetadata: const SmartContextMenuPagingMetadata(),
              asyncPagingChildren: (metadata) async => [
                SmartContextMenuItem.simple(title: 'Anna'),
              ],
            ),
          ),
        ],
      );
      await openLoadedSubmenu(tester);
      expect(find.text('Anna'), findsOneWidget);

      await goBack(tester);
      expect(find.text('Views: 120'), findsOneWidget);
    });
  });
}
