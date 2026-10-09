part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuContentItem] that opens a submenu with [children].
///
/// Create it with [SmartContextMenuItem.submenu].
final class SmartContextMenuSubmenuItem extends SmartContextMenuContentItem {
  /// The items of the submenu opened by this item.
  final List<SmartContextMenuItem> children;

  const SmartContextMenuSubmenuItem._({
    required super.id,
    required super.title,
    required super.titleStyle,
    required super.leading,
    required super.trailing,
    required super.isDestructive,
    required super.tintColor,
    required super.isDisabled,
    required super.customBuilder,
    required super.padding,
    required super.childrenGap,
    required this.children,
  }) : super._();
}
