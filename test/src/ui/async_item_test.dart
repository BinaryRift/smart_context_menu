import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  final loadedItem = SmartContextMenuItem.simple(title: 'Loaded');

  testWidgets('shows the loading title, then the loaded item', (tester) async {
    final completer = Completer<SmartContextMenuAsyncResult>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(title: 'Loading'),
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
    final completer = Completer<SmartContextMenuAsyncResult>();

    await tester.pumpMenu(
      items: [SmartContextMenuItem.async(asyncItem: () => completer.future)],
    );
    await tester.openMenu();

    expect(find.text(const SmartContextMenuLabels().loading), findsOneWidget);

    completer.complete(loadedItem);
    await tester.settleMenu();
  });

  testWidgets('uses the child of the loading item while loading', (
    tester,
  ) async {
    final completer = Completer<SmartContextMenuAsyncResult>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(
            title: 'Loading',
            child: const Text('Custom loading'),
          ),
          asyncItem: () => completer.future,
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

  testWidgets('shows the retry label with the retry icon when loading fails', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          asyncItem: () => Future.error(Exception('Failed')),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text(const SmartContextMenuLabels().retry), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsOneWidget);
    expect(find.byIcon(SmartContextMenuDefaults.errorIcon), findsNothing);
  });

  testWidgets('shows the title, leading and trailing of the error item', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          error: SmartContextMenuItem.error(
            title: 'Could not check',
            leading: const Icon(CupertinoIcons.lock),
            trailing: const Icon(CupertinoIcons.clock),
          ),
          asyncItem: () => Future.error(Exception('Failed')),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Could not check'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.lock), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.text(const SmartContextMenuLabels().retry), findsNothing);
    expect(find.byIcon(SmartContextMenuDefaults.retryIcon), findsNothing);
  });

  testWidgets('uses the child of the error item and retries on tap', (
    tester,
  ) async {
    var calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          error: SmartContextMenuItem.error(child: const Text('Custom error')),
          asyncItem: () async {
            calls++;
            if (calls == 1) throw Exception('Failed');
            return loadedItem;
          },
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

  testWidgets('lets a button in the child of the error item handle the tap', (
    tester,
  ) async {
    var calls = 0;
    var buttonTaps = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          error: SmartContextMenuItem.error(
            child: Row(
              children: [
                const Expanded(child: Text('No access')),
                CupertinoButton(
                  onPressed: () => buttonTaps++,
                  child: const Text('Settings'),
                ),
              ],
            ),
          ),
          asyncItem: () async {
            calls++;
            if (calls == 1) throw Exception('Failed');
            return loadedItem;
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Settings'));
    await tester.settleMenu();
    expect(buttonTaps, 1);
    expect(calls, 1);

    await tester.tap(find.text('No access'));
    await tester.settleMenu();
    expect(calls, 2);
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('shows the retry label when loading takes too long', (
    tester,
  ) async {
    final completer = Completer<SmartContextMenuAsyncResult>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(title: 'Loading'),
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

  testWidgets('uses the padding of the loading item while loading', (
    tester,
  ) async {
    const padding = EdgeInsets.all(24);
    final completer = Completer<SmartContextMenuAsyncResult>();

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(
            title: 'Loading',
            padding: padding,
          ),
          asyncItem: () => completer.future,
        ),
      ],
    );
    await tester.openMenu();

    expect(tester.itemPaddingOf('Loading'), padding);

    completer.complete(loadedItem);
    await tester.settleMenu();
  });

  testWidgets('keeps the padding of the loading item after a failure', (
    tester,
  ) async {
    const padding = EdgeInsets.all(24);

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(padding: padding),
          asyncItem: () => Future.error(Exception('Failed')),
        ),
      ],
    );
    await tester.openMenu();

    expect(tester.itemPaddingOf(const SmartContextMenuLabels().retry), padding);
  });

  testWidgets('uses the padding of the error item after a failure', (
    tester,
  ) async {
    const padding = EdgeInsets.all(8);

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(
            padding: const EdgeInsets.all(24),
          ),
          error: SmartContextMenuItem.error(padding: padding),
          asyncItem: () => Future.error(Exception('Failed')),
        ),
      ],
    );
    await tester.openMenu();

    expect(tester.itemPaddingOf(const SmartContextMenuLabels().retry), padding);
  });

  testWidgets('shows the loading item again on retry', (tester) async {
    final completer = Completer<SmartContextMenuAsyncResult>();
    var calls = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(title: 'Loading'),
          asyncItem: () {
            calls++;
            if (calls == 1) return Future.error(Exception('Failed'));
            return completer.future;
          },
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text(const SmartContextMenuLabels().retry));
    await tester.settleMenu();
    expect(find.text('Loading'), findsOneWidget);

    completer.complete(loadedItem);
    await tester.settleMenu();
    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('shows a loading item returned by asyncItem', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          loading: SmartContextMenuItem.loading(title: 'Checking'),
          asyncItem: () async => SmartContextMenuItem.loading(title: 'Waiting'),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Checking'), findsNothing);
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
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

  testWidgets('centers the retry label', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.async(
          asyncItem: () => Future.error(Exception('Failed')),
        ),
      ],
    );
    await tester.openMenu();

    expect(
      tester
          .widget<Text>(find.text(const SmartContextMenuLabels().retry))
          .textAlign,
      TextAlign.center,
    );
  });
}
