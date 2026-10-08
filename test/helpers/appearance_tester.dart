import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'menu_tester.dart';

/// A style where every color differs from the defaults.
const customStyle = SmartContextMenuStyle(
  titleStyle: TextStyle(
    fontFamily: 'Custom',
    fontSize: 13,
    color: Color(0xFF00FF00),
  ),
  disabledForegroundColor: Color(0xFF000002),
  destructiveColor: Color(0xFF000003),
  disabledBackgroundColor: Color(0xFF000004),
  dividerColor: Color(0xFF000005),
);

const customConfig = SmartContextMenuConfig(style: customStyle);

/// Enabled, disabled and destructive items.
List<SmartContextMenuItem> appearanceItems() => [
  SmartContextMenuItem.simple(title: 'Enabled'),
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
  Color? backgroundOf(String title) => backgroundAt(find.text(title));

  /// The background color of the item that contains [finder].
  Color? backgroundAt(Finder finder) {
    final container = widget<AnimatedContainer>(
      find.ancestor(of: finder, matching: find.byType(AnimatedContainer)).first,
    );
    return (container.decoration as BoxDecoration?)?.color;
  }

  /// The padding of the item with [title].
  EdgeInsetsGeometry? itemPaddingOf(String title) => widget<AnimatedContainer>(
    find
        .ancestor(
          of: find.text(title),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  ).padding;

  /// Puts a finger on [target] and moves it slightly, so the item
  /// under the finger is highlighted.
  Future<TestGesture> pressAt(Finder target) async {
    final gesture = await startGesture(getCenter(target));
    await pump();
    await gesture.moveBy(const Offset(2, 0));
    await pump();
    return gesture;
  }

  /// Lifts the finger outside the menu, so no item is tapped.
  Future<void> releaseOutside(TestGesture gesture) async {
    await gesture.moveTo(const Offset(1, 1));
    await pump();
    await gesture.up();
    await settleMenu();
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
