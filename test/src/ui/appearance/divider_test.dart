import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  const style = SmartContextMenuStyle(
    dividersBetweenItems: true,
    dividerColor: Color(0xFF000001),
    dividerThickness: 2,
    dividerIndent: 8,
    dividerEndIndent: 4,
  );
  final dividers = find.byType(Divider);
  List<SmartContextMenuItem> items(List<String> titles) => [
    for (final title in titles) SmartContextMenuItem.simple(title: title),
  ];

  testWidgets('are off by default', (tester) async {
    await tester.pumpMenu(items: items(['A', 'B', 'C']));
    await tester.openMenu();

    expect(dividers, findsNothing);
  });

  testWidgets('use the default look', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(dividersBetweenItems: true),
      ),
      items: items(['A', 'B']),
      brightness: Brightness.light,
    );
    await tester.openMenu();

    final divider = tester.widget<Divider>(dividers);
    expect(divider.thickness, SmartContextMenuDefaults.dividerThickness);
    expect(divider.height, SmartContextMenuDefaults.dividerThickness);
    expect(divider.indent, 0);
    expect(divider.endIndent, 0);
    expect(
      divider.color,
      isSameColorAs(light(SmartContextMenuDefaults.dividerColor)),
    );
  });

  testWidgets('apply the style', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(style: style),
      items: items(['A', 'B']),
    );
    await tester.openMenu();

    final divider = tester.widget<Divider>(dividers);
    expect(divider.thickness, 2);
    expect(divider.height, 2);
    expect(divider.indent, 8);
    expect(divider.endIndent, 4);
    expect(divider.color, isSameColorAs(style.dividerColor));
  });

  testWidgets('are drawn between every two items', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(style: style),
      items: items(['A', 'B', 'C']),
    );
    await tester.openMenu();

    expect(dividers, findsNWidgets(2));
  });

  testWidgets('are not drawn next to a separator', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(style: style),
      items: [
        SmartContextMenuItem.simple(title: 'A'),
        SmartContextMenuItem.simple(title: 'B'),
        SmartContextMenuItem.separator(),
        SmartContextMenuItem.simple(title: 'C'),
      ],
    );
    await tester.openMenu();

    expect(dividers, findsOneWidget);
  });

  group('before the loading row of the next page', () {
    Future<Completer<List<SmartContextMenuItem>>> openPagingSubmenu(
      WidgetTester tester, {
      SmartContextMenuLoadingItem? loading,
    }) async {
      final nextPage = Completer<List<SmartContextMenuItem>>();
      await tester.pumpMenu(
        config: const SmartContextMenuConfig(style: style),
        items: [
          SmartContextMenuItem.pagingSubmenu(
            title: 'More',
            loading: loading,
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
      return nextPage;
    }

    // The back item and its placeholder have their own dividers.
    const backDividers = 2;

    testWidgets('a divider is drawn before a loading item', (tester) async {
      final nextPage = await openPagingSubmenu(
        tester,
        loading: SmartContextMenuItem.loading(title: 'Loading'),
      );

      expect(dividers, findsNWidgets(backDividers + 2));

      nextPage.complete([]);
      await tester.settleMenu();
    });

    testWidgets('no divider is drawn before the default loader', (
      tester,
    ) async {
      final nextPage = await openPagingSubmenu(tester);

      expect(dividers, findsNWidgets(backDividers + 1));

      nextPage.complete([]);
      await tester.settleMenu();
    });
  });

  testWidgets('the back item has a divider with the style', (tester) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(dividerThickness: 2, dividerIndent: 8),
      ),
      items: submenuItems(),
    );
    await tester.openSubmenu();

    // The back item and its invisible placeholder; one child has none.
    final backDividers = tester.widgetList<Divider>(dividers);
    expect(backDividers, hasLength(2));
    for (final divider in backDividers) {
      expect(divider.thickness, 2);
      expect(divider.indent, 8);
    }
  });
}
