import 'package:flutter/widgets.dart' show IconData, TextAlign, Widget;

import '../core/ui/styles/smart_context_menu_defaults.dart';

/// The appearance of the loading, error and empty items, and of the
/// loading indicator of a submenu or page.
///
/// Set it as [SmartContextMenuStyle.statusStyle]. Status items also take
/// the colors, the text, the item padding and
/// [SmartContextMenuStyle.defaultIconSize] of the style.
///
/// ```dart
/// const style = SmartContextMenuStyle(
///   statusStyle: SmartContextMenuStatusStyle(
///     titleAlign: TextAlign.start,
///     errorIcon: CupertinoIcons.wifi_exclamationmark,
///   ),
/// );
/// ```
final class SmartContextMenuStatusStyle {
  /// The alignment of the titles of loading, error and empty items in the
  /// space between their leading and trailing.
  ///
  /// Does not affect their child. Defaults to
  /// [SmartContextMenuDefaults.statusTitleAlign], the middle.
  final TextAlign titleAlign;

  /// The icon after the title of a [SmartContextMenuItem.error] item
  /// without its own trailing.
  ///
  /// Defaults to [SmartContextMenuDefaults.errorIcon].
  final IconData errorIcon;

  /// The icon after the title of an error item that retries a failed load,
  /// unless the item has its own trailing.
  ///
  /// Defaults to [SmartContextMenuDefaults.retryIcon].
  final IconData retryIcon;

  /// The icon after the title of a [SmartContextMenuItem.empty] item
  /// without its own trailing.
  ///
  /// Defaults to [SmartContextMenuDefaults.emptyIcon].
  final IconData emptyIcon;

  /// The activity indicator of loading items without their own trailing,
  /// and of a loading submenu or page.
  ///
  /// The widget is used at its own size, so size it to fit an item row:
  ///
  /// ```dart
  /// const statusStyle = SmartContextMenuStatusStyle(
  ///   loadingIndicator: SizedBox.square(
  ///     dimension: 20,
  ///     child: CircularProgressIndicator(strokeWidth: 2),
  ///   ),
  /// );
  /// ```
  ///
  /// If null, which is the default, a [CupertinoActivityIndicator] is used:
  /// in loading items as large as [SmartContextMenuStyle.defaultIconSize],
  /// and in a submenu with [SmartContextMenuDefaults.loaderIndicatorRadius].
  final Widget? loadingIndicator;

  /// The vertical padding around the activity indicator of a loading
  /// submenu or page.
  ///
  /// Defaults to [SmartContextMenuDefaults.loaderVerticalPadding].
  final double loaderVerticalPadding;

  /// Creates a status item style.
  const SmartContextMenuStatusStyle({
    this.titleAlign = SmartContextMenuDefaults.statusTitleAlign,
    this.errorIcon = SmartContextMenuDefaults.errorIcon,
    this.retryIcon = SmartContextMenuDefaults.retryIcon,
    this.emptyIcon = SmartContextMenuDefaults.emptyIcon,
    this.loadingIndicator,
    this.loaderVerticalPadding = SmartContextMenuDefaults.loaderVerticalPadding,
  });

  /// Creates a copy of this style with the given fields replaced.
  ///
  /// Null arguments keep the current values, so [loadingIndicator] cannot be
  /// reset to null with it.
  SmartContextMenuStatusStyle copyWith({
    TextAlign? titleAlign,
    IconData? errorIcon,
    IconData? retryIcon,
    IconData? emptyIcon,
    Widget? loadingIndicator,
    double? loaderVerticalPadding,
  }) {
    return SmartContextMenuStatusStyle(
      titleAlign: titleAlign ?? this.titleAlign,
      errorIcon: errorIcon ?? this.errorIcon,
      retryIcon: retryIcon ?? this.retryIcon,
      emptyIcon: emptyIcon ?? this.emptyIcon,
      loadingIndicator: loadingIndicator ?? this.loadingIndicator,
      loaderVerticalPadding:
          loaderVerticalPadding ?? this.loaderVerticalPadding,
    );
  }
}
