import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

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
}
