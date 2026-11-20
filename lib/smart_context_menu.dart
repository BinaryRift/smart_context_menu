/// iOS-style context menu with smart positioning, fluid animations,
/// drag-to-select and rich submenus.
///
/// Start with [SmartContextMenu]: wrap a widget with it and pass the menu
/// items. The menu opens on long press.
///
/// The main classes:
///
/// * [SmartContextMenu] attaches a menu to a widget.
/// * [SmartContextMenuItem] is an entry of the menu: an action, a submenu,
///   an async or paginated submenu, an item loaded on the fly, an item
///   rebuilt from the state of the app while the menu is open, a loading,
///   error or empty state, or a row of compact cells.
/// * [SmartContextMenuConfig] sets the behavior and appearance of the menu.
/// * [SmartContextMenuStyle] sets the appearance, as part of the config;
///   [SmartContextMenuRowStyle] sets the appearance of rows in it.
/// * [SmartContextMenuTheme] sets the config for the menus below it.
/// * [SmartContextMenuController] opens and closes the menu from code.
///
/// Supporting types:
///
/// * [SmartContextMenuLabels] holds the strings shown by the menu itself.
/// * [SmartContextMenuBlur] sets the strength of the blurs.
/// * [SmartContextMenuPagingMetadata] describes a page of a paginated
///   submenu.
/// * [SmartContextMenuRowFlex] sets the share of a cell in a row,
///   [SmartContextMenuRowSize] the size of the cells.
///   [SmartContextMenuRowEntry] is a cell of a row: any item but a row.
/// * The subtypes of [SmartContextMenuItem], one for each way to create
///   an item, such as [SmartContextMenuSimpleItem]. Switch on an item to
///   read the fields of its type. [SmartContextMenuContentItem] is the base
///   of the actions and submenus, [SmartContextMenuStatusItem] of the
///   loading, error and empty items.
/// * [SmartContextMenuAsyncResult] and [SmartContextMenuListenableResult]
///   are the items that an async item can load and that the builder of
///   a listenable item can return.
/// * [SmartContextMenuItemState] is passed to custom item builders.
/// * [SmartContextMenuHeaderDetails] is passed to the builder of the
///   slivers above the preview.
/// * [SmartContextMenuDefaults] holds the default values of the menu.
library;

export 'src/controllers/smart_context_menu_controller.dart';
export 'src/core/ui/styles/smart_context_menu_defaults.dart';
export 'src/domain/smart_context_menu_activation_mode.dart';
export 'src/domain/smart_context_menu_blur.dart';
export 'src/domain/smart_context_menu_config.dart';
export 'src/domain/smart_context_menu_header_details.dart';
export 'src/domain/smart_context_menu_item.dart';
export 'src/domain/smart_context_menu_item_state.dart';
export 'src/domain/smart_context_menu_labels.dart';
export 'src/domain/smart_context_menu_paging_metadata.dart';
export 'src/domain/smart_context_menu_row_size.dart';
export 'src/domain/smart_context_menu_row_style.dart';
export 'src/domain/smart_context_menu_style.dart';
export 'src/ui/theme/smart_context_menu_theme.dart';
export 'src/ui/view/smart_context_menu.dart';
