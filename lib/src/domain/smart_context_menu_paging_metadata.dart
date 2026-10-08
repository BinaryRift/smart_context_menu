import 'package:flutter/foundation.dart' show immutable;

import '../core/ui/styles/smart_context_menu_defaults.dart';

/// Describes a page of a [SmartContextMenuItem.pagingSubmenu].
///
/// The menu does not interpret the fields: it passes the metadata to the
/// [SmartContextMenuPageLoader] as is. Use [page] and [limit] for offset
/// pagination, [nextCursor] for cursor pagination and [extra] for anything
/// else.
///
/// The first page is described by the `initialMetadata` of
/// [SmartContextMenuItem.pagingSubmenu]. Each next page is described by the
/// [SmartContextMenuItem.pagingMetadata] of the last item of the previous
/// page. To mark the last page, leave the metadata of its last item null
/// or return an empty page.
@immutable
final class SmartContextMenuPagingMetadata {
  /// The number of the page to load.
  ///
  /// Defaults to 1.
  final int page;

  /// The maximum number of items on a page.
  ///
  /// Defaults to [SmartContextMenuDefaults.pageLimit].
  final int limit;

  /// The cursor of the page to load, for cursor-based APIs.
  final String? nextCursor;

  /// Custom filters or parameters passed through to the loader.
  ///
  /// Defaults to an empty map.
  final Map<String, dynamic> extra;

  /// Creates paging metadata.
  const SmartContextMenuPagingMetadata({
    this.page = 1,
    this.limit = SmartContextMenuDefaults.pageLimit,
    this.nextCursor,
    this.extra = const {},
  });

  /// Returns a copy with the given fields replaced.
  ///
  /// [nextCursor] cannot be reset to null this way; create a new instance
  /// instead.
  SmartContextMenuPagingMetadata copyWith({
    int? page,
    int? limit,
    String? nextCursor,
    Map<String, dynamic>? extra,
  }) {
    return SmartContextMenuPagingMetadata(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      nextCursor: nextCursor ?? this.nextCursor,
      extra: extra ?? this.extra,
    );
  }
}
