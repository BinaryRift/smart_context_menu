part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuItem] that shows a state, such as loading, instead
/// of an action.
///
/// It does not respond to taps and is not dimmed. Its [title] is aligned
/// between [leading] and [trailing] by
/// [SmartContextMenuStyle.statusTitleAlign], in the middle by default. A sign
/// of the state is shown after [title] unless [trailing] is set.
///
/// See [SmartContextMenuLoadingItem], [SmartContextMenuErrorItem] and
/// [SmartContextMenuEmptyItem].
sealed class SmartContextMenuStatusItem extends SmartContextMenuItem
    implements SmartContextMenuListenableResult {
  /// The text of the item.
  ///
  /// If null, the label of the state from [SmartContextMenuLabels] is shown.
  final String? title;

  /// The style of [title].
  ///
  /// Defaults to [SmartContextMenuStyle.titleStyle].
  final TextStyle? titleStyle;

  /// A widget shown before [title], usually an [Icon].
  ///
  /// Text without its own style takes the style and the color of the title;
  /// icons without their own color take the title color.
  final Widget? leading;

  /// A widget shown after [title] instead of the sign of the state.
  ///
  /// Text without its own style takes the style and the color of the title;
  /// icons without their own color take the title color.
  final Widget? trailing;

  /// The content shown instead of [title], [leading] and [trailing].
  ///
  /// The item [padding] is still applied. Text and icons in it take
  /// the color of the item.
  final Widget? child;

  /// The padding around the item content.
  ///
  /// If null, [SmartContextMenuStyle.itemPadding] is used.
  final EdgeInsets? padding;

  /// The gap between [leading], [title] and [trailing].
  ///
  /// If null, [SmartContextMenuStyle.itemChildrenGap] is used.
  final double? childrenGap;

  const SmartContextMenuStatusItem._({
    required super.id,
    required this.title,
    required this.titleStyle,
    required this.leading,
    required this.trailing,
    required this.child,
    required this.padding,
    required this.childrenGap,
  }) : super._();
}

/// A [SmartContextMenuStatusItem] that shows a loading state.
///
/// Create it with [SmartContextMenuItem.loading].
final class SmartContextMenuLoadingItem extends SmartContextMenuStatusItem {
  const SmartContextMenuLoadingItem._({
    required super.id,
    required super.title,
    required super.titleStyle,
    required super.leading,
    required super.trailing,
    required super.child,
    required super.padding,
    required super.childrenGap,
  }) : super._();
}

/// A [SmartContextMenuStatusItem] that shows a failed load.
///
/// Create it with [SmartContextMenuItem.error].
final class SmartContextMenuErrorItem extends SmartContextMenuStatusItem {
  const SmartContextMenuErrorItem._({
    required super.id,
    required super.title,
    required super.titleStyle,
    required super.leading,
    required super.trailing,
    required super.child,
    required super.padding,
    required super.childrenGap,
  }) : super._();
}

/// A [SmartContextMenuStatusItem] that shows that there are no items.
///
/// Create it with [SmartContextMenuItem.empty].
final class SmartContextMenuEmptyItem extends SmartContextMenuStatusItem {
  const SmartContextMenuEmptyItem._({
    required super.id,
    required super.title,
    required super.titleStyle,
    required super.leading,
    required super.trailing,
    required super.child,
    required super.padding,
    required super.childrenGap,
  }) : super._();
}
