import 'package:flutter/widgets.dart'
    show
        BorderRadiusGeometry,
        BoxDecoration,
        Color,
        Decoration,
        IconData,
        ShapeDecoration,
        TextStyle;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_blur.dart';

/// The appearance of the back item pinned to the top of a submenu.
///
/// Set it as [SmartContextMenuStyle.backButtonStyle]. The back item also
/// takes [SmartContextMenuStyle.titleStyle], the item padding, the press
/// highlight and [SmartContextMenuStyle.defaultIconSize] of the style, and
/// always has a divider below it.
///
/// ```dart
/// const style = SmartContextMenuStyle(
///   backButtonStyle: SmartContextMenuBackButtonStyle(
///     foregroundColor: Color(0xFF0A84FF),
///     blur: SmartContextMenuBlur.extraStrong,
///   ),
/// );
/// ```
final class SmartContextMenuBackButtonStyle {
  /// The background decoration of the back item.
  ///
  /// Replaces its default background from [SmartContextMenuStyle.menuColor]
  /// and [borderRadius]. The decoration determines the clip of both the back
  /// item and [blur]. It must support [Decoration.getClipPath] for clipping;
  /// [BoxDecoration] and [ShapeDecoration] do. Use a transparent decoration
  /// to show the blurred scrolling items underneath without painting a
  /// background. If null, the default background is used.
  final Decoration? decoration;

  /// The blur behind the back item.
  ///
  /// Visible when submenu items scroll under the back item. If null,
  /// they are not blurred. Defaults to [SmartContextMenuBlur.strong].
  final SmartContextMenuBlur? blur;

  /// The corner radius of the back item.
  ///
  /// Ignored when [decoration] is set; that decoration determines the clip
  /// instead. Defaults to [SmartContextMenuDefaults.backButtonBorderRadius].
  final BorderRadiusGeometry borderRadius;

  /// The title and icon color of the back item.
  ///
  /// If null, the title uses [titleStyle] over
  /// [SmartContextMenuStyle.titleStyle], and the icon uses
  /// [SmartContextMenuStyle.defaultIconColor].
  final Color? foregroundColor;

  /// The style of the back item title, merged over
  /// [SmartContextMenuStyle.titleStyle].
  ///
  /// [foregroundColor] takes precedence over its color.
  /// Defaults to [SmartContextMenuDefaults.backButtonTitleStyle].
  final TextStyle titleStyle;

  /// The icon of the back item.
  ///
  /// Defaults to [SmartContextMenuDefaults.backIcon], which points the other
  /// way in right-to-left text.
  final IconData icon;

  /// Creates a back item style.
  const SmartContextMenuBackButtonStyle({
    this.decoration,
    this.blur = SmartContextMenuBlur.strong,
    this.borderRadius = SmartContextMenuDefaults.backButtonBorderRadius,
    this.foregroundColor,
    this.titleStyle = SmartContextMenuDefaults.backButtonTitleStyle,
    this.icon = SmartContextMenuDefaults.backIcon,
  });

  /// Creates a copy of this style with the given fields replaced.
  ///
  /// Null arguments keep the current values, so nullable fields such as
  /// [blur] cannot be reset to null with it.
  SmartContextMenuBackButtonStyle copyWith({
    Decoration? decoration,
    SmartContextMenuBlur? blur,
    BorderRadiusGeometry? borderRadius,
    Color? foregroundColor,
    TextStyle? titleStyle,
    IconData? icon,
  }) {
    return SmartContextMenuBackButtonStyle(
      decoration: decoration ?? this.decoration,
      blur: blur ?? this.blur,
      borderRadius: borderRadius ?? this.borderRadius,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      titleStyle: titleStyle ?? this.titleStyle,
      icon: icon ?? this.icon,
    );
  }
}
