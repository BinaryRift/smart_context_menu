import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  Finder bandOf(Color color) => find.byWidgetPredicate(
    (widget) =>
        widget is ColoredBox && widget.color.toARGB32() == color.toARGB32(),
  );

  testWidgets('shows the default band', (tester) async {
    await tester.pumpMenu(
      brightness: Brightness.light,
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(),
        SmartContextMenuItem.simple(title: 'Delete'),
      ],
    );
    await tester.openMenu();

    final band = bandOf(SmartContextMenuDefaults.separatorColor.color);
    expect(band, findsOneWidget);
    expect(
      tester.getSize(band).height,
      SmartContextMenuDefaults.separatorHeight,
    );
  });

  testWidgets('applies the style', (tester) async {
    const color = Color(0xFF000001);
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(separatorHeight: 3, separatorColor: color),
      ),
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(),
        SmartContextMenuItem.simple(title: 'Delete'),
      ],
    );
    await tester.openMenu();

    expect(tester.getSize(bandOf(color)).height, 3);
  });

  testWidgets('child replaces the band', (tester) async {
    await tester.pumpMenu(
      brightness: Brightness.light,
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(child: const Text('Danger zone')),
        SmartContextMenuItem.simple(title: 'Delete'),
      ],
    );
    await tester.openMenu();

    expect(find.text('Danger zone'), findsOneWidget);
    expect(bandOf(SmartContextMenuDefaults.separatorColor.color), findsNothing);
  });

  testWidgets('releasing over the separator triggers nothing', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++),
        SmartContextMenuItem.separator(child: const Text('Section')),
        SmartContextMenuItem.simple(title: 'Delete'),
      ],
    );
    await tester.openMenu();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Copy')),
    );
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Section')));
    await tester.pump();
    await gesture.up();
    await tester.settleMenu();

    expect(taps, 0);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('tapping the separator does not close the menu', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.separator(child: const Text('Section')),
        SmartContextMenuItem.simple(title: 'Delete'),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Section'));
    await tester.settleMenu();

    expect(find.text('Copy'), findsOneWidget);
  });

  group('cleanup', () {
    Finder sections() => find.textContaining('Section');

    testWidgets('hides separators at the start and the end', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.separator(child: const Text('Section 1')),
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.separator(child: const Text('Section 2')),
        ],
      );
      await tester.openMenu();

      expect(sections(), findsNothing);
    });

    testWidgets('shows one of several separators in a row', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.separator(child: const Text('Section 1')),
          SmartContextMenuItem.separator(child: const Text('Section 2')),
          SmartContextMenuItem.simple(title: 'Delete'),
        ],
      );
      await tester.openMenu();

      expect(find.text('Section 1'), findsOneWidget);
      expect(find.text('Section 2'), findsNothing);
    });

    testWidgets('keeps items shown on condition free of checks', (
      tester,
    ) async {
      const canDelete = false;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(title: 'Copy'),
          SmartContextMenuItem.separator(child: const Text('Section')),
          // ignore: dead_code
          if (canDelete) SmartContextMenuItem.simple(title: 'Delete'),
        ],
      );
      await tester.openMenu();

      expect(sections(), findsNothing);
    });

    testWidgets('shows a trailing separator once the next page loads', (
      tester,
    ) async {
      final secondPage = Completer<List<SmartContextMenuItem>>();
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.pagingSubmenu(
            title: 'More',
            initialMetadata: const SmartContextMenuPagingMetadata(limit: 2),
            asyncPagingChildren: (metadata) async => metadata.page == 1
                ? [
                    SmartContextMenuItem.simple(title: 'First'),
                    SmartContextMenuItem.separator(
                      child: const Text('Section'),
                      pagingMetadata: metadata.copyWith(page: 2),
                    ),
                  ]
                : secondPage.future,
          ),
        ],
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();
      expect(sections(), findsNothing);

      secondPage.complete([SmartContextMenuItem.simple(title: 'Second')]);
      await tester.settleMenu();

      expect(find.text('Second'), findsOneWidget);
      expect(sections(), findsOneWidget);
    });
  });
}
