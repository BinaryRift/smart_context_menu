import 'dart:async' show FutureOr;
import 'dart:ui' as ui show Image, ImageFilter;
import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/gestures.dart' show HitTestResult;
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
import '../layout/smart_context_menu_horizontal_layout.dart';
import '../layout/smart_context_menu_vertical_layout.dart';
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
  final GlobalKey _headerKey = GlobalKey();
  final ValueNotifier<double> _currentMenuHeight = ValueNotifier(0.0);
  final ValueNotifier<Offset> _previewMotion = ValueNotifier(Offset.zero);

  late final Animation<double> _backgroundAnimation;
  late final CurvedAnimation _backgroundCurve;
  late final CurvedAnimation _menuAnimation;

  late SmartContextMenuHorizontalLayout _horizontalLayout;
  late final SmartContextMenuVerticalLayout _verticalLayout;
  Offset? _pointerDownPos;
  bool _isScrolling = false;
  Offset _startPreviewPosition = MotionTranslation.none.toOffset;
  Future<void>? _closing;

  SmartContextMenuConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _verticalLayout = SmartContextMenuVerticalLayout(
      anchorTop: widget.anchorRect.top,
      previewHeight: widget.anchorRect.height,
      menuGap: _config.menuGap,
      moveBackDown: _config.moveBackDown,
    );
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _horizontalLayout = SmartContextMenuHorizontalLayout(
      anchorRect: widget.anchorRect,
      screenWidth: MediaQuery.of(context).size.width,
      screenPadding: _config.screenPadding,
    );
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

    _verticalLayout.setBounds(
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
            if (_verticalLayout.update(_currentMenuHeight.value)) {
              _scrollToBottom();
            }

            return SliverPadding(
              padding: EdgeInsets.only(top: _verticalLayout.topPadding),
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
      alignment: _horizontalLayout.alignment,
      close: _close,
    );

    return SliverExtentListener(
      onExtentChanged: _onHeaderExtentChanged,
      sliver: SliverFadeTransition(
        opacity: widget.routeAnimation,
        sliver: SliverPadding(
          padding: _horizontalLayout.padding,
          sliver: SliverMainAxisGroup(
            key: _headerKey,
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
          padding: _horizontalLayout.padding,
          child: Align(
            alignment: _horizontalLayout.alignment,
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
      alignment: _horizontalLayout.alignment,
      child: ScaleTransition(
        alignment: Alignment.center,
        scale: _menuAnimation,
        child: FadeTransition(
          opacity: widget.routeAnimation,
          child: Padding(
            padding: _horizontalLayout.padding,
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

  bool _isPointInside(Offset globalPos, GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;
    final localPos = renderBox.globalToLocal(globalPos);
    return renderBox.paintBounds.contains(localPos);
  }

  /// Whether [globalPos] hits a widget in the header slivers.
  ///
  /// Unlike [_isPointInside], empty space next to the widgets does not
  /// count: a sliver is in the hit test path only if one of its children
  /// is hit.
  bool _isPointOnHeader(Offset globalPos) {
    final header = _headerKey.currentContext?.findRenderObject();
    if (header == null) return false;

    final result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(
      result,
      globalPos,
      View.of(context).viewId,
    );
    return result.path.any((entry) => entry.target == header);
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

    if (!hitMenu && !hitPreview && !_isPointOnHeader(event.position)) {
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(max);
      }
    });
  }

  bool _isOverflowing() =>
      _verticalLayout.isOverflowing(_currentMenuHeight.value);

  void _onHeaderExtentChanged(double extent) {
    final newExtent = extent.roundToDouble();
    if (newExtent != _verticalLayout.headerExtent) {
      setState(() => _verticalLayout.headerExtent = newExtent);
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
