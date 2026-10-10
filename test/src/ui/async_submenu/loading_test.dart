import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'package:smart_context_menu/src/core/ui/motion/tokens/motion_durations.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_level_switcher.dart';

import '../../../helpers/menu_tester.dart';

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
}
