// ignore_for_file: unintended_html_in_doc_comment

import 'dart:async' show FutureOr;
import 'package:flutter/widgets.dart'
    show Widget, BuildContext, EdgeInsets, TextStyle;

import '../core/ui/styles/smart_context_menu_defaults.dart';
import 'smart_context_menu_item_state.dart';
import 'smart_context_menu_paging_metadata.dart';

typedef SmartContextMenuPageLoader =
    Future<List<SmartContextMenuItem>> Function(
      SmartContextMenuPagingMetadata? metadata,
    );
typedef SmartContextMenuSubmenuLoader =
    Future<List<SmartContextMenuItem>> Function();
typedef SmartContextMenuItemLoader = Future<SmartContextMenuItem> Function();
typedef SmartContextMenuItemBuilder =
    Widget Function(BuildContext context, SmartContextMenuItemState state);

enum SmartContextMenuDividerPosition { top, bottom }

final class SmartContextMenuItem {
  static int _nextId = 0;
  static String _generateId() => "smart_context_menu_item_${_nextId++}";

  final String id;
  final String? title;
  final TextStyle? titleStyle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets padding;
  final double childrenGap;
  final bool isDestructive;
  final bool isDisabled;
  final bool hasDivider;
  final bool closeOnTap;
  final Widget? customDivider;
  final SmartContextMenuDividerPosition dividerPosition;

  final FutureOr<void> Function()? onTap;
  final List<SmartContextMenuItem>? children;
  final SmartContextMenuSubmenuLoader? asyncChildren;
  final SmartContextMenuItemLoader? asyncItem;
  final Duration? loadingTimeout;

  /// Example:
  ///
  /// Future<List<SmartContextMenuItem>> loadPage(
  ///   SmartContextMenuPagingMetadata? metadata,
  ///  ) async {
  ///
  ///    final data = await api.fetchItems(page: page);
  ///    Or MOCK:
  ///    await Future.delayed(const Duration(seconds: 2));
  ///    final data = List<SmartContextMenuItem>.generate(3, (index) {
  ///     return SmartContextMenuItem(
  ///       title: "item_$index",
  ///       leading: Icon(AppIcons.profile.iconData, size: 20),
  ///     );
  ///   });
  ///
  ///   return data.map((d) {
  ///     final isLast = data.indexOf(d) == data.length - 1;
  ///     final SmartContextMenuPagingMetadata metaData =
  ///     SmartContextMenuPagingMetadata(
  ///       page: (metadata?.page ?? 0) + 1,
  ///     );
  ///     final nextMetadata = isLast && !(metadata?.page == 10) ? metaData : null;
  ///     return SmartContextMenuItem(
  ///       title: "page_${metadata?.page} ${d.title}",
  ///       pagingMetadata: nextMetadata
  ///     );
  ///   }).toList();
  /// }
  ///
  /// Use:
  ///
  /// SmartContextMenuItem(
  ///   title: "Async paging submenu",
  ///   asyncPagingChildren: (metadata) => loadPage(metadata),
  ///   pagingMetadata: SmartContextMenuPagingMetadata(page: 1),
  /// ),
  ///
  final SmartContextMenuPageLoader? asyncPagingChildren;
  final SmartContextMenuPagingMetadata? pagingMetadata;

  final SmartContextMenuItemBuilder? customBuilder;

  bool get showTransitionIcon =>
      children != null || asyncChildren != null || asyncPagingChildren != null;
  bool get isInternalInterected =>
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
    this.isDisabled = false,
    this.hasDivider = false,
    this.customDivider,
    this.onTap,
    this.children,
    this.asyncChildren,
    this.asyncPagingChildren,
    this.asyncItem,
    this.loadingTimeout,
    this.pagingMetadata,
    this.customBuilder,
    EdgeInsets? padding,
    this.childrenGap = SmartContextMenuDefaults.childrenGap,
    this.closeOnTap = true,
    this.dividerPosition = SmartContextMenuDividerPosition.bottom,
  }) : assert(
         (children != null ? 1 : 0) +
                 (asyncChildren != null ? 1 : 0) +
                 (asyncPagingChildren != null ? 1 : 0) <=
             1,
         'Menu item can have only one of children, asyncChildren '
         'or asyncPagingChildren.',
       ),

       padding = padding ?? SmartContextMenuDefaults.itemPadding;

  factory SmartContextMenuItem.simple({
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    bool isDisabled = false,
    bool hasDivider = false,
    bool closeOnTap = true,
    Widget? customDivider,
    SmartContextMenuItemBuilder? customBuilder,
    FutureOr<void> Function()? onTap,
    EdgeInsets? padding,
    double childrenGap = SmartContextMenuDefaults.childrenGap,
    SmartContextMenuPagingMetadata? pagingMetadata,
    SmartContextMenuDividerPosition? dividerPosition,
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    hasDivider: hasDivider,
    closeOnTap: closeOnTap,
    customDivider: customDivider,
    onTap: onTap,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    pagingMetadata: pagingMetadata,
    dividerPosition: dividerPosition ?? SmartContextMenuDividerPosition.bottom,
  );

  factory SmartContextMenuItem.submenu({
    required List<SmartContextMenuItem> children,
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    bool isDisabled = false,
    bool hasDivider = false,
    bool closeOnTap = true,
    Widget? customDivider,
    SmartContextMenuItemBuilder? customBuilder,
    FutureOr<void> Function()? onTap,
    EdgeInsets? padding,
    double childrenGap = SmartContextMenuDefaults.childrenGap,
    SmartContextMenuDividerPosition? dividerPosition,
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    hasDivider: hasDivider,
    closeOnTap: closeOnTap,
    customDivider: customDivider,
    onTap: onTap,
    children: children,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    dividerPosition: dividerPosition ?? SmartContextMenuDividerPosition.bottom,
  );

  factory SmartContextMenuItem.asyncSubmenu({
    required SmartContextMenuSubmenuLoader asyncChildren,
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    bool isDisabled = false,
    bool hasDivider = false,
    bool closeOnTap = true,
    Widget? customDivider,
    SmartContextMenuItemBuilder? customBuilder,
    FutureOr<void> Function()? onTap,
    EdgeInsets? padding,
    double childrenGap = SmartContextMenuDefaults.childrenGap,
    SmartContextMenuDividerPosition? dividerPosition,
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    title: title,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    hasDivider: hasDivider,
    closeOnTap: closeOnTap,
    customDivider: customDivider,
    onTap: onTap,
    asyncChildren: asyncChildren,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    dividerPosition: dividerPosition ?? SmartContextMenuDividerPosition.bottom,
  );

  factory SmartContextMenuItem.pagingSubmenu({
    required SmartContextMenuPageLoader asyncPagingChildren,
    required SmartContextMenuPagingMetadata initialMetadata,
    String? id,
    String? title,
    TextStyle? titleStyle,
    Widget? leading,
    Widget? trailing,
    bool isDestructive = false,
    bool isDisabled = false,
    bool hasDivider = false,
    bool closeOnTap = true,
    Widget? customDivider,
    SmartContextMenuItemBuilder? customBuilder,
    FutureOr<void> Function()? onTap,
    EdgeInsets? padding,
    double childrenGap = SmartContextMenuDefaults.childrenGap,
    SmartContextMenuDividerPosition? dividerPosition,
  }) => SmartContextMenuItem._(
    id: id ?? _generateId(),
    title: title,
    asyncPagingChildren: asyncPagingChildren,
    pagingMetadata: initialMetadata,
    titleStyle: titleStyle,
    leading: leading,
    trailing: trailing,
    isDestructive: isDestructive,
    isDisabled: isDisabled,
    hasDivider: hasDivider,
    closeOnTap: closeOnTap,
    customDivider: customDivider,
    onTap: onTap,
    customBuilder: customBuilder,
    padding: padding,
    childrenGap: childrenGap,
    dividerPosition: dividerPosition ?? SmartContextMenuDividerPosition.bottom,
  );

  factory SmartContextMenuItem.async({
    required SmartContextMenuItemLoader builder,
    String? id,
    Duration timeout = const Duration(seconds: 15),
    bool hasDivider = false,
    Widget? customDivider,
    EdgeInsets? padding,
    Widget? leading,
    String? loadingTitle,
    TextStyle? titleStyle,
    double childrenGap = SmartContextMenuDefaults.childrenGap,
    SmartContextMenuDividerPosition? dividerPosition,
  }) {
    return SmartContextMenuItem._(
      id: id ?? _generateId(),
      title: loadingTitle,
      asyncItem: builder,
      loadingTimeout: timeout,
      hasDivider: hasDivider,
      closeOnTap: false,
      customDivider: customDivider,
      padding: padding,
      leading: leading,
      titleStyle: titleStyle,
      childrenGap: childrenGap,
      dividerPosition: dividerPosition ?? SmartContextMenuDividerPosition.bottom,
    );
  }
}
