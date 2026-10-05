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
  bool _isLoading = false;
  bool _isForward = true;
  Future<List<SmartContextMenuItem>>? _activeLoadTask;

  List<SmartMenuLevel> get menuStack => _menuStack;
  SmartMenuLevel get currentLevel => _menuStack.last;
  bool get isLoading => _isLoading;
  bool get isForward => _isForward;
  int get stackLength => _menuStack.length;
  SmartContextMenuCache get cache => _cache;

  void _pushSubmenuLevel({
    required String parentId,
    required List<SmartContextMenuItem> items,
    SmartContextMenuPageLoader? pagingMethod,
    SmartContextMenuSubmenuLoader? asyncLoader,
    SmartContextMenuPagingMetadata? initialMetadata,
    bool loading = false,
  }) {
    _isForward = true;
    _isLoading = loading;
    _menuStack.add(SmartMenuLevel(
      items: items,
      asyncLoader: asyncLoader,
      pagingMethod: pagingMethod,
      nextMetadata: initialMetadata,
      parentId: parentId,
    ));
    notifyListeners();
    if (enableHaptics) HapticFeedback.selectionClick();
  }

  void popLevel() {
    if (_menuStack.length <= 1) return;
    _isForward = false;
    _activeLoadTask = null;
    _menuStack.removeLast();
    notifyListeners();
  }

  void popSubmenu() {
    if (_menuStack.length <= 1) return;
    _isForward = false;
    _isLoading = false;
    _activeLoadTask = null;
    _menuStack.removeLast();
    notifyListeners();
    if (enableHaptics) HapticFeedback.selectionClick();
  }

  int calculateTotalItemCount() {
    final level = currentLevel;
    final bool hasBack = _menuStack.length > 1;
    final int itemsCount = level.items.length;

    int count = hasBack ? 1 : 0;
    if (itemsCount == 0) {
      if (_isLoading) return count + 1;
      if (level.hasError) return count + 1;
    }
    count += itemsCount;
    if (level.hasPaging || level.hasError) {
      count += 1;
    }
    return count;
  }

  void handleItemTap(SmartContextMenuItem item) async {
    if (item.isDisabled || _isLoading) return;

    if (item.children != null) {
      final id = item.id;
      _pushSubmenuLevel(items: item.children!, parentId: id);
      return;
    }

    if (item.asyncChildren != null) {
      _handleAsyncSubmenu(item);
      return;
    }

    if (item.asyncPagingChildren != null) {
      _handleAsyncPagingStart(item);
      return;
    }

    _handleOnTap(item);
  }

  Future<void> _handleOnTap(SmartContextMenuItem item) async {
    if (item.onTap == null && !item.closeOnTap) return;
    if (enableHaptics) HapticFeedback.lightImpact();
    if (item.closeOnTap) {
      await navigator.dismissWithDelay();
    }
    await item.onTap?.call();
  }

  Future<void> _handleAsyncSubmenu(SmartContextMenuItem item) async {
    if (_tryRestoreSubmenuFromCache(item)) return;
    final task = item.asyncChildren?.call();
    if (task == null) return;

    _pushSubmenuLevel(
      items: [],
      loading: true,
      parentId: item.id,
      asyncLoader: item.asyncChildren,
    );

    await _runAsyncLoad(task, onData: (results) {
      _cache.submenus[item.id] = results;
      _menuStack.last.items.addAll(results);
    });
  }

  Future<void> _handleAsyncPagingStart(SmartContextMenuItem item) async {
    if (_tryRestoreSubmenuFromCache(item)) return;

    final loader = item.asyncPagingChildren;
    final metadata = item.pagingMetadata;
    if (loader == null || metadata == null) return;
    final task = loader(metadata);

    _pushSubmenuLevel(
      items: [],
      loading: true,
      parentId: item.id,
      pagingMethod: loader,
      initialMetadata: metadata,
    );

    await _runAsyncLoad(task, onData: (results) {
      final nextMeta = results.isNotEmpty ? results.last.pagingMetadata : null;
      _cache.paging[item.id] = (List.from(results), nextMeta);

      final level = _menuStack.last;
      level.items.addAll(results);
      level.nextMetadata = nextMeta;
    });
  }

  Future<void> _runAsyncLoad(
    Future<List<SmartContextMenuItem>> task, {
    required void Function(List<SmartContextMenuItem> data) onData,
  }) async {
    _activeLoadTask = task;

    try {
      final results = await task;

      if (hasListeners && _activeLoadTask == task) {
        _isLoading = false;
        onData(results);
        notifyListeners();
      }
    } catch (e) {
      _handleLoadError(task);
    }
  }

  void _handleLoadError(Future task) {
    if (hasListeners && _activeLoadTask == task) {
      _isLoading = false;
      _activeLoadTask = null;
      _menuStack.last.hasError = true;
      notifyListeners();
    }
  }

  Future<void> handlePagination() async {
    final currentLevel = _menuStack.last;
    final pagingMethod = currentLevel.pagingMethod;
    final metadata = currentLevel.nextMetadata;
    if (currentLevel.isPaginating ||
        pagingMethod == null ||
        metadata == null ||
        !hasListeners) {
      return;
    }

    currentLevel.isPaginating = true;
    notifyListeners();
    final List<SmartContextMenuItem> targetList = currentLevel.items;

    try {
      final newItems = await pagingMethod(metadata);

      _processPaginationResult(currentLevel, targetList, newItems);
    } catch (e) {
      _handlePaginationError(currentLevel);
    }
  }

  void _processPaginationResult(
    SmartMenuLevel level,
    List<SmartContextMenuItem> targetList,
    List<SmartContextMenuItem> newItems,
  ) {
    if (hasListeners && level.items == targetList) {
      final nextMeta =
          newItems.isNotEmpty ? newItems.last.pagingMetadata : null;
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
      final nextMeta =
          newItems.isNotEmpty ? newItems.last.pagingMetadata : null;
      _cache.paging[parentId] = (updatedList, nextMeta);
    }
  }

  void _handlePaginationError(SmartMenuLevel level) {
    if (!hasListeners) return;
    level.isPaginating = false;
    level.hasError = true;
    notifyListeners();
  }

  bool _tryRestoreSubmenuFromCache(SmartContextMenuItem item) {
    final id = item.id;

    if (_cache.submenus.containsKey(id)) {
      _pushSubmenuLevel(items: _cache.submenus[id]!, parentId: id);
      return true;
    }

    if (_cache.paging.containsKey(id)) {
      final (items, meta) = _cache.paging[id]!;
      _pushSubmenuLevel(
        items: List.from(items),
        pagingMethod: item.asyncPagingChildren,
        initialMetadata: meta,
        parentId: id,
      );
      return true;
    }

    return false;
  }

  void onRetryLoad(bool hasPagination) {
    final currentLevel = _menuStack.last;
    final String? parentId = currentLevel.parentId;

    currentLevel.hasError = false;
    notifyListeners();
    if (hasPagination) {
      handlePagination();
    } else if (parentId != null) {
      _retryLevelLoad(currentLevel);
    }
  }

  Future<void> _retryLevelLoad(SmartMenuLevel level) async {
    if (!hasListeners) return;

    // Paging levels retry through [handlePagination].
    final task = level.asyncLoader?.call();
    if (task == null) return;

    _isLoading = true;
    notifyListeners();

    await _runAsyncLoad(task, onData: (results) {
      if (level.parentId != null) {
        _cache.submenus[level.parentId!] = results;
      }
      level.items.addAll(results);
    });
  }
}
