import 'smart_context_menu_item.dart';
import 'smart_context_menu_paging_metadata.dart';

final class SmartMenuLevel {
  final List<SmartContextMenuItem> items;
  final SmartContextMenuSubmenuLoader? asyncLoader;
  final String? parentId;
  final SmartContextMenuPageLoader? pagingMethod;

  /// How long a load of the items or of a page may take, if limited.
  final Duration? loadingTimeout;

  /// The item shown while the items or a page load, if not the default one.
  final SmartContextMenuLoadingItem? loadingItem;

  /// The item shown after the items or a page fail to load, if not
  /// the default one.
  final SmartContextMenuErrorItem? errorItem;

  /// The item shown when the submenu has no items, if not the default one.
  final SmartContextMenuEmptyItem? emptyItem;
  SmartContextMenuPagingMetadata? nextMetadata;
  bool isLoading;
  bool isPaginating;
  bool hasError;

  SmartMenuLevel({
    required List<SmartContextMenuItem> items,
    this.asyncLoader,
    this.parentId,
    this.pagingMethod,
    this.loadingTimeout,
    this.loadingItem,
    this.errorItem,
    this.emptyItem,
    this.nextMetadata,
    this.isLoading = false,
    this.isPaginating = false,
    this.hasError = false,
  }) : items = List.from(items);

  bool get hasPaging => pagingMethod != null && nextMetadata != null;

  /// Whether the level is a submenu and shows the back item.
  bool get hasBack => parentId != null;

  /// Whether the level is a submenu that has no items and nothing more
  /// to load.
  bool get isEmpty =>
      hasBack && items.isEmpty && !isLoading && !hasError && !hasPaging;

  /// The number of rows in the level list: the back item, the items and
  /// the loader, retry, paging or empty row.
  int get rowCount {
    int count = hasBack ? 1 : 0;
    if (items.isEmpty && (isLoading || hasError || isEmpty)) return count + 1;
    count += items.length;
    if (hasPaging || hasError) count += 1;
    return count;
  }
}
