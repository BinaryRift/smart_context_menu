// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

import '../../controllers/smart_context_menu_overlay_controller.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/transitions/tricky_transition.dart';
import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../../domain/smart_context_menu_level.dart';
import '../../domain/smart_context_menu_row_size.dart';
import '../keys/service_item_key.dart';
import '../layout/smart_context_menu_separator_rule.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../widgets/smart_context_menu_back_item.dart';
import '../widgets/smart_context_menu_divider.dart';
import '../widgets/smart_context_menu_pagination_trigger.dart';
import '../widgets/smart_context_menu_retry_row.dart';
import '../widgets/smart_context_menu_row_layout.dart';
import '../widgets/smart_context_menu_swipe_back_exclusion.dart';
import 'item/smart_context_menu_item_view.dart';
import 'smart_context_menu_submenu_view.dart';

/// The content of a menu [level]: its items, the back item of a submenu
/// and the loading, retry and paging rows.
final class SmartContextMenuLevelView extends StatelessWidget {
  final SmartMenuLevel level;
  final SmartContextMenuOverlayController controller;
  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;
  final Color? glassTint;

  const SmartContextMenuLevelView({
    super.key,
    required this.level,
    required this.controller,
    required this.config,
    required this.hoverController,
    this.glassTint,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBack = level.hasBack;
    final bool hasPaging = level.hasPaging;
    final bool hasError = level.hasError;
    final int itemsCount = level.items.length;
    final int headerOffset = hasBack ? 1 : 0;

    final list = ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemCount: level.rowCount,
      itemBuilder: (context, index) => _routeItem(
        index: index,
        hasBack: hasBack,
        headerOffset: headerOffset,
        itemsCount: itemsCount,
        hasPaging: hasPaging,
        hasError: hasError,
      ),
    );
    if (!hasBack) return list;
    return SmartContextMenuSubmenuView(
      list: list,
      config: config,
      hoverController: hoverController,
      onBack: controller.popSubmenu,
      glassTint: glassTint,
    );
  }

  Widget _routeItem({
    required int index,
    required bool hasBack,
    required int headerOffset,
    required int itemsCount,
    required bool hasPaging,
    required bool hasError,
  }) {
    if (hasBack && index == 0) {
      return SmartContextMenuBackItem.placeholder(
        config: config,
        hoverController: hoverController,
        onTap: controller.popSubmenu,
      );
    }

    final int relativeIndex = index - headerOffset;

    final Widget child;
    final bool isTransitionState;

    if (level.isLoading && itemsCount == 0) {
      child = _buildLoadingRow();
      isTransitionState = true;
    } else if (level.isEmpty && relativeIndex == 0) {
      child = SmartContextMenuItemView(
        key: ServiceItemKey.empty,
        item: level.emptyItem ?? SmartContextMenuItem.empty(),
        config: config,
        hoverController: hoverController,
      );
      isTransitionState = true;
    } else if (hasError && relativeIndex == itemsCount) {
      child = _dividedFromItems(
        SmartContextMenuRetryRow(
          item: level.errorItem,
          config: config,
          hoverController: hoverController,
          onRetry: () => controller.onRetryLoad(level),
        ),
      );
      isTransitionState = true;
    } else if (!hasError && hasPaging && relativeIndex == itemsCount) {
      child = SmartContextMenuPaginationTrigger(
        key: ServiceItemKey.pagingTrigger(itemsCount),
        onVisible: () => controller.handlePagination(level),
        child: _buildPageLoadingRow(),
      );
      isTransitionState = true;
    } else {
      child = _buildMenuItem(relativeIndex, itemsCount);
      isTransitionState = false;
    }

    return AnimatedSwitcher(
      duration: isTransitionState ? MotionDurations.fast : Duration.zero,
      transitionBuilder: _transitionBuilder,
      child: child,
    );
  }

  // A static method stays equal between builds. AnimatedSwitcher rebuilds
  // the transitions of all its children when its transitionBuilder changes,
  // so a leaving paging trigger would be mounted again and load one more
  // page.
  static Widget _transitionBuilder(Widget child, Animation<double> animation) {
    return TrickyTransition(animation: animation, child: child);
  }

  Widget _buildLoadingRow() {
    return SmartContextMenuItemView(
      key: ServiceItemKey.loader,
      item: level.loadingItem ?? _defaultLoadingItem(),
      config: config,
      hoverController: hoverController,
    );
  }

  // A loading item of the app is a row of the list, unlike the default
  // loader.
  Widget _buildPageLoadingRow() {
    final row = _buildLoadingRow();
    return level.loadingItem == null ? row : _dividedFromItems(row);
  }

  // A row after the items is divided from them as they are from each other.
  Widget _dividedFromItems(Widget row) {
    final last = level.items.where((item) => !_isHidden(item)).lastOrNull;
    if (!config.style.dividersBetweenItems ||
        last == null ||
        last is SmartContextMenuSeparatorItem) {
      return row;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SmartContextMenuDivider(style: config.style),
        row,
      ],
    );
  }

  SmartContextMenuLoadingItem _defaultLoadingItem() {
    final statusStyle = config.style.statusStyle;
    return SmartContextMenuItem.loading(
      padding: EdgeInsets.symmetric(
        vertical: statusStyle.loaderVerticalPadding,
      ),
      child: Center(
        child:
            statusStyle.loadingIndicator ??
            const CupertinoActivityIndicator(
              radius: SmartContextMenuDefaults.loaderIndicatorRadius,
            ),
      ),
    );
  }

  Widget _buildMenuItem(int relativeIndex, int itemsCount) {
    if (relativeIndex < 0 || relativeIndex >= itemsCount) {
      return const SizedBox.shrink();
    }

    final item = level.items[relativeIndex];
    if (_isHidden(item) ||
        item is SmartContextMenuSeparatorItem &&
            !SmartContextMenuSeparatorRule.showsAt(
              level.items,
              relativeIndex,
              isHidden: _isHidden,
            )) {
      return const SizedBox.shrink();
    }

    final itemView = switch (item) {
      SmartContextMenuRowItem() => _buildRow(item),
      _ => _buildItemView(item),
    };
    if (!config.style.dividersBetweenItems) return itemView;

    // The item stays the first child, so it keeps its state when the divider
    // appears, for example after the next page loads.
    final next = level.items
        .skip(relativeIndex + 1)
        .where((item) => !_isHidden(item))
        .firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        itemView,
        if (next != null && _needsDividerBetween(item, next))
          SmartContextMenuDivider(style: config.style),
      ],
    );
  }

  static bool _needsDividerBetween(
    SmartContextMenuItem item,
    SmartContextMenuItem next,
  ) =>
      item is! SmartContextMenuSeparatorItem &&
      next is! SmartContextMenuSeparatorItem;

  // A row without cells to show is left out, like a separator at the edge.
  static bool _isHidden(SmartContextMenuItem item) =>
      item is SmartContextMenuRowItem && _cellsOf(item).isEmpty;

  /// The items of [row] with their flex, without the separators that are
  /// not shown: the same rules apply as in a level.
  static List<(SmartContextMenuItem, int?)> _cellsOf(
    SmartContextMenuRowItem row,
  ) {
    final entries = row.children.map(_unwrap).toList();
    final items = [for (final (item, _) in entries) item];
    return [
      for (var i = 0; i < entries.length; i++)
        if (items[i] is! SmartContextMenuSeparatorItem)
          entries[i]
        else if (SmartContextMenuSeparatorRule.showsAt(items, i))
          (items[i], null),
    ];
  }

  static (SmartContextMenuItem, int?) _unwrap(SmartContextMenuRowEntry entry) {
    return switch (entry) {
      SmartContextMenuRowFlex(:final flex, :final child) => (
        _unwrap(child).$1,
        flex,
      ),
      SmartContextMenuItem item => (item, null),
    };
  }

  // The row is not an item for drag-to-select and hover: its cells are.
  Widget _buildRow(SmartContextMenuRowItem row) {
    final style = config.style;
    final cells = _cellsOf(row);
    final hasDividers =
        row.dividersBetweenChildren ?? style.dividersBetweenItems;
    final children = <Widget>[];
    for (var i = 0; i < cells.length; i++) {
      final (item, flex) = cells[i];
      final isSeparator = item is SmartContextMenuSeparatorItem;
      // No divider next to a separator.
      if (hasDividers &&
          i > 0 &&
          !isSeparator &&
          cells[i - 1].$1 is! SmartContextMenuSeparatorItem) {
        children.add(SmartContextMenuRowDivider(style: style));
      }
      final view = _buildItemView(item, rowSize: row.size);
      children.add(
        isSeparator
            ? view
            : SmartContextMenuRowCell(flex: flex ?? 1, child: view),
      );
    }
    return SmartContextMenuSwipeBackExclusion(
      key: ValueKey(row.id),
      excludes: !row.enableSwipeBack,
      child: SmartContextMenuRowLayout(
        padding: row.padding ?? style.rowStyle.padding,
        childrenGap: row.childrenGap ?? style.rowStyle.childrenGap,
        children: children,
      ),
    );
  }

  Widget _buildItemView(
    SmartContextMenuItem item, {
    SmartContextMenuRowSize? rowSize,
  }) {
    if (item is SmartContextMenuAsyncItem) {
      final parentId = item.id;
      return SmartContextMenuItemView.async(
        key: ValueKey(item.id),
        item: item,
        config: config,
        onTap: controller.handleItemTap,
        cachedItem: controller.cache.resolvedItems[parentId],
        onLoaded: (item) => controller.cache.resolvedItems[parentId] = item,
        hoverController: hoverController,
        rowSize: rowSize,
      );
    }
    return SmartContextMenuItemView(
      key: ValueKey(item.id),
      onTap: controller.handleItemTap,
      item: item,
      config: config,
      hoverController: hoverController,
      rowSize: rowSize,
    );
  }
}
