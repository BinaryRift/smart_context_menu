import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

const _labels = SmartContextMenuLabels();

void main() {
  group('without items', () {
    testWidgets('shows the default empty item', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.asyncSubmenu(
            title: 'More',
            asyncChildren: () async => [],
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('More'));
      await tester.settleMenu();

      expect(find.text(_labels.empty), findsOneWidget);
      expect(find.byIcon(SmartContextMenuDefaults.emptyIcon), findsOneWidget);
    });

    testWidgets('shows its empty item, also after reopening', (tester) async {
      var calls = 0;

      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.asyncSubmenu(
            title: 'More',
            empty: SmartContextMenuItem.empty(title: 'No files'),
            asyncChildren: () async {
              calls++;
              return [];
            },
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('More'));
      await tester.settleMenu();
      expect(find.text('No files'), findsOneWidget);
      expect(find.text(_labels.empty), findsNothing);

      await tester.tap(find.text(_labels.back).last);
      await tester.settleMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();

      expect(calls, 1);
      expect(find.text('No files'), findsOneWidget);
    });

    testWidgets('shows its empty item after a retry', (tester) async {
      var calls = 0;

      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.asyncSubmenu(
            title: 'More',
            empty: SmartContextMenuItem.empty(title: 'No files'),
            asyncChildren: () async {
              calls++;
              if (calls == 1) throw Exception('Failed');
              return [];
            },
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('More'));
      await tester.settleMenu();
      expect(find.text('No files'), findsNothing);

      await tester.tap(find.text(_labels.retry));
      await tester.settleMenu();

      expect(find.text(_labels.retry), findsNothing);
      expect(find.text('No files'), findsOneWidget);
    });

    testWidgets('shows the empty item when the first page is empty', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.pagingSubmenu(
            title: 'More',
            empty: SmartContextMenuItem.empty(title: 'No contacts'),
            initialMetadata: const SmartContextMenuPagingMetadata(),
            asyncPagingChildren: (_) async => [],
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('More'));
      await tester.settleMenu(frames: 10);

      expect(find.text('No contacts'), findsOneWidget);
    });

    testWidgets('shows no empty item when the next page is empty', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.pagingSubmenu(
            title: 'More',
            empty: SmartContextMenuItem.empty(title: 'No contacts'),
            initialMetadata: const SmartContextMenuPagingMetadata(limit: 1),
            asyncPagingChildren: (metadata) async {
              if (metadata.page > 1) return [];
              return [
                SmartContextMenuItem.simple(
                  title: 'Page 1',
                  pagingMetadata: metadata.copyWith(page: 2),
                ),
              ];
            },
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('More'));
      await tester.settleMenu(frames: 10);

      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('No contacts'), findsNothing);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });
  });
}
