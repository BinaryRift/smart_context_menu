import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoDynamicColor;
import 'package:flutter/material.dart';

import '../../controllers/smart_context_menu_overlay_controller.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/transitions/tricky_transition.dart';
import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../../domain/smart_context_menu_level.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import 'smart_context_menu_item_view.dart';

part '../widgets/pagination_trigger.dart';

/// The content of the current menu level: its items, the back item
/// of a submenu and the loading, retry and paging rows.
final class SmartContextMenuLevelView extends StatelessWidget {
  final SmartContextMenuOverlayController controller;
  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;

  const SmartContextMenuLevelView({
    super.key,
    required this.controller,
    required this.config,
    required this.hoverController,
  });

  @override
  Widget build(BuildContext context) {
    final level = controller.currentLevel;
    final bool hasBack = controller.stackLength > 1;
    final bool hasPaging = level.hasPaging;
    final bool hasError = level.hasError;
    final int itemsCount = level.items.length;
    final int headerOffset = hasBack ? 1 : 0;
    final int totalCount = controller.calculateTotalItemCount();

    return Stack(
      children: [
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: totalCount,
          itemBuilder: (context, index) => _routeItem(
            context,
            level: level,
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
            child: GestureDetector(
              onPanStart: (_) {},
              behavior: HitTestBehavior.opaque,
              child: _buildBluredBackButton(context),
            ),
          ),
      ],
    );
  }

  Widget _routeItem(
    BuildContext context, {
    required SmartMenuLevel level,
    required int index,
    required bool hasBack,
    required int headerOffset,
    required int itemsCount,
    required bool hasPaging,
    required bool hasError,
  }) {
    if (hasBack && index == 0) {
      return Visibility.maintain(
        visible: false,
        child: IgnorePointer(
          child: _buildBackButton(context, key: ServiceItemKey.backPlaceholder),
        ),
      );
    }

    final int relativeIndex = index - headerOffset;

    final Widget child;
    final bool isTransitionState;

    if (controller.isLoading && itemsCount == 0) {
      child = _buildInitialLoader();
      isTransitionState = true;
    } else if (hasError && relativeIndex == itemsCount) {
      child = _buildRetryButton(hasPaging);
      isTransitionState = true;
    } else if (!hasError && hasPaging && relativeIndex == itemsCount) {
      child = _buildPagingTrigger(itemsCount);
      isTransitionState = true;
    } else {
      child = _buildMenuItem(level, relativeIndex, itemsCount);
      isTransitionState = false;
    }

    return AnimatedSwitcher(
      duration: isTransitionState ? MotionDurations.fast : Duration.zero,
      transitionBuilder: (child, animation) {
        return isTransitionState
            ? TrickyTransition(animation: animation, child: child)
            : child;
      },
      child: child,
    );
  }

  Widget _buildMenuItem(
    SmartMenuLevel level,
    int relativeIndex,
    int itemsCount,
  ) {
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

  Widget _buildBluredBackButton(BuildContext context) {
    Widget child = Container(
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          config.menuColor ?? SmartContextMenuDefaults.menuColor,
          context,
        ),
        borderRadius: config.backButtonBorderRadius,
      ),
      child: _buildBackButton(context, key: ServiceItemKey.back),
    );

    if (config.backButtonBlur != null) {
      return ClipRRect(
        borderRadius: config.backButtonBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: config.backButtonBlur!.sigmaX,
            sigmaY: config.backButtonBlur!.sigmaY,
          ),
          child: child,
        ),
      );
    }
    return child;
  }

  Widget _buildBackButton(BuildContext context, {required Key key}) {
    return SmartContextMenuItemView(
      key: key,
      onTap: (_) => controller.popSubmenu(),
      config: config,
      hoverController: hoverController,
      item: SmartContextMenuItem.simple(
        closeOnTap: false,
        title: config.labels.back,
        titleStyle: SmartContextMenuDefaults.textStyle.copyWith(
          fontWeight: FontWeight.w600,
        ),
        leading: Icon(
          SmartContextMenuDefaults.backIcon,
          size: config.defaultIconSize,
          color: CupertinoDynamicColor.maybeResolve(
            config.defaultIconColor,
            context,
          ),
        ),
        hasDivider: true,
        customDivider: _buildDivider(context),
      ),
    );
  }

  Widget _buildRetryButton(bool hasPagination) {
    return SmartContextMenuItemView.error(
      key: ServiceItemKey.retry,
      onRetry: () => controller.onRetryLoad(hasPagination),
      config: config,
      hoverController: hoverController,
      item: SmartContextMenuItem.simple(
        title: config.labels.retry,
        leading: Icon(
          SmartContextMenuDefaults.errorIcon,
          size: config.defaultIconSize,
        ),
        trailing: Icon(
          SmartContextMenuDefaults.retryIcon,
          size: config.defaultIconSize,
        ),
      ),
    );
  }

  Widget _buildInitialLoader() =>
      _buildLoader(key: const ValueKey("initial_loader"));

  Widget _buildPagingTrigger(int itemsCount) {
    return _PaginationTrigger(
      key: ValueKey("paging_trigger_${itemsCount}_${controller.stackLength}"),
      onVisible: controller.handlePagination,
      child: _buildLoader(),
    );
  }

  Widget _buildLoader({Key? key}) {
    return Container(
      key: key ?? const ValueKey("menu_loader"),
      padding: const EdgeInsets.symmetric(
        vertical: SmartContextMenuDefaults.loaderVerticalPadding,
      ),
      alignment: Alignment.center,
      child: const CupertinoActivityIndicator(radius: 12),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: CupertinoDynamicColor.resolve(
        SmartContextMenuDefaults.dividerColor,
        context,
      ),
    );
  }
}
