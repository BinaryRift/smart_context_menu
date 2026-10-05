import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

const _labels = SmartContextMenuLabels();

List<SmartContextMenuItem> _items(List<String> titles) => [
  for (final title in titles) SmartContextMenuItem.simple(title: title),
];

void main() {
  testWidgets('shows a loader, then the loaded items', (tester) async {
    final completer = Completer<List<SmartContextMenuItem>>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          asyncChildren: () => completer.future,
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

    completer.complete(_items(['Loaded']));
    await tester.settleMenu();

    expect(find.byType(CupertinoActivityIndicator), findsNothing);
    expect(find.text('Loaded'), findsOneWidget);
  });

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

  testWidgets('loads the next page until the last one', (tester) async {
    final pages = <int>[];

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          initialMetadata: const SmartContextMenuPagingMetadata(limit: 2),
          asyncPagingChildren: (metadata) async {
            pages.add(metadata.page);
            final isLastPage = metadata.page == 2;
            return [
              SmartContextMenuItem.simple(title: 'Page ${metadata.page} A'),
              SmartContextMenuItem.simple(
                title: 'Page ${metadata.page} B',
                pagingMetadata: isLastPage
                    ? null
                    : metadata.copyWith(page: metadata.page + 1),
              ),
            ];
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu(frames: 10);

    expect(pages, [1, 2]);
    expect(find.text('Page 2 B'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('shows the retry item when a page fails and retries it', (
    tester,
  ) async {
    var page2Calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          initialMetadata: const SmartContextMenuPagingMetadata(limit: 1),
          asyncPagingChildren: (metadata) async {
            if (metadata.page == 1) {
              return [
                SmartContextMenuItem.simple(
                  title: 'Page 1',
                  pagingMetadata: metadata.copyWith(page: 2),
                ),
              ];
            }
            page2Calls++;
            if (page2Calls == 1) throw Exception('Failed');
            return _items(['Page 2']);
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu(frames: 10);
    expect(find.text('Page 1'), findsOneWidget);
    expect(find.text(_labels.retry), findsOneWidget);

    await tester.tap(find.text(_labels.retry));
    await tester.settleMenu(frames: 10);

    expect(page2Calls, 2);
    expect(find.text(_labels.retry), findsNothing);
    expect(find.text('Page 2'), findsOneWidget);
  });
}
