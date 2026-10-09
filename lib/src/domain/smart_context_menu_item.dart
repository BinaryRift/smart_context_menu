import 'dart:async' show FutureOr;
import 'package:flutter/widgets.dart'
    show Widget, BuildContext, Color, EdgeInsets, Listenable, TextStyle;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_item_state.dart';
import 'smart_context_menu_paging_metadata.dart';

part 'items/smart_context_menu_async_item.dart';
part 'items/smart_context_menu_async_submenu_item.dart';
part 'items/smart_context_menu_content_item.dart';
part 'items/smart_context_menu_listenable_item.dart';
part 'items/smart_context_menu_paging_submenu_item.dart';
part 'items/smart_context_menu_separator_item.dart';
part 'items/smart_context_menu_simple_item.dart';
part 'items/smart_context_menu_status_item.dart';
part 'items/smart_context_menu_submenu_item.dart';

/// Loads one page of items for [SmartContextMenuItem.pagingSubmenu].
///
/// Receives the metadata of the page to load.
typedef SmartContextMenuPageLoader =
    Future<List<SmartContextMenuItem>> Function(
      SmartContextMenuPagingMetadata metadata,
    );

/// Loads all items of a submenu for [SmartContextMenuItem.asyncSubmenu].
typedef SmartContextMenuSubmenuLoader =
    Future<List<SmartContextMenuItem>> Function();

/// Loads an item for [SmartContextMenuItem.async].
///
/// Returns a [SmartContextMenuAsyncResult]: an item that runs an action,
/// an item that opens a submenu or a status item.
typedef SmartContextMenuItemLoader =
    Future<SmartContextMenuAsyncResult> Function();

/// Builds the item of [SmartContextMenuItem.listenable] from the current
/// state of the app.
///
/// Returns a [SmartContextMenuItem.simple], a [SmartContextMenuItem.loading]
/// while the item is loading, a [SmartContextMenuItem.error] if it failed
/// to load or a [SmartContextMenuItem.empty] if there is nothing to show.
typedef SmartContextMenuListenableItemBuilder =
    SmartContextMenuListenableResult Function();

/// Builds the content of an item from its current state.
typedef SmartContextMenuItemBuilder =
    Widget Function(BuildContext context, SmartContextMenuItemState state);

/// An item that [SmartContextMenuItem.async] can load: a
/// [SmartContextMenuSimpleItem], an item that opens a submenu
/// ([SmartContextMenuSubmenuItem], [SmartContextMenuAsyncSubmenuItem],
/// [SmartContextMenuPagingSubmenuItem]) or a [SmartContextMenuStatusItem].
///
/// Includes every [SmartContextMenuListenableResult].
sealed class SmartContextMenuAsyncResult implements SmartContextMenuItem {}

/// An item that the builder of [SmartContextMenuItem.listenable] can return:
/// a [SmartContextMenuSimpleItem] or a [SmartContextMenuStatusItem].
sealed class SmartContextMenuListenableResult
    implements SmartContextMenuAsyncResult {}

/// An entry of a [SmartContextMenu].
///
/// Create items with the method that matches what the item does. Each one
/// returns its own subtype, so a `switch` on an item covers all of them:
///
/// * [SmartContextMenuItem.simple] runs an action,
///   a [SmartContextMenuSimpleItem].
/// * [SmartContextMenuItem.submenu] opens a submenu,
///   a [SmartContextMenuSubmenuItem].
/// * [SmartContextMenuItem.asyncSubmenu] opens a submenu and loads its
///   items, a [SmartContextMenuAsyncSubmenuItem].
/// * [SmartContextMenuItem.pagingSubmenu] opens a submenu and loads its
///   items page by page, a [SmartContextMenuPagingSubmenuItem].
/// * [SmartContextMenuItem.async] shows a placeholder and replaces it with
///   a loaded item, a [SmartContextMenuAsyncItem].
/// * [SmartContextMenuItem.listenable] builds the item from the state of
///   the app and rebuilds it while the menu is open,
///   a [SmartContextMenuListenableItem].
/// * [SmartContextMenuItem.loading] shows a loading state, usually of
///   an async or a listenable item, a [SmartContextMenuLoadingItem].
/// * [SmartContextMenuItem.error] shows a failed load,
///   a [SmartContextMenuErrorItem].
/// * [SmartContextMenuItem.empty] shows that there are no items,
///   a [SmartContextMenuEmptyItem].
/// * [SmartContextMenuItem.separator] separates groups of items,
///   a [SmartContextMenuSeparatorItem].
///
/// A submenu replaces the current menu and shows a back item at the top.
/// Tapping the back item or swiping right returns to the parent menu,
/// see [SmartContextMenuConfig.enableSwipeBack].
///
/// ```dart
/// SmartContextMenuItem.submenu(
///   title: 'Move to',
///   leading: const Icon(CupertinoIcons.folder),
///   children: [
///     SmartContextMenuItem.simple(
///       title: 'Documents',
///       onTap: () => debugPrint('Documents'),
///     ),
///     SmartContextMenuItem.simple(
///       title: 'Archive',
///       onTap: () => debugPrint('Archive'),
///     ),
///   ],
/// )
/// ```
sealed class SmartContextMenuItem {
  static int _nextId = 0;
  static String _generateId() => "smart_context_menu_item_${_nextId++}";

  /// Identifies the item within the menu.
  ///
  /// Loaded submenus and items are cached by [id] until the menu closes,
  /// so ids must be unique across the menu and all its submenus.
  /// A unique id is generated when none is given.
  final String id;

  const SmartContextMenuItem._({required this.id});

  /// Creates an item that runs [onTap] when tapped.
  ///
  /// Set [pagingMetadata] only on items returned by a
  /// [SmartContextMenuPageLoader], see [SmartContextMenuItem.pagingSubmenu].
  static SmartContextMenuSimpleItem simple({
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    Color? tintColor,
    bool isDisabled = false,
    bool closeOnTap = true,
    SmartContextMenuItemBuilder? customBuilder,
    FutureOr<void> Function()? onTap,
    EdgeInsets? padding,
    double? childrenGap,
    SmartContextMenuPagingMetadata? pagingMetadata,
  }) => SmartContextMenuSimpleItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    tintColor: tintColor,
    isDisabled: isDisabled,
    closeOnTap: closeOnTap,
    onTap: onTap,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    pagingMetadata: pagingMetadata,
  );

  /// Creates an item that opens a submenu with [children].
  ///
  /// Without [children], the submenu shows a [SmartContextMenuItem.empty].
  static SmartContextMenuSubmenuItem submenu({
    required List<SmartContextMenuItem> children,
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    Color? tintColor,
    bool isDisabled = false,
    SmartContextMenuItemBuilder? customBuilder,
    EdgeInsets? padding,
    double? childrenGap,
  }) => SmartContextMenuSubmenuItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    tintColor: tintColor,
    isDisabled: isDisabled,
    children: children,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
  );

  /// Creates an item that opens a submenu with items loaded by
  /// [asyncChildren].
  ///
  /// [asyncChildren] is called when the item is tapped. Until it completes,
  /// the submenu shows [loading], a [SmartContextMenuItem.loading], or by
  /// default an activity indicator in the middle. If it fails or takes
  /// longer than [timeout], the submenu shows [error], a
  /// [SmartContextMenuItem.error], and tapping it retries loading. The loaded
  /// items are cached by [id] until the menu closes. If there are no items,
  /// the submenu shows [empty], or by default a [SmartContextMenuItem.empty].
  ///
  /// [timeout] defaults to [SmartContextMenuDefaults.loadingTimeout].
  /// Without its own title and trailing, [error] shows
  /// [SmartContextMenuLabels.retry] and [SmartContextMenuStyle.retryIcon].
  ///
  /// ```dart
  /// SmartContextMenuItem.asyncSubmenu(
  ///   title: 'Recent files',
  ///   leading: const Icon(CupertinoIcons.clock),
  ///   asyncChildren: () async {
  ///     await Future<void>.delayed(const Duration(seconds: 1));
  ///     return [
  ///       SmartContextMenuItem.simple(title: 'Report.pdf'),
  ///       SmartContextMenuItem.simple(title: 'Photo.png'),
  ///     ];
  ///   },
  /// )
  /// ```
  static SmartContextMenuAsyncSubmenuItem asyncSubmenu({
    required SmartContextMenuSubmenuLoader asyncChildren,
    Duration timeout = SmartContextMenuDefaults.loadingTimeout,
    SmartContextMenuLoadingItem? loading,
    SmartContextMenuErrorItem? error,
    SmartContextMenuEmptyItem? empty,
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    Color? tintColor,
    bool isDisabled = false,
    SmartContextMenuItemBuilder? customBuilder,
    EdgeInsets? padding,
    double? childrenGap,
  }) => SmartContextMenuAsyncSubmenuItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    tintColor: tintColor,
    isDisabled: isDisabled,
    asyncChildren: asyncChildren,
    timeout: timeout,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    loading: loading,
    error: error,
    empty: empty,
  );

  /// Creates an item that opens a submenu with items loaded page by page.
  ///
  /// [asyncPagingChildren] is called with [initialMetadata] when the item
  /// is tapped. The [SmartContextMenuSimpleItem.pagingMetadata] of the last
  /// item of each page describes the next page, which is loaded when the
  /// user scrolls to the end of the submenu. A page that is empty or whose
  /// last item has no metadata is the last one. While a page loads, the
  /// submenu shows [loading], a [SmartContextMenuItem.loading], or by
  /// default an activity indicator in the middle, after the loaded items.
  ///
  /// If a page fails to load or takes longer than [timeout], the submenu
  /// shows [error], a [SmartContextMenuItem.error], after the loaded items,
  /// and tapping it retries loading the page. The loaded pages are cached
  /// by [id] until the menu closes. If the first page has no items, the
  /// submenu shows [empty], or by default a [SmartContextMenuItem.empty].
  ///
  /// [timeout] defaults to [SmartContextMenuDefaults.loadingTimeout].
  /// Without its own title and trailing, [error] shows
  /// [SmartContextMenuLabels.retry] and [SmartContextMenuStyle.retryIcon].
  ///
  /// ```dart
  /// SmartContextMenuItem.pagingSubmenu(
  ///   title: 'Contacts',
  ///   leading: const Icon(CupertinoIcons.person_2),
  ///   initialMetadata: const SmartContextMenuPagingMetadata(limit: 10),
  ///   asyncPagingChildren: (metadata) async {
  ///     await Future<void>.delayed(const Duration(seconds: 1));
  ///     final isLastPage = metadata.page == 5;
  ///     return List.generate(metadata.limit, (index) {
  ///       final number = (metadata.page - 1) * metadata.limit + index + 1;
  ///       final isLastItem = index == metadata.limit - 1;
  ///       return SmartContextMenuItem.simple(
  ///         title: 'Contact $number',
  ///         // The last item of a page describes the next page.
  ///         pagingMetadata: isLastItem && !isLastPage
  ///             ? metadata.copyWith(page: metadata.page + 1)
  ///             : null,
  ///       );
  ///     });
  ///   },
  /// )
  /// ```
  static SmartContextMenuPagingSubmenuItem pagingSubmenu({
    required SmartContextMenuPageLoader asyncPagingChildren,
    required SmartContextMenuPagingMetadata initialMetadata,
    Duration timeout = SmartContextMenuDefaults.loadingTimeout,
    SmartContextMenuLoadingItem? loading,
    SmartContextMenuErrorItem? error,
    SmartContextMenuEmptyItem? empty,
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    Color? tintColor,
    bool isDisabled = false,
    SmartContextMenuItemBuilder? customBuilder,
    EdgeInsets? padding,
    double? childrenGap,
  }) => SmartContextMenuPagingSubmenuItem._(
    id: id ?? _generateId(),
    title: title,
    asyncPagingChildren: asyncPagingChildren,
    initialMetadata: initialMetadata,
    timeout: timeout,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    tintColor: tintColor,
    isDisabled: isDisabled,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    loading: loading,
    error: error,
    empty: empty,
  );

  /// Creates a separator between groups of items.
  ///
  /// A separator has no actions and no press highlight, and drag-to-select
  /// passes over it. By default it is a band of
  /// [SmartContextMenuStyle.separatorHeight] in
  /// [SmartContextMenuStyle.separatorColor];
  /// [child] replaces the band, for example with a section title.
  ///
  /// A separator at the start or the end of a menu level is not shown, and
  /// of several separators in a row only the first one is. So items shown
  /// on condition can keep their separators without extra checks. A separator
  /// at the end of a loaded page appears when the next page loads; set
  /// [pagingMetadata] on it if it is the last item of a page, see
  /// [SmartContextMenuItem.pagingSubmenu].
  ///
  /// ```dart
  /// [
  ///   SmartContextMenuItem.simple(title: 'Copy'),
  ///   SmartContextMenuItem.simple(title: 'Share'),
  ///   SmartContextMenuItem.separator(),
  ///   SmartContextMenuItem.simple(title: 'Delete', isDestructive: true),
  /// ]
  /// ```
  static SmartContextMenuSeparatorItem separator({
    String? id,
    Widget? child,
    SmartContextMenuPagingMetadata? pagingMetadata,
  }) => SmartContextMenuSeparatorItem._(
    id: id ?? _generateId(),
    child: child,
    pagingMetadata: pagingMetadata,
  );

  /// Creates a placeholder that is replaced by the item loaded by
  /// [asyncItem].
  ///
  /// [asyncItem] is called when the placeholder first appears. Until it
  /// completes, the placeholder shows [loading], a
  /// [SmartContextMenuItem.loading]; by default its title is
  /// [SmartContextMenuLabels.loading]. If loading fails or takes longer than
  /// [timeout], the placeholder shows [error], a [SmartContextMenuItem.error],
  /// and tapping it retries loading. The loaded item is cached by [id] until
  /// the menu closes.
  ///
  /// [timeout] defaults to [SmartContextMenuDefaults.loadingTimeout].
  ///
  /// Without its own title and trailing, [error] shows
  /// [SmartContextMenuLabels.retry] and [SmartContextMenuStyle.retryIcon].
  /// Without its own padding, it keeps the padding of [loading]; the loaded
  /// item uses its own.
  ///
  /// ```dart
  /// SmartContextMenuItem.async(
  ///   loading: SmartContextMenuItem.loading(title: 'Checking access'),
  ///   error: SmartContextMenuItem.error(title: 'Could not check access'),
  ///   asyncItem: () async {
  ///     await Future<void>.delayed(const Duration(seconds: 1));
  ///     return SmartContextMenuItem.simple(
  ///       title: 'Edit',
  ///       leading: const Icon(CupertinoIcons.pencil),
  ///       onTap: () => debugPrint('Edit'),
  ///     );
  ///   },
  /// )
  /// ```
  static SmartContextMenuAsyncItem async({
    required SmartContextMenuItemLoader asyncItem,
    String? id,
    Duration timeout = SmartContextMenuDefaults.loadingTimeout,
    SmartContextMenuLoadingItem? loading,
    SmartContextMenuErrorItem? error,
  }) => SmartContextMenuAsyncItem._(
    id: id ?? _generateId(),
    asyncItem: asyncItem,
    timeout: timeout,
    loading: loading ?? SmartContextMenuItem.loading(),
    error: error ?? SmartContextMenuItem.error(),
  );

  /// Creates an item that is built by [builder] and built again each time
  /// [listenable] notifies, also while the menu is open.
  ///
  /// Use it when the state of the item lives in the app, for example in
  /// a [ChangeNotifier]: a toggle that stays in the open menu, a counter,
  /// or an action that is already running. The menu does not dispose
  /// [listenable]. To rebuild the item from a [Stream], wrap the stream in
  /// a [ChangeNotifier] that calls `notifyListeners` on each event.
  ///
  /// [builder] returns the item to show: a [SmartContextMenuItem.simple],
  /// whose `onTap` and `closeOnTap` are used, so it can act on the current
  /// state, a [SmartContextMenuItem.loading] while the item is loading,
  /// a [SmartContextMenuItem.error] if it failed to load, or
  /// a [SmartContextMenuItem.empty] if there is nothing to show.
  ///
  /// ```dart
  /// SmartContextMenuItem.listenable(
  ///   listenable: favorites,
  ///   builder: () {
  ///     if (favorites.isLoading) {
  ///       return SmartContextMenuItem.loading(title: 'Checking');
  ///     }
  ///     final isFavorite = favorites.contains(post.id);
  ///     return SmartContextMenuItem.simple(
  ///       title: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
  ///       leading: Icon(
  ///         isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
  ///       ),
  ///       closeOnTap: false,
  ///       onTap: () => favorites.toggle(post.id),
  ///     );
  ///   },
  /// )
  /// ```
  static SmartContextMenuListenableItem listenable({
    required Listenable listenable,
    required SmartContextMenuListenableItemBuilder builder,
    String? id,
  }) => SmartContextMenuListenableItem._(
    id: id ?? _generateId(),
    listenable: listenable,
    builder: builder,
  );

  /// Creates an item that shows a loading state.
  ///
  /// Pass it as `loading` to [SmartContextMenuItem.async], or return it from
  /// the builder of [SmartContextMenuItem.listenable], so that it is
  /// replaced once loading finishes. Anywhere else it stays as it is until
  /// the menu closes.
  ///
  /// The item shows [title] (or [SmartContextMenuLabels.loading]) with
  /// [leading] and an activity indicator, and does not respond to taps.
  /// [trailing] replaces the activity indicator. Pass [child] to replace
  /// this content; text and icons in it take the color of the item.
  ///
  /// ```dart
  /// SmartContextMenuItem.listenable(
  ///   listenable: sync,
  ///   builder: () => switch (sync.state) {
  ///     SyncState.checking => SmartContextMenuItem.loading(title: 'Checking'),
  ///     SyncState.syncing => SmartContextMenuItem.loading(title: 'Syncing'),
  ///     SyncState.idle => SmartContextMenuItem.simple(
  ///       title: 'Sync now',
  ///       onTap: sync.start,
  ///     ),
  ///   },
  /// )
  /// ```
  static SmartContextMenuLoadingItem loading({
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    Widget? child,
    EdgeInsets? padding,
    double? childrenGap,
  }) => SmartContextMenuLoadingItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    child: child,
    padding: padding,
    childrenGap: childrenGap,
  );

  /// Creates an item that shows a failed load.
  ///
  /// The item shows [title] (or [SmartContextMenuLabels.error]) with
  /// [leading] and [SmartContextMenuStyle.errorIcon], and does not
  /// respond to taps. [trailing] replaces the icon. Pass [child] to replace
  /// this content; text and icons in it take the color of the item.
  /// Interactive widgets in [child], such as buttons, handle their own taps.
  ///
  /// Pass it as `error` to [SmartContextMenuItem.async],
  /// [SmartContextMenuItem.asyncSubmenu] or
  /// [SmartContextMenuItem.pagingSubmenu]: tapping it there retries loading,
  /// see [SmartContextMenuAsyncItem.error]. Anywhere else, for
  /// example from the builder of [SmartContextMenuItem.listenable], it does
  /// not respond to taps. To retry from it there, add a button to [child],
  /// or return a [SmartContextMenuItem.simple] with `onTap` instead.
  ///
  /// ```dart
  /// SmartContextMenuItem.listenable(
  ///   listenable: views,
  ///   builder: () => switch (views.state) {
  ///     ViewsState.loading => SmartContextMenuItem.loading(title: 'Views'),
  ///     ViewsState.failed => SmartContextMenuItem.error(
  ///       title: 'Could not load views',
  ///     ),
  ///     ViewsState.loaded => SmartContextMenuItem.simple(
  ///       title: 'Views: ${views.count}',
  ///     ),
  ///   },
  /// )
  /// ```
  static SmartContextMenuErrorItem error({
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    Widget? child,
    EdgeInsets? padding,
    double? childrenGap,
  }) => SmartContextMenuErrorItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    child: child,
    padding: padding,
    childrenGap: childrenGap,
  );

  /// Creates an item that shows that there are no items.
  ///
  /// The item shows [title] (or [SmartContextMenuLabels.empty]) with
  /// [leading] and [SmartContextMenuStyle.emptyIcon], and does not
  /// respond to taps. [trailing] replaces the icon. Pass [child] to replace
  /// this content; text and icons in it take the color of the item.
  ///
  /// A submenu without items shows it by itself: pass it as `empty` to
  /// [SmartContextMenuItem.asyncSubmenu] or
  /// [SmartContextMenuItem.pagingSubmenu] to change it, and return no items
  /// from the loader. Return it from the builder of
  /// [SmartContextMenuItem.listenable] when the state of the app has nothing
  /// to show.
  ///
  /// ```dart
  /// SmartContextMenuItem.listenable(
  ///   listenable: drafts,
  ///   builder: () => drafts.isEmpty
  ///       ? SmartContextMenuItem.empty(title: 'No drafts')
  ///       : SmartContextMenuItem.simple(
  ///           title: 'Drafts: ${drafts.count}',
  ///           onTap: drafts.open,
  ///         ),
  /// )
  /// ```
  static SmartContextMenuEmptyItem empty({
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    Widget? child,
    EdgeInsets? padding,
    double? childrenGap,
  }) => SmartContextMenuEmptyItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    child: child,
    padding: padding,
    childrenGap: childrenGap,
  );
}
