import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/services.dart' show HapticFeedback;
import '../domain/smart_context_menu_item.dart';
import '../domain/smart_context_menu_level.dart';
import '../domain/smart_context_menu_navigator.dart';
import '../domain/smart_context_menu_paging_metadata.dart';
import '../ui/state/smart_context_menu_cache.dart';

final class SmartContextMenuOverlayController extends ChangeNotifier {
  final SmartContextMenuNavigator navigator;
  final List<SmartContextMenuItem> initialItems;
  final bool enableHaptics;
  late final SmartContextMenuCache _cache;

  SmartContextMenuOverlayController({
    required this.navigator,
    required this.initialItems,
    required this.enableHaptics,
  }) {
    _cache = SmartContextMenuCache();
    _menuStack.add(SmartMenuLevel(items: initialItems));
  }

  @override
  void dispose() {
    _cache.clear();
    _activeLoadTask = null;
    _menuStack.clear();
    super.dispose();
  }

  final List<SmartMenuLevel> _menuStack = [];
  bool _isForward = true;
  Future<List<SmartContextMenuItem>>? _activeLoadTask;

  List<SmartMenuLevel> get menuStack => _menuStack;
  SmartMenuLevel get currentLevel => _menuStack.last;

  /// The level below [currentLevel], or null on the root level.
  SmartMenuLevel? get previousLevel =>
      _menuStack.length > 1 ? _menuStack[_menuStack.length - 2] : null;
  bool get isForward => _isForward;
  int get stackLength => _menuStack.length;
  SmartContextMenuCache get cache => _cache;

  SmartMenuLevel _pushSubmenuLevel({
    required String parentId,
    required List<SmartContextMenuItem> items,
    SmartContextMenuPageLoader? pagingMethod,
    SmartContextMenuSubmenuLoader? asyncLoader,
    SmartContextMenuPagingMetadata? initialMetadata,
    Duration? loadingTimeout,
    SmartContextMenuLoadingItem? loadingItem,
    SmartContextMenuErrorItem? errorItem,
    SmartContextMenuEmptyItem? emptyItem,
    bool loading = false,
  }) {
    _isForward = true;
    final level = SmartMenuLevel(
      items: items,
      asyncLoader: asyncLoader,
      pagingMethod: pagingMethod,
      loadingTimeout: loadingTimeout,
      loadingItem: loadingItem,
      errorItem: errorItem,
      emptyItem: emptyItem,
      nextMetadata: initialMetadata,
      parentId: parentId,
      isLoading: loading,
    );
    _menuStack.add(level);
    notifyListeners();
    if (enableHaptics) HapticFeedback.selectionClick();
    return level;
  }

  void popSubmenu() {
    if (_menuStack.length <= 1) return;
    _isForward = false;
    _activeLoadTask = null;
    _menuStack.removeLast();
    notifyListeners();
    if (enableHaptics) HapticFeedback.selectionClick();
  }

  void handleItemTap(SmartContextMenuItem item) async {
    if (currentLevel.isLoading) return;
    if (item case SmartContextMenuContentItem(isDisabled: true)) return;

    switch (item) {
      case SmartContextMenuSimpleItem():
        _handleOnTap(item);
      case SmartContextMenuSubmenuItem():
        _pushSubmenuLevel(items: item.children, parentId: item.id);
      case SmartContextMenuAsyncSubmenuItem():
        _handleAsyncSubmenu(item);
      case SmartContextMenuPagingSubmenuItem():
        _handleAsyncPagingStart(item);
      // Not tapped themselves: async and listenable items pass the item
      // they show.
      case SmartContextMenuAsyncItem() ||
          SmartContextMenuListenableItem() ||
          SmartContextMenuStatusItem() ||
          SmartContextMenuSeparatorItem():
        break;
    }
  }

  Future<void> _handleOnTap(SmartContextMenuSimpleItem item) async {
    if (item.onTap == null && !item.closeOnTap) return;
    if (enableHaptics) HapticFeedback.lightImpact();
    if (item.closeOnTap) {
      await navigator.dismissWithDelay();
    }
    await item.onTap?.call();
  }

  Future<void> _handleAsyncSubmenu(
    SmartContextMenuAsyncSubmenuItem item,
  ) async {
    if (_cache.submenus[item.id] case final items?) {
      _pushSubmenuLevel(items: items, emptyItem: item.empty, parentId: item.id);
      return;
    }
    final task = item.asyncChildren()._limit(item.timeout);

    final level = _pushSubmenuLevel(
      items: [],
      loading: true,
      parentId: item.id,
      asyncLoader: item.asyncChildren,
      loadingTimeout: item.timeout,
      loadingItem: item.loading,
      errorItem: item.error,
      emptyItem: item.empty,
    );

    await _runAsyncLoad(
      task,
      level,
      onData: (results) {
        _cache.submenus[item.id] = results;
        level.items.addAll(results);
      },
    );
  }

  Future<void> _handleAsyncPagingStart(
    SmartContextMenuPagingSubmenuItem item,
  ) async {
    if (_cache.paging[item.id] case (final items, final nextMetadata)?) {
      _pushSubmenuLevel(
        items: List.from(items),
        pagingMethod: item.asyncPagingChildren,
        initialMetadata: nextMetadata,
        loadingTimeout: item.timeout,
        loadingItem: item.loading,
        errorItem: item.error,
        emptyItem: item.empty,
        parentId: item.id,
      );
      return;
    }

    final loader = item.asyncPagingChildren;
    final metadata = item.initialMetadata;
    final task = loader(metadata)._limit(item.timeout);

    final level = _pushSubmenuLevel(
      items: [],
      loading: true,
      parentId: item.id,
      pagingMethod: loader,
      initialMetadata: metadata,
      loadingTimeout: item.timeout,
      loadingItem: item.loading,
      errorItem: item.error,
      emptyItem: item.empty,
    );

    await _runAsyncLoad(
      task,
      level,
      onData: (results) {
        final nextMeta = _nextPageMetadata(results);
        _cache.paging[item.id] = (List.from(results), nextMeta);

        level.items.addAll(results);
        level.nextMetadata = nextMeta;
      },
    );
  }

  Future<void> _runAsyncLoad(
    Future<List<SmartContextMenuItem>> task,
    SmartMenuLevel level, {
    required void Function(List<SmartContextMenuItem> data) onData,
  }) async {
    _activeLoadTask = task;

    try {
      final results = await task;

      if (hasListeners && _activeLoadTask == task) {
        level.isLoading = false;
        onData(results);
        notifyListeners();
      }
    } catch (e) {
      _handleLoadError(task, level);
    }
  }

  void _handleLoadError(Future task, SmartMenuLevel level) {
    if (hasListeners && _activeLoadTask == task) {
      level.isLoading = false;
      _activeLoadTask = null;
      level.hasError = true;
      notifyListeners();
    }
  }

  /// Loads the next page of [level].
  Future<void> handlePagination(SmartMenuLevel level) async {
    final pagingMethod = level.pagingMethod;
    final metadata = level.nextMetadata;
    if (level.isPaginating ||
        pagingMethod == null ||
        metadata == null ||
        !hasListeners) {
      return;
    }

    level.isPaginating = true;
    notifyListeners();
    final List<SmartContextMenuItem> targetList = level.items;

    try {
      final timeout = level.loadingTimeout;
      final newItems = await pagingMethod(metadata)._limit(timeout);

      _processPaginationResult(level, targetList, newItems);
    } catch (e) {
      _handlePaginationError(level);
    }
  }

  void _processPaginationResult(
    SmartMenuLevel level,
    List<SmartContextMenuItem> targetList,
    List<SmartContextMenuItem> newItems,
  ) {
    if (hasListeners && level.items == targetList) {
      final nextMeta = _nextPageMetadata(newItems);
      level.items.addAll(newItems);
      level.nextMetadata = nextMeta;
      level.isPaginating = false;
      notifyListeners();

      final String? parentId = level.parentId;
      _cachePaginationResult(parentId: parentId, newItems: newItems);
    }
  }

  void _cachePaginationResult({
    required String? parentId,
    required List<SmartContextMenuItem> newItems,
  }) {
    if (parentId != null) {
      final currentCached = _cache.paging[parentId] ?? ([], null);
      final updatedList = [...currentCached.$1, ...newItems];
      final nextMeta = _nextPageMetadata(newItems);
      _cache.paging[parentId] = (updatedList, nextMeta);
    }
  }

  // The last item of a page describes the next page; a page without
  // metadata on its last item is the last one.
  static SmartContextMenuPagingMetadata? _nextPageMetadata(
    List<SmartContextMenuItem> page,
  ) => switch (page.lastOrNull) {
    SmartContextMenuSimpleItem(:final pagingMetadata) ||
    SmartContextMenuSeparatorItem(:final pagingMetadata) => pagingMetadata,
    _ => null,
  };

  void _handlePaginationError(SmartMenuLevel level) {
    if (!hasListeners) return;
    level.isPaginating = false;
    level.hasError = true;
    notifyListeners();
  }

  /// Retries the failed load of [level]: the next page of a paginated
  /// level or the items of an async submenu.
  void onRetryLoad(SmartMenuLevel level) {
    final bool hasPagination = level.hasPaging;

    level.hasError = false;
    notifyListeners();
    if (hasPagination) {
      handlePagination(level);
    } else if (level.hasBack) {
      _retryLevelLoad(level);
    }
  }

  Future<void> _retryLevelLoad(SmartMenuLevel level) async {
    if (!hasListeners) return;

    // Paging levels retry through [handlePagination].
    final task = level.asyncLoader?.call()._limit(level.loadingTimeout);
    if (task == null) return;

    level.isLoading = true;
    notifyListeners();

    await _runAsyncLoad(
      task,
      level,
      onData: (results) {
        if (level.parentId != null) {
          _cache.submenus[level.parentId!] = results;
        }
        level.items.addAll(results);
      },
    );
  }
}

extension<T> on Future<T> {
  /// Fails with a `TimeoutException` if the future takes longer
  /// than [timeout].
  Future<T> _limit(Duration? timeout) =>
      timeout == null ? this : this.timeout(timeout);
}
