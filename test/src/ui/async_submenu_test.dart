import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'package:smart_context_menu/src/core/ui/motion/tokens/motion_durations.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_level_switcher.dart';

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

  testWidgets('shows the loading item while the items load', (tester) async {
    final completer = Completer<List<SmartContextMenuItem>>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          loading: SmartContextMenuItem.loading(title: 'Loading files'),
          asyncChildren: () => completer.future,
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();

    expect(find.text('Loading files'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

    completer.complete(_items(['Loaded']));
    await tester.settleMenu();

    expect(find.text('Loading files'), findsNothing);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('shows the default loader without a title', (tester) async {
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
    expect(find.text(_labels.loading), findsNothing);

    completer.complete([]);
    await tester.settleMenu();
  });

  testWidgets('animates the menu height when the items are loaded', (
    tester,
  ) async {
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

    double menuHeight() =>
        tester.getSize(find.byType(SmartContextMenuLevelSwitcher)).height;
    final loadingHeight = menuHeight();

    completer.complete(_items(['A', 'B', 'C', 'D']));
    await tester.pump();
    await tester.pump(MotionDurations.standard * 0.3);
    final animatedHeight = menuHeight();

    await tester.settleMenu();
    final loadedHeight = menuHeight();

    expect(loadedHeight, greaterThan(loadingHeight));
    expect(animatedHeight, inExclusiveRange(loadingHeight, loadedHeight));
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

  testWidgets('shows the loading item for the first and the next pages', (
    tester,
  ) async {
    final nextPage = Completer<List<SmartContextMenuItem>>();
    final firstPage = Completer<List<SmartContextMenuItem>>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          loading: SmartContextMenuItem.loading(title: 'Loading contacts'),
          initialMetadata: const SmartContextMenuPagingMetadata(limit: 2),
          asyncPagingChildren: (metadata) =>
              metadata.page == 1 ? firstPage.future : nextPage.future,
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Loading contacts'), findsOneWidget);

    firstPage.complete([
      SmartContextMenuItem.simple(title: 'A'),
      SmartContextMenuItem.simple(
        title: 'B',
        pagingMetadata: const SmartContextMenuPagingMetadata(page: 2, limit: 2),
      ),
    ]);
    await tester.settleMenu();

    expect(find.text('B'), findsOneWidget);
    expect(find.text('Loading contacts'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Loading contacts')).dy,
      greaterThan(tester.getTopLeft(find.text('B')).dy),
    );

    nextPage.complete([]);
    await tester.settleMenu();
    expect(find.text('Loading contacts'), findsNothing);
  });

  testWidgets('keeps the loading item after leaving and reopening', (
    tester,
  ) async {
    final nextPage = Completer<List<SmartContextMenuItem>>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          loading: SmartContextMenuItem.loading(title: 'Loading contacts'),
          initialMetadata: const SmartContextMenuPagingMetadata(limit: 2),
          asyncPagingChildren: (metadata) async {
            if (metadata.page > 1) return nextPage.future;
            return [
              SmartContextMenuItem.simple(title: 'A'),
              SmartContextMenuItem.simple(
                title: 'B',
                pagingMetadata: metadata.copyWith(page: 2),
              ),
            ];
          },
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();
    await tester.tap(find.text(_labels.back).last);
    await tester.settleMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu();

    expect(find.text('B'), findsOneWidget);
    expect(find.text('Loading contacts'), findsOneWidget);

    nextPage.complete([]);
    await tester.settleMenu();
  });

  testWidgets('loads the next page on scroll after leaving and reopening', (
    tester,
  ) async {
    final pages = <int>[];

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          initialMetadata: const SmartContextMenuPagingMetadata(),
          asyncPagingChildren: (metadata) async {
            pages.add(metadata.page);
            final first = (metadata.page - 1) * metadata.limit;
            return [
              for (var i = 1; i <= metadata.limit; i++)
                SmartContextMenuItem.simple(
                  title: 'Item ${first + i}',
                  pagingMetadata: i == metadata.limit && metadata.page < 3
                      ? metadata.copyWith(page: metadata.page + 1)
                      : null,
                ),
            ];
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu(frames: 10);
    expect(pages, [1]);

    await tester.tap(find.text(_labels.back).last);
    await tester.settleMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu(frames: 10);
    expect(pages, [1]);

    await tester.drag(find.text('Item 5'), const Offset(0, -600));
    await tester.settleMenu(frames: 10);

    expect(pages, [1, 2]);
    expect(find.text('Item 21', skipOffstage: false), findsOneWidget);
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

  testWidgets('shows its error item when a page fails, also after reopening', (
    tester,
  ) async {
    var page2Calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          error: SmartContextMenuItem.error(title: 'Could not load page'),
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
            if (page2Calls <= 2) throw Exception('Failed');
            return _items(['Page 2']);
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('More'));
    await tester.settleMenu(frames: 10);
    expect(find.text('Could not load page'), findsOneWidget);
    expect(find.text(_labels.retry), findsNothing);

    await tester.tap(find.text(_labels.back).last);
    await tester.settleMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu(frames: 10);

    expect(page2Calls, 2);
    expect(find.text('Could not load page'), findsOneWidget);

    await tester.tap(find.text('Could not load page'));
    await tester.settleMenu(frames: 10);

    expect(page2Calls, 3);
    expect(find.text('Could not load page'), findsNothing);
    expect(find.text('Page 2'), findsOneWidget);
  });

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
