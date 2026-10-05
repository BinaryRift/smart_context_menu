import 'dart:ui' show ImageFilter;
import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoDynamicColor;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show RenderMetaData, RenderPointerListener;

import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_scales.dart';
import '../../core/ui/motion/tokens/motion_slides.dart';
import '../../core/ui/motion/tokens/motion_traslation.dart';
import '../../controllers/smart_context_menu_overlay_controller.dart';
import '../../core/ui/motion/transitions/tricky_transition.dart';
import '../../domain/smart_context_menu_navigator.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../widgets/smart_context_menu_blur_box.dart';
import 'smart_context_menu_item_view.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../widgets/smart_context_menu_shadow_box.dart';
import '../widgets/widget_size_listener.dart';

part '../widgets/pagination_trigger.dart';

final class SmartContextMenuView extends StatefulWidget {
  final List<SmartContextMenuItem> initialItems;
  final SmartContextMenuConfig config;
  final ValueNotifier<double> heightNotifier;
  final ValueNotifier<Offset> previewMotionNotifier;

  const SmartContextMenuView({
    super.key,
    required this.initialItems,
    required this.config,
    required this.heightNotifier,
    required this.previewMotionNotifier,
  });

  @override
  State<SmartContextMenuView> createState() => _SmartContextMenuViewState();
}

final class _SmartContextMenuViewState extends State<SmartContextMenuView>
    implements SmartContextMenuNavigator {
  late final SmartContextMenuOverlayController _controller;
  late final SmartContextMenuHoverController _hoverController;
  ValueNotifier<bool>? _scrollingNotifier;
  RenderBox? _menuRenderBox;

  SmartContextMenuConfig get _config => widget.config;

  Color get _menuColor => CupertinoDynamicColor.resolve(
    _config.menuColor ?? SmartContextMenuDefaults.menuColor,
    context,
  );

  BoxDecoration get _defaultDecoration => BoxDecoration(
    color: _menuColor,
    borderRadius: _config.borderRadius,
    border: Border.all(
      color: CupertinoDynamicColor.resolve(
        _config.borderColor ?? SmartContextMenuDefaults.borderColor,
        context,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = SmartContextMenuOverlayController(
      navigator: this,
      initialItems: widget.initialItems,
      enableHaptics: _config.enableHaptics,
    )..addListener(_onControllerUpdate);
    _hoverController = SmartContextMenuHoverController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollingNotifier?.removeListener(_onScrollChanged);
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      _scrollingNotifier = scrollable.position.isScrollingNotifier;
      _scrollingNotifier?.addListener(_onScrollChanged);
    }
  }

  @override
  void dispose() {
    _scrollingNotifier?.removeListener(_onScrollChanged);
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Future<void> dismissWithDelay() async {
    final route = ModalRoute.of(context);
    if (!mounted || route == null) return;

    if (Navigator.of(context).canPop()) {
      final delay = route.transitionDuration * 0.5;
      Navigator.of(context).pop();
      await Future.delayed(delay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final Matrix4 stretchMatrix = Matrix4.identity()
      ..setTranslationRaw(
        _controller.translateX,
        _controller.translateY,
        _controller.translateZ,
      )
      ..setEntry(0, 0, _controller.scaleX)
      ..setEntry(1, 1, _controller.scaleY)
      ..setEntry(2, 2, MotionScale.none.value);

    return WidgetSizeListener(
      onSizeChanged: _onSizeChanged,
      child: SmartContextMenuShadowBox(
        borderRadius: _config.borderRadius,
        child: SmartContextMenuBlurBox(
          config: _config,
          child: AnimatedContainer(
            duration: MotionDurations.fast,
            curve: MotionCurves.quartOut,
            transformAlignment: Alignment.center,
            transform: stretchMatrix,
            width: _config.menuWidth,
            decoration: _config.menuDecoration ?? _defaultDecoration,
            clipBehavior: Clip.antiAlias,
            child: AnimatedSize(
              duration: MotionDurations.standard,
              curve: MotionCurves.quartOut,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * _config.menuHeightFactor,
                ),
                child: Listener(
                  onPointerDown: _onPointerEvent,
                  onPointerMove: _onPointerEvent,
                  onPointerUp: _onPointerEvent,
                  onPointerCancel: _onPointerEvent,
                  child: AnimatedSwitcher(
                    duration: MotionDurations.standard,
                    layoutBuilder: _layoutBuilder,
                    transitionBuilder: _transitionBuilder,
                    child: _buildMenuContent(
                      key: ValueKey(_controller.stackLength),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _layoutBuilder(Widget? currentChild, List<Widget> previousChildren) {
    return Stack(
      alignment:
          _controller.isForward ? Alignment.centerRight : Alignment.centerLeft,
      children: [
        ...previousChildren,
        ?currentChild,
      ],
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    final slideAnimation = CurvedAnimation(
      parent: animation,
      curve: MotionCurves.emphasized,
    );

    return RepaintBoundary(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: _controller.isForward
                ? MotionSlide.rightHalf.offset
                : MotionSlide.leftHalf.offset,
            end: MotionSlide.none.offset,
          ).animate(slideAnimation),
          child: child,
        ),
      ),
    );
  }

  Widget _buildMenuContent({required Key key}) {
    final currentLevel = _controller.currentLevel;
    final bool hasBack = _controller.stackLength > 1;
    final bool hasPaging = currentLevel.hasPaging;
    final bool hasError = currentLevel.hasError;
    final int itemsCount = currentLevel.items.length;
    final int headerOffset = hasBack ? 1 : 0;
    final int totalCount = _controller.calculateTotalItemCount();

    return Stack(
      key: key,
      children: [
        ListView.builder(
          key: key,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: totalCount,
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
            child: GestureDetector(
              onPanStart: (_) {},
              behavior: HitTestBehavior.opaque,
              child: _buildBluredBackButton(),
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
      return Visibility.maintain(
        visible: false,
        child: IgnorePointer(
          child: _buildBackButton(key: ServiceItemKey.backPlaceholder),
        ),
      );
    }

    final int relativeIndex = index - headerOffset;

    final Widget child;
    final bool isTransitionState;

    if (_controller.isLoading && itemsCount == 0) {
      child = _buildInitialLoader();
      isTransitionState = true;
    } else if (hasError && relativeIndex == itemsCount) {
      child = _buildRetryButton(hasPaging);
      isTransitionState = true;
    } else if (!hasError && hasPaging && relativeIndex == itemsCount) {
      child = _buildPagingTrigger(itemsCount);
      isTransitionState = true;
    } else {
      child = _buildMenuItem(relativeIndex, itemsCount);
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

  Widget _buildMenuItem(int relativeIndex, int itemsCount) {
    final items = _controller.currentLevel.items;

    if (relativeIndex < 0 || relativeIndex >= itemsCount) {
      return const SizedBox.shrink();
    }

    final item = items[relativeIndex];
    if (item.asyncItem != null) {
      final parentId = item.id;
      return SmartContextMenuItemView.async(
        key: ValueKey(item.id),
        item: item,
        config: _config,
        onTap: _controller.handleItemTap,
        cachedItem: _controller.cache.resolvedItems[parentId],
        onLoaded: (item) => _controller.cache.resolvedItems[parentId] = item,
        hoverController: _hoverController,
      );
    }
    return SmartContextMenuItemView(
      key: ValueKey(item.id),
      onTap: _controller.handleItemTap,
      item: item,
      config: _config,
      hoverController: _hoverController,
    );
  }

  Widget _buildBluredBackButton() {
    Widget child = Container(
      decoration: BoxDecoration(
        color: _menuColor,
        borderRadius: _config.backButtonBorderRadius,
      ),
      child: _buildBackButton(key: ServiceItemKey.back),
    );

    if (_config.backButtonBlur != null) {
      return ClipRRect(
        borderRadius: _config.backButtonBorderRadius,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _config.backButtonBlur!.sigmaX,
            sigmaY: _config.backButtonBlur!.sigmaY,
          ),
          child: child,
        ),
      );
    }
    return child;
  }

  Widget _buildBackButton({required Key key}) {
    return SmartContextMenuItemView(
      key: key,
      onTap: (_) => _controller.popSubmenu(),
      config: _config,
      hoverController: _hoverController,
      item: SmartContextMenuItem.simple(
        closeOnTap: false,
        title: _config.labels.back,
        titleStyle: SmartContextMenuDefaults.textStyle.copyWith(
          fontWeight: FontWeight.w600,
        ),
        leading: Icon(
          SmartContextMenuDefaults.backIcon,
          size: _config.defaultIconSize,
          color: CupertinoDynamicColor.maybeResolve(
            _config.defaultIconColor,
            context,
          ),
        ),
        hasDivider: true,
        customDivider: _buildDivider(),
      ),
    );
  }

  Widget _buildRetryButton(bool hasPagination) {
    return SmartContextMenuItemView.error(
      key: ServiceItemKey.retry,
      onRetry: () => _controller.onRetryLoad(hasPagination),
      config: _config,
      hoverController: _hoverController,
      item: SmartContextMenuItem.simple(
        title: _config.labels.retry,
        leading: Icon(
          SmartContextMenuDefaults.errorIcon,
          size: _config.defaultIconSize,
        ),
        trailing: Icon(
          SmartContextMenuDefaults.retryIcon,
          size: _config.defaultIconSize,
        ),
      ),
    );
  }

  Widget _buildInitialLoader() =>
      _buildLoader(key: const ValueKey("initial_loader"));

  Widget _buildPagingTrigger(int itemsCount) {
    return _PaginationTrigger(
      key: ValueKey("paging_trigger_${itemsCount}_${_controller.stackLength}"),
      onVisible: _controller.handlePagination,
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

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: CupertinoDynamicColor.resolve(
        SmartContextMenuDefaults.dividerColor,
        context,
      ),
    );
  }

  void _onControllerUpdate() => setState(() {});

  void _onSizeChanged(Size size) {
    final newHeight = size.height.roundToDouble();
    final oldHeight = widget.heightNotifier.value.roundToDouble();

    if (oldHeight != newHeight) {
      widget.heightNotifier.value = newHeight;
    }
  }

  void _onPointerEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _handlePointerDown(event);
    } else if (event is PointerMoveEvent) {
      _handlePointerMove(event);
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _handlePointerReset();
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _controller.setPointerStartPosition(event.position);
    _updateTopmostItem(event.position);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_controller.startPosition == null) return;
    _updateTopmostItem(event.position);
    _setMenuEffect(event.position);
  }

  void _handlePointerReset() {
    final isScrolling = _scrollingNotifier?.value ?? false;
    if (_hoverController.value != null && !isScrolling) {
      _hoverController.setReleased();
    }

    Future.microtask(() {
      _hoverController.update(null);
      _resetMenuEffect();
      _controller.setPointerStartPosition(null);
    });
  }

  void _updateTopmostItem(Offset globalPosition) {
    final bool isScrolling = _scrollingNotifier?.value ?? false;

    if (isScrolling) {
      if (_hoverController.value != null) _hoverController.update(null);
      return;
    }

    _menuRenderBox ??= context.findRenderObject() as RenderBox?;
    final RenderBox? menuBox = _menuRenderBox;
    if (menuBox == null || !menuBox.hasSize) return;

    Key? foundKey;
    bool isChildIntercepted = false;

    bool scan(RenderObject object) {
      if (object is RenderBox && !object.hasSize) return false;

      if (object is! RenderBox) {
        bool found = false;
        object.visitChildren((child) {
          if (!found) found = scan(child);
        });
        return found;
      }

      final Offset offset = object.localToGlobal(Offset.zero);
      final Rect rect = offset & object.size;

      // Pointer is outside the bounds: skip the whole subtree.
      if (!rect.contains(globalPosition)) return false;

      // Check for interactive elements.
      if (object is RenderPointerListener ||
          object is RenderSemanticsGestureHandler) {
        isChildIntercepted = true;
      }

      if (object is RenderMetaData && object.metaData is Key) {
        foundKey = object.metaData as Key;
        isChildIntercepted = false;
        return true;
      }

      final List<RenderObject> children = [];
      object.visitChildren((child) => children.add(child));

      for (final child in children.reversed) {
        if (scan(child)) return true;
      }

      return false;
    }

    scan(menuBox);

    final finalKey = isChildIntercepted ? null : foundKey;

    if (_hoverController.value != finalKey) {
      _hoverController.update(finalKey);
    }
  }

  void _setMenuEffect(Offset position) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final RenderBox? box = renderObject as RenderBox?;
    if (box == null || !box.hasSize) return;
    if (_controller.startPosition == null) return;

    final Offset delta = position - _controller.startPosition!;

    _controller.calculateMenuStretch(delta, box.size);

    widget.previewMotionNotifier.value = Offset(
      _controller.translateX,
      _controller.translateY,
    );
  }

  void _resetMenuEffect() {
    _controller.resetMenuStretch();
    widget.previewMotionNotifier.value = MotionTranslation.none.toOffset;
  }

  void _onScrollChanged() {
    if (_scrollingNotifier?.value == true) {
      _hoverController.update(null);
    }
  }
}
