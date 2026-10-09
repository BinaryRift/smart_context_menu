# smart_context_menu example

Menus for checking submenus: static, async, paginated and nested, with levels of different heights.
Long press a card to open its menu. In a submenu, swipe right or tap the back item to return.

The listenable items keep their state in the app: they change while the menu is open, and the download keeps running after the menu closes.

Loads and item taps are logged with `debugPrint`, so you can see that paginated submenus load their pages only on scroll.
