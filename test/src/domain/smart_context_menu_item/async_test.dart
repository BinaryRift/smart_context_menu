import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  Future<SmartContextMenuItem> loader() async =>
      SmartContextMenuItem.simple(title: 'Loaded');

  test('keeps the loader and the placeholder fields', () {
    const leading = SizedBox();
    const titleStyle = TextStyle(fontSize: 20);
    Widget builder(BuildContext context, SmartContextMenuItemState state) =>
        const SizedBox();
    final item = SmartContextMenuItem.async(
      asyncItem: loader,
      timeout: const Duration(seconds: 3),
      leading: leading,
      loadingTitle: 'Checking',
      titleStyle: titleStyle,
      loadingBuilder: builder,
      errorBuilder: builder,
      childrenGap: 4,
    );

    expect(item.asyncItem, loader);
    expect(item.loadingTimeout, const Duration(seconds: 3));
    expect(item.leading, same(leading));
    expect(item.title, 'Checking');
    expect(item.titleStyle, titleStyle);
    expect(item.loadingBuilder, builder);
    expect(item.errorBuilder, builder);
    expect(item.childrenGap, 4);
  });

  test('stays open on tap and uses the default timeout', () {
    final item = SmartContextMenuItem.async(asyncItem: loader);

    expect(item.loadingTimeout, SmartContextMenuDefaults.loadingTimeout);
    expect(item.closeOnTap, isFalse);
    expect(item.showTransitionIcon, isFalse);
    expect(item.isInternalInteracted, isTrue);
  });
}
