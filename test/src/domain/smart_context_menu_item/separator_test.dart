import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('has no child and no paging metadata by default', () {
    final item = SmartContextMenuItem.separator();

    expect(item.child, isNull);
    expect(item.pagingMetadata, isNull);
  });

  test('keeps the given child and paging metadata', () {
    const child = Text('Section');
    const metadata = SmartContextMenuPagingMetadata(page: 2);
    final item = SmartContextMenuItem.separator(
      child: child,
      pagingMetadata: metadata,
    );

    expect(item.child, same(child));
    expect(item.pagingMetadata, metadata);
  });
}
