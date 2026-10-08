import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

extension on WidgetTester {
  /// Drags [target] right by [distance] slowly, so the release has no speed.
  Future<void> slowSwipe(Finder target, double distance) async {
    final gesture = await startGesture(getCenter(target));
    const step = 25.0;
    for (var moved = 0.0; moved < distance; moved += step) {
      await gesture.moveBy(const Offset(step, 0));
      await pump(const Duration(milliseconds: 50));
    }
    await pump(const Duration(milliseconds: 300));
    await gesture.up();
    await settleMenu();
  }
}

void main() {
  final taps = <String>[];

  SmartContextMenuItem item(String title) => SmartContextMenuItem.simple(
    title: title,
    closeOnTap: false,
    onTap: () => taps.add(title),
  );

  List<SmartContextMenuItem> submenu() => [
    SmartContextMenuItem.submenu(
      title: 'More',
      children: [item('Child'), item('Other child')],
    ),
    item('Root item'),
  ];

  setUp(taps.clear);

  Future<void> openSubmenu(
    WidgetTester tester, {
    SmartContextMenuConfig config = const SmartContextMenuConfig(),
  }) async {
    await tester.pumpMenu(items: submenu(), config: config);
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Child'), findsOneWidget);
  }

  testWidgets('a swipe past half of the menu returns to the parent', (
    tester,
  ) async {
    await openSubmenu(tester);

    await tester.slowSwipe(find.text('Child'), 200);

    expect(find.text('Child'), findsNothing);
    expect(find.text('More'), findsOneWidget);
    expect(taps, isEmpty);
  });

  testWidgets('a short swipe stays in the submenu', (tester) async {
    await openSubmenu(tester);

    await tester.slowSwipe(find.text('Child'), 75);

    expect(find.text('Child'), findsOneWidget);
    expect(find.text('Root item'), findsNothing);
    expect(taps, isEmpty);
  });

  testWidgets('a fast swipe returns to the parent', (tester) async {
    await openSubmenu(tester);

    await tester.fling(find.text('Child'), const Offset(80, 0), 1500);
    await tester.settleMenu();

    expect(find.text('Child'), findsNothing);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('does nothing when swiping back is disabled', (tester) async {
    await openSubmenu(
      tester,
      config: const SmartContextMenuConfig(enableSwipeBack: false),
    );

    await tester.slowSwipe(find.text('Child'), 200);

    expect(find.text('Child'), findsOneWidget);
    expect(taps, isEmpty);
  });

  testWidgets('does nothing on the root level', (tester) async {
    await tester.pumpMenu(items: submenu());
    await tester.openMenu();

    await tester.slowSwipe(find.text('Root item'), 200);

    expect(find.text('Root item'), findsOneWidget);
    expect(find.text('Child'), findsNothing);
    expect(taps, isEmpty);
  });

  testWidgets('items work after a swipe back', (tester) async {
    await openSubmenu(tester);
    await tester.slowSwipe(find.text('Child'), 200);

    await tester.tap(find.text('Root item'));
    await tester.settleMenu();

    expect(taps, ['Root item']);
  });

  testWidgets('a swipe while loading drops the loaded items', (tester) async {
    final completer = Completer<List<SmartContextMenuItem>>();
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          asyncChildren: () => completer.future,
        ),
        item('Root item'),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();

    await tester.slowSwipe(find.byType(CupertinoActivityIndicator), 200);
    completer.complete([item('Loaded')]);
    await tester.settleMenu();

    expect(find.text('Root item'), findsOneWidget);
    expect(find.text('Loaded'), findsNothing);
  });
}
