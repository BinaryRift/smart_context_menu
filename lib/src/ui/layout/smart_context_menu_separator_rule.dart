import '../../domain/smart_context_menu_item.dart';

/// Which separators of a menu level or a row are shown.
///
/// Separators next to each other form a run; items that are not shown
/// between them do not break it. A run shows at most one separator: the
/// last one with a child, which titles the items after it, or else the
/// first band. A run at the end shows nothing, and a run at the start shows
/// only a title. So items shown on condition can keep their separators
/// without extra checks.
abstract final class SmartContextMenuSeparatorRule {
  /// Whether the separator at [index] of [items] is shown.
  ///
  /// [isHidden] tells the items that are not shown, such as a row without
  /// cells.
  static bool showsAt(
    List<SmartContextMenuItem> items,
    int index, {
    bool Function(SmartContextMenuItem item) isHidden = _shown,
  }) {
    bool isGap(SmartContextMenuItem item) =>
        item is SmartContextMenuSeparatorItem || isHidden(item);

    var start = index;
    while (start > 0 && isGap(items[start - 1])) {
      start--;
    }
    var end = index;
    while (end < items.length - 1 && isGap(items[end + 1])) {
      end++;
    }
    // Nothing to separate or to title after the run.
    if (end == items.length - 1) return false;

    int? lastTitle;
    int? firstBand;
    for (var i = start; i <= end; i++) {
      final item = items[i];
      if (item is! SmartContextMenuSeparatorItem) continue;
      if (item.child != null) {
        lastTitle = i;
      } else {
        firstBand ??= i;
      }
    }
    if (lastTitle != null) return index == lastTitle;
    return start > 0 && index == firstBand;
  }

  static bool _shown(SmartContextMenuItem item) => false;
}
