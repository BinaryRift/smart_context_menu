part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuItem] that is built by [builder] and built again each
/// time [listenable] notifies.
///
/// Create it with [SmartContextMenuItem.listenable].
final class SmartContextMenuListenableItem extends SmartContextMenuItem {
  /// Notifies when the item of [builder] should be built again.
  final Listenable listenable;

  /// Builds the item shown in place of this one.
  final SmartContextMenuListenableItemBuilder builder;

  const SmartContextMenuListenableItem._({
    required super.id,
    required this.listenable,
    required this.builder,
  }) : super._();
}
