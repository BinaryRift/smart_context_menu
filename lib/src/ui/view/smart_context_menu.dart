import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/gestures.dart'
    show LongPressGestureRecognizer, TapGestureRecognizer, GestureBinding;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart' show HapticFeedback;

import '../../core/ui/motion/tokens/motion_curves.dart';
import '../../core/ui/motion/tokens/motion_durations.dart';
import '../../core/ui/motion/tokens/motion_scales.dart';
import '../../controllers/smart_context_menu_controller.dart';
import '../../domain/smart_context_menu_activation_mode.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../routes/smart_context_menu_route.dart';
import '../state/smart_context_menu_session.dart';

/// Shows an iOS-style context menu for [child] on long press.
///
/// While pressed, [child] shrinks slightly. When the menu opens, [child]
/// is lifted above the blurred screen and the menu with [items] appears
/// next to it. The preview is a snapshot of [child] taken at the moment
/// of opening, so it does not update while the menu is open.
///
/// To open the menu from code, pass a [controller]. To turn off the long
/// press, set [SmartContextMenuConfig.activationMode] to
/// [SmartContextMenuActivationMode.manual].
///
/// ```dart
/// SmartContextMenu(
///   items: [
///     SmartContextMenuItem.simple(
///       title: 'Copy',
///       leading: const Icon(CupertinoIcons.doc_on_doc),
///       onTap: () => debugPrint('Copy'),
///     ),
///     SmartContextMenuItem.simple(
///       title: 'Delete',
///       leading: const Icon(CupertinoIcons.delete),
///       isDestructive: true,
///       onTap: () => debugPrint('Delete'),
///     ),
///   ],
///   child: const Text('Long press me'),
/// )
/// ```
final class SmartContextMenu extends StatefulWidget {
  /// The widget the menu is attached to.
  ///
  /// It receives the long press and is shown as the preview above the menu.
  final Widget child;

  /// The items of the root menu.
  ///
  /// If empty, the menu does not open, neither on long press nor via
  /// [controller].
  final List<SmartContextMenuItem> items;

  /// The behavior and appearance of the menu.
  ///
  /// Defaults to `const SmartContextMenuConfig()`.
  final SmartContextMenuConfig config;

  /// Opens and closes the menu from code.
  ///
  /// Required when [SmartContextMenuConfig.activationMode] is
  /// [SmartContextMenuActivationMode.manual].
  final SmartContextMenuController? controller;

  /// Creates a context menu for [child].
  const SmartContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.config = const SmartContextMenuConfig(),
    this.controller,
  });

  @override
  State<SmartContextMenu> createState() => _SmartContextMenuState();
}

final class _SmartContextMenuState extends State<SmartContextMenu>
    with SingleTickerProviderStateMixin {
  final GlobalKey _previewKey = GlobalKey();
  final GlobalKey _persistentKey = GlobalKey();
  final Duration _pressDuration = MotionDurations.medium;
  late final String _heroTag;
  late final LongPressGestureRecognizer _longPressRecognizer;
  late final TapGestureRecognizer _tapRecognizer;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  late final SmartContextMenuSession _session;
  int? _activePointer;

  List<SmartContextMenuItem> get _items => widget.items;
  bool get _hasInternalActivation =>
      widget.config.activationMode == SmartContextMenuActivationMode.longPress;

  @override
  void initState() {
    super.initState();
    _debugValidateConfiguration();
    _heroTag = "menu_hero_${identityHashCode(widget)}";
    _session = SmartContextMenuSession();
    _setupAnimations();
    _setupRecognizers();
    _bindController();
    if (_items.isEmpty) debugPrint("Context menu info: menu is empty");
  }

  @override
  void didUpdateWidget(covariant SmartContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _debugValidateConfiguration();
    _syncRecognizers();
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      _bindController();
      return;
    }
    _syncControllerVisibility();
  }

  @override
  void dispose() {
    final activeRoute = _session.activeRoute;
    if (activeRoute != null) {
      _dismissRouteIfNeeded(activeRoute);
    }
    _session.invalidate();
    widget.controller?.detach();
    _longPressRecognizer.dispose();
    _scaleController.dispose();
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasInternalActivation = _hasInternalActivation;
    final contentStack = Stack(
      alignment: Alignment.center,
      children: [
        _buildSourceContent(),
        _buildPhantomHero(),
      ],
    );
    final content = hasInternalActivation
        ? ScaleTransition(
            scale: _scaleAnimation,
            child: contentStack,
          )
        : contentStack;

    if (!hasInternalActivation) {
      return content;
    }

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerCancel: (_) {
        if (!_session.hasActiveSession) _scaleController.reverse();
      },
      child: RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: {
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
            () => _longPressRecognizer,
            (instance) {},
          ),
          TapGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
            () => _tapRecognizer,
            (instance) {},
          ),
        },
        child: content,
      ),
    );
  }

  Widget _buildSourceContent() {
    return RepaintBoundary(
      key: _previewKey,
      child: Visibility(
        visible: !_session.isMenuVisible,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: KeyedSubtree(
          key: _persistentKey,
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildPhantomHero() {
    if (!_session.hasActiveSession) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Hero(
          tag: _heroTag,
          flightShuttleBuilder: _buildFlightShuttle,
          child: _session.isMenuVisible && _session.snapshot != null
              ? RawImage(image: _session.snapshot, fit: BoxFit.fill)
              : const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
        ),
      ),
    );
  }

  Widget _buildFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return _session.snapshot != null
        ? RawImage(image: _session.snapshot, fit: BoxFit.fill)
        : const SizedBox.shrink();
  }

  void _setupRecognizers() {
    _longPressRecognizer = LongPressGestureRecognizer(
      debugOwner: this,
      duration: _pressDuration,
    );

    _tapRecognizer = TapGestureRecognizer();
    _syncRecognizers();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      vsync: this,
      duration: _pressDuration,
    );

    _scaleAnimation = Tween<double>(
      begin: MotionScale.none.value,
      end: MotionScale.pressed.value,
    ).animate(
      CurvedAnimation(parent: _scaleController, curve: MotionCurves.standard),
    );
  }

  void _syncRecognizers() {
    final canHandleGestures = _hasInternalActivation && _items.isNotEmpty;

    _longPressRecognizer.onLongPress =
        canHandleGestures ? _handleLongPress : null;
    _tapRecognizer.onTapDown = canHandleGestures ? (_) => _startScale() : null;
    _tapRecognizer.onTapUp = canHandleGestures ? (_) => _stopScale() : null;
    _tapRecognizer.onTapCancel = canHandleGestures ? _stopScale : null;

    if (!canHandleGestures) {
      _scaleController.reset();
      return;
    }

    if (!_session.hasActiveSession && _scaleController.value != 0) {
      _scaleController.reset();
    }
  }

  void _bindController() {
    widget.controller?.attach(
      open: _handleControllerOpen,
      close: _closeMenu,
      isOpen: _session.isMenuVisible,
    );
  }

  void _syncControllerVisibility() {
    widget.controller?.syncVisibility(_session.isMenuVisible);
  }

  void _startScale() {
    if (!_session.hasActiveSession) _scaleController.forward();
  }

  void _stopScale() {
    if (_session.hasActiveSession) return;
    _scaleController.animateTo(0, duration: MotionDurations.ultraFast);
  }

  Future<void> _handleLongPress() async {
    if (_session.hasActiveSession) return;

    _interruptInternalGestures();

    await _scaleController.animateTo(0, duration: MotionDurations.fast);

    if (widget.config.enableHaptics) {
      await HapticFeedback.lightImpact();
    }

    if (mounted) {
      await _openMenu();
    }
  }

  Future<void> _handleControllerOpen() {
    return _openMenu();
  }

  Future<void> _openMenu() {
    if (_items.isEmpty) return Future.value();

    final sessionFuture = _session.sessionFuture;
    if (sessionFuture != null) return sessionFuture;

    final sessionId = _session.begin();
    _refreshSessionState();
    final future = _runOpenSession(sessionId);
    _session.bind(future);
    return future;
  }

  Future<void> _runOpenSession(int sessionId) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final barrierLabel =
      CupertinoLocalizations.of(context).modalBarrierDismissLabel;

    final image = await _captureSnapshot();
    if (!_session.canContinueOpening(sessionId, mounted: mounted) ||
        image == null) {
      _finishSession(sessionId);
      return;
    }
    _session.setSnapshot(image);

    final anchorRect = _calculateAnchorRect();
    if (!_session.canContinueOpening(sessionId, mounted: mounted) ||
        anchorRect == Rect.zero) {
      _finishSession(sessionId);
      return;
    }

    final route = SmartContextMenuRoute(
      anchorRect: anchorRect,
      snapshot: _session.snapshot,
      heroTag: _heroTag,
      items: widget.items,
      config: widget.config,
      barrierLabel: barrierLabel,
    );

    _session.attachRoute(
      sessionId: sessionId,
      route: route,
      navigator: navigator,
    );
    navigator.push(route);
    _scheduleRouteOpened(sessionId);

    if (_session.isClosing) {
      _dismissRouteIfNeeded(route);
    }

    try {
      await route.completed;
    } finally {
      _finishSession(sessionId);
    }
  }

  Future<void> _closeMenu() async {
    final sessionFuture = _session.sessionFuture;
    if (sessionFuture == null) return;

    if (_session.startClosing()) _refreshSessionState();

    final route = _session.activeRoute;
    if (route == null) {
      await sessionFuture;
      return;
    }

    _dismissRouteIfNeeded(route);

    await sessionFuture;
  }

  Future<ui.Image?> _captureSnapshot() async {
    final boundary = _previewKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    return await boundary.toImage(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
  }

  Rect _calculateAnchorRect() {
    final contextRef = _previewKey.currentContext;
    if (contextRef == null || !contextRef.mounted) return Rect.zero;

    final box = contextRef.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  void _scheduleRouteOpened(int sessionId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_session.markOpen(sessionId)) _refreshSessionState();
    });
  }

  void _finishSession(int sessionId) {
    if (_session.finishIfCurrent(sessionId)) _refreshSessionState();
  }

  void _dismissRouteIfNeeded(SmartContextMenuRoute route) {
    final navigator = _session.activeNavigator ?? route.navigator;
    if (navigator == null || !route.isActive) return;

    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
  }

  void _refreshSessionState() {
    if (mounted) setState(() {});
    _syncControllerVisibility();
  }

  void _interruptInternalGestures() {
    if (_activePointer != null) {
      GestureBinding.instance.gestureArena.close(_activePointer!);
      GestureBinding.instance.gestureArena.sweep(_activePointer!);
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointer = event.pointer;
  }

  void _debugValidateConfiguration() {
    assert(
      widget.config.activationMode != SmartContextMenuActivationMode.manual ||
          widget.controller != null,
      "SmartContextMenu in manual mode requires a controller.",
    );
  }
}
