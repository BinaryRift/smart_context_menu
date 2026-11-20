import 'dart:async';

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('shows the labels of the config', (tester) async {
    final placeholder = Completer<SmartContextMenuAsyncResult>();
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        labels: SmartContextMenuLabels(
          back: 'Return',
          retry: 'Again',
          loading: 'Wait',
        ),
      ),
      items: [
        SmartContextMenuItem.async(asyncItem: () => placeholder.future),
        SmartContextMenuItem.asyncSubmenu(
          title: 'More',
          asyncChildren: () async => throw Exception('Failed'),
        ),
      ],
    );
    await tester.openMenu();
    expect(find.text('Wait'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.settleMenu();
    expect(find.text('Return'), findsWidgets);
    expect(find.text('Again'), findsOneWidget);

    // Completes the load so that its timeout timer does not stay pending.
    placeholder.complete(SmartContextMenuItem.simple(title: 'Loaded'));
    await tester.settleMenu();
  });

  testWidgets('takes the barrier label from CupertinoLocalizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        localizationsDelegates: const [_LocalizationsDelegate()],
        home: Center(
          child: SmartContextMenu(
            items: [SmartContextMenuItem.simple(title: 'Copy')],
            child: const Text(menuTargetText),
          ),
        ),
      ),
    );
    await tester.openMenu();

    final route = ModalRoute.of(tester.element(find.text('Copy')))!;
    expect(route.barrierLabel, _Localizations.dismissLabel);
  });

  testWidgets('opens in an app without Cupertino localizations', (
    tester,
  ) async {
    var taps = 0;

    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          pageBuilder: (context, _, _) => builder(context),
        ),
        home: Center(
          child: SmartContextMenu(
            items: [
              SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++),
            ],
            child: const Text(menuTargetText),
          ),
        ),
      ),
    );
    await tester.openMenu();
    expect(find.text('Copy'), findsOneWidget);

    await tester.tap(find.text('Copy'));
    await tester.settleMenu();

    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}

final class _Localizations extends DefaultCupertinoLocalizations {
  static const dismissLabel = 'Close the menu';

  const _Localizations();

  @override
  String get modalBarrierDismissLabel => dismissLabel;
}

final class _LocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _LocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture(const _Localizations());

  @override
  bool shouldReload(_LocalizationsDelegate old) => false;
}
