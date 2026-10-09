import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  final listenable = ChangeNotifier();
  SmartContextMenuListenableResult builder() => SmartContextMenuItem.simple();

  tearDownAll(listenable.dispose);

  test('keeps the listenable and the builder', () {
    final item = SmartContextMenuItem.listenable(
      listenable: listenable,
      builder: builder,
    );

    expect(item.listenable, same(listenable));
    expect(item.builder, builder);
  });
}
