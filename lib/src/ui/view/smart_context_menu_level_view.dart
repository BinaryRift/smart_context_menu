import 'package:flutter/widgets.dart';

import '../../controllers/smart_context_menu_overlay_controller.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/transitions/tricky_transition.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_level.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../widgets/smart_context_menu_back_item.dart';
import '../widgets/smart_context_menu_loader.dart';
import '../widgets/smart_context_menu_pagination_trigger.dart';
import '../widgets/smart_context_menu_retry_item.dart';
import 'smart_context_menu_item_view.dart';

/// The content of a menu [level]: its items, the back item of a submenu
/// and the loading, retry and paging rows.
final class SmartContextMenuLevelView extends StatelessWidget {
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
            top: -0.5,
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
      child = SmartContextMenuLoader(
        key: ServiceItemKey.loader,
        verticalPadding: config.style.loaderVerticalPadding,
      );
      isTransitionState = true;
    } else if (hasError && relativeIndex == itemsCount) {
      child = SmartContextMenuRetryItem(
        config: config,
        hoverController: hoverController,
        onRetry: () => controller.onRetryLoad(level),
      );
      isTransitionState = true;
    } else if (!hasError && hasPaging && relativeIndex == itemsCount) {
      child = SmartContextMenuPaginationTrigger(
        key: ServiceItemKey.pagingTrigger(itemsCount),
        onVisible: () => controller.handlePagination(level),
        loaderVerticalPadding: config.style.loaderVerticalPadding,
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

  Widget _buildMenuItem(int relativeIndex, int itemsCount) {
    if (relativeIndex < 0 || relativeIndex >= itemsCount) {
      return const SizedBox.shrink();
    }

    final item = level.items[relativeIndex];
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
