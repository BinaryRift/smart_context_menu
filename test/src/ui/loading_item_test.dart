import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('shows its title with an activity indicator in the menu', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.loading(title: 'Syncing')],
    );
    await tester.openMenu();

    expect(find.text('Syncing'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('shows its trailing instead of the activity indicator', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.loading(
          title: 'Syncing',
          trailing: const Icon(CupertinoIcons.clock),
        ),
      ],
    );
    await tester.openMenu();

    expect(find.text('Syncing'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);
  });

  testWidgets('is not highlighted under the finger', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.loading(title: 'Syncing')],
    );
    await tester.openMenu();

    final gesture = await tester.pressAt(find.text('Syncing'));
    expect(
      tester.backgroundOf('Syncing'),
      isSameColorAs(const Color(0x00000000)),
    );

    await tester.releaseOutside(gesture);
  });

  testWidgets('shows its title with an activity indicator in a submenu', (
    tester,
  ) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.submenu(
          title: 'More',
          children: [SmartContextMenuItem.loading(title: 'Syncing')],
        ),
      ],
    );
    await tester.openMenu();
    await tester.tap(find.text('More'));
    await tester.settleMenu();

    expect(find.text('Syncing'), findsOneWidget);
    expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
  });

  testWidgets('gives its child the color of the item', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Enabled'),
        SmartContextMenuItem.loading(
          child: const Row(
            children: [Text('Custom'), Icon(CupertinoIcons.clock)],
          ),
        ),
      ],
    );
    await tester.openMenu();

    final color = tester.titleStyleOf('Enabled').color;
    expect(
      DefaultTextStyle.of(tester.element(find.text('Custom'))).style.color,
      color,
    );
    expect(tester.iconColorOf(CupertinoIcons.clock), color);
  });

  testWidgets('centers its title, unlike an action', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(title: 'Copy'),
        SmartContextMenuItem.loading(title: 'Syncing'),
      ],
    );
    await tester.openMenu();

    expect(
      tester.widget<Text>(find.text('Syncing')).textAlign,
      TextAlign.center,
    );
    expect(tester.widget<Text>(find.text('Copy')).textAlign, TextAlign.start);
  });

  testWidgets('aligns its title by the style', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.loading(title: 'Syncing')],
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(statusTitleAlign: TextAlign.start),
      ),
    );
    await tester.openMenu();

    expect(
      tester.widget<Text>(find.text('Syncing')).textAlign,
      TextAlign.start,
    );
  });

  testWidgets('sizes its activity indicator as the icons', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.loading(title: 'Syncing')],
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(defaultIconSize: 28),
      ),
    );
    await tester.openMenu();

    expect(
      tester
          .widget<CupertinoActivityIndicator>(
            find.byType(CupertinoActivityIndicator),
          )
          .radius,
      14,
    );
  });

  group('with the loading indicator of the style', () {
    const config = SmartContextMenuConfig(
      style: SmartContextMenuStyle(
        loadingIndicator: Icon(CupertinoIcons.hourglass),
      ),
    );

    testWidgets('shows it instead of the activity indicator', (tester) async {
      await tester.pumpMenu(
        items: [SmartContextMenuItem.loading(title: 'Syncing')],
        config: config,
      );
      await tester.openMenu();

      expect(find.byIcon(CupertinoIcons.hourglass), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
    });

    testWidgets('keeps the trailing of the item', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.loading(
            title: 'Syncing',
            trailing: const Icon(CupertinoIcons.clock),
          ),
        ],
        config: config,
      );
      await tester.openMenu();

      expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.hourglass), findsNothing);
    });

    testWidgets('shows it in the middle of a loading submenu', (tester) async {
      final completer = Completer<List<SmartContextMenuItem>>();
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.asyncSubmenu(
            title: 'More',
            asyncChildren: () => completer.future,
          ),
        ],
        config: config,
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();

      expect(find.byIcon(CupertinoIcons.hourglass), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.text(const SmartContextMenuLabels().loading), findsNothing);

      completer.complete([]);
      await tester.settleMenu();
    });

    // A CircularProgressIndicator paints its stroke a little outside its box.
    testWidgets('does not clip it once shown', (tester) async {
      await tester.pumpMenu(
        items: [SmartContextMenuItem.loading(title: 'Syncing')],
        config: config,
      );
      await tester.openMenu();

      expect(
        _clipsOf(find.byIcon(CupertinoIcons.hourglass)),
        everyElement(Clip.none),
      );
    });

    testWidgets('does not clip it in a loading submenu', (tester) async {
      final completer = Completer<List<SmartContextMenuItem>>();
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.asyncSubmenu(
            title: 'More',
            asyncChildren: () => completer.future,
          ),
        ],
        config: config,
      );
      await tester.openMenu();
      await tester.tap(find.text('More'));
      await tester.settleMenu();

      expect(
        _clipsOf(find.byIcon(CupertinoIcons.hourglass)),
        everyElement(Clip.none),
      );

      completer.complete([]);
      await tester.settleMenu();
    });
  });
}

/// The clip behaviors of the [ClipRect]s above [finder].
List<Clip> _clipsOf(Finder finder) {
  final clips = find.ancestor(of: finder, matching: find.byType(ClipRect));
  return [
    for (final clip in clips.evaluate()) (clip.widget as ClipRect).clipBehavior,
  ];
}
