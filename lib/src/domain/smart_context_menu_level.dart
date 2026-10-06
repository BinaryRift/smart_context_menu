import 'smart_context_menu_item.dart';
import 'smart_context_menu_paging_metadata.dart';

final class SmartMenuLevel {
  final List<SmartContextMenuItem> items;
  final SmartContextMenuSubmenuLoader? asyncLoader;
  final String? parentId;
  final SmartContextMenuPageLoader? pagingMethod;
  SmartContextMenuPagingMetadata? nextMetadata;
  bool isLoading;
  bool isPaginating;
  bool hasError;

  SmartMenuLevel({
    required List<SmartContextMenuItem> items,
    this.asyncLoader,
    this.parentId,
    this.pagingMethod,
    this.nextMetadata,
    this.isLoading = false,
    this.isPaginating = false,
    this.hasError = false,
  }) : items = List.from(items);

  bool get hasPaging => pagingMethod != null && nextMetadata != null;

  /// Whether the level is a submenu and shows the back item.
  bool get hasBack => parentId != null;

  /// The number of rows in the level list: the back item, the items and
  /// the loader, retry or paging row.
  int get rowCount {
    int count = hasBack ? 1 : 0;
    if (items.isEmpty && (isLoading || hasError)) return count + 1;
    count += items.length;
    if (hasPaging || hasError) count += 1;
    return count;
  }
}
