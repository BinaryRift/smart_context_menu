import 'dart:async' show FutureOr;
import 'dart:ui' as ui show Image;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import '../../core/ui/gestures/gesture_thresholds.dart';
import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_timing.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_header_details.dart';
import '../../domain/smart_context_menu_item.dart';
import '../components/fixed_extent_header_delegate.dart';
import '../components/smart_menu_reactive_physics.dart';
import '../extensions/render_object_ext.dart';
import '../layout/smart_context_menu_horizontal_layout.dart';
import '../layout/smart_context_menu_vertical_layout.dart';
import '../widgets/smart_context_menu_background.dart';
import '../widgets/smart_context_menu_header.dart';
import '../widgets/smart_context_menu_preview.dart';
import 'smart_context_menu_view.dart';

final class SmartContextMenuOverlay extends StatefulWidget {
  final Animation<double> routeAnimation;
  final Rect anchorRect;
  final ui.Image? snapshot;
  final String heroTag;
  final List<SmartContextMenuItem> items;
  final SmartContextMenuConfig config;
  final FutureOr<void> Function()? onPreviewTap;
  final SmartContextMenuHeaderBuilder? headerSliversBuilder;
  final bool fadeHeaderSlivers;

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
    this.fadeHeaderSlivers = true,
  });

  @override
  State<SmartContextMenuOverlay> createState() =>
      _SmartContextMenuOverlayState();
}

final class _SmartContextMenuOverlayState
    extends State<SmartContextMenuOverlay> {
  late final ScrollController _scrollController;
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _previewKey = GlobalKey();
  final List<GlobalKey> _headerKeys = [];
  final List<double> _headerExtents = [];
  final ValueNotifier<double> _currentMenuHeight = ValueNotifier(0.0);
  final ValueNotifier<Offset> _previewMotion = ValueNotifier(Offset.zero);

  late final CurvedAnimation _menuAnimation;

  late SmartContextMenuHorizontalLayout _horizontalLayout;
  late final SmartContextMenuVerticalLayout _verticalLayout;
  Offset? _pointerDownPos;
  bool _isScrolling = false;
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
    _menuAnimation = CurvedAnimation(
      parent: widget.routeAnimation,
      curve: MotionCurves.menuScaleIn,
      reverseCurve: MotionCurves.menuScaleOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    final screenPadding = _config.screenPadding;
    _horizontalLayout = SmartContextMenuHorizontalLayout(
      anchorRect: widget.anchorRect,
      screenWidth: media.size.width,
      screenPadding: screenPadding.copyWith(
        left: screenPadding.left + media.padding.left,
        right: screenPadding.right + media.padding.right,
      ),
      menuWidth: _config.menuWidth,
    );
  }

  @override
  void dispose() {
    _currentMenuHeight.dispose();
    _previewMotion.dispose();
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
            Positioned.fill(
              child: SmartContextMenuBackground(
                animation: widget.routeAnimation,
                color: _config.style.backgroundColor,
                blur: _config.style.backgroundBlur,
              ),
            ),
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
    // Pinned header slivers pin below this space, not under the status bar.
    final double statusBarHeight = widget.headerSliversBuilder == null
        ? 0
        : media.padding.top;

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
        if (statusBarHeight > 0)
          SliverPersistentHeader(
            pinned: true,
            delegate: FixedExtentHeaderDelegate(
              height: statusBarHeight,
              child: const SizedBox.shrink(),
            ),
          ),

        AnimatedBuilder(
          animation: _currentMenuHeight,
          builder: (context, child) {
            if (_verticalLayout.update(_currentMenuHeight.value)) {
              _scrollToBottom();
            }

            return SliverPadding(
              padding: EdgeInsets.only(
                top: _verticalLayout.topPadding - statusBarHeight,
              ),
            );
          },
        ),

        ..._buildHeader(),

        SliverPersistentHeader(
          pinned: false,
          delegate: FixedExtentHeaderDelegate(
            height: widget.anchorRect.height,
            child: SmartContextMenuPreview(
              snapshot: widget.snapshot,
              size: widget.anchorRect.size,
              heroTag: widget.heroTag,
              layout: _horizontalLayout,
              motion: _previewMotion,
              snapshotKey: _previewKey,
              onTap: widget.onPreviewTap == null ? null : _onPreviewTap,
            ),
          ),
        ),

        SliverPadding(padding: EdgeInsets.only(top: _config.menuGap)),

        SliverToBoxAdapter(child: _buildMenu()),

        SliverPadding(padding: EdgeInsets.only(bottom: bottomSafe)),
      ],
    );
  }

  List<Widget> _buildHeader() {
    final builder = widget.headerSliversBuilder;
    if (builder == null) return const [];

    final slivers = SmartContextMenuHeader(
      builder: builder,
      layout: _horizontalLayout,
      animation: widget.routeAnimation,
      fade: widget.fadeHeaderSlivers,
      motion: _previewMotion,
      close: _close,
      onExtentChanged: _onHeaderExtentChanged,
      keyOf: _headerKeyOf,
    ).build(context);

    // Forget the heights of the slivers the builder no longer returns.
    if (_headerExtents.length > slivers.length) {
      _headerExtents.length = slivers.length;
      _verticalLayout.headerExtent = _totalHeaderExtent();
    }
    return slivers;
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
            padding: _horizontalLayout.menuPadding,
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

  /// Whether [position] is on the menu, the preview or a widget in the
  /// header slivers, so a tap there does not close the menu.
  bool _isOnContent(Offset position) {
    RenderObject? find(GlobalKey key) => key.currentContext?.findRenderObject();

    final menu = find(_menuKey);
    final preview = find(_previewKey);
    final header = [for (final key in _headerKeys) ?find(key)];
    return (menu is RenderBox && menu.containsGlobal(position)) ||
        (preview is RenderBox && preview.containsGlobal(position)) ||
        header.anyHitAt(position, viewId: View.of(context).viewId);
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

    if (!_isOnContent(event.position)) {
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

  GlobalKey _headerKeyOf(int index) {
    while (_headerKeys.length <= index) {
      _headerKeys.add(GlobalKey());
    }
    return _headerKeys[index];
  }

  void _onHeaderExtentChanged(int index, double extent) {
    while (_headerExtents.length <= index) {
      _headerExtents.add(0);
    }
    _headerExtents[index] = extent;

    final total = _totalHeaderExtent();
    if (total != _verticalLayout.headerExtent) {
      setState(() => _verticalLayout.headerExtent = total);
    }
  }

  double _totalHeaderExtent() {
    return _headerExtents
        .fold(0.0, (sum, extent) => sum + extent)
        .roundToDouble();
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
      await Future<void>.delayed(
        route.transitionDuration * MotionTiming.closingAction,
      );
    }();
  }
}
