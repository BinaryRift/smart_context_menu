import 'dart:async' show FutureOr;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart' show HapticFeedback;

import '../../controllers/smart_context_menu_controller.dart';
import '../../domain/smart_context_menu_activation_mode.dart';
import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_header_details.dart';
import '../../domain/smart_context_menu_item.dart';
import '../routes/smart_context_menu_route.dart';
import '../state/smart_context_menu_session.dart';
import '../theme/smart_context_menu_theme.dart';
import '../widgets/smart_context_menu_anchor.dart';
import '../widgets/smart_context_menu_press_detector.dart';

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
/// To set the config of all menus in the app or in a part of the tree, wrap
/// it with a [SmartContextMenuTheme].
///
/// To show your own content above the preview, for example a reactions
/// bar, pass [headerSliversBuilder].
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
  /// Replaces the config of the nearest [SmartContextMenuTheme] as a whole.
  /// To change a few of its settings, start from it with
  /// `SmartContextMenuTheme.of(context).copyWith(...)`.
  /// If null, the config of the theme is used, and without a theme
  /// `const SmartContextMenuConfig()`.
  final SmartContextMenuConfig? config;

  /// Opens and closes the menu from code.
  ///
  /// Required when [SmartContextMenuConfig.activationMode] is
  /// [SmartContextMenuActivationMode.manual].
  final SmartContextMenuController? controller;

  /// Called when the preview above the open menu is tapped.
  ///
  /// The menu starts closing before it is called, as with an item that
  /// closes on tap. Use it for the main action of [child], for example to
  /// open a message. If null, tapping the preview does nothing.
  final FutureOr<void> Function()? onPreviewTap;

  /// Builds slivers shown above the preview while the menu is open.
  ///
  /// Use it for content tied to [child], for example a reactions bar above
  /// a message. The slivers move with the preview when it is dragged or
  /// the menu is stretched, and fade in and out with the menu, see
  /// [fadeHeaderSlivers]. To line them up with the preview, animate them
  /// with the menu and close the menu, use the
  /// [SmartContextMenuHeaderDetails] passed to the builder.
  ///
  /// The slivers are direct children of the scroll view of the menu, so
  /// a [PinnedHeaderSliver] stays at the top, right below the status bar,
  /// while a tall preview and the menu scroll under it.
  ///
  /// If null, nothing is shown above the preview.
  final SmartContextMenuHeaderBuilder? headerSliversBuilder;

  /// Whether the slivers from [headerSliversBuilder] fade in and out with
  /// the menu.
  ///
  /// Set it to false to animate them only with
  /// [SmartContextMenuHeaderDetails.animation]. Defaults to true.
  final bool fadeHeaderSlivers;

  /// Creates a context menu for [child].
  const SmartContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.config,
    this.controller,
    this.onPreviewTap,
    this.headerSliversBuilder,
    this.fadeHeaderSlivers = true,
  });

  @override
  State<SmartContextMenu> createState() => _SmartContextMenuState();
}

final class _SmartContextMenuState extends State<SmartContextMenu> {
  final GlobalKey _previewKey = GlobalKey();
  final GlobalKey _persistentKey = GlobalKey();
  late final String _heroTag;

  late final SmartContextMenuSession _session;
  late SmartContextMenuConfig _config;

  List<SmartContextMenuItem> get _items => widget.items;
  bool get _hasInternalActivation =>
      _config.activationMode == SmartContextMenuActivationMode.longPress;

  @override
  void initState() {
    super.initState();
    _heroTag = "menu_hero_${identityHashCode(widget)}";
    _session = SmartContextMenuSession();
    _bindController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveConfig();
  }

  @override
  void didUpdateWidget(covariant SmartContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resolveConfig();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartContextMenuPressDetector(
      enabled: _hasInternalActivation && _items.isNotEmpty,
      isMenuActive: _session.hasActiveSession,
      onLongPress: _handleLongPress,
      child: SmartContextMenuAnchor(
        previewKey: _previewKey,
        contentKey: _persistentKey,
        heroTag: _heroTag,
        snapshot: () => _session.snapshot,
        isMenuActive: _session.hasActiveSession,
        isMenuVisible: _session.isMenuVisible,
        child: widget.child,
      ),
    );
  }

  void _resolveConfig() {
    _config = widget.config ?? SmartContextMenuTheme.of(context);
    _debugValidateConfiguration();
  }

  void _bindController() {
    widget.controller?.attach(
      open: _openMenu,
      close: _closeMenu,
      isOpen: _session.isMenuVisible,
    );
  }

  void _syncControllerVisibility() {
    widget.controller?.syncVisibility(_session.isMenuVisible);
  }

  Future<void> _handleLongPress() async {
    if (_config.enableHaptics) {
      await HapticFeedback.lightImpact();
    }

    if (mounted) {
      await _openMenu();
    }
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
    final barrierLabel = CupertinoLocalizations.of(
      context,
    ).modalBarrierDismissLabel;

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
      config: _config,
      onPreviewTap: widget.onPreviewTap,
      headerSliversBuilder: widget.headerSliversBuilder,
      fadeHeaderSlivers: widget.fadeHeaderSlivers,
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
    final boundary =
        _previewKey.currentContext?.findRenderObject()
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

  void _debugValidateConfiguration() {
    assert(
      _config.activationMode != SmartContextMenuActivationMode.manual ||
          widget.controller != null,
      "SmartContextMenu in manual mode requires a controller.",
    );
  }
}
