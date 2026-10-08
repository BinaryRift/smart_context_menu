import '../../domain/smart_context_menu_item.dart';
import '../../domain/smart_context_menu_paging_metadata.dart';

typedef PagingData = (
  List<SmartContextMenuItem> items,
  SmartContextMenuPagingMetadata? meta,
);

final class SmartContextMenuCache {
  /// Resolved items of [SmartContextMenuItem.async].
  final Map<String, SmartContextMenuItem> resolvedItems = {};

  /// Fully loaded submenu lists (`asyncChildren`).
  final Map<String, List<SmartContextMenuItem>> submenus = {};

  /// Paging state: accumulated items and the latest metadata.
  final Map<String, PagingData> paging = {};

  void clear() {
    resolvedItems.clear();
    submenus.clear();
    paging.clear();
  }
}
