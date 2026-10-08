import 'dart:async' show FutureOr;
import 'dart:math' as math;
import 'dart:ui' as ui show Image, ImageFilter;
import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../core/ui/gestures/gesture_thresholds.dart';
import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_opacity.dart';
import '../../core/ui/motion/tokens/motion_translation.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_header_details.dart';
import '../../domain/smart_context_menu_item.dart';
import '../components/smart_menu_reactive_physics.dart';
import '../widgets/sliver_extent_listener.dart';
import 'smart_context_menu_view.dart';

part '../components/preview_header_delegate.dart';

final class SmartContextMenuOverlay extends StatefulWidget {
  final Animation<double> routeAnimation;
  final Rect anchorRect;
  final ui.Image? snapshot;
  final String heroTag;
  final List<SmartContextMenuItem> items;
  final SmartContextMenuConfig config;
  final FutureOr<void> Function()? onPreviewTap;
  final SmartContextMenuHeaderBuilder? headerSliversBuilder;

  const SmartContextMenuOverlay({
    super.key,
    required this.routeAnimation,
    required this.anchorRect,
    required this.snapshot,
    required this.heroTag,
    required this.items,
    required this.config,
    this.onPreviewTap,
    this.headerSliversBuilder,
  });

  @override
  State<SmartContextMenuOverlay> createState() => _SmartContextMenuOverlayState();
}

final class _SmartContextMenuOverlayState extends State<SmartContextMenuOverlay> {
  late final ScrollController _scrollController;
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _previewKey = GlobalKey();
  final ValueNotifier<double> _currentMenuHeight = ValueNotifier(0.0);
  final ValueNotifier<Offset> _previewMotion = ValueNotifier(Offset.zero);

  late final Animation<double> _backgroundAnimation;
  late final CurvedAnimation _backgroundCurve;
  late final CurvedAnimation _menuAnimation;

  Alignment _menuAlignment = Alignment.topCenter;
  double? _leftPadding;
  double? _rightPadding;
  double _appliedTopOffset = double.maxFinite;
  double _headerExtent = 0.0;
  double _heightThreshold = double.infinity;
  double _lastContentHeight = 0.0;
  Offset? _pointerDownPos;
  bool _isScrolling = false;
  Offset _startPreviewPosition = MotionTranslation.none.toOffset;
  Future<void>? _closing;

  SmartContextMenuConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshLayout();
  }

  @override
  void dispose() {
    _currentMenuHeight.dispose();
    _previewMotion.dispose();
    _backgroundCurve.dispose();
    _menuAnimation.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        child: Stack(
          children: [
            _buildBackground(context),
            Positioned.fill(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final double topSafe = media.padding.top + _config.screenPadding.top;
    final double bottomSafe =
        media.padding.bottom + _config.screenPadding.bottom;
    final double previewHeight = widget.anchorRect.height;

    final heightThreshold = _heightThreshold = _calculateMenuHeightThreshold(
      screenHeight: screenHeight,
      topSafe: topSafe,
      bottomSafe: bottomSafe,
    );

    return CustomScrollView(
      controller: _scrollController,
      physics: SmartMenuReactivePhysics(
        isOverflowing: _isOverflowing,
        parent: const BouncingScrollPhysics(),
      ),
      slivers: [
        AnimatedBuilder(
          animation: _currentMenuHeight,
          builder: (context, child) {
            _updateTopOffset(
              screenHeight: screenHeight,
              bottomSafe: bottomSafe,
              topSafe: topSafe,
              heightThreshold: heightThreshold,
            );

            _scrollToBottomIfNeeded(heightThreshold: heightThreshold);

            return SliverPadding(
              padding: EdgeInsets.only(
                top: _appliedTopOffset - _headerExtent,
              ),
            );
          },
        ),

        if (widget.headerSliversBuilder != null) _buildHeader(),

        SliverPersistentHeader(
          pinned: false,
          delegate: _PreviewHeaderDelegate(
            height: previewHeight,
            child: _buildPreview(),
          ),
        ),

        SliverPadding(padding: EdgeInsets.only(top: _config.menuGap)),

        SliverToBoxAdapter(child: _buildMenu()),

        SliverPadding(padding: EdgeInsets.only(bottom: bottomSafe)),
      ],
    );
  }

  Widget _buildBackground(BuildContext context) {
    final backgroundColor =
        CupertinoDynamicColor.resolve(_config.style.backgroundColor, context);

    return Positioned.fill(
      child: FadeTransition(
        opacity: _backgroundAnimation,
        child: _config.style.backgroundBlur != null
            ? AnimatedBuilder(
                animation: _backgroundCurve,
                builder: (context, child) {
                  return BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: _config.style.backgroundBlur!.sigmaX *
                          _backgroundCurve.value,
                      sigmaY: _config.style.backgroundBlur!.sigmaY *
                          _backgroundCurve.value,
                    ),
                    child: child,
                  );
                },
                child: Container(color: backgroundColor),
              )
            : Container(color: backgroundColor),
      ),
    );
  }

  Widget _buildHeader() {
    final header = SmartContextMenuHeaderDetails(
      alignment: _menuAlignment,
      close: _close,
    );

    return SliverExtentListener(
      onExtentChanged: _onHeaderExtentChanged,
      sliver: SliverFadeTransition(
        opacity: widget.routeAnimation,
        sliver: SliverPadding(
          padding: EdgeInsets.only(
            left: _leftPadding ?? 0,
            right: _rightPadding ?? 0,
          ),
          sliver: SliverMainAxisGroup(
            slivers: widget.headerSliversBuilder!(context, header),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return ValueListenableBuilder(
      valueListenable: _previewMotion,
      builder: (context, offset, child) {
        return TweenAnimationBuilder<Offset>(
          duration: MotionDurations.fast,
          curve: MotionCurves.entrance,
          tween: Tween<Offset>(begin: offset, end: offset),
          builder: (context, animatedOffset, child) {
            return Transform.translate(
              offset: animatedOffset,
              child: child,
            );
          },
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onPreviewTap == null ? null : _onPreviewTap,
        onPanStart: _onPreviewPanStart,
        onPanUpdate: _onPreviewPanUpdate,
        onPanEnd: _onPreviewPanEnd,
        onPanCancel: _onPreviewPanCancel,
        child: Padding(
          padding: EdgeInsets.only(
            left: _leftPadding ?? 0,
            right: _rightPadding ?? 0,
          ),
          child: Align(
            alignment: _menuAlignment,
            child: SizedBox(
              width: widget.anchorRect.width,
              height: widget.anchorRect.height,
              child: KeyedSubtree(
                key: _previewKey,
                child: Hero(
                  tag: widget.heroTag,
                  child: RawImage(image: widget.snapshot, fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Align(
      alignment: _menuAlignment,
      child: ScaleTransition(
        alignment: Alignment.center,
        scale: _menuAnimation,
        child: FadeTransition(
          opacity: widget.routeAnimation,
          child: Padding(
            padding: EdgeInsets.only(
              left: _leftPadding ?? 0,
              right: _rightPadding ?? 0,
            ),
            child: GestureDetector(
              onPanStart: (_) => (),
              child: SmartContextMenuView(
                key: _menuKey,
                config: _config,
                initialItems: widget.items,
                heightNotifier: _currentMenuHeight,
                previewMotionNotifier: _previewMotion,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setupAnimations() {
    _backgroundCurve = CurvedAnimation(
      parent: widget.routeAnimation,
      curve: MotionCurves.quartOut,
      reverseCurve: MotionCurves.quartIn,
    );

    _backgroundAnimation = Tween<double>(
      begin: MotionOpacity.hidden.value,
      end: MotionOpacity.visible.value,
    ).animate(_backgroundCurve);

    _menuAnimation = CurvedAnimation(
      parent: widget.routeAnimation,
      curve: MotionCurves.menuScaleIn,
      reverseCurve: MotionCurves.menuScaleOut,
    );
  }

  void _refreshLayout() {
    _calculateHorizontalPosition();
  }

  void _calculateHorizontalPosition() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double centerX = widget.anchorRect.center.dx;
    final double screenCenter = screenWidth / 2;

    final double leftPadding = widget.config.screenPadding.left;
    final double rightPadding = widget.config.screenPadding.right;

    if ((centerX - screenCenter).abs() < GestureThresholds.centerThreshold) {
      _menuAlignment = Alignment.topCenter;
      _leftPadding = null;
      _rightPadding = null;
    } else if (centerX < screenCenter) {
      _menuAlignment = Alignment.topLeft;
      _leftPadding = widget.anchorRect.left.clamp(leftPadding, screenWidth);
      _rightPadding = null;
    } else {
      _menuAlignment = Alignment.topRight;
      _leftPadding = null;
      _rightPadding = (screenWidth - widget.anchorRect.right)
          .clamp(rightPadding, screenWidth);
    }
  }

  bool _isPointInside(Offset globalPos, GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final localPos = renderBox.globalToLocal(globalPos);
    return renderBox.paintBounds.contains(localPos);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerDownPos = event.position;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_pointerDownPos == null) return;
    if (!_config.barrierDismissible) {
      _pointerDownPos = null;
      return;
    }

    if (_isScrolling) {
      _isScrolling = false;
      return;
    }

    // Ignore tiny finger movements: treat as a tap only within tap slop.
    final double distance = (event.position - _pointerDownPos!).distance;
    _pointerDownPos = null;
    if (distance > GestureThresholds.tapSlop) return;

    final bool hitMenu = _isPointInside(event.position, _menuKey);
    final bool hitPreview = _isPointInside(event.position, _previewKey);

    if (!hitMenu && !hitPreview) {
      Navigator.of(context).pop();
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      _isScrolling = true;
    }
    return false;
  }

  /// Moves the preview up when the menu grows and does not fit below it.
  ///
  /// With [SmartContextMenuConfig.moveBackDown], the preview also moves back
  /// down when the menu shrinks, but not below its place on the screen, and
  /// only while the preview and the menu fit on the screen without
  /// scrolling. While they scroll, it only moves up: moving down would shift
  /// the scroll position under the user.
  ///
  /// The header slivers always fit above the preview: if there is no room
  /// for them, the preview moves down.
  void _updateTopOffset({
    required double screenHeight,
    required double bottomSafe,
    required double topSafe,
    required double heightThreshold,
  }) {
    final double previewHeight = widget.anchorRect.height;
    final double menuHeight = _currentMenuHeight.value;
    double targetTop = widget.anchorRect.top;
    final double totalH = previewHeight + _config.menuGap + menuHeight;
    final double spaceBelow = screenHeight - targetTop - bottomSafe;

    if (totalH > spaceBelow) {
      targetTop -= (totalH - spaceBelow);
    }

    final double minTop = topSafe + _headerExtent;
    final double finalTop = math.max(targetTop, minTop);

    final bool canMoveDown =
        _config.moveBackDown && menuHeight <= heightThreshold;

    if (finalTop < _appliedTopOffset || canMoveDown) {
      _appliedTopOffset = finalTop;
    }
    _appliedTopOffset = math.max(_appliedTopOffset, minTop);
  }

  double _calculateMenuHeightThreshold({
    required double screenHeight,
    required double topSafe,
    required double bottomSafe,
  }) {
    // topSafe and bottomSafe already include the screen padding.
    final double availableTotalHeight = screenHeight - topSafe - bottomSafe;

    final double menuHeightThreshold = availableTotalHeight -
        _headerExtent -
        widget.anchorRect.height -
        _config.menuGap;
    return menuHeightThreshold;
  }

  void _scrollToBottomIfNeeded({
    required double heightThreshold,
  }) {
    final menuHeight = _currentMenuHeight.value;
    final isOverflowing = menuHeight > heightThreshold;
    final contentHeight = menuHeight + _headerExtent;

    if (contentHeight > _lastContentHeight && isOverflowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final max = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(max);
        }
      });
    }
    _lastContentHeight = contentHeight;
  }

  bool _isOverflowing() => _currentMenuHeight.value > _heightThreshold;

  void _onHeaderExtentChanged(double extent) {
    final newExtent = extent.roundToDouble();
    if (newExtent != _headerExtent) {
      setState(() => _headerExtent = newExtent);
    }
  }

  /// Closes the menu and calls [SmartContextMenuOverlay.onPreviewTap]
  /// halfway through the closing, as an item that closes on tap does.
  Future<void> _onPreviewTap() async {
    if (_closing != null) return;
    if (_config.enableHaptics) HapticFeedback.lightImpact();

    await _close();
    await widget.onPreviewTap?.call();
  }

  /// Closes the menu once and completes halfway through the closing.
  ///
  /// Does nothing if the menu is already closing, so it never pops
  /// the route below the menu.
  Future<void> _close() {
    return _closing ??= () async {
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;

      Navigator.of(context).pop();
      await Future<void>.delayed(route.transitionDuration * 0.5);
    }();
  }

  void _onPreviewPanStart(DragStartDetails details) {
    _startPreviewPosition = details.localPosition;
  }

  void _onPreviewPanUpdate(DragUpdateDetails details) {
    final Offset delta = details.localPosition - _startPreviewPosition;

    final double maxTranslation = MotionTranslation.subtle.dx;

    final double tx = (delta.dx * GestureThresholds.dragResistance).clamp(
      -maxTranslation,
      maxTranslation,
    );
    final double ty = (delta.dy * GestureThresholds.dragResistance).clamp(
      -maxTranslation,
      maxTranslation,
    );

    _previewMotion.value = Offset(tx, ty);
  }

  void _onPreviewPanEnd(DragEndDetails details) {
    _previewMotion.value = MotionTranslation.none.toOffset;
    _startPreviewPosition = MotionTranslation.none.toOffset;
  }

  void _onPreviewPanCancel() {
    _previewMotion.value = MotionTranslation.none.toOffset;
    _startPreviewPosition = MotionTranslation.none.toOffset;
  }
}
