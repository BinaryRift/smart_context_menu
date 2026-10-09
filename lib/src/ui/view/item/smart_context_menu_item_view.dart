import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';

import '../../../core/ui/motion/tokens/motion_durations.dart';
import '../../../core/ui/motion/transitions/tricky_transition.dart';
import '../../../domain/smart_context_menu_config.dart';
import '../../../domain/smart_context_menu_item.dart';
import '../../../domain/smart_context_menu_item_state.dart';
import '../../../domain/smart_context_menu_style.dart';
import '../../keys/item_content_key.dart';
import '../../keys/service_item_key.dart';
import '../../state/smart_context_menu_hover_controller.dart';
import '../../theme/smart_context_menu_item_colors.dart';
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

  const SmartContextMenuItemView({
    super.key,
    required this.item,
    required this.config,
    this.onTap,
    this.hoverController,
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
  }) : onRetry = null;

  const SmartContextMenuItemView.error({
    super.key,
    required this.item,
    required this.config,
    required this.onRetry,
    this.hoverController,
  }) : onTap = null,
       cachedItem = null,
       onLoaded = null;

  @override
  State<SmartContextMenuItemView> createState() =>
      _SmartContextMenuItemViewState();
}

final class _SmartContextMenuItemViewState
    extends State<SmartContextMenuItemView> {
  bool _isHighlight = false;

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
  bool get _hasInteractions =>
      widget.onRetry != null ||
      widget.onTap != null ||
      switch (_item) {
        SmartContextMenuSimpleItem(:final onTap, :final closeOnTap) =>
          onTap != null || closeOnTap,
        SmartContextMenuSubmenuItem() ||
        SmartContextMenuAsyncSubmenuItem() ||
        SmartContextMenuPagingSubmenuItem() ||
        SmartContextMenuAsyncItem() => true,
        SmartContextMenuListenableItem() ||
        SmartContextMenuStatusItem() ||
        SmartContextMenuSeparatorItem() => false,
      };
  SmartContextMenuItem get _item => _resolvedItem ?? widget.item;
  SmartContextMenuConfig get _config => widget.config;
  SmartContextMenuStyle get _style => widget.config.style;

  // A failed load keeps the padding of the loading item, so the item does
  // not change its size.
  EdgeInsetsGeometry get _padding =>
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
      _style.itemPadding;

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
    widget.hoverController?.removeListener(_handleGlobalPointer);
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
      isPressed: _isHighlight,
      isBack: widget.key == ServiceItemKey.back,
    );
    final (isDisabled, isDestructive) = switch (_item) {
      SmartContextMenuContentItem item => (item.isDisabled, item.isDestructive),
      _ => (false, false),
    };
    final itemState = SmartContextMenuItemState(
      isPressed: _isHighlight,
      isDisabled: isDisabled,
      isDestructive: isDestructive,
      foregroundColor: colors.foreground,
    );

    return MetaData(
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
          child: _buildContent(itemState),
        ),
      ),
    );
  }

  Widget _buildSeparator(SmartContextMenuSeparatorItem item) {
    return item.child ??
        Container(
          height: _style.separatorHeight,
          color: CupertinoDynamicColor.resolve(_style.separatorColor, context),
        );
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
      ),
      SmartContextMenuContentItem item => KeyedSubtree(
        key: ItemContentKey.content,
        child:
            item.customBuilder?.call(context, state) ??
            SmartContextMenuItemRow.content(
              item: item,
              style: _style,
              foregroundColor: state.foregroundColor,
            ),
      ),
      // Async and listenable items show the item they load or build, and
      // a separator is built without the item frame.
      SmartContextMenuAsyncItem() ||
      SmartContextMenuListenableItem() ||
      SmartContextMenuSeparatorItem() => const SizedBox.shrink(),
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
    _isHighlight = widget.hoverController?.value == widget.key && !_isDisabled;
  }

  void _handleGlobalPointer() {
    final activeKey = widget.hoverController?.value;
    final bool isReleased = widget.hoverController?.isPointerReleased ?? false;
    final myKey = widget.key;

    final bool isMeHovered = activeKey == myKey;
    final bool shouldHighlight = isMeHovered && !_isDisabled;

    if (shouldHighlight != _isHighlight) {
      setState(() => _isHighlight = shouldHighlight);
      _generateFeedback(shouldHighlight);
    }

    if (isReleased) {
      if (_isHighlight && !_isDisabled) {
        _handleTap();
      }
      if (_isHighlight) setState(() => _isHighlight = false);
      return;
    }
  }

  void _generateFeedback(bool shouldHighlight) {
    if (shouldHighlight && _config.enableHaptics) {
      HapticFeedback.selectionClick();
    }
  }
}
