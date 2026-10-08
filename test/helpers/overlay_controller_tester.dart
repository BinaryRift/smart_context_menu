import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/controllers/smart_context_menu_overlay_controller.dart';
import 'package:smart_context_menu/src/domain/smart_context_menu_navigator.dart';

/// Counts the menu dismissals instead of closing a route.
final class FakeMenuNavigator implements SmartContextMenuNavigator {
  int dismissals = 0;

  @override
  Future<void> dismissWithDelay() async => dismissals++;
}

/// An overlay controller with [items] on the root level and haptics off.
SmartContextMenuOverlayController overlayController(
  List<SmartContextMenuItem> items, {
  FakeMenuNavigator? navigator,
}) {
  // Loads apply their results only while the controller has listeners.
  return SmartContextMenuOverlayController(
    navigator: navigator ?? FakeMenuNavigator(),
    initialItems: items,
    enableHaptics: false,
  )..addListener(() {});
}

List<String?> itemTitles(List<SmartContextMenuItem> items) => [
  for (final item in items) item.title,
];
