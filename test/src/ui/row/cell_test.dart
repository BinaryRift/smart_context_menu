// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/view/item/smart_context_menu_item_view.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_row_layout.dart';

import '../../../helpers/appearance_tester.dart';

const _copyIcon = CupertinoIcons.doc_on_doc;
const _shareIcon = CupertinoIcons.share;
const _cellWidth = 62.0;
const _style = SmartContextMenuStyle();

/// Shows [items] as cells of [size] in a row, each [_cellWidth] wide.
Future<void> _pumpCells(
  WidgetTester tester,
  List<SmartContextMenuItem> items, {
  SmartContextMenuRowSize size = SmartContextMenuRowSize.medium,
  SmartContextMenuConfig config = const SmartContextMenuConfig(),
  TextDirection textDirection = TextDirection.ltr,
  bool failed = false,
}) {
  return tester.pumpWidget(
    CupertinoApp(
      home: Directionality(
        textDirection: textDirection,
        // A column leaves the height free, as the scroll view of the menu.
        child: Column(
          children: [
            SizedBox(
              width: _cellWidth * items.length,
              child: SmartContextMenuRowLayout(
                children: [
                  for (final item in items)
                    SmartContextMenuRowCell(
                      flex: 1,
                      child: failed
                          ? SmartContextMenuItemView.error(
                              key: ValueKey(item.id),
                              item: item,
                              config: config,
                              onRetry: () {},
                              rowSize: size,
                            )
                          : SmartContextMenuItemView(
                              key: ValueKey(item.id),
                              item: item,
                              config: config,
                              rowSize: size,
                            ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Rect _cellOf(WidgetTester tester, Finder content) => tester.getRect(
  find.ancestor(of: content, matching: find.byType(AnimatedContainer)).first,
);

void main() {
  group('medium', () {
    testWidgets('shows the leading above the title', (tester) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(_copyIcon),
        ),
      ]);

      final icon = tester.getRect(find.byIcon(_copyIcon));
      final title = tester.getRect(find.text('Copy'));
      final cell = _cellOf(tester, find.text('Copy'));
      expect(
        icon.top - cell.top,
        SmartContextMenuDefaults.rowMediumItemPadding.top,
      );
      expect(
        title.top - icon.bottom,
        SmartContextMenuDefaults.rowItemChildrenGap,
      );
      expect(icon.center.dx, cell.center.dx);
      expect(title.center.dx, cell.center.dx);
      expect(
        tester.itemPaddingOf('Copy'),
        SmartContextMenuDefaults.rowMediumItemPadding,
      );
    });

    testWidgets('shows only the title without a leading', (tester) async {
      await _pumpCells(tester, [SmartContextMenuItem.simple(title: '2×')]);

      expect(find.text('2×'), findsOneWidget);
    });

    testWidgets('shows only the leading without a title', (tester) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(leading: const Icon(_copyIcon)),
      ]);

      expect(find.byIcon(_copyIcon), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('centers the title in up to titleMaxLines lines', (
      tester,
    ) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(title: 'Add to Favorites'),
      ]);

      final title = tester.widget<Text>(find.text('Add to Favorites'));
      expect(title.textAlign, TextAlign.center);
      expect(title.maxLines, SmartContextMenuDefaults.titleMaxLines);
      expect(title.overflow, TextOverflow.ellipsis);
    });

    testWidgets('keeps the content of a lower cell at the top', (tester) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(_copyIcon),
        ),
        SmartContextMenuItem.simple(
          title: 'Share with everyone',
          leading: const Icon(_shareIcon),
        ),
      ]);

      final copy = tester.getRect(find.byIcon(_copyIcon));
      final share = tester.getRect(find.byIcon(_shareIcon));
      expect(copy.top, share.top);
      expect(
        tester.getTopLeft(find.text('Copy')).dy,
        tester.getTopLeft(find.text('Share with everyone')).dy,
      );
      expect(
        _cellOf(tester, find.text('Copy')).height,
        _cellOf(tester, find.text('Share with everyone')).height,
      );
    });
  });

  group('small', () {
    testWidgets('shows only the leading, labeled with the title', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(_copyIcon),
        ),
      ], size: SmartContextMenuRowSize.small);

      expect(find.byIcon(_copyIcon), findsOneWidget);
      expect(find.text('Copy'), findsNothing);
      expect(find.bySemanticsLabel('Copy'), findsOneWidget);
      expect(
        tester
            .widget<AnimatedContainer>(
              find
                  .ancestor(
                    of: find.byIcon(_copyIcon),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first,
            )
            .padding,
        SmartContextMenuDefaults.rowSmallItemPadding,
      );
      semantics.dispose();
    });

    testWidgets('shows the title without a leading', (tester) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(title: '0.5×'),
      ], size: SmartContextMenuRowSize.small);

      expect(find.text('0.5×'), findsOneWidget);
    });
  });

  testWidgets('does not show the trailing', (tester) async {
    for (final size in SmartContextMenuRowSize.values) {
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(
          title: 'Alerts',
          leading: const Icon(_copyIcon),
          trailing: const Text('On'),
        ),
      ], size: size);

      expect(find.text('On'), findsNothing, reason: '$size');
    }
  });

  group('title style', () {
    testWidgets('merges the row title style over the title style', (
      tester,
    ) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(
          title: 'Copy',
          titleStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        SmartContextMenuItem.simple(title: 'Share'),
      ]);

      final own = tester.titleStyleOf('Copy');
      expect(own.fontSize, SmartContextMenuDefaults.rowTitleStyle.fontSize);
      expect(own.fontWeight, FontWeight.w600);
      expect(
        tester.titleStyleOf('Share').fontSize,
        SmartContextMenuDefaults.rowTitleStyle.fontSize,
      );
    });

    testWidgets('takes the row title style from the style', (tester) async {
      await _pumpCells(
        tester,
        [SmartContextMenuItem.simple(title: 'Copy')],
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(
            rowStyle: SmartContextMenuRowStyle(
              titleStyle: TextStyle(fontSize: 10),
            ),
          ),
        ),
      );

      expect(tester.titleStyleOf('Copy').fontSize, 10);
    });
  });

  group('padding and gap', () {
    testWidgets('of the item take precedence over the style', (tester) async {
      const padding = EdgeInsets.all(3);
      await _pumpCells(tester, [
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(_copyIcon),
          padding: padding,
          childrenGap: 9,
        ),
      ]);

      expect(tester.itemPaddingOf('Copy'), padding);
      expect(
        tester.getTopLeft(find.text('Copy')).dy -
            tester.getBottomLeft(find.byIcon(_copyIcon)).dy,
        9,
      );
    });

    testWidgets('come from the style of each size', (tester) async {
      const small = EdgeInsets.all(1);
      const medium = EdgeInsets.all(2);
      const config = SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          rowStyle: SmartContextMenuRowStyle(
            smallItemPadding: small,
            mediumItemPadding: medium,
            itemChildrenGap: 7,
          ),
        ),
      );

      await _pumpCells(
        tester,
        [SmartContextMenuItem.simple(title: 'Copy')],
        size: SmartContextMenuRowSize.small,
        config: config,
      );
      expect(tester.itemPaddingOf('Copy'), small);

      await _pumpCells(tester, [
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(_copyIcon),
        ),
      ], config: config);
      expect(tester.itemPaddingOf('Copy'), medium);
      expect(
        tester.getTopLeft(find.text('Copy')).dy -
            tester.getBottomLeft(find.byIcon(_copyIcon)).dy,
        7,
      );
    });
  });

  group('submenu icon', () {
    for (final size in SmartContextMenuRowSize.values) {
      testWidgets('is in the top end corner of a $size cell', (tester) async {
        await _pumpCells(tester, [
          SmartContextMenuItem.submenu(
            title: 'More',
            leading: const Icon(_copyIcon),
            children: [],
          ),
        ], size: size);

        final icon = find.byIcon(_style.submenuIcon);
        final cell = _cellOf(tester, find.byIcon(_copyIcon));
        expect(tester.getSize(icon), Size.square(_style.defaultIconSize / 2));
        expect(tester.getRect(icon).top - cell.top, 6);
        expect(cell.right - tester.getRect(icon).right, 6);
        expect(
          tester.getRect(find.byIcon(_copyIcon)).center.dx,
          cell.center.dx,
        );
      });
    }

    testWidgets('is in the top left corner in RTL', (tester) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          leading: const Icon(_copyIcon),
          asyncChildren: () async => [],
        ),
      ], textDirection: TextDirection.rtl);

      final icon = find.byIcon(CupertinoIcons.chevron_back);
      final cell = _cellOf(tester, find.byIcon(_copyIcon));
      expect(tester.getRect(icon).top - cell.top, 6);
      expect(tester.getRect(icon).left - cell.left, 6);
    });

    testWidgets('is dimmed on a disabled cell', (tester) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.pagingSubmenu(
          title: 'More',
          isDisabled: true,
          asyncPagingChildren: (_) async => [],
          initialMetadata: const SmartContextMenuPagingMetadata(),
        ),
      ]);

      expect(
        tester.widget<Icon>(find.byIcon(_style.submenuIcon)).color,
        isSameColorAs(light(SmartContextMenuDefaults.disabledForegroundColor)),
      );
    });

    testWidgets('is not shown on an action', (tester) async {
      await _pumpCells(tester, [SmartContextMenuItem.simple(title: 'Copy')]);

      expect(find.byIcon(_style.submenuIcon), findsNothing);
    });
  });

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
        await _pumpCells(tester, [item], size: SmartContextMenuRowSize.small);

        expect(sign, findsOneWidget);
        expect(find.byType(Text), findsNothing);
      });

      testWidgets('$name shows its sign above a short title in a medium '
          'cell', (tester) async {
        await _pumpCells(tester, [item]);

        expect(sign, findsOneWidget);
        expect(
          tester.getBottomLeft(sign).dy,
          lessThan(tester.getTopLeft(find.text(label)).dy),
        );
      });
    }

    testWidgets('a failed load shows the retry sign and title', (tester) async {
      await _pumpCells(tester, [SmartContextMenuItem.error()], failed: true);

      expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('takes the row labels of the config', (tester) async {
      await _pumpCells(
        tester,
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
      await _pumpCells(
        tester,
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
      await _pumpCells(tester, [
        SmartContextMenuItem.error(
          title: 'Offline',
          leading: const Icon(_copyIcon),
          trailing: const Icon(_shareIcon),
        ),
      ]);

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsOneWidget);
      expect(find.byIcon(_copyIcon), findsNothing);
      expect(find.byIcon(_shareIcon), findsNothing);
    });

    testWidgets('shows its child instead', (tester) async {
      await _pumpCells(tester, [
        SmartContextMenuItem.loading(child: const Text('Syncing')),
      ]);

      expect(find.text('Syncing'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });
  });

  group('customBuilder', () {
    for (final size in SmartContextMenuRowSize.values) {
      testWidgets('gets the $size row size', (tester) async {
        SmartContextMenuRowSize? rowSize;
        await _pumpCells(tester, [
          SmartContextMenuItem.simple(
            customBuilder: (context, state) {
              rowSize = state.rowSize;
              return const SizedBox(height: 10);
            },
          ),
        ], size: size);

        expect(rowSize, size);
      });
    }

    testWidgets('gets no row size in a list', (tester) async {
      var rowSize = SmartContextMenuRowSize.small as SmartContextMenuRowSize?;
      await tester.pumpWidget(
        CupertinoApp(
          home: SmartContextMenuItemView(
            key: const ValueKey('item'),
            config: const SmartContextMenuConfig(),
            item: SmartContextMenuItem.simple(
              customBuilder: (context, state) {
                rowSize = state.rowSize;
                return const SizedBox(height: 10);
              },
            ),
          ),
        ),
      );

      expect(rowSize, isNull);
    });
  });
}
