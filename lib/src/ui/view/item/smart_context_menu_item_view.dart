import 'dart:async';

// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';

import '../../../core/ui/motion/tokens/motion_durations.dart';
import '../../../core/ui/motion/transitions/tricky_transition.dart';
import '../../../domain/smart_context_menu_config.dart';
import '../../../domain/smart_context_menu_item.dart';
import '../../../domain/smart_context_menu_item_state.dart';
import '../../../domain/smart_context_menu_row_size.dart';
import '../../../domain/smart_context_menu_style.dart';
import '../../extensions/render_object_ext.dart';
import '../../keys/item_content_key.dart';
import '../../keys/service_item_key.dart';
import '../../state/smart_context_menu_hover_controller.dart';
import '../../theme/smart_context_menu_item_colors.dart';
import 'smart_context_menu_item_cell.dart';
import 'smart_context_menu_item_row.dart';
import 'smart_context_menu_status_content.dart';

final class SmartContextMenuItemView extends StatefulWidget {
  final SmartContextMenuItem item;
  final SmartContextMenuConfig config;
  final SmartContextMenuAsyncResult? cachedItem;
  final void Function(SmartContextMenuAsyncResult item)? onLoaded;
  final VoidCallback? onRetry;
  final ValueChanged<SmartContextMenuItem>? onTap;
  final SmartContextMenuHoverController? hoverController;

  /// The size of the cell if the item is shown in a row, or null in a list.
  final SmartContextMenuRowSize? rowSize;

  const SmartContextMenuItemView({
    super.key,
    required this.item,
    required this.config,
    this.onTap,
    this.hoverController,
    this.rowSize,
  }) : cachedItem = null,
       onLoaded = null,
       onRetry = null;

  const SmartContextMenuItemView.async({
    super.key,
    required this.item,
    required this.config,
    this.onTap,
    required this.onLoaded,
    this.cachedItem,
    this.hoverController,
    this.rowSize,
  }) : onRetry = null;

  const SmartContextMenuItemView.error({
    super.key,
    required this.item,
    required this.config,
    required this.onRetry,
    this.hoverController,
    this.rowSize,
  }) : onTap = null,
       cachedItem = null,
       onLoaded = null;

  @override
  State<SmartContextMenuItemView> createState() =>
      _SmartContextMenuItemViewState();
}

final class _SmartContextMenuItemViewState
    extends State<SmartContextMenuItemView> {
  bool _isPressed = false;
  bool _isHovered = false;
  bool get _isHighlight => _isPressed || _isHovered;

  /// Runs from the moment the item is pressed: a tapped item stays
  /// pressed until it ends, so even a quick tap shows the highlight.
  Timer? _minHighlightTimer;

  /// Whether the item is tapped and stays pressed until
  /// [_minHighlightTimer] ends.
  bool _isTapHighlightHeld = false;

  /// The item loaded by an async item or built by a listenable item.
  SmartContextMenuAsyncResult? _resolvedItem;
  Object? _error;
  bool get _isStatus => _error == null && _item is SmartContextMenuStatusItem;
  bool get _isDisabled =>
      _isStatus ||
      !_hasInteractions ||
      switch (_item) {
        SmartContextMenuContentItem(:final isDisabled) => isDisabled,
        _ => false,
      };

  /// Whether the item does something on tap: a failed load retries, other
  /// items act by their kind. [widget.onTap] does not count: the menu passes
  /// it to every item to run their actions.
  bool get _hasInteractions =>
      _error != null ||
      switch (_item) {
        SmartContextMenuSimpleItem(:final onTap, :final closeOnTap) =>
          onTap != null || closeOnTap,
        SmartContextMenuSubmenuItem() ||
        SmartContextMenuAsyncSubmenuItem() ||
        SmartContextMenuPagingSubmenuItem() ||
        SmartContextMenuAsyncItem() => true,
        SmartContextMenuListenableItem() ||
        SmartContextMenuStatusItem() ||
        SmartContextMenuSeparatorItem() ||
        SmartContextMenuRowItem() => false,
      };
  SmartContextMenuItem get _item => _resolvedItem ?? widget.item;
  SmartContextMenuConfig get _config => widget.config;
  SmartContextMenuStyle get _style => widget.config.style;

  // A failed load keeps the padding of the loading item, so the item does
  // not change its size.
  EdgeInsets get _padding =>
      switch (_item) {
        SmartContextMenuContentItem(:final padding) ||
        SmartContextMenuStatusItem(:final padding) => padding,
        _ => null,
      } ??
      switch (widget.item) {
        SmartContextMenuAsyncItem(:final loading) when _error != null =>
          loading.padding,
        _ => null,
      } ??
      switch (widget.rowSize) {
        null => _style.itemPadding,
        SmartContextMenuRowSize.small => _style.rowStyle.smallItemPadding,
        SmartContextMenuRowSize.medium => _style.rowStyle.mediumItemPadding,
      };

  static Listenable? _listenableOf(SmartContextMenuItem item) => switch (item) {
    SmartContextMenuListenableItem(:final listenable) => listenable,
    _ => null,
  };

  @override
  void initState() {
    super.initState();

    if (widget.onRetry != null) {
      _error = "External error";
    }

    switch (widget.item) {
      case SmartContextMenuAsyncItem item:
        if (widget.cachedItem case final cachedItem?) {
          _resolvedItem = cachedItem;
        } else {
          _loadAsyncData(item);
        }
      case SmartContextMenuListenableItem item:
        item.listenable.addListener(_onListenableChanged);
        _buildListenableItem(item);
      default:
    }
  }

  @override
  void didUpdateWidget(SmartContextMenuItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final listenable = _listenableOf(widget.item);
    final oldListenable = _listenableOf(oldWidget.item);
    if (listenable != oldListenable) {
      oldListenable?.removeListener(_onListenableChanged);
      listenable?.addListener(_onListenableChanged);
    }
    if (widget.item case SmartContextMenuListenableItem item) {
      _buildListenableItem(item);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.hoverController?.removeListener(_handleGlobalPointer);
    widget.hoverController?.addListener(_handleGlobalPointer);
  }

  @override
  void dispose() {
    _minHighlightTimer?.cancel();
    widget.hoverController?.removeListener(_handleGlobalPointer);
    widget.hoverController?.forget(this);
    _listenableOf(widget.item)?.removeListener(_onListenableChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Without MetaData, drag-to-select does not find the separator.
    if (_item case SmartContextMenuSeparatorItem item) {
      return _buildSeparator(item);
    }

    final colors = SmartContextMenuItemColors.resolve(
      context,
      item: _item,
      style: _style,
      isPressed: _isPressed,
      isHovered: _isHovered,
      isBack: widget.key == ServiceItemKey.back,
    );
    final (isDisabled, isDestructive) = switch (_item) {
      SmartContextMenuContentItem item => (item.isDisabled, item.isDestructive),
      _ => (false, false),
    };
    final itemState = SmartContextMenuItemState(
      isPressed: _isPressed,
      isHovered: _isHovered,
      isDisabled: isDisabled,
      isDestructive: isDestructive,
      foregroundColor: colors.foreground,
      rowSize: widget.rowSize,
    );

    final item = MetaData(
      metaData: widget.key,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: MotionDurations.instant,
        color: colors.overlay,
        padding: _padding,
        child: AnimatedSwitcher(
          duration: MotionDurations.fast,
          transitionBuilder: (child, animation) =>
              TrickyTransition(animation: animation, child: child),
          // A cell lower than its row keeps its content at the top.
          layoutBuilder: widget.rowSize == null
              ? AnimatedSwitcher.defaultLayoutBuilder
              : (currentChild, previousChildren) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previousChildren, ?currentChild],
                ),
          child: _buildContent(itemState),
        ),
      ),
    );
    if (widget.hoverController == null) return item;

    // The mouse tracker updates the regions after every frame, so the hover
    // follows the item under a stationary cursor as the menu changes.
    return MouseRegion(
      onEnter: _onCursor,
      onHover: _onCursor,
      onExit: (_) => widget.hoverController?.unhover(this),
      child: item,
    );
  }

  /// An interactive child of the item handles the cursor itself.
  void _onCursor(PointerEvent event) {
    final controller = widget.hoverController;
    final key = widget.key;
    if (controller == null || key == null) return;
    final keyAt = context.findRenderObject()?.findMenuItemKeyAt(event.position);
    if (keyAt == key) {
      controller.hover(this, key);
    } else {
      controller.unhover(this);
    }
  }

  // A row stretches its separators to its height.
  Widget _buildSeparator(SmartContextMenuSeparatorItem item) {
    if (item.child case final child?) return child;
    final color = CupertinoDynamicColor.resolve(_style.separatorColor, context);
    if (widget.rowSize != null) {
      return SizedBox(
        width: _style.separatorThickness,
        child: ColoredBox(color: color),
      );
    }
    return Container(height: _style.separatorThickness, color: color);
  }

  Widget _buildContent(SmartContextMenuItemState state) {
    return switch (_item) {
      SmartContextMenuStatusItem item => SmartContextMenuStatusContent(
        key: switch (item) {
          SmartContextMenuLoadingItem() => ItemContentKey.loading,
          SmartContextMenuErrorItem() => ItemContentKey.error,
          SmartContextMenuEmptyItem() => ItemContentKey.empty,
        },
        item: item,
        config: _config,
        foregroundColor: state.foregroundColor,
        // The menu retries the failed load on tap.
        retries: _error != null,
        rowSize: widget.rowSize,
      ),
      SmartContextMenuContentItem item => KeyedSubtree(
        key: ItemContentKey.content,
        child:
            item.customBuilder?.call(context, state) ??
            switch (widget.rowSize) {
              null => SmartContextMenuItemRow.content(
                item: item,
                style: _style,
                foregroundColor: state.foregroundColor,
              ),
              final size => SmartContextMenuItemCell.content(
                item: item,
                size: size,
                padding: _padding,
                style: _style,
                foregroundColor: state.foregroundColor,
              ),
            },
      ),
      // Async and listenable items show the item they load or build, and
      // a separator and a row are built without the item frame.
      SmartContextMenuAsyncItem() ||
      SmartContextMenuListenableItem() ||
      SmartContextMenuSeparatorItem() ||
      SmartContextMenuRowItem() => const SizedBox.shrink(),
    };
  }

  void _handleTap() {
    if (_isStatus) return;
    if (_error != null) {
      if (widget.onRetry case final onRetry?) {
        onRetry();
      } else if (widget.item case SmartContextMenuAsyncItem item) {
        _loadAsyncData(item);
      }
      return;
    }
    if (_item case SmartContextMenuContentItem(isDisabled: true)) return;
    widget.onTap?.call(_item);
  }

  Future<void> _loadAsyncData(SmartContextMenuAsyncItem item) async {
    setState(() {
      _resolvedItem = item.loading;
      _error = null;
    });

    try {
      final result = await item.asyncItem().timeout(item.timeout);

      if (mounted) {
        widget.onLoaded?.call(result);
        setState(() {
          _resolvedItem = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _resolvedItem = item.error;
        });
      }
    }
  }

  void _onListenableChanged() {
    if (widget.item case SmartContextMenuListenableItem item) {
      setState(() => _buildListenableItem(item));
    }
  }

  void _buildListenableItem(SmartContextMenuListenableItem item) {
    _resolvedItem = item.builder();
    final (:isPressed, :isHovered) = _pointerState;
    _isPressed = isPressed;
    _isHovered = isHovered;
    _isTapHighlightHeld = false;
  }

  /// The pointer state of the item in [widget.hoverController].
  ({bool isPressed, bool isHovered}) get _pointerState {
    final controller = widget.hoverController;
    if (controller == null || controller.value != widget.key || _isDisabled) {
      return (isPressed: false, isHovered: false);
    }
    return (
      isPressed: !controller.isPointerHover,
      isHovered: controller.isCursor,
    );
  }

  void _handleGlobalPointer() {
    final bool isReleased = widget.hoverController?.isPointerReleased ?? false;
    final bool wasHighlight = _isHighlight;
    final (isPressed: isPointerPressed, :isHovered) = _pointerState;

    if (isPointerPressed && (!_isPressed || _isTapHighlightHeld)) {
      // Pressed, or pressed again before the highlight of the tap ended.
      _isTapHighlightHeld = false;
      _startMinHighlightTimer();
    }
    final isPressed = isPointerPressed || _isTapHighlightHeld;

    if (isPressed != _isPressed || isHovered != _isHovered) {
      setState(() {
        _isPressed = isPressed;
        _isHovered = isHovered;
      });
      if (!wasHighlight && isPressed) _generateFeedback();
    }

    if (isReleased && isPointerPressed) {
      _handleTap();
      _clearHighlightAfterTap();
    }
  }

  void _startMinHighlightTimer() {
    _minHighlightTimer?.cancel();
    _minHighlightTimer = Timer(MotionDurations.ultraFast, _onMinHighlightEnd);
  }

  void _clearHighlightAfterTap() {
    if (_minHighlightTimer?.isActive ?? false) {
      _isTapHighlightHeld = true;
    } else {
      setState(() => _isPressed = false);
    }
  }

  void _onMinHighlightEnd() {
    if (!_isTapHighlightHeld || !mounted) return;
    _isTapHighlightHeld = false;
    setState(() => _isPressed = false);
  }

  void _generateFeedback() {
    if (_config.enableHaptics) HapticFeedback.selectionClick();
  }
}
