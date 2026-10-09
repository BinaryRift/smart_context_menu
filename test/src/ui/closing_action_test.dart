import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

/// The menu closes in 200 milliseconds.
const _closing = Duration(milliseconds: 200);

void main() {
  testWidgets('an item runs its action three quarters through the closing', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++)],
    );
    await tester.openMenu();

    await tester.tap(find.text('Copy'));
    await tester.pump();
    await tester.pump(_closing * 0.7);
    expect(taps, 0);

    await tester.pump(_closing * 0.1);
    expect(taps, 1);
    await tester.settleMenu();
  });

  testWidgets('with slower animations, the action waits for the closing', (
    tester,
  ) async {
    timeDilation = 5;
    // Reset before the test ends: the binding checks it before tear-downs.
    try {
      var taps = 0;
      await tester.pumpMenu(
        items: [
          SmartContextMenuItem.simple(title: 'Copy', onTap: () => taps++),
        ],
      );
      await tester.openMenu();
      await tester.settleMenu(frames: 20);

      await tester.tap(find.text('Copy'));
      await tester.pump();
      await tester.pump(_closing * 5 * 0.7);
      expect(taps, 0);

      await tester.pump(_closing * 5 * 0.1);
      expect(taps, 1);
      await tester.settleMenu(frames: 20);
    } finally {
      timeDilation = 1;
    }
  });

  testWidgets('onPreviewTap runs once the menu has closed', (tester) async {
    var taps = 0;
    await tester.pumpMenu(
      items: [SmartContextMenuItem.simple(title: 'Copy')],
      onPreviewTap: () => taps++,
    );
    await tester.openMenu();
    // The route ignores pointers until its transition ends.
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(RawImage).last);
    await tester.pump();
    await tester.pump(_closing * 0.9);
    expect(taps, 0);

    await tester.pump(_closing * 0.2);
    expect(taps, 1);
  });
}
