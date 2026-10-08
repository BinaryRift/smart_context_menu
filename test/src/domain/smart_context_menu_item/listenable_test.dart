import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  final listenable = ChangeNotifier();
  SmartContextMenuItem? builder() => null;

  tearDownAll(listenable.dispose);

  test('keeps the listenable, the builder and the placeholder fields', () {
    const leading = SizedBox();
    const titleStyle = TextStyle(fontSize: 20);
    Widget loadingBuilder(
      BuildContext context,
      SmartContextMenuItemState state,
    ) => const SizedBox();
    final item = SmartContextMenuItem.listenable(
      listenable: listenable,
      builder: builder,
      leading: leading,
      loadingTitle: 'Checking',
      titleStyle: titleStyle,
      loadingBuilder: loadingBuilder,
      childrenGap: 4,
    );

    expect(item.listenable, same(listenable));
    expect(item.listenableBuilder, builder);
    expect(item.leading, same(leading));
    expect(item.title, 'Checking');
    expect(item.titleStyle, titleStyle);
    expect(item.loadingBuilder, loadingBuilder);
    expect(item.childrenGap, 4);
  });

  test('leaves taps to the built item', () {
    final item = SmartContextMenuItem.listenable(
      listenable: listenable,
      builder: builder,
    );

    expect(item.closeOnTap, isFalse);
    expect(item.onTap, isNull);
    expect(item.asyncItem, isNull);
    expect(item.loadingTimeout, isNull);
    expect(item.errorBuilder, isNull);
    expect(item.showTransitionIcon, isFalse);
    expect(item.isInternalInteracted, isFalse);
  });
}
