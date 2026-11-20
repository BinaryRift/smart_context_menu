import 'package:flutter/widgets.dart' show EdgeInsets, TextStyle;

import '../core/ui/styles/smart_context_menu_defaults.dart';

/// The appearance of the rows of a [SmartContextMenu], see
/// [SmartContextMenuItem.row].
///
/// Set it as [SmartContextMenuStyle.rowStyle]. The cells also take the
/// colors, [SmartContextMenuStyle.titleMaxLines] and the icons of the style,
/// and a row draws its separators and dividers with the separator and
/// divider fields of the style.
///
/// ```dart
/// const style = SmartContextMenuStyle(
///   rowStyle: SmartContextMenuRowStyle(
///     titleStyle: TextStyle(fontSize: 11),
///     childrenGap: 4,
///   ),
/// );
/// ```
final class SmartContextMenuRowStyle {
  /// The padding around the cells of a row without its own padding, see
  /// [SmartContextMenuRowItem.padding].
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsets padding;

  /// The gap between the cells of a row without its own gap, see
  /// [SmartContextMenuRowItem.childrenGap].
  ///
  /// The gap belongs to no cell: a finger over it removes the highlight.
  /// Defaults to 0.
  final double childrenGap;

  /// The padding around the content of the cells of a small row without
  /// their own padding, see [SmartContextMenuRowSize.small].
  ///
  /// The whole cell, padding included, is pressed and highlighted.
  /// Defaults to [SmartContextMenuDefaults.rowSmallItemPadding].
  final EdgeInsets smallItemPadding;

  /// The padding around the content of the cells of a medium row without
  /// their own padding, see [SmartContextMenuRowSize.medium].
  ///
  /// The whole cell, padding included, is pressed and highlighted.
  /// Defaults to [SmartContextMenuDefaults.rowMediumItemPadding].
  final EdgeInsets mediumItemPadding;

  /// The gap between the leading and the title of the cells of a medium row
  /// without their own gap.
  ///
  /// Defaults to [SmartContextMenuDefaults.rowItemChildrenGap].
  final double itemChildrenGap;

  /// The style of the titles of the cells, merged over the title style of
  /// their items or [SmartContextMenuStyle.titleStyle].
  ///
  /// Defaults to [SmartContextMenuDefaults.rowTitleStyle].
  final TextStyle titleStyle;

  /// The empty space above the vertical dividers between the cells, see
  /// [SmartContextMenuRowItem.dividersBetweenChildren].
  ///
  /// Defaults to 0.
  final double dividerIndent;

  /// The empty space below the vertical dividers between the cells, see
  /// [SmartContextMenuRowItem.dividersBetweenChildren].
  ///
  /// Defaults to 0.
  final double dividerEndIndent;

  /// Creates a row style.
  const SmartContextMenuRowStyle({
    this.padding = EdgeInsets.zero,
    this.childrenGap = 0,
    this.smallItemPadding = SmartContextMenuDefaults.rowSmallItemPadding,
    this.mediumItemPadding = SmartContextMenuDefaults.rowMediumItemPadding,
    this.itemChildrenGap = SmartContextMenuDefaults.rowItemChildrenGap,
    this.titleStyle = SmartContextMenuDefaults.rowTitleStyle,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
  });

  /// Creates a copy of this style with the given fields replaced.
  SmartContextMenuRowStyle copyWith({
    EdgeInsets? padding,
    double? childrenGap,
    EdgeInsets? smallItemPadding,
    EdgeInsets? mediumItemPadding,
    double? itemChildrenGap,
    TextStyle? titleStyle,
    double? dividerIndent,
    double? dividerEndIndent,
  }) {
    return SmartContextMenuRowStyle(
      padding: padding ?? this.padding,
      childrenGap: childrenGap ?? this.childrenGap,
      smallItemPadding: smallItemPadding ?? this.smallItemPadding,
      mediumItemPadding: mediumItemPadding ?? this.mediumItemPadding,
      itemChildrenGap: itemChildrenGap ?? this.itemChildrenGap,
      titleStyle: titleStyle ?? this.titleStyle,
      dividerIndent: dividerIndent ?? this.dividerIndent,
      dividerEndIndent: dividerEndIndent ?? this.dividerEndIndent,
    );
  }
}
