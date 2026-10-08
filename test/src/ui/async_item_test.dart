import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  final loadedItem = SmartContextMenuItem.simple(title: 'Loaded');

  testWidgets('shows the loading title, then the loaded item', (tester) async {
    final completer = Completer<SmartContextMenuItem>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loadingTitle: 'Loading',
          asyncItem: () => completer.future,
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Loading'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

    completer.complete(loadedItem);
    await tester.settleMenu();

    expect(find.text('Loading'), findsNothing);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('shows the loading label without a loading title', (
    tester,
  ) async {
    final completer = Completer<SmartContextMenuItem>();

    await tester.pumpMenu(
      items: [SmartContextMenuItem.async(asyncItem: () => completer.future)],
    );
    await tester.openMenu();

    expect(find.text(const SmartContextMenuLabels().loading), findsOneWidget);

    completer.complete(loadedItem);
    await tester.settleMenu();
  });

  testWidgets('uses loadingBuilder while loading', (tester) async {
    final completer = Completer<SmartContextMenuItem>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loadingTitle: 'Loading',
          asyncItem: () => completer.future,
          loadingBuilder: (context, state) => const Text('Custom loading'),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Custom loading'), findsOneWidget);
    expect(find.text('Loading'), findsNothing);

    completer.complete(loadedItem);
    await tester.settleMenu();

    expect(find.text('Custom loading'), findsNothing);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('shows the retry label when loading fails', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          asyncItem: () => Future.error(Exception('Failed')),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text(const SmartContextMenuLabels().retry), findsOneWidget);
  });

  testWidgets('uses errorBuilder and retries on tap', (tester) async {
    var calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          asyncItem: () async {
            calls++;
            if (calls == 1) throw Exception('Failed');
            return loadedItem;
          },
          errorBuilder: (context, state) => const Text('Custom error'),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Custom error'), findsOneWidget);
    expect(find.text(const SmartContextMenuLabels().retry), findsNothing);

    await tester.tap(find.text('Custom error'));
    await tester.settleMenu();

    expect(calls, 2);
    expect(find.text('Custom error'), findsNothing);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('shows the retry label when loading takes too long', (
    tester,
  ) async {
    final completer = Completer<SmartContextMenuItem>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loadingTitle: 'Loading',
          timeout: const Duration(seconds: 2),
          asyncItem: () => completer.future,
        ),
      ],
    );
    await tester.openMenu();
    expect(find.text('Loading'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.settleMenu();
    expect(find.text(const SmartContextMenuLabels().retry), findsOneWidget);

    completer.complete(loadedItem);
    await tester.settleMenu();
    expect(find.text('Loaded'), findsNothing);
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
}
