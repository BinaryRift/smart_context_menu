import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

const _labels = SmartContextMenuLabels();

List<SmartContextMenuItem> _items(List<String> titles) => [
  for (final title in titles) SmartContextMenuItem.simple(title: title),
];

void main() {
  testWidgets('shows the retry item on error and retries on tap', (
    tester,
  ) async {
    var calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          asyncChildren: () async {
            calls++;
            if (calls == 1) throw Exception('Failed');
            return _items(['Loaded']);
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text(_labels.retry), findsOneWidget);

    await tester.tap(find.text(_labels.retry));
    await tester.settleMenu();

    expect(calls, 2);
    expect(find.text(_labels.retry), findsNothing);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('loads again when it opens again after an error', (tester) async {
    var calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          asyncChildren: () async {
            calls++;
            if (calls == 1) throw Exception('Failed');
            return _items(['Loaded']);
          },
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text(_labels.retry), findsOneWidget);

    await tester.tap(find.text(_labels.back).last);
    await tester.settleMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();

    expect(calls, 2);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('shows the retry label with the retry icon by default', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          asyncChildren: () => Future.error(Exception('Failed')),
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu();

    expect(find.text(_labels.retry), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsNothing);
  });

  testWidgets('shows its error item on error and retries on tap', (
    tester,
  ) async {
    var calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          error: SmartContextMenuItem.error(
            title: 'Could not load files',
            trailing: const Icon(CupertinoIcons.clock),
          ),
          asyncChildren: () async {
            calls++;
            if (calls == 1) throw Exception('Failed');
            return _items(['Loaded']);
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Could not load files'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.text(_labels.retry), findsNothing);
    expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsNothing);

    await tester.tap(find.text('Could not load files'));
    await tester.settleMenu();

    expect(calls, 2);
    expect(find.text('Could not load files'), findsNothing);
    expect(find.text('Loaded'), findsOneWidget);
  });
}
