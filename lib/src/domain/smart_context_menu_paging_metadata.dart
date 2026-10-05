import 'package:flutter/foundation.dart' show immutable;

@immutable
final class SmartContextMenuPagingMetadata {
  final int page;
  final int limit;
  final String? nextCursor;
  /// Custom filters or parameters passed through to the loader.
  final Map<String, dynamic> extra; 

  const SmartContextMenuPagingMetadata({
    this.page = 1,
    this.limit = 20,
    this.nextCursor,
    this.extra = const {},
  });

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
