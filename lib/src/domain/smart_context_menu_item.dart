import 'dart:async' show FutureOr;
import 'package:flutter/widgets.dart'
    show Widget, BuildContext, Color, EdgeInsets, Listenable, TextStyle;
import 'package:meta/meta.dart' show internal;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_item_state.dart';
import 'smart_context_menu_paging_metadata.dart';

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
typedef SmartContextMenuItemLoader = Future<SmartContextMenuItem> Function();

/// Builds the item of [SmartContextMenuItem.listenable] from the current
/// state of the app.
///
/// Returns a [SmartContextMenuItem.loading] while the item is loading and
/// a [SmartContextMenuItem.error] if it failed to load.
typedef SmartContextMenuListenableItemBuilder = SmartContextMenuItem Function();

/// Builds the content of an item from its current state.
typedef SmartContextMenuItemBuilder =
    Widget Function(BuildContext context, SmartContextMenuItemState state);

/// An entry of a [SmartContextMenu].
///
/// Create items with the factory that matches what the item does:
///
/// * [SmartContextMenuItem.simple] runs [onTap].
/// * [SmartContextMenuItem.submenu] opens a submenu with [children].
/// * [SmartContextMenuItem.asyncSubmenu] opens a submenu and loads its
///   items with [asyncChildren].
/// * [SmartContextMenuItem.pagingSubmenu] opens a submenu and loads its
///   items page by page with [asyncPagingChildren].
/// * [SmartContextMenuItem.async] shows a placeholder and replaces it with
///   the item loaded by [asyncItem].
/// * [SmartContextMenuItem.listenable] builds the item with
///   [listenableBuilder] and rebuilds it when [listenable] notifies.
/// * [SmartContextMenuItem.loading] shows a loading state, usually of
///   an async or a listenable item.
/// * [SmartContextMenuItem.error] shows a failed load.
/// * [SmartContextMenuItem.separator] separates groups of items.
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
final class SmartContextMenuItem {
  static int _nextId = 0;
  static String _generateId() => "smart_context_menu_item_${_nextId++}";

  /// Identifies the item within the menu.
  ///
  /// Loaded submenus and items are cached by [id] until the menu closes,
  /// so ids must be unique across the menu and all its submenus.
  /// Factories generate a unique id when none is given.
  final String id;

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

  /// The padding around the item content.
  ///
  /// If null, [SmartContextMenuStyle.itemPadding] is used.
  final EdgeInsets? padding;

  /// The gap between [leading], [title], [trailing] and the submenu chevron.
  ///
  /// If null, [SmartContextMenuStyle.itemChildrenGap] is used.
  final double? childrenGap;

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

  /// Whether the item separates groups of items.
  ///
  /// Set by [SmartContextMenuItem.separator].
  final bool isSeparator;

  /// Whether the item shows that it is loading.
  ///
  /// True for a [SmartContextMenuLoadingItem].
  bool get isLoading => this is SmartContextMenuLoadingItem;

  /// Whether the menu closes when the item is tapped.
  ///
  /// The menu starts closing before [onTap] is called.
  /// Ignored for items that open a submenu. Defaults to true.
  final bool closeOnTap;

  /// Called when the item is tapped.
  ///
  /// If [closeOnTap] is true, the menu starts closing first.
  final FutureOr<void> Function()? onTap;

  /// The items of the submenu opened by this item.
  ///
  /// Set by [SmartContextMenuItem.submenu].
  final List<SmartContextMenuItem>? children;

  /// Loads the items of the submenu opened by this item.
  ///
  /// Set by [SmartContextMenuItem.asyncSubmenu].
  final SmartContextMenuSubmenuLoader? asyncChildren;

  /// Loads the item shown in place of this placeholder.
  ///
  /// Set by [SmartContextMenuItem.async].
  final SmartContextMenuItemLoader? asyncItem;

  /// The item shown while [asyncItem], the items of [asyncChildren] or
  /// a page of [asyncPagingChildren] are loading.
  ///
  /// Set by [SmartContextMenuItem.async], [SmartContextMenuItem.asyncSubmenu]
  /// and [SmartContextMenuItem.pagingSubmenu]. If null in a submenu, it shows
  /// an activity indicator in the middle, see
  /// [SmartContextMenuStyle.loaderVerticalPadding].
  final SmartContextMenuLoadingItem? loadingItem;

  /// Notifies when the item of [listenableBuilder] should be built again.
  ///
  /// Set by [SmartContextMenuItem.listenable].
  final Listenable? listenable;

  /// Builds the item shown in place of this one.
  ///
  /// Set by [SmartContextMenuItem.listenable].
  final SmartContextMenuListenableItemBuilder? listenableBuilder;

  /// How long loading may take before it fails: the item of [asyncItem],
  /// the items of [asyncChildren] or each page of [asyncPagingChildren].
  ///
  /// Set by [SmartContextMenuItem.async], [SmartContextMenuItem.asyncSubmenu]
  /// and [SmartContextMenuItem.pagingSubmenu].
  final Duration? loadingTimeout;

  /// Loads one page of the submenu opened by this item.
  ///
  /// Set by [SmartContextMenuItem.pagingSubmenu].
  final SmartContextMenuPageLoader? asyncPagingChildren;

  /// The metadata of a page of a paginated submenu.
  ///
  /// On a [SmartContextMenuItem.pagingSubmenu] item, it describes the first
  /// page. On the last item of a loaded page, it describes the next page;
  /// null there marks the last page.
  final SmartContextMenuPagingMetadata? pagingMetadata;

  /// Builds the item content instead of [leading], [title] and [trailing].
  ///
  /// The item [padding] and press highlight are still applied, and taps
  /// are handled as usual. Interactive widgets inside, such as
  /// buttons, handle their own taps: the item is not triggered over them.
  final SmartContextMenuItemBuilder? customBuilder;

  /// Builds the content of the placeholder after [asyncItem] has failed.
  ///
  /// Tapping the placeholder retries loading. The padding of [loadingItem]
  /// and the press highlight are still applied. If null, the placeholder
  /// shows [SmartContextMenuLabels.retry] with error and retry icons.
  /// Set by [SmartContextMenuItem.async].
  final SmartContextMenuItemBuilder? errorBuilder;

  /// Whether the item shows a submenu chevron.
  @internal
  bool get showTransitionIcon =>
      children != null || asyncChildren != null || asyncPagingChildren != null;

  /// Whether a tap is handled by the menu itself.
  @internal
  bool get isInternalInteracted =>
      asyncItem != null ||
      asyncChildren != null ||
      asyncPagingChildren != null ||
      children != null;

  const SmartContextMenuItem._({
    required this.id,
    this.title,
    this.titleStyle,
    this.leading,
    this.trailing,
    this.isDestructive = false,
    this.tintColor,
    this.isDisabled = false,
    this.isSeparator = false,
    this.onTap,
    this.children,
    this.asyncChildren,
    this.asyncPagingChildren,
    this.asyncItem,
    this.loadingItem,
    this.listenable,
    this.listenableBuilder,
    this.loadingTimeout,
    this.pagingMetadata,
    this.customBuilder,
    this.errorBuilder,
    this.padding,
    this.childrenGap,
    this.closeOnTap = true,
  }) : assert(
         (children != null ? 1 : 0) +
                 (asyncChildren != null ? 1 : 0) +
                 (asyncPagingChildren != null ? 1 : 0) <=
             1,
         'Menu item can have only one of children, asyncChildren '
         'or asyncPagingChildren.',
       );

  /// Creates an item that runs [onTap] when tapped.
  ///
  /// Set [pagingMetadata] only on items returned by a
  /// [SmartContextMenuPageLoader], see [SmartContextMenuItem.pagingSubmenu].
  factory SmartContextMenuItem.simple({
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
  }) => SmartContextMenuItem._(
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
  factory SmartContextMenuItem.submenu({
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
  }) => SmartContextMenuItem._(
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
  /// default an activity indicator in the middle; if it fails or takes
  /// longer than [timeout], a retry item. The loaded items are cached by [id]
  /// until the menu closes.
  ///
  /// [timeout] defaults to [SmartContextMenuDefaults.loadingTimeout].
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
  factory SmartContextMenuItem.asyncSubmenu({
    required SmartContextMenuSubmenuLoader asyncChildren,
    Duration timeout = SmartContextMenuDefaults.loadingTimeout,
    SmartContextMenuLoadingItem? loading,
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
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    tintColor: tintColor,
    isDisabled: isDisabled,
    asyncChildren: asyncChildren,
    loadingTimeout: timeout,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    loadingItem: loading,
  );

  /// Creates an item that opens a submenu with items loaded page by page.
  ///
  /// [asyncPagingChildren] is called with [initialMetadata] when the item
  /// is tapped. The [SmartContextMenuItem.pagingMetadata] of the last item
  /// of each page describes the next page, which is loaded when the user
  /// scrolls to the end of the submenu. A page that is empty or whose last
  /// item has no metadata is the last one. While a page loads, the submenu
  /// shows [loading], a [SmartContextMenuItem.loading], or by default
  /// an activity indicator in the middle, after the loaded items.
  ///
  /// If a page fails to load or takes longer than [timeout], the submenu
  /// shows a retry item. The loaded pages are cached by [id] until the menu
  /// closes.
  ///
  /// [timeout] defaults to [SmartContextMenuDefaults.loadingTimeout].
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
  factory SmartContextMenuItem.pagingSubmenu({
    required SmartContextMenuPageLoader asyncPagingChildren,
    required SmartContextMenuPagingMetadata initialMetadata,
    Duration timeout = SmartContextMenuDefaults.loadingTimeout,
    SmartContextMenuLoadingItem? loading,
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
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    title: title,
    asyncPagingChildren: asyncPagingChildren,
    pagingMetadata: initialMetadata,
    loadingTimeout: timeout,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    tintColor: tintColor,
    isDisabled: isDisabled,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    loadingItem: loading,
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
  factory SmartContextMenuItem.separator({
    String? id,
    Widget? child,
    SmartContextMenuPagingMetadata? pagingMetadata,
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    isSeparator: true,
    closeOnTap: false,
    customBuilder: child == null ? null : (context, state) => child,
    pagingMetadata: pagingMetadata,
  );

  /// Creates a placeholder that is replaced by the item loaded by
  /// [asyncItem].
  ///
  /// [asyncItem] is called when the placeholder first appears. Until it
  /// completes, the placeholder shows [loading], a
  /// [SmartContextMenuItem.loading]; by default its title is
  /// [SmartContextMenuLabels.loading]. If loading fails or takes longer than
  /// [timeout], the placeholder turns into a retry item. The loaded item is
  /// cached by [id] until the menu closes.
  ///
  /// [timeout] defaults to [SmartContextMenuDefaults.loadingTimeout].
  ///
  /// Use [errorBuilder] to replace the default error content. The retry item
  /// keeps the padding of [loading]; the loaded item uses its own.
  ///
  /// ```dart
  /// SmartContextMenuItem.async(
  ///   loading: SmartContextMenuItem.loading(title: 'Checking access'),
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
  factory SmartContextMenuItem.async({
    required SmartContextMenuItemLoader asyncItem,
    String? id,
    Duration timeout = SmartContextMenuDefaults.loadingTimeout,
    SmartContextMenuLoadingItem? loading,
    SmartContextMenuItemBuilder? errorBuilder,
  }) {
    return SmartContextMenuItem._(
      id: id ?? _generateId(),
      asyncItem: asyncItem,
      loadingItem: loading ?? SmartContextMenuItem.loading(),
      loadingTimeout: timeout,
      closeOnTap: false,
      errorBuilder: errorBuilder,
    );
  }

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
  /// whose [onTap] and [closeOnTap] are used, so it can act on the current
  /// state, a [SmartContextMenuItem.loading] while the item is loading, or
  /// a [SmartContextMenuItem.error] if it failed to load.
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
  factory SmartContextMenuItem.listenable({
    required Listenable listenable,
    required SmartContextMenuListenableItemBuilder builder,
    String? id,
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    listenable: listenable,
    listenableBuilder: builder,
    closeOnTap: false,
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
  /// [leading] and [SmartContextMenuDefaults.errorIcon], and does not
  /// respond to taps. [trailing] replaces the icon. Pass [child] to replace
  /// this content; text and icons in it take the color of the item.
  /// Interactive widgets in [child], such as buttons, handle their own taps.
  ///
  /// Return it from the builder of [SmartContextMenuItem.listenable] when
  /// the state of the app has an error. To retry from the item, add
  /// a button to [child], or return a [SmartContextMenuItem.simple] with
  /// `onTap` instead.
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
}

/// A [SmartContextMenuItem] that shows a state, such as loading, instead
/// of an action.
///
/// It does not respond to taps and is not dimmed. A sign of the state is
/// shown after [title] unless [trailing] is set.
///
/// See [SmartContextMenuLoadingItem] and [SmartContextMenuErrorItem].
sealed class SmartContextMenuStatusItem extends SmartContextMenuItem {
  /// The content shown instead of [title], [leading] and [trailing].
  ///
  /// The item [padding] is still applied. Text and icons in it take
  /// the color of the item.
  final Widget? child;

  const SmartContextMenuStatusItem._({
    required super.id,
    super.title,
    super.titleStyle,
    super.leading,
    super.trailing,
    this.child,
    super.padding,
    super.childrenGap,
  }) : super._(closeOnTap: false);
}

/// A [SmartContextMenuStatusItem] that shows a loading state.
///
/// Create it with [SmartContextMenuItem.loading].
final class SmartContextMenuLoadingItem extends SmartContextMenuStatusItem {
  const SmartContextMenuLoadingItem._({
    required super.id,
    super.title,
    super.titleStyle,
    super.leading,
    super.trailing,
    super.child,
    super.padding,
    super.childrenGap,
  }) : super._();
}

/// A [SmartContextMenuStatusItem] that shows a failed load.
///
/// Create it with [SmartContextMenuItem.error].
final class SmartContextMenuErrorItem extends SmartContextMenuStatusItem {
  const SmartContextMenuErrorItem._({
    required super.id,
    super.title,
    super.titleStyle,
    super.leading,
    super.trailing,
    super.child,
    super.padding,
    super.childrenGap,
  }) : super._();
}
