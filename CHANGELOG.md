## 1.2.0 (unreleased)

* `SmartContextMenuStyle.surface` selects the surface of the menu. The default,
  `SmartContextMenuSurface.glass`, blurs and refracts the backdrop inside the menu on Impeller
  renderers with shader filter support. The default glass blur uses a sigma of 2 in light mode
  and 1.8 in dark mode. Set `SmartContextMenuGlassStyle.blur` to `SmartContextMenuBlur.none`
  to turn off the glass blur.
  When the shader is unavailable or `MediaQuery.highContrast` is
  enabled at the anchor, the menu opens as `SmartContextMenuSurface.standard`.
* Configure the two surfaces independently with `glassStyle` and `standardStyle`. Both have
  `color`, `border` and `blur`. Set a `BorderSide` to control the border color, width and
  stroke alignment. `standardStyle.decoration` replaces the built-in standard finish.
* Tune the glass rim reflection, refracting bevel and direction of the light with
  `glassStyle.rimWidth`, `glassStyle.bevelWidth` and `glassStyle.lightDirection`.
* Deprecate `SmartContextMenuStyle.menuColor`, `borderColor`, `menuDecoration` and `menuBlur`
  in favor of `standardStyle`. The getters and arguments still configure or expose Standard,
  including during fallback.
* Default dark glass uses a more transparent tint and a softer edge highlight.
  Dark glass reflections inherit some of the glass tint.
* Keep the backdrop steady when a Liquid Glass menu moves or stretches.
* Fix Impeller validation errors when animating Liquid Glass shadows.
* Set `SmartContextMenuBackButtonStyle.highlightColor` to style the pressed and hovered Back
  row independently.
* Make the default hover highlight more visible in dark mode.
* The standard panel draws an edge highlight by default. Use `border: BorderSide.none`
  for the highlight alone, `standardStyle.lightDirection` to aim it, and
  `showEdgeHighlight: false` to switch it off.
* `SmartContextMenuStyle.backgroundBlur` is `null` by default. To restore the full-screen
  blur from 1.1.x, set `backgroundBlur: SmartContextMenuBlur.medium`.

## 1.1.0

* `SmartContextMenuItem.row` shows items side by side as compact cells in one line, as in the
  compact menus of iOS. The cells are items of the other types and keep their actions, states
  and colors. `SmartContextMenuRowSize.medium`, the default, shows the icon above the title,
  and `SmartContextMenuRowSize.small` the icon only. `SmartContextMenuRowFlex` gives a cell a
  larger share of the width. Drag-to-select and cursor hover work across the cells. In a
  submenu, a horizontal drag that starts on a row selects its cells unless `enableSwipeBack`
  is set. A row returned by a page loader carries its own `pagingMetadata`. This is a new item
  type, so keep a `_` case when you switch on items.
* `SmartContextMenuRowStyle`, the `rowStyle` of the style, sets the padding, the gaps, the title
  style and the divider indents of rows. `dividersBetweenChildren` of a row draws vertical
  lines between its cells.
* `SmartContextMenuItemState.rowSize` lets a `customBuilder` fit its content to a cell.
* `SmartContextMenuLabels` has short titles for loading, error and empty cells: `rowLoading`,
  `rowError`, `rowRetry` and `rowEmpty`.
* The menu opens on a right click or a two-finger click on a trackpad in the default
  `longPress` activation mode. Of nested menus, only the innermost one opens. A secondary
  pointer-down handler on the child also runs; a secondary tap handler waiting for release
  can be canceled as the menu opens.
* Menu items highlight on cursor hover on desktop and web, without selecting an action. The
  highlight follows the item under a stationary cursor as the menu scrolls, switches levels
  or resizes. Items are selected with the primary mouse button only.
  `SmartContextMenuItemState.isHovered` tells hover from a press in `customBuilder`.
* `SmartContextMenu.of(context)` opens the menu from its child, for example from a "⋯" button
  in a list row, without a controller. It returns the controller passed to the menu or the
  menu's own one; `SmartContextMenu.maybeOf(context)` returns `null` outside a menu. The
  `manual` activation mode no longer requires a controller.
* `SmartContextMenuBackButtonStyle`, the `backButtonStyle` of the style, sets the look of the
  pinned Back item. Its new `decoration` sets the background and clips the blur to the
  decoration's shape, and `foregroundColor` colors the title and the icon. The fields
  `backButtonBlur`, `backButtonBorderRadius`, `backButtonColor`, `backButtonTitleStyle` and
  `backIcon` of the style remain as deprecated aliases until 2.0.0.
* `SmartContextMenuStatusStyle`, the `statusStyle` of the style, sets the look of loading, error
  and empty items: `titleAlign`, `errorIcon`, `retryIcon`, `emptyIcon`, `loadingIndicator` and
  `loaderVerticalPadding`. The same fields of the style, with `statusTitleAlign` for
  `titleAlign`, remain as deprecated aliases until 2.0.0. A group and its deprecated fields
  cannot be set together.
* `separatorThickness` sets the thickness of a separator band. The old `separatorHeight` name
  remains as a deprecated alias until 2.0.0, in the style and in `SmartContextMenuDefaults`.
* Dynamic colors in `menuShadows` now follow the theme.
* Fixed nested menus: a press on the inner menu no longer shrinks the outer widget too.
* Fixed section titles: a separator with a `child` at the start of a menu, a submenu or a row
  is now shown, since it titles the items after it. Of several separators next to each other,
  the last one with a `child` is shown instead of the first separator. Bands without a `child`
  are shown as before.
* Fixed a controller passed to another menu: it no longer stops working when the menu it
  was passed to before is removed or rebuilt without it.

## 1.0.4

* Fixed static analysis on Flutter 3.50: the package no longer reports the deprecated
  `package:flutter/material.dart` and `package:flutter/cupertino.dart` libraries. Flutter 3.32
  and `CupertinoDynamicColor`s from `package:flutter/cupertino.dart` are still supported.
* The page below the menu no longer plays its exit transition when it was pushed with a plain
  `PageRoute`, such as `PageRouteBuilder` or custom routes of navigation packages.
* The animated GIF is now the first image on pub.dev.

## 1.0.3

* Shortened the package description to fit pub.dev's recommended length and updated
  the displayed package version in the web demo.

## 1.0.2

* Improved the example app with hints for opening menus, tap-to-open files, and visible feedback
  for demo actions and chat reactions.
* Refreshed the pub.dev screenshots and package description to show the light and dark themes,
  drag-to-select, and a reactions bar above a chat message.
* Raised the example app's minimum deployment targets to iOS 15 and macOS 12.

## 1.0.1

* The default menu width is now 250 instead of 280, matching the iOS context menu on iPhone.
  Set `menuWidth: 280` to keep the previous width.
* The web demo now shows Russian instructions and a Russian loading screen with `?lang=ru`.
* Improved the READMEs and API documentation, and added a minimal pub.dev example.
* In RTL, submenus now enter from the left, swipe back moves left, and the default navigation
  chevrons point in the matching direction. The example app has an RTL layout switch.

## 1.0.0

* Initial release: an iOS-style context menu for Flutter.
* Opening: a lifted preview above a blurred background, drag-to-select, opening and closing
  from code with `SmartContextMenuController`, and support for your own `Hero` widgets.
* Positioning: the widget stays in place and moves only as far as needed; long menus scroll
  inside, and tall widgets scroll together with the menu.
* Motion: a liquid stretch under the finger, smooth changes of height, a preview that glides up
  to make room and a swipe back that follows the finger.
* Items: actions, separators, dividers and custom content; static, async and paginated submenus;
  async and listenable items; loading, error and empty states with retry.
* Header slivers above the widget, such as a reactions bar.
* Appearance: light and dark themes, `SmartContextMenuTheme` for the whole app,
  `SmartContextMenuStyle` for colors, text, icons, blur and shadows, and
  `SmartContextMenuLabels` for the strings.
