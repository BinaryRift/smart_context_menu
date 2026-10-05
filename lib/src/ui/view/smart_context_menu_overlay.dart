import 'dart:ui' as ui show Image, ImageFilter;
import 'package:flutter/material.dart';
import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_opacity.dart';
import '../../core/ui/motion/tokens/motion_traslation.dart';
import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../components/smart_menu_reactive_physics.dart';
import 'smart_context_menu_view.dart';

part '../components/preview_header_delegate.dart';

final class SmartContextMenuOverlay extends StatefulWidget {
  final Animation<double> routeAnimation;
  final Rect anchorRect;
  final ui.Image? snapshot;
  final String heroTag;
  final List<SmartContextMenuItem> items;
  final SmartContextMenuConfig config;

  const SmartContextMenuOverlay({
    super.key,
    required this.routeAnimation,
    required this.anchorRect,
    required this.snapshot,
    required this.heroTag,
    required this.items,
    required this.config,
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
  late final Animation<double> _menuAnimation;

  Alignment _menuAlignment = Alignment.topCenter;
  double? _leftPadding;
  double? _rightPadding;
  double _appliedTopOffset = double.maxFinite;
  double _lastMenuHeight = 0.0;
  Offset? _pointerDownPos;
  bool _isScrolling = false;
  Offset _startPreviewPosition = MotionTranslation.none.toOffset;

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

    final heightThreshold = _calculateMenuHeightThreshold(
      screenHeight: screenHeight,
      topSafe: topSafe,
      bottomSafe: bottomSafe,
    );

    return CustomScrollView(
      controller: _scrollController,
      physics: SmartMenuReactivePhysics(
        heightNotifier: _currentMenuHeight,
        heightThreshold: heightThreshold,
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
            );

            _scrollToBottomIfNeeded(heightThreshold: heightThreshold);

            return SliverPadding(
              padding: EdgeInsets.only(top: _appliedTopOffset),
            );
          },
        ),

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
    return Positioned.fill(
      child: FadeTransition(
        opacity: _backgroundAnimation,
        child: _config.backgroundBlur != null
            ? AnimatedBuilder(
                animation: _backgroundCurve,
                builder: (context, child) {
                  return BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: _config.backgroundBlur!.sigmaX *
                          _backgroundCurve.value,
                      sigmaY: _config.backgroundBlur!.sigmaY *
                          _backgroundCurve.value,
                    ),
                    child: child,
                  );
                },
                child: Container(color: _config.backgroundColor),
              )
            : Container(color: _config.backgroundColor),
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
      curve: const Interval(0.2, 1.0, curve: MotionCurves.lightSpring),
      reverseCurve: const Interval(0.5, 1.0, curve: MotionCurves.slow),
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

    if ((centerX - screenCenter).abs() < MenuDefaults.centerThreshold) {
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

    if (_isScrolling) {
      _isScrolling = false;
      return;
    }

    // Ignore tiny finger movements: treat as a tap only within tap slop.
    final double distance = (event.position - _pointerDownPos!).distance;
    _pointerDownPos = null;
    if (distance > MenuDefaults.tapSlop) return;

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

  void _updateTopOffset({
    required double screenHeight,
    required double bottomSafe,
    required double topSafe,
  }) {
    final double previewHeight = widget.anchorRect.height;
    final double menuHeight = _currentMenuHeight.value;
    double targetTop = widget.anchorRect.top;
    final double totalH = previewHeight + _config.menuGap + menuHeight;
    final double spaceBelow = screenHeight - targetTop - bottomSafe;

    if (totalH > spaceBelow) {
      targetTop -= (totalH - spaceBelow);
    }

    final double finalTop = targetTop.clamp(topSafe, screenHeight);

    if (finalTop < _appliedTopOffset) {
      _appliedTopOffset = finalTop;
    }
  }

  double _calculateMenuHeightThreshold({
    required double screenHeight,
    required double topSafe,
    required double bottomSafe,
  }) {
    final double availableTotalHeight = screenHeight -
        topSafe -
        bottomSafe -
        _config.screenPadding.top -
        _config.screenPadding.bottom;

    final double menuHeightThreshold =
        availableTotalHeight - widget.anchorRect.height - _config.menuGap;
    return menuHeightThreshold;
  }

  void _scrollToBottomIfNeeded({
    required double heightThreshold,
  }) {
    final menuHeight = _currentMenuHeight.value;
    final isOverflowing = menuHeight > heightThreshold;

    if (menuHeight > _lastMenuHeight && isOverflowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final max = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(max);
        }
      });
    }
    _lastMenuHeight = menuHeight;
  }

  void _onPreviewPanStart(DragStartDetails details) {
    _startPreviewPosition = details.localPosition;
  }

  void _onPreviewPanUpdate(DragUpdateDetails details) {
    final Offset delta = details.localPosition - _startPreviewPosition;

    final double maxTranslation = MotionTranslation.subtle.dx;

    final double tx = (delta.dx * MenuDefaults.dragResistance).clamp(
      -maxTranslation,
      maxTranslation,
    );
    final double ty = (delta.dy * MenuDefaults.dragResistance).clamp(
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
