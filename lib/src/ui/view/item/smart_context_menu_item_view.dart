import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter/widgets.dart';

import '../../../core/ui/motion/tokens/motion_durations.dart';
import '../../../core/ui/styles/smart_context_menu_defaults.dart';
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
  final SmartContextMenuItem? cachedItem;
  final void Function(SmartContextMenuItem item)? onLoaded;
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
  SmartContextMenuItem? _resolvedItem;
  Object? _error;
  bool get _isStatus => _error == null && _item is SmartContextMenuStatusItem;
  bool get _isDisabled => _item.isDisabled || _isStatus || !_hasInteractions;
  bool get _hasInteractions =>
      _item.onTap != null ||
      _item.isInternalInteracted ||
      _item.closeOnTap ||
      widget.onRetry != null ||
      widget.onTap != null;
  SmartContextMenuItem get _item => _resolvedItem ?? widget.item;
  SmartContextMenuConfig get _config => widget.config;
  SmartContextMenuStyle get _style => widget.config.style;

  // A failed load keeps the padding of the loading item, so the item does
  // not change its size.
  EdgeInsetsGeometry get _padding =>
      _item.padding ??
      (_error != null ? widget.item.loadingItem?.padding : null) ??
      _style.itemPadding;

  @override
  void initState() {
    super.initState();

    if (widget.onRetry != null) {
      _error = "External error";
    }

    if (widget.item.asyncItem != null) {
      if (widget.cachedItem != null) {
        _resolvedItem = widget.cachedItem;
      } else {
        _loadAsyncData();
      }
    }

    if (widget.item.listenableBuilder != null) {
      widget.item.listenable?.addListener(_onListenableChanged);
      _buildListenableItem();
    }
  }

  @override
  void didUpdateWidget(SmartContextMenuItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.listenable != oldWidget.item.listenable) {
      oldWidget.item.listenable?.removeListener(_onListenableChanged);
      widget.item.listenable?.addListener(_onListenableChanged);
    }
    if (widget.item.listenableBuilder != null) _buildListenableItem();
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
    widget.item.listenable?.removeListener(_onListenableChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SmartContextMenuItemColors.resolve(
      context,
      item: _item,
      style: _style,
      isPressed: _isHighlight,
      isBack: widget.key == ServiceItemKey.back,
    );
    final itemState = SmartContextMenuItemState(
      isPressed: _isHighlight,
      isDisabled: _item.isDisabled,
      isDestructive: _item.isDestructive,
      foregroundColor: colors.foreground,
    );

    // Without MetaData, drag-to-select does not find the separator.
    if (_item.isSeparator) return _buildSeparator(itemState);

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

  Widget _buildSeparator(SmartContextMenuItemState state) {
    final customBuilder = _item.customBuilder;
    if (customBuilder != null) return customBuilder(context, state);

    return Container(
      height: _style.separatorHeight,
      color: CupertinoDynamicColor.resolve(_style.separatorColor, context),
    );
  }

  Widget _buildContent(SmartContextMenuItemState state) {
    if (_item case final SmartContextMenuStatusItem item) {
      return SmartContextMenuStatusContent(
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
      );
    }

    return KeyedSubtree(
      key: ItemContentKey.content,
      child:
          _item.customBuilder?.call(context, state) ??
          SmartContextMenuItemRow(
            item: _item,
            style: _style,
            foregroundColor: state.foregroundColor,
          ),
    );
  }

  void _handleTap() {
    if (_isStatus) return;
    if (_error != null) {
      widget.onRetry != null ? widget.onRetry!() : _loadAsyncData();
      return;
    }
    if (_item.isDisabled) return;
    widget.onTap?.call(_item);
  }

  Future<void> _loadAsyncData() async {
    setState(() {
      _resolvedItem = widget.item.loadingItem;
      _error = null;
    });

    try {
      final Duration timeout =
          widget.item.loadingTimeout ?? SmartContextMenuDefaults.loadingTimeout;
      final result = await widget.item.asyncItem!().timeout(timeout);

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
          _resolvedItem = widget.item.errorItem;
        });
      }
    }
  }

  void _onListenableChanged() => setState(_buildListenableItem);

  void _buildListenableItem() {
    final item = widget.item.listenableBuilder!();
    assert(
      !(item.isSeparator ||
          item.isInternalInteracted ||
          item.listenableBuilder != null),
      'The builder of SmartContextMenuItem.listenable must return '
      'a SmartContextMenuItem.simple, a SmartContextMenuItem.loading, '
      'a SmartContextMenuItem.error or a SmartContextMenuItem.empty.',
    );
    _resolvedItem = item;
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
