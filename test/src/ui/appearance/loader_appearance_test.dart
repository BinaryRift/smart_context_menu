import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  Future<EdgeInsetsGeometry> loaderPaddingOf(
    WidgetTester tester, {
    SmartContextMenuConfig config = const SmartContextMenuConfig(),
  }) async {
    final completer = Completer<List<SmartContextMenuItem>>();
    await tester.pumpMenu(
      config: config,
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

    return tester
        .widget<Padding>(
          find
              .ancestor(
                of: find.byType(CupertinoActivityIndicator),
                matching: find.byType(Padding),
              )
              .first,
        )
        .padding;
  }

  testWidgets('uses the default vertical padding', (tester) async {
    expect(
      await loaderPaddingOf(tester),
      const EdgeInsets.symmetric(
        vertical: SmartContextMenuDefaults.loaderVerticalPadding,
      ),
    );
  });

  testWidgets('applies the vertical padding', (tester) async {
    expect(
      await loaderPaddingOf(
        tester,
        config: const SmartContextMenuConfig(
          style: SmartContextMenuStyle(loaderVerticalPadding: 16),
        ),
      ),
      const EdgeInsets.symmetric(vertical: 16),
    );
  });
}
