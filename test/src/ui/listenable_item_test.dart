import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/view/smart_context_menu_item_view.dart';

import '../../helpers/appearance_tester.dart';
import '../../helpers/menu_tester.dart';

void main() {
  late _Notifier notifier;

  setUp(() => notifier = _Notifier());
  tearDown(() => notifier.dispose());

  testWidgets('rebuilds the item in the open menu', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () =>
              SmartContextMenuItem.simple(title: '${notifier.count} views'),
        ),
      ],
    );
    await tester.openMenu();
    expect(find.text('0 views'), findsOneWidget);

    notifier.increment();
    await tester.settleMenu();

    expect(find.text('0 views'), findsNothing);
    expect(find.text('1 views'), findsOneWidget);
  });

  group('while the builder returns null', () {
    testWidgets('shows the loading title, then the built item', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            loadingTitle: 'Loading',
            builder: () => notifier.isLoading
                ? null
                : SmartContextMenuItem.simple(title: 'Loaded'),
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('Loading'), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      notifier.finishLoading();
      await tester.settleMenu();

      expect(find.text('Loading'), findsNothing);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(find.text('Loaded'), findsOneWidget);
    });

    testWidgets('shows the loading label without a loading title', (
      tester,
    ) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            builder: () => null,
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text(const SmartContextMenuLabels().loading), findsOneWidget);
    });

    testWidgets('uses loadingBuilder', (tester) async {
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            loadingTitle: 'Loading',
            loadingBuilder: (context, state) => const Text('Custom loading'),
            builder: () => null,
          ),
        ],
      );
      await tester.openMenu();

      expect(find.text('Custom loading'), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('looks like the loading of an async item', (tester) async {
      final completer = Completer<SmartContextMenuItem>();
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.async(
            loadingTitle: 'Async',
            asyncItem: () => completer.future,
          ),
          SmartContextMenuItem.listenable(
            listenable: notifier,
            loadingTitle: 'Listenable',
            builder: () => null,
          ),
        ],
      );
      await tester.openMenu();

      expect(
        tester.titleStyleOf('Listenable').color,
        tester.titleStyleOf('Async').color,
      );

      // Completes the load so that its timeout timer does not stay pending.
      completer.complete(SmartContextMenuItem.simple(title: 'Loaded'));
      await tester.settleMenu();
    });

    testWidgets('ignores taps', (tester) async {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.listenable(
            listenable: notifier,
            loadingTitle: 'Loading',
            builder: () => notifier.isLoading
                ? null
                : SmartContextMenuItem.simple(
                    title: 'Loaded',
                    onTap: () => taps++,
                  ),
          ),
        ],
      );
      await tester.openMenu();

      await tester.tap(find.text('Loading'));
      await tester.settleMenu();
      notifier.finishLoading();
      await tester.settleMenu();

      expect(taps, 0);
      expect(find.text('Loaded'), findsOneWidget);
    });
  });

  testWidgets('a tap runs onTap of the last built item', (tester) async {
    final taps = <int>[];
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () {
            final count = notifier.count;
            return SmartContextMenuItem.simple(
              title: 'Count',
              closeOnTap: false,
              onTap: () => taps.add(count),
            );
          },
        ),
      ],
    );
    await tester.openMenu();

    notifier.increment();
    await tester.settleMenu();
    await tester.tap(find.text('Count'));
    await tester.settleMenu();

    expect(taps, [1]);
  });

  testWidgets('a toggle stays in the open menu', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () => SmartContextMenuItem.simple(
            title: notifier.isOn ? 'Turn off' : 'Turn on',
            closeOnTap: false,
            onTap: notifier.toggle,
          ),
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Turn on'));
    await tester.settleMenu();
    expect(find.text('Turn off'), findsOneWidget);

    await tester.tap(find.text('Turn off'));
    await tester.settleMenu();
    expect(find.text('Turn on'), findsOneWidget);
  });

  testWidgets('the built item closes the menu on tap', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () =>
              SmartContextMenuItem.simple(title: 'Edit', onTap: () => taps++),
        ),
      ],
    );
    await tester.openMenu();

    await tester.tap(find.text('Edit'));
    await tester.settleMenu();

    expect(taps, 1);
    expect(find.text('Edit'), findsNothing);
  });

  testWidgets('stops listening when the menu closes', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.listenable(
          listenable: notifier,
          builder: () =>
              SmartContextMenuItem.simple(title: '${notifier.count} views'),
        ),
      ],
    );
    await tester.openMenu();
    expect(notifier.isListened, isTrue);

    await tester.tapAt(const Offset(1, 1));
    await tester.settleMenu();
    expect(find.text('0 views'), findsNothing);

    expect(notifier.isListened, isFalse);
    notifier.increment();
    await tester.pump();
  });

  testWidgets('listens to the new listenable when it is replaced', (
    tester,
  ) async {
    final other = _Notifier();
    addTearDown(other.dispose);

    Future<void> pumpItem(_Notifier listenable) {
      return tester.pumpWidget(
        CupertinoApp(
          home: SmartContextMenuItemView(
            key: const ValueKey('item'),
            config: const SmartContextMenuConfig(),
            item: SmartContextMenuItem.listenable(
              listenable: listenable,
              builder: () => SmartContextMenuItem.simple(
                title: '${listenable.count} views',
              ),
            ),
          ),
        ),
      );
    }

    await pumpItem(notifier);
    await pumpItem(other);

    expect(notifier.isListened, isFalse);
    expect(other.isListened, isTrue);

    other.increment();
    await tester.pump();
    expect(find.text('1 views'), findsOneWidget);
  });
}

final class _Notifier extends ChangeNotifier {
  int count = 0;
  bool isLoading = true;
  bool isOn = false;

  bool get isListened => hasListeners;

  void increment() {
    count++;
    notifyListeners();
  }

  void finishLoading() {
    isLoading = false;
    notifyListeners();
  }

  void toggle() {
    isOn = !isOn;
    notifyListeners();
  }
}
