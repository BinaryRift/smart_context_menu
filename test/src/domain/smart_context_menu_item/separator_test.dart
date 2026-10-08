import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('is a separator without actions', () {
    final item = SmartContextMenuItem.separator();

    expect(item.isSeparator, isTrue);
    expect(item.closeOnTap, isFalse);
    expect(item.onTap, isNull);
    expect(item.customBuilder, isNull);
    expect(item.isInternalInteracted, isFalse);
  });

  test('builds the given child', () {
    const child = Text('Section');
    const metadata = SmartContextMenuPagingMetadata(page: 2);
    final item = SmartContextMenuItem.separator(
      child: child,
      pagingMetadata: metadata,
    );

    expect(
      item.customBuilder!(
        _FakeContext(),
        const SmartContextMenuItemState(
          isPressed: false,
          isDisabled: false,
          isDestructive: false,
          foregroundColor: Color(0xFF000000),
        ),
      ),
      same(child),
    );
    expect(item.pagingMetadata, metadata);
  });
}

final class _FakeContext extends Fake implements BuildContext {}
