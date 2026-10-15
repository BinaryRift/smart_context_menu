## 1.0.1

* The default menu width is now 250 instead of 280, matching the iOS context menu on iPhone.
  Set `menuWidth: 280` to keep the previous width.
* The web demo now shows Russian instructions and a Russian loading screen with `?lang=ru`.
* Improved the READMEs and API documentation, and added a minimal pub.dev example.
* In RTL, submenus now enter from the left, swipe back moves left, and the default navigation
  chevrons point in the matching direction.

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
