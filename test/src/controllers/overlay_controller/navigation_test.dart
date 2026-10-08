import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/overlay_controller_tester.dart';

void main() {
  test('previousLevel is null on the root and the parent in a submenu', () {
    final submenu = SmartContextMenuItem.submenu(
      title: 'More',
      children: [SmartContextMenuItem.simple(title: 'Child')],
    );
    final controller = overlayController([submenu]);
    final root = controller.currentLevel;
    expect(controller.previousLevel, isNull);

    controller.handleItemTap(submenu);
    expect(controller.previousLevel, same(root));

    controller.popSubmenu();
    expect(controller.previousLevel, isNull);
  });

  test('popSubmenu on the root level does nothing', () {
    var notifications = 0;
    final controller = overlayController([
      SmartContextMenuItem.simple(title: 'Edit'),
    ])..addListener(() => notifications++);
    final root = controller.currentLevel;

    controller.popSubmenu();

    expect(controller.stackLength, 1);
    expect(controller.currentLevel, same(root));
    expect(notifications, 0);
  });
}
