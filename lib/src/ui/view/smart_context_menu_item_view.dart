import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoDynamicColor, CupertinoTheme;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../core/ui/motion/transitions/tricky_transition.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../../domain/smart_context_menu_item_state.dart';
import '../../domain/smart_context_menu_style.dart';
import '../keys/item_content_key.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';

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
  bool get _isLoading => _error == null && _item.isLoading;
  bool get _isDisabled => _item.isDisabled || _isLoading || !_hasInteractions;
  bool get _hasInteractions =>
      _item.onTap != null ||
      _item.isInternalInteracted ||
      _item.closeOnTap ||
      widget.onRetry != null ||
      widget.onTap != null;
  SmartContextMenuItem get _item => _resolvedItem ?? widget.item;
  SmartContextMenuConfig get _config => widget.config;
  SmartContextMenuStyle get _style => widget.config.style;

  Color _resolve(Color color) => CupertinoDynamicColor.resolve(color, context);

  Color get _baseForegroundColor =>
      _style.titleStyle.color ?? SmartContextMenuDefaults.foregroundColor;

  // The same brightness that CupertinoDynamicColor.resolve uses.
  bool get _isDark =>
      (CupertinoTheme.maybeBrightnessOf(context) ?? Brightness.light) ==
      Brightness.dark;

  double get _tintOpacity {
    if (_isHighlight) {
      return _isDark
          ? SmartContextMenuDefaults.darkTintPressedOpacity
          : SmartContextMenuDefaults.tintPressedOpacity;
    }
    return _isDark
        ? SmartContextMenuDefaults.darkTintOpacity
        : SmartContextMenuDefaults.tintOpacity;
  }

  double get _highlightOpacity {
    if (_isDark) return SmartContextMenuDefaults.darkHighlightOpacity;
    return widget.key == ServiceItemKey.back
        ? SmartContextMenuDefaults.backHighlightOpacity
        : SmartContextMenuDefaults.highlightOpacity;
  }

  Color? get _tintColor =>
      _item.tintColor ?? (_item.isDestructive ? _style.destructiveColor : null);

  Color get _overlayColor {
    if (_item.isDisabled) {
      final disabledBackgroundColor = _style.disabledBackgroundColor;
      return disabledBackgroundColor == null
          ? Colors.transparent
          : _resolve(disabledBackgroundColor);
    }
    final tintColor = _tintColor;
    if (tintColor != null) {
      return _resolve(tintColor).withValues(alpha: _tintOpacity);
    }
    if (!_isHighlight) return Colors.transparent;
    final highlightColor = _style.highlightColor;
    return highlightColor != null
        ? _resolve(highlightColor)
        : _resolve(_baseForegroundColor).withValues(alpha: _highlightOpacity);
  }

  Color get _foregroundColor {
    final tintColor = _tintColor;
    if (tintColor != null) {
      return _resolve(tintColor).withValues(
        alpha: _item.isDisabled
            ? SmartContextMenuDefaults.tintDisabledForegroundOpacity
            : 1,
      );
    }
    if (_item.isDisabled) {
      return _resolve(_style.disabledForegroundColor);
    }
    return _resolve(_item.titleStyle?.color ?? _baseForegroundColor);
  }

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
    final itemState = SmartContextMenuItemState(
      isPressed: _isHighlight,
      isDisabled: _item.isDisabled,
      isDestructive: _item.isDestructive,
      foregroundColor: _foregroundColor,
    );

    // Without MetaData, drag-to-select does not find the separator.
    if (_item.isSeparator) return _buildSeparator(itemState);

    return MetaData(
      metaData: widget.key,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: MotionDurations.instant,
        color: _overlayColor,
        padding: _item.padding ?? _style.itemPadding,
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
      color: _resolve(_style.separatorColor),
    );
  }

  Widget _buildContent(SmartContextMenuItemState state) {
    if (_isLoading) return _buildLoadingBody();
    if (_error != null) return _buildErrorBody(state);

    return KeyedSubtree(
      key: ItemContentKey.content,
      child: _item.customBuilder != null
          ? _item.customBuilder!(context, state)
          : _body(_item),
    );
  }

  Widget _body(SmartContextMenuItem item) {
    return IconTheme.merge(
      data: IconThemeData(color: _foregroundColor),
      child: _buildRow(item),
    );
  }

  Widget _buildRow(SmartContextMenuItem item) {
    final gap = SizedBox(width: item.childrenGap ?? _style.itemChildrenGap);
    return Row(
      children: [
        if (item.leading != null) ...[item.leading!, gap],
        Expanded(
          child: Text(
            item.title ?? "",
            style: (item.titleStyle ?? _style.titleStyle).copyWith(
              color: _foregroundColor,
            ),
            maxLines: _style.titleMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.trailing != null) ...[gap, item.trailing!],
        if (item.showTransitionIcon) ...[
          gap,
          Icon(
            _style.submenuIcon,
            size: _style.defaultIconSize,
            color: item.isDisabled
                ? _resolve(_style.disabledForegroundColor)
                : CupertinoDynamicColor.maybeResolve(
                    _style.defaultIconColor,
                    context,
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingBody() {
    if (_item case SmartContextMenuLoadingItem(:final child?)) {
      return KeyedSubtree(
        key: ItemContentKey.loading,
        child: DefaultTextStyle.merge(
          style: (_item.titleStyle ?? _style.titleStyle).copyWith(
            color: _foregroundColor,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: _foregroundColor),
            child: child,
          ),
        ),
      );
    }

    final loadingItem = SmartContextMenuItem.simple(
      title: _item.title ?? _config.labels.loading,
      titleStyle: _item.titleStyle,
      leading: _item.leading,
      childrenGap: _item.childrenGap,
      trailing: CupertinoActivityIndicator(),
    );
    return KeyedSubtree(key: ItemContentKey.loading, child: _body(loadingItem));
  }

  Widget _buildErrorBody(SmartContextMenuItemState state) {
    final errorBuilder = widget.item.errorBuilder;
    if (errorBuilder != null) {
      return KeyedSubtree(
        key: ItemContentKey.error,
        child: errorBuilder(context, state),
      );
    }

    final errorItem = SmartContextMenuItem.simple(
      title: _config.labels.retry,
      leading: Icon(
        SmartContextMenuDefaults.errorIcon,
        size: _style.defaultIconSize,
      ),
      trailing: Icon(
        SmartContextMenuDefaults.retryIcon,
        size: _style.defaultIconSize,
      ),
    );
    return KeyedSubtree(key: ItemContentKey.error, child: _body(errorItem));
  }

  void _handleTap() {
    if (_isLoading) return;
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
      'a SmartContextMenuItem.simple or a SmartContextMenuItem.loading.',
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
