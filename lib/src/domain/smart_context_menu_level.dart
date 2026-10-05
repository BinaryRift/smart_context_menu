import 'smart_context_menu_item.dart';
import 'smart_context_menu_paging_metadata.dart';

final class SmartMenuLevel {
  final List<SmartContextMenuItem> items;
  final SmartContextMenuSubmenuLoader? asyncLoader;
  final String? parentId;
  final SmartContextMenuPageLoader? pagingMethod;
  SmartContextMenuPagingMetadata? nextMetadata;
  bool isPaginating;
  bool hasError;

  SmartMenuLevel({
    required List<SmartContextMenuItem> items,
    this.asyncLoader,
    this.parentId,
    this.pagingMethod,
    this.nextMetadata,
    this.isPaginating = false,
    this.hasError = false,
  }) : items = List.from(items);

  bool get hasPaging => pagingMethod != null && nextMetadata != null;
}
