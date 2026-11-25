// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../../helpers/row_tester.dart';

void main() {
  group('status', () {
    final signs = <String, (SmartContextMenuItem, Finder, String)>{
      'loading': (
        SmartContextMenuItem.loading(),
        find.byType(CupertinoActivityIndicator),
        'Loading…',
      ),
      'error': (
        SmartContextMenuItem.error(),
        find.byIcon(SmartContextMenuDefaults.errorIcon),
        'Error',
      ),
      'empty': (
        SmartContextMenuItem.empty(),
        find.byIcon(SmartContextMenuDefaults.emptyIcon),
        'No items',
      ),
    };

    for (final MapEntry(key: name, value: (item, sign, label))
        in signs.entries) {
      testWidgets('$name shows only its sign in a small cell', (tester) async {
        await tester.pumpCells([item], size: SmartContextMenuRowSize.small);

        expect(sign, findsOneWidget);
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('$name shows its sign above a short title in a medium '
          'cell', (tester) async {
        await tester.pumpCells([item]);

        expect(sign, findsOneWidget);
        expect(
          tester.getBottomLeft(sign).dy,
          lessThan(tester.getTopLeft(find.text(label)).dy),
        );
      });
    }

    testWidgets('a failed load shows the retry sign and title', (tester) async {
      await tester.pumpCells([SmartContextMenuItem.error()], failed: true);

      expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('takes the row labels of the config', (tester) async {
      await tester.pumpCells(
        [
          SmartContextMenuItem.loading(),
          SmartContextMenuItem.error(),
          SmartContextMenuItem.empty(),
        ],
        config: const SmartContextMenuConfig(
          labels: SmartContextMenuLabels(
            rowLoading: 'Wait',
            rowError: 'Oops',
            rowEmpty: 'None',
          ),
        ),
      );

      expect(find.text('Wait'), findsOneWidget);
      expect(find.text('Oops'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
    });

    testWidgets('a failed load takes rowRetry of the config', (tester) async {
      await tester.pumpCells(
        [SmartContextMenuItem.error()],
        failed: true,
        config: const SmartContextMenuConfig(
          labels: SmartContextMenuLabels(rowRetry: 'Again'),
        ),
      );

      expect(find.text('Again'), findsOneWidget);
    });

    testWidgets('keeps its own title but not its leading and trailing', (
      tester,
    ) async {
      await tester.pumpCells([
        SmartContextMenuItem.error(
          title: 'Offline',
          leading: const Icon(copyIcon),
          trailing: const Icon(shareIcon),
        ),
      ]);

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsOneWidget);
      expect(find.byIcon(copyIcon), findsNothing);
      expect(find.byIcon(shareIcon), findsNothing);
    });

    testWidgets('shows its child instead', (tester) async {
      await tester.pumpCells([
        SmartContextMenuItem.loading(child: const Text('Syncing')),
      ]);

      expect(find.text('Syncing'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });
  });
}
