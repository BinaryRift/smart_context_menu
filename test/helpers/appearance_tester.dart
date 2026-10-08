import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'menu_tester.dart';

/// A style where every color differs from the defaults.
const customStyle = SmartContextMenuStyle(
  textStyle: TextStyle(
    fontFamily: 'Custom',
    fontSize: 13,
    color: Color(0xFF00FF00),
  ),
  secondaryTextColor: Color(0xFF000002),
  destructiveColor: Color(0xFF000003),
  disabledItemColor: Color(0xFF000004),
  dividerColor: Color(0xFF000005),
);

const customConfig = SmartContextMenuConfig(style: customStyle);

/// Enabled (with a divider), disabled and destructive items.
List<SmartContextMenuItem> appearanceItems() => [
  SmartContextMenuItem.simple(title: 'Enabled', hasDivider: true),
  SmartContextMenuItem.simple(title: 'Disabled', isDisabled: true),
  SmartContextMenuItem.simple(title: 'Destructive', isDestructive: true),
];

/// A submenu item titled 'More' with one child.
List<SmartContextMenuItem> submenuItems() => [
  SmartContextMenuItem.submenu(
    title: 'More',
    children: [SmartContextMenuItem.simple(title: 'Child')],
  ),
];

/// The light variant of a dynamic color.
Color light(CupertinoDynamicColor color) => color.color;

extension AppearanceTester on WidgetTester {
  TextStyle titleStyleOf(String title) =>
      widget<Text>(find.text(title).first).style!;

  /// The background color of the item with [title].
  Color? backgroundOf(String title) {
    final container = widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text(title),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    return (container.decoration as BoxDecoration?)?.color;
  }

  Color? iconColorOf(IconData icon) =>
      IconTheme.of(element(find.byIcon(icon).first)).color;

  /// Opens the menu and the 'More' submenu of [submenuItems].
  Future<void> openSubmenu() async {
    await openMenu();
    await tap(find.text('More'));
    await settleMenu();
  }
}
