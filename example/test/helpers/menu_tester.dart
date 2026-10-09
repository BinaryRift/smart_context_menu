import 'package:flutter_test/flutter_test.dart';

extension MenuTester on WidgetTester {
  /// Long-presses [target] and waits until its menu is open.
  Future<void> openMenu(Finder target) async {
    await longPress(target);
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
