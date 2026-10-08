import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  final listenable = ChangeNotifier();
  SmartContextMenuItem builder() => SmartContextMenuItem.simple();

  tearDownAll(listenable.dispose);

  test('keeps the listenable and the builder', () {
    final item = SmartContextMenuItem.listenable(
      listenable: listenable,
      builder: builder,
    );

    expect(item.listenable, same(listenable));
    expect(item.listenableBuilder, builder);
  });

  test('leaves taps to the built item', () {
    final item = SmartContextMenuItem.listenable(
      listenable: listenable,
      builder: builder,
    );

    expect(item.closeOnTap, isFalse);
    expect(item.onTap, isNull);
    expect(item.title, isNull);
    expect(item.loadingBuilder, isNull);
    expect(item.asyncItem, isNull);
    expect(item.loadingTimeout, isNull);
    expect(item.errorBuilder, isNull);
    expect(item.showTransitionIcon, isFalse);
    expect(item.isInternalInteracted, isFalse);
  });
}
