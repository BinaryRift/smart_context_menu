import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('keeps the given fields', () {
    void onTap() {}
    const leading = SizedBox();
    const trailing = SizedBox();
    const titleStyle = TextStyle(fontSize: 20);
    const metadata = SmartContextMenuPagingMetadata(page: 2);
    final item = SmartContextMenuItem.simple(
      title: 'Edit',
      titleStyle: titleStyle,
      leading: leading,
      trailing: trailing,
      isDestructive: true,
      tintColor: const Color(0xFF00FF00),
      isDisabled: true,
      closeOnTap: false,
      onTap: onTap,
      childrenGap: 4,
      pagingMetadata: metadata,
    );

    expect(item.title, 'Edit');
    expect(item.titleStyle, titleStyle);
    expect(item.leading, same(leading));
    expect(item.trailing, same(trailing));
    expect(item.isDestructive, isTrue);
    expect(item.tintColor, const Color(0xFF00FF00));
    expect(item.isDisabled, isTrue);
    expect(item.closeOnTap, isFalse);
    expect(item.onTap, onTap);
    expect(item.childrenGap, 4);
    expect(item.pagingMetadata, metadata);
  });

  test('has defaults of a plain action', () {
    final item = SmartContextMenuItem.simple(title: 'Edit');

    expect(item.isDestructive, isFalse);
    expect(item.isDisabled, isFalse);
    expect(item.closeOnTap, isTrue);
    expect(item.onTap, isNull);
    expect(item.pagingMetadata, isNull);
  });
}
