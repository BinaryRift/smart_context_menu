part of '../smart_context_menu_item.dart';

/// A [SmartContextMenuItem] that the user acts on: it runs an action or
/// opens a submenu.
///
/// Holds the content and the look shared by [SmartContextMenuSimpleItem],
/// [SmartContextMenuSubmenuItem], [SmartContextMenuAsyncSubmenuItem] and
/// [SmartContextMenuPagingSubmenuItem].
sealed class SmartContextMenuContentItem extends SmartContextMenuItem
    implements SmartContextMenuAsyncResult {
  /// The text of the item.
  ///
  /// Shown in up to [SmartContextMenuStyle.titleMaxLines] lines and truncated
  /// with an ellipsis.
  final String? title;

  /// The style of [title].
  ///
  /// Defaults to [SmartContextMenuStyle.titleStyle]. Its color is used
  /// only while the item is enabled, not destructive and has no [tintColor].
  final TextStyle? titleStyle;

  /// A widget shown before [title], usually an [Icon].
  ///
  /// Icons without their own color take the title color.
  final Widget? leading;

  /// A widget shown after [title].
  ///
  /// Items that open a submenu also show a chevron after it.
  /// Icons without their own color take the title color.
  final Widget? trailing;

  /// Whether the item performs a destructive action.
  ///
  /// Destructive items are tinted with [SmartContextMenuStyle.destructiveColor]
  /// unless [tintColor] is set.
  final bool isDestructive;

  /// The color the item is tinted with, like a destructive item.
  ///
  /// The title and icons take this color, and the background takes
  /// a translucent shade of it. A disabled item has only the dimmed title
  /// and icons, see [SmartContextMenuStyle.disabledBackgroundColor]. Takes
  /// precedence over [SmartContextMenuStyle.destructiveColor] and the color
  /// of [titleStyle]. May be a [CupertinoDynamicColor] to follow the theme.
  final Color? tintColor;

  /// Whether the item is disabled.
  ///
  /// Disabled items are dimmed and do not respond to taps.
  final bool isDisabled;

  /// Builds the item content instead of [leading], [title] and [trailing].
  ///
  /// The item [padding] and press highlight are still applied, and taps
  /// are handled as usual. Interactive widgets inside, such as
  /// buttons, handle their own taps: the item is not triggered over them.
  final SmartContextMenuItemBuilder? customBuilder;

  /// The padding around the item content.
  ///
  /// If null, [SmartContextMenuStyle.itemPadding] is used.
  final EdgeInsets? padding;

  /// The gap between [leading], [title], [trailing] and the submenu chevron.
  ///
  /// If null, [SmartContextMenuStyle.itemChildrenGap] is used.
  final double? childrenGap;

  const SmartContextMenuContentItem._({
    required super.id,
    required this.title,
    required this.titleStyle,
    required this.leading,
    required this.trailing,
    required this.isDestructive,
    required this.tintColor,
    required this.isDisabled,
    required this.customBuilder,
    required this.padding,
    required this.childrenGap,
  }) : super._();
}
