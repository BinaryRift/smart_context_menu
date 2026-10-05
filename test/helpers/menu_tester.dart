import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

const String menuTargetText = 'Target';

extension MenuTester on WidgetTester {
  /// Pumps a [SmartContextMenu] with a text child centered on the screen.
  Future<void> pumpMenu({
    required List<SmartContextMenuItem> items,
    SmartContextMenuConfig config = const SmartContextMenuConfig(),
    SmartContextMenuController? controller,
  }) {
    return pumpWidget(
      CupertinoApp(
        home: Center(
          child: SmartContextMenu(
            items: items,
            config: config,
            controller: controller,
            child: const Text(menuTargetText),
          ),
        ),
      ),
    );
  }

  /// Long-presses [target] (the menu child by default) and waits
  /// until the menu is open.
  Future<void> openMenu([Finder? target]) async {
    await longPress(target ?? find.text(menuTargetText));
    await settleMenu();
  }

  /// Advances frames while letting real async work complete.
  ///
  /// Opening captures a snapshot via toImage(), which only completes
  /// in real time, so plain [pumpAndSettle] never sees the menu.
  Future<void> settleMenu({int frames = 5}) async {
    for (var i = 0; i < frames; i++) {
      await pump(const Duration(milliseconds: 100));
      await runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
    }
  }
}
