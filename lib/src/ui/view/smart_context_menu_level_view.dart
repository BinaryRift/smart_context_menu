import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

import '../../controllers/smart_context_menu_overlay_controller.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/transitions/tricky_transition.dart';
import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../../domain/smart_context_menu_level.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../widgets/smart_context_menu_back_item.dart';
import '../widgets/smart_context_menu_divider.dart';
import '../widgets/smart_context_menu_pagination_trigger.dart';
import '../widgets/smart_context_menu_retry_row.dart';
import 'smart_context_menu_item_view.dart';

/// The content of a menu [level]: its items, the back item of a submenu
/// and the loading, retry and paging rows.
final class SmartContextMenuLevelView extends StatelessWidget {
  // Covers the gap between the menu border and the pinned back item that
  // shows while the items scroll under it.
  static const double _backItemOverlap = 0.5;

  final SmartMenuLevel level;
  final SmartContextMenuOverlayController controller;
  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;

  const SmartContextMenuLevelView({
    super.key,
    required this.level,
    required this.controller,
    required this.config,
    required this.hoverController,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBack = level.hasBack;
    final bool hasPaging = level.hasPaging;
    final bool hasError = level.hasError;
    final int itemsCount = level.items.length;
    final int headerOffset = hasBack ? 1 : 0;

    return Stack(
      children: [
        ListView.builder(
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
        ),
        if (hasBack)
          Positioned(
            top: -_backItemOverlap,
            left: 0,
            right: 0,
            child: SmartContextMenuBackItem(
              config: config,
              hoverController: hoverController,
              onTap: controller.popSubmenu,
            ),
          ),
      ],
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
    final items = level.items;
    if (!config.style.dividersBetweenItems ||
        items.isEmpty ||
        items.last.isSeparator) {
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
    return SmartContextMenuItem.loading(
      padding: EdgeInsets.symmetric(
        vertical: config.style.loaderVerticalPadding,
      ),
      child: const Center(
        child: CupertinoActivityIndicator(
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
    if (item.isSeparator && !_showsSeparatorAt(relativeIndex)) {
      return const SizedBox.shrink();
    }

    final itemView = _buildItemView(item);
    if (!config.style.dividersBetweenItems) return itemView;

    // The item stays the first child, so it keeps its state when the divider
    // appears, for example after the next page loads.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        itemView,
        if (relativeIndex < itemsCount - 1 &&
            _needsDividerBetween(item, level.items[relativeIndex + 1]))
          SmartContextMenuDivider(style: config.style),
      ],
    );
  }

  static bool _needsDividerBetween(
    SmartContextMenuItem item,
    SmartContextMenuItem next,
  ) => !item.isSeparator && !next.isSeparator;

  // A separator is shown only between items: not at the start or the end
  // of the level, and only the first one of several in a row. Items shown
  // on condition can keep their separators without extra checks.
  bool _showsSeparatorAt(int index) {
    final items = level.items;
    if (index > 0 && items[index - 1].isSeparator) return false;
    final hasItemBefore = items.take(index).any((item) => !item.isSeparator);
    final hasItemAfter = items.skip(index + 1).any((item) => !item.isSeparator);
    return hasItemBefore && hasItemAfter;
  }

  Widget _buildItemView(SmartContextMenuItem item) {
    if (item.asyncItem != null) {
      final parentId = item.id;
      return SmartContextMenuItemView.async(
        key: ValueKey(item.id),
        item: item,
        config: config,
        onTap: controller.handleItemTap,
        cachedItem: controller.cache.resolvedItems[parentId],
        onLoaded: (item) => controller.cache.resolvedItems[parentId] = item,
        hoverController: hoverController,
      );
    }
    return SmartContextMenuItemView(
      key: ValueKey(item.id),
      onTap: controller.handleItemTap,
      item: item,
      config: config,
      hoverController: hoverController,
    );
  }
}
