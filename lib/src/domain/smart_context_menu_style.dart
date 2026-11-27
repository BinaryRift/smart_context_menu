import 'package:flutter/widgets.dart'
    show
        BorderRadiusGeometry,
        BorderSide,
        BoxShadow,
        Color,
        Decoration,
        EdgeInsets,
        IconData,
        TextAlign,
        TextStyle,
        Widget;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_back_button_style.dart';
import 'smart_context_menu_blur.dart';
import 'smart_context_menu_glass_style.dart';
import 'smart_context_menu_row_style.dart';
import 'smart_context_menu_standard_style.dart';
import 'smart_context_menu_status_style.dart';
import 'smart_context_menu_surface.dart';

/// The appearance of a [SmartContextMenu]: colors, blurs, radii, text
/// and icons.
///
/// Set it as [SmartContextMenuConfig.style], in a [SmartContextMenuTheme]
/// or for one menu. Every field has a default, so set only what you need.
/// The back item, the status items and the rows have their own parts:
/// [backButtonStyle], [statusStyle] and [rowStyle].
///
/// Color fields may be [CupertinoDynamicColor]s, which are resolved for the
/// current theme brightness. A plain [Color] is used as is in both themes.
///
/// ```dart
/// const menuConfig = SmartContextMenuConfig(
///   style: SmartContextMenuStyle(
///     surface: SmartContextMenuSurface.standard,
///     standardStyle: SmartContextMenuStandardStyle(
///       blur: SmartContextMenuBlur.small,
///     ),
///     titleStyle: TextStyle(fontSize: 15, color: Color(0xFF1C1C1E)),
///   ),
/// );
/// ```
final class SmartContextMenuStyle {
  // Menu

  /// The surface of the menu. Defaults to [SmartContextMenuSurface.glass].
  ///
  /// The surface and its settings are taken from this style when the menu
  /// opens, whether this style is set on the menu or in [SmartContextMenuTheme].
  final SmartContextMenuSurface surface;

  /// The appearance of the Liquid Glass panel.
  final SmartContextMenuGlassStyle glassStyle;

  final SmartContextMenuStandardStyle? _standardStyle;
  final Color? _menuColor;
  final Color? _borderColor;
  final Decoration? _menuDecoration;
  final SmartContextMenuBlur? _menuBlur;

  /// The appearance of the standard panel, including during fallback.
  SmartContextMenuStandardStyle get standardStyle =>
      _standardStyle ??
      SmartContextMenuStandardStyle(
        color: _menuColor ?? SmartContextMenuDefaults.menuColor,
        border: BorderSide(
          color: _borderColor ?? SmartContextMenuDefaults.borderColor,
        ),
        decoration: _menuDecoration,
        blur: _menuBlur,
      );

  /// The standard panel color. See [SmartContextMenuStandardStyle.color].
  @Deprecated('Use standardStyle.color instead.')
  Color get menuColor => standardStyle.color;

  /// The standard panel border color. See [SmartContextMenuStandardStyle.border].
  @Deprecated('Use standardStyle.border.color instead.')
  Color get borderColor => standardStyle.border.color;

  /// The corner radius of the menu.
  ///
  /// Applied to the built-in surfaces, their borders, [menuShadows] and the
  /// local blur. A custom [SmartContextMenuStandardStyle.decoration] defines
  /// the clip for the Standard panel contents.
  /// Liquid Glass takes the smaller component of each elliptical radius
  /// and caps each corner at half the shorter side of the panel.
  /// Defaults to [SmartContextMenuDefaults.borderRadius].
  final BorderRadiusGeometry borderRadius;

  /// The custom Standard decoration. See [SmartContextMenuStandardStyle.decoration].
  @Deprecated('Use standardStyle.decoration instead.')
  Decoration? get menuDecoration => standardStyle.decoration;

  /// The local blur for Standard. See [SmartContextMenuStandardStyle.blur].
  @Deprecated('Use standardStyle.blur instead.')
  SmartContextMenuBlur? get menuBlur => standardStyle.blur;

  /// The shadows under the menu.
  ///
  /// Drawn with a custom [SmartContextMenuStandardStyle.decoration] too.
  /// Pass an empty list to remove them. Defaults to
  /// [SmartContextMenuDefaults.menuShadows].
  final List<BoxShadow> menuShadows;

  // Background

  /// The color that dims the screen behind the menu.
  ///
  /// Defaults to [SmartContextMenuDefaults.backgroundColor].
  final Color backgroundColor;

  /// The blur of the screen behind the menu.
  ///
  /// Defaults to null. Set a blur to apply it in addition to [backgroundColor].
  final SmartContextMenuBlur? backgroundBlur;

  // Back item

  /// The appearance of the back item pinned to the top of a submenu.
  ///
  /// If none is given, it is built from the deprecated back item fields,
  /// such as `backButtonBlur`, which default to the defaults of
  /// [SmartContextMenuBackButtonStyle].
  SmartContextMenuBackButtonStyle get backButtonStyle =>
      _backButtonStyle ??
      SmartContextMenuBackButtonStyle(
        blur: _backButtonBlur,
        borderRadius: _backButtonBorderRadius,
        foregroundColor: _backButtonColor,
        titleStyle: _backButtonTitleStyle,
        icon: _backIcon,
      );
  final SmartContextMenuBackButtonStyle? _backButtonStyle;
  final SmartContextMenuBlur? _backButtonBlur;
  final BorderRadiusGeometry _backButtonBorderRadius;
  final Color? _backButtonColor;
  final TextStyle _backButtonTitleStyle;
  final IconData _backIcon;

  /// The former place of [SmartContextMenuBackButtonStyle.blur].
  @Deprecated('Use backButtonStyle.blur instead.')
  SmartContextMenuBlur? get backButtonBlur => backButtonStyle.blur;

  /// The former place of [SmartContextMenuBackButtonStyle.borderRadius].
  @Deprecated('Use backButtonStyle.borderRadius instead.')
  BorderRadiusGeometry get backButtonBorderRadius =>
      backButtonStyle.borderRadius;

  /// The former place of [SmartContextMenuBackButtonStyle.foregroundColor].
  @Deprecated('Use backButtonStyle.foregroundColor instead.')
  Color? get backButtonColor => backButtonStyle.foregroundColor;

  /// The former place of [SmartContextMenuBackButtonStyle.titleStyle].
  @Deprecated('Use backButtonStyle.titleStyle instead.')
  TextStyle get backButtonTitleStyle => backButtonStyle.titleStyle;

  /// The former place of [SmartContextMenuBackButtonStyle.icon].
  @Deprecated('Use backButtonStyle.icon instead.')
  IconData get backIcon => backButtonStyle.icon;

  // Items

  /// The padding around the content of items without their own padding,
  /// see [SmartContextMenuContentItem.padding] and
  /// [SmartContextMenuStatusItem.padding].
  ///
  /// Also used by the back and retry items.
  /// Defaults to [SmartContextMenuDefaults.itemPadding].
  final EdgeInsets itemPadding;

  /// The gap between the parts of items without their own gap, see
  /// [SmartContextMenuContentItem.childrenGap] and
  /// [SmartContextMenuStatusItem.childrenGap].
  ///
  /// Also used by the back and retry items.
  /// Defaults to [SmartContextMenuDefaults.itemChildrenGap].
  final double itemChildrenGap;

  /// The base style of item titles.
  ///
  /// Used for items without their own title style, see
  /// [SmartContextMenuContentItem.titleStyle], and for the
  /// retry and loading items. The back item merges
  /// [SmartContextMenuBackButtonStyle.titleStyle] over it. Its color is used only while an item is
  /// enabled, not destructive and has no
  /// [SmartContextMenuContentItem.tintColor],
  /// and also tints the press highlight unless [highlightColor] is set.
  /// If the style has no color, [SmartContextMenuDefaults.foregroundColor] is used.
  /// Defaults to [SmartContextMenuDefaults.titleStyle].
  final TextStyle titleStyle;

  /// The maximum number of lines of an item title.
  ///
  /// Longer titles are truncated with an ellipsis.
  /// Defaults to [SmartContextMenuDefaults.titleMaxLines].
  final int titleMaxLines;

  /// The color of the title, icons and submenu chevron of a disabled item.
  ///
  /// Defaults to [SmartContextMenuDefaults.disabledForegroundColor].
  final Color disabledForegroundColor;

  /// The color of the title, icons and background tint of a destructive
  /// item.
  ///
  /// [SmartContextMenuContentItem.tintColor] takes precedence over it.
  /// Defaults to [SmartContextMenuDefaults.destructiveColor].
  final Color destructiveColor;

  /// The background of a disabled item, including a tinted one.
  ///
  /// If null, which is the default, disabled items have no background.
  final Color? disabledBackgroundColor;

  /// The background of a hovered or pressed item, including the back item.
  ///
  /// [SmartContextMenuBackButtonStyle.highlightColor] takes precedence
  /// for the back item.
  ///
  /// Tinted and destructive items keep their own highlight tint. If null,
  /// which is the default, the highlight uses the color of [titleStyle]. In the
  /// dark theme it uses [SmartContextMenuDefaults.darkHoverHighlightOpacity]
  /// while hovered and [SmartContextMenuDefaults.darkHighlightOpacity] while
  /// pressed. In the light theme it uses
  /// [SmartContextMenuDefaults.highlightOpacity] for both states and
  /// [SmartContextMenuDefaults.backHighlightOpacity] for the back item.
  final Color? highlightColor;

  /// The color of the dividers, see [dividersBetweenItems].
  ///
  /// Defaults to [SmartContextMenuDefaults.dividerColor].
  final Color dividerColor;

  /// The thickness of the divider, which is also the space it takes.
  ///
  /// Defaults to [SmartContextMenuDefaults.dividerThickness].
  final double dividerThickness;

  /// The empty space before the divider, on the left in left-to-right text.
  ///
  /// Defaults to 0.
  final double dividerIndent;

  /// The empty space after the divider, on the right in left-to-right text.
  ///
  /// Defaults to 0.
  final double dividerEndIndent;

  /// Whether to draw a divider between every two adjacent items, as in iOS.
  ///
  /// No divider is drawn next to a [SmartContextMenuItem.separator]. The back
  /// item of a submenu always has a divider below it. Defaults to false.
  final bool dividersBetweenItems;

  /// The thickness of a [SmartContextMenuItem.separator] without a child:
  /// its height in a menu level, its width in a [SmartContextMenuItem.row].
  ///
  /// Defaults to [SmartContextMenuDefaults.separatorThickness].
  final double separatorThickness;

  /// The former name of [separatorThickness].
  @Deprecated('Use separatorThickness instead.')
  double get separatorHeight => separatorThickness;

  /// The color of a [SmartContextMenuItem.separator] without a child.
  ///
  /// Defaults to [SmartContextMenuDefaults.separatorColor].
  final Color separatorColor;

  // Rows

  /// The appearance of the rows, see [SmartContextMenuItem.row].
  ///
  /// Defaults to a [SmartContextMenuRowStyle] with its defaults.
  SmartContextMenuRowStyle get rowStyle =>
      _rowStyle ?? const SmartContextMenuRowStyle();
  final SmartContextMenuRowStyle? _rowStyle;

  // Status items

  /// The appearance of the loading, error and empty items, and of the
  /// loading indicator of a submenu or page.
  ///
  /// If none is given, it is built from the deprecated status fields, such
  /// as `errorIcon`, which default to the defaults of
  /// [SmartContextMenuStatusStyle].
  SmartContextMenuStatusStyle get statusStyle =>
      _statusStyle ??
      SmartContextMenuStatusStyle(
        titleAlign: _statusTitleAlign,
        errorIcon: _errorIcon,
        retryIcon: _retryIcon,
        emptyIcon: _emptyIcon,
        loadingIndicator: _loadingIndicator,
        loaderVerticalPadding: _loaderVerticalPadding,
      );
  final SmartContextMenuStatusStyle? _statusStyle;
  final TextAlign _statusTitleAlign;
  final IconData _errorIcon;
  final IconData _retryIcon;
  final IconData _emptyIcon;
  final Widget? _loadingIndicator;
  final double _loaderVerticalPadding;

  /// The former place of [SmartContextMenuStatusStyle.titleAlign].
  @Deprecated('Use statusStyle.titleAlign instead.')
  TextAlign get statusTitleAlign => statusStyle.titleAlign;

  /// The former place of [SmartContextMenuStatusStyle.errorIcon].
  @Deprecated('Use statusStyle.errorIcon instead.')
  IconData get errorIcon => statusStyle.errorIcon;

  /// The former place of [SmartContextMenuStatusStyle.retryIcon].
  @Deprecated('Use statusStyle.retryIcon instead.')
  IconData get retryIcon => statusStyle.retryIcon;

  /// The former place of [SmartContextMenuStatusStyle.emptyIcon].
  @Deprecated('Use statusStyle.emptyIcon instead.')
  IconData get emptyIcon => statusStyle.emptyIcon;

  /// The former place of [SmartContextMenuStatusStyle.loadingIndicator].
  @Deprecated('Use statusStyle.loadingIndicator instead.')
  Widget? get loadingIndicator => statusStyle.loadingIndicator;

  /// The former place of
  /// [SmartContextMenuStatusStyle.loaderVerticalPadding].
  @Deprecated('Use statusStyle.loaderVerticalPadding instead.')
  double get loaderVerticalPadding => statusStyle.loaderVerticalPadding;

  // Icons

  /// The size of the icons drawn by the menu itself: the submenu chevron,
  /// the back icon, the error, retry and empty icons, and the activity
  /// indicator of loading items.
  ///
  /// Does not affect the leading and trailing widgets of items, such as
  /// [SmartContextMenuContentItem.leading].
  /// Defaults to [SmartContextMenuDefaults.iconSize].
  final double defaultIconSize;

  /// The color of the submenu chevron and the back icon.
  ///
  /// [SmartContextMenuBackButtonStyle.foregroundColor] takes precedence for
  /// the back icon. If null,
  /// the icons take the title color of their item.
  final Color? defaultIconColor;

  /// The chevron of an item that opens a submenu.
  ///
  /// Defaults to [SmartContextMenuDefaults.submenuIcon].
  final IconData submenuIcon;

  /// Creates a menu style.
  ///
  /// Set [standardStyle] to customize the Standard panel. The deprecated
  /// Standard fields, such as [menuColor], can be used in place of the group.
  ///
  /// Set the back item with [backButtonStyle] or with the deprecated back
  /// item fields, such as [backButtonBlur], not both; the same goes for
  /// [statusStyle] and the deprecated status fields. With a group, the
  /// deprecated fields would be ignored, so a debug assert fails.
  const SmartContextMenuStyle({
    this.surface = SmartContextMenuSurface.glass,
    this.glassStyle = const SmartContextMenuGlassStyle(),
    SmartContextMenuStandardStyle? standardStyle,
    @Deprecated('Use standardStyle.color instead.') Color? menuColor,
    @Deprecated('Use standardStyle.border with a BorderSide instead.')
    Color? borderColor,
    this.borderRadius = SmartContextMenuDefaults.borderRadius,
    @Deprecated('Use standardStyle.decoration instead.')
    Decoration? menuDecoration,
    @Deprecated('Use standardStyle.blur instead.')
    SmartContextMenuBlur? menuBlur,
    this.menuShadows = SmartContextMenuDefaults.menuShadows,
    this.backgroundColor = SmartContextMenuDefaults.backgroundColor,
    this.backgroundBlur,
    SmartContextMenuBackButtonStyle? backButtonStyle,
    @Deprecated('Use backButtonStyle.blur instead.')
    SmartContextMenuBlur? backButtonBlur = SmartContextMenuBlur.strong,
    @Deprecated('Use backButtonStyle.borderRadius instead.')
    BorderRadiusGeometry backButtonBorderRadius =
        SmartContextMenuDefaults.backButtonBorderRadius,
    @Deprecated('Use backButtonStyle.foregroundColor instead.')
    Color? backButtonColor,
    @Deprecated('Use backButtonStyle.titleStyle instead.')
    TextStyle backButtonTitleStyle =
        SmartContextMenuDefaults.backButtonTitleStyle,
    @Deprecated('Use backButtonStyle.icon instead.')
    IconData backIcon = SmartContextMenuDefaults.backIcon,
    this.itemPadding = SmartContextMenuDefaults.itemPadding,
    this.itemChildrenGap = SmartContextMenuDefaults.itemChildrenGap,
    this.titleStyle = SmartContextMenuDefaults.titleStyle,
    this.titleMaxLines = SmartContextMenuDefaults.titleMaxLines,
    this.disabledForegroundColor =
        SmartContextMenuDefaults.disabledForegroundColor,
    this.destructiveColor = SmartContextMenuDefaults.destructiveColor,
    this.disabledBackgroundColor,
    this.highlightColor,
    this.dividerColor = SmartContextMenuDefaults.dividerColor,
    this.dividerThickness = SmartContextMenuDefaults.dividerThickness,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
    this.dividersBetweenItems = false,
    double? separatorThickness,
    @Deprecated('Use separatorThickness instead.') double? separatorHeight,
    this.separatorColor = SmartContextMenuDefaults.separatorColor,
    SmartContextMenuRowStyle? rowStyle,
    SmartContextMenuStatusStyle? statusStyle,
    @Deprecated('Use statusStyle.titleAlign instead.')
    TextAlign statusTitleAlign = SmartContextMenuDefaults.statusTitleAlign,
    @Deprecated('Use statusStyle.errorIcon instead.')
    IconData errorIcon = SmartContextMenuDefaults.errorIcon,
    @Deprecated('Use statusStyle.retryIcon instead.')
    IconData retryIcon = SmartContextMenuDefaults.retryIcon,
    @Deprecated('Use statusStyle.emptyIcon instead.')
    IconData emptyIcon = SmartContextMenuDefaults.emptyIcon,
    @Deprecated('Use statusStyle.loadingIndicator instead.')
    Widget? loadingIndicator,
    @Deprecated('Use statusStyle.loaderVerticalPadding instead.')
    double loaderVerticalPadding =
        SmartContextMenuDefaults.loaderVerticalPadding,
    this.defaultIconSize = SmartContextMenuDefaults.iconSize,
    this.defaultIconColor,
    this.submenuIcon = SmartContextMenuDefaults.submenuIcon,
  }) : assert(
         standardStyle == null ||
             (menuColor == null &&
                 borderColor == null &&
                 menuDecoration == null &&
                 menuBlur == null),
         'Set either standardStyle or the deprecated Standard fields, '
         'such as menuColor, not both.',
       ),
       assert(
         backButtonStyle == null ||
             (identical(backButtonBlur, SmartContextMenuBlur.strong) &&
                 identical(
                   backButtonBorderRadius,
                   SmartContextMenuDefaults.backButtonBorderRadius,
                 ) &&
                 backButtonColor == null &&
                 identical(
                   backButtonTitleStyle,
                   SmartContextMenuDefaults.backButtonTitleStyle,
                 ) &&
                 identical(backIcon, SmartContextMenuDefaults.backIcon)),
         'Set the back item either with backButtonStyle or with the '
         'deprecated fields, such as backButtonBlur, not both.',
       ),
       assert(
         statusStyle == null ||
             (identical(
                   statusTitleAlign,
                   SmartContextMenuDefaults.statusTitleAlign,
                 ) &&
                 identical(errorIcon, SmartContextMenuDefaults.errorIcon) &&
                 identical(retryIcon, SmartContextMenuDefaults.retryIcon) &&
                 identical(emptyIcon, SmartContextMenuDefaults.emptyIcon) &&
                 loadingIndicator == null &&
                 identical(
                   loaderVerticalPadding,
                   SmartContextMenuDefaults.loaderVerticalPadding,
                 )),
         'Set the status items either with statusStyle or with the '
         'deprecated fields, such as errorIcon, not both.',
       ),
       _standardStyle = standardStyle,
       _menuColor = menuColor,
       _borderColor = borderColor,
       _menuDecoration = menuDecoration,
       _menuBlur = menuBlur,
       _backButtonStyle = backButtonStyle,
       _backButtonBlur = backButtonBlur,
       _backButtonBorderRadius = backButtonBorderRadius,
       _backButtonColor = backButtonColor,
       _backButtonTitleStyle = backButtonTitleStyle,
       _backIcon = backIcon,
       separatorThickness =
           separatorThickness ??
           separatorHeight ??
           SmartContextMenuDefaults.separatorThickness,
       _rowStyle = rowStyle,
       _statusStyle = statusStyle,
       _statusTitleAlign = statusTitleAlign,
       _errorIcon = errorIcon,
       _retryIcon = retryIcon,
       _emptyIcon = emptyIcon,
       _loadingIndicator = loadingIndicator,
       _loaderVerticalPadding = loaderVerticalPadding;

  /// Creates a copy of this style with the given fields replaced.
  ///
  /// Changing [surface] keeps both surface styles. Pass a new [standardStyle]
  /// to replace the group or use [SmartContextMenuStandardStyle.copyWith] to
  /// update specific settings. The deprecated Standard arguments can still
  /// update individual settings when [standardStyle] is omitted.
  ///
  /// Null arguments keep the current values. The deprecated back item
  /// and status fields replace the fields of [backButtonStyle] and
  /// [statusStyle]; pass either a group or its deprecated fields.
  SmartContextMenuStyle copyWith({
    SmartContextMenuSurface? surface,
    SmartContextMenuGlassStyle? glassStyle,
    SmartContextMenuStandardStyle? standardStyle,
    @Deprecated('Use standardStyle.color instead.') Color? menuColor,
    @Deprecated('Use standardStyle.border with a BorderSide instead.')
    Color? borderColor,
    BorderRadiusGeometry? borderRadius,
    @Deprecated('Use standardStyle.decoration instead.')
    Decoration? menuDecoration,
    @Deprecated('Use standardStyle.blur instead.')
    SmartContextMenuBlur? menuBlur,
    List<BoxShadow>? menuShadows,
    Color? backgroundColor,
    SmartContextMenuBlur? backgroundBlur,
    SmartContextMenuBackButtonStyle? backButtonStyle,
    @Deprecated('Use backButtonStyle.blur instead.')
    SmartContextMenuBlur? backButtonBlur,
    @Deprecated('Use backButtonStyle.borderRadius instead.')
    BorderRadiusGeometry? backButtonBorderRadius,
    @Deprecated('Use backButtonStyle.foregroundColor instead.')
    Color? backButtonColor,
    @Deprecated('Use backButtonStyle.titleStyle instead.')
    TextStyle? backButtonTitleStyle,
    @Deprecated('Use backButtonStyle.icon instead.') IconData? backIcon,
    EdgeInsets? itemPadding,
    double? itemChildrenGap,
    TextStyle? titleStyle,
    int? titleMaxLines,
    Color? disabledForegroundColor,
    Color? destructiveColor,
    Color? disabledBackgroundColor,
    Color? highlightColor,
    Color? dividerColor,
    double? dividerThickness,
    double? dividerIndent,
    double? dividerEndIndent,
    bool? dividersBetweenItems,
    double? separatorThickness,
    @Deprecated('Use separatorThickness instead.') double? separatorHeight,
    Color? separatorColor,
    SmartContextMenuRowStyle? rowStyle,
    SmartContextMenuStatusStyle? statusStyle,
    @Deprecated('Use statusStyle.titleAlign instead.')
    TextAlign? statusTitleAlign,
    @Deprecated('Use statusStyle.errorIcon instead.') IconData? errorIcon,
    @Deprecated('Use statusStyle.retryIcon instead.') IconData? retryIcon,
    @Deprecated('Use statusStyle.emptyIcon instead.') IconData? emptyIcon,
    @Deprecated('Use statusStyle.loadingIndicator instead.')
    Widget? loadingIndicator,
    @Deprecated('Use statusStyle.loaderVerticalPadding instead.')
    double? loaderVerticalPadding,
    double? defaultIconSize,
    Color? defaultIconColor,
    IconData? submenuIcon,
  }) {
    assert(
      backButtonStyle == null ||
          (backButtonBlur == null &&
              backButtonBorderRadius == null &&
              backButtonColor == null &&
              backButtonTitleStyle == null &&
              backIcon == null),
      'Pass either backButtonStyle or the deprecated back item fields, '
      'such as backButtonBlur, not both.',
    );
    assert(
      statusStyle == null ||
          (statusTitleAlign == null &&
              errorIcon == null &&
              retryIcon == null &&
              emptyIcon == null &&
              loadingIndicator == null &&
              loaderVerticalPadding == null),
      'Pass either statusStyle or the deprecated status fields, such as '
      'errorIcon, not both.',
    );
    assert(
      standardStyle == null ||
          (menuColor == null &&
              borderColor == null &&
              menuDecoration == null &&
              menuBlur == null),
      'Pass either standardStyle or the deprecated Standard fields, '
      'such as menuColor, not both.',
    );
    final currentStandard = this.standardStyle;
    if (menuColor != null ||
        borderColor != null ||
        menuDecoration != null ||
        menuBlur != null) {
      standardStyle ??= currentStandard.copyWith(
        color: menuColor,
        border: borderColor == null
            ? null
            : currentStandard.border.copyWith(color: borderColor),
        decoration: menuDecoration,
        blur: menuBlur,
      );
    }
    return SmartContextMenuStyle(
      surface: surface ?? this.surface,
      glassStyle: glassStyle ?? this.glassStyle,
      standardStyle: standardStyle ?? currentStandard,
      borderRadius: borderRadius ?? this.borderRadius,
      menuShadows: menuShadows ?? this.menuShadows,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      backButtonStyle:
          backButtonStyle ??
          this.backButtonStyle.copyWith(
            blur: backButtonBlur,
            borderRadius: backButtonBorderRadius,
            foregroundColor: backButtonColor,
            titleStyle: backButtonTitleStyle,
            icon: backIcon,
          ),
      itemPadding: itemPadding ?? this.itemPadding,
      itemChildrenGap: itemChildrenGap ?? this.itemChildrenGap,
      titleStyle: titleStyle ?? this.titleStyle,
      titleMaxLines: titleMaxLines ?? this.titleMaxLines,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      destructiveColor: destructiveColor ?? this.destructiveColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      highlightColor: highlightColor ?? this.highlightColor,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      dividerIndent: dividerIndent ?? this.dividerIndent,
      dividerEndIndent: dividerEndIndent ?? this.dividerEndIndent,
      dividersBetweenItems: dividersBetweenItems ?? this.dividersBetweenItems,
      separatorThickness:
          separatorThickness ?? separatorHeight ?? this.separatorThickness,
      separatorColor: separatorColor ?? this.separatorColor,
      rowStyle: rowStyle ?? this.rowStyle,
      statusStyle:
          statusStyle ??
          this.statusStyle.copyWith(
            titleAlign: statusTitleAlign,
            errorIcon: errorIcon,
            retryIcon: retryIcon,
            emptyIcon: emptyIcon,
            loadingIndicator: loadingIndicator,
            loaderVerticalPadding: loaderVerticalPadding,
          ),
      defaultIconSize: defaultIconSize ?? this.defaultIconSize,
      defaultIconColor: defaultIconColor ?? this.defaultIconColor,
      submenuIcon: submenuIcon ?? this.submenuIcon,
    );
  }
}
