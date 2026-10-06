import 'package:flutter/cupertino.dart'
    show CupertinoActivityIndicator, CupertinoDynamicColor;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../core/ui/motion/tokens/motion_opacity.dart';
import '../../core/ui/motion/transitions/tricky_transition.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../../domain/smart_context_menu_item_state.dart';
import '../../domain/smart_context_menu_style.dart';
import '../keys/item_content_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../widgets/smart_context_menu_divider.dart';

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
  })  : cachedItem = null,
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
  })  : onTap = null,
        cachedItem = null,
        onLoaded = null;

  @override
  State<SmartContextMenuItemView> createState() => _SmartContextMenuItemViewState();
}

final class _SmartContextMenuItemViewState extends State<SmartContextMenuItemView> {
  bool _isHighlight = false;
  SmartContextMenuItem? _resolvedItem;
  bool _isLoading = false;
  Object? _error;
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

  Color get _baseTextColor =>
      _style.textStyle.color ?? SmartContextMenuDefaults.textColor;

  Color get _overlayColor {
    if (_item.isDestructive) {
      final alpha = _item.isDisabled
          ? 0.08
          : _isHighlight
              ? 0.24
              : 0.12;
      return _resolve(_style.destructiveColor)
          .withValues(alpha: alpha);
    }
    if (_item.isDisabled) {
      return _resolve(_style.disabledItemColor);
    }
    return _isHighlight
        ? _resolve(_baseTextColor).withValues(alpha: 0.1)
        : Colors.transparent;
  }

  Color get _textColor {
    if (_item.isDestructive) {
      return _resolve(_style.destructiveColor).withValues(
        alpha: _item.isDisabled
            ? MotionOpacity.medium.value
            : MotionOpacity.visible.value,
      );
    }
    if (_item.isDisabled) {
      return _resolve(_style.secondaryTextColor);
    }
    return _resolve(
      _item.titleStyle?.color ?? _baseTextColor,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.onRetry != null) {
      _error = "External error";
      _isLoading = false;
    }

    if (widget.item.asyncItem != null) {
      if (widget.cachedItem != null) {
        _resolvedItem = widget.cachedItem;
        _isLoading = false;
      } else {
        _loadAsyncData();
      }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemState = SmartContextMenuItemState(
      isPressed: _isHighlight,
      isDisabled: _item.isDisabled,
      isDestructive: _item.isDestructive,
      textColor: _textColor,
    );

    return MetaData(
      metaData: widget.key,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_item.hasDivider && _item.dividerPosition == SmartContextMenuDividerPosition.top)
            _item.customDivider ??
                SmartContextMenuDivider(color: _style.dividerColor),
          AnimatedContainer(
            duration: MotionDurations.instant,
            color: _overlayColor,
            padding: _item.padding,
            child: AnimatedSwitcher(
              duration: MotionDurations.fast,
              transitionBuilder: (child, animation) =>
                  TrickyTransition(animation: animation, child: child),
              child: _buildContent(itemState),
            ),
          ),
          if (_item.hasDivider &&
              _item.dividerPosition == SmartContextMenuDividerPosition.bottom)
            _item.customDivider ??
                SmartContextMenuDivider(color: _style.dividerColor),
        ],
      ),
    );
  }

  Widget _buildContent(SmartContextMenuItemState state) {
    if (_isLoading) return _buildLoadingBody(state);
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
      data: IconThemeData(color: _textColor),
      child: _buildRow(item),
    );
  }

  Widget _buildRow(SmartContextMenuItem item) {
    return Row(
      children: [
        if (item.leading != null) ...[
          item.leading!,
          SizedBox(width: _item.childrenGap),
        ],
        Expanded(
          child: Text(
            item.title ?? "",
            style: (item.titleStyle ?? _style.textStyle).copyWith(
              color: _textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.trailing != null) ...[
          SizedBox(width: item.childrenGap),
          item.trailing!,
        ],
        if (item.showTransitionIcon) ...[
          SizedBox(width: item.childrenGap),
          Icon(
            _style.submenuIcon,
            size: _style.defaultIconSize,
            color: item.isDisabled
                ? _resolve(_style.secondaryTextColor)
                : CupertinoDynamicColor.maybeResolve(
                    _style.defaultIconColor,
                    context,
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingBody(SmartContextMenuItemState state) {
    final loadingBuilder = _item.loadingBuilder;
    if (loadingBuilder != null) {
      return KeyedSubtree(
        key: ItemContentKey.loading,
        child: loadingBuilder(context, state),
      );
    }

    final loadingItem = SmartContextMenuItem.simple(
      title: _item.title ?? _config.labels.loading,
      titleStyle: _item.titleStyle,
      leading: _item.leading,
      childrenGap: _item.childrenGap,
      trailing: CupertinoActivityIndicator(),
    );
    return KeyedSubtree(
      key: ItemContentKey.loading,
      child: _body(loadingItem),
    );
  }

  Widget _buildErrorBody(SmartContextMenuItemState state) {
    final errorBuilder = _item.errorBuilder;
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
    return KeyedSubtree(
      key: ItemContentKey.error,
      child: _body(errorItem),
    );
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
      _isLoading = true;
      _error = null;
    });

    try {
      final Duration timeout = widget.item.loadingTimeout ??
          SmartContextMenuDefaults.loadingTimeout;
      final result = await widget.item.asyncItem!().timeout(timeout);

      if (mounted) {
        widget.onLoaded?.call(result);
        setState(() {
          _resolvedItem = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
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
