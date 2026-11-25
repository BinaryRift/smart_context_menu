// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('has its defaults', () {
    const style = SmartContextMenuStatusStyle();

    expect(style.titleAlign, SmartContextMenuDefaults.statusTitleAlign);
    expect(style.errorIcon, SmartContextMenuDefaults.errorIcon);
    expect(style.retryIcon, SmartContextMenuDefaults.retryIcon);
    expect(style.emptyIcon, SmartContextMenuDefaults.emptyIcon);
    expect(style.loadingIndicator, isNull);
    expect(
      style.loaderVerticalPadding,
      SmartContextMenuDefaults.loaderVerticalPadding,
    );
  });

  group('copyWith', () {
    const original = SmartContextMenuStatusStyle(
      titleAlign: TextAlign.end,
      errorIcon: CupertinoIcons.xmark,
      retryIcon: CupertinoIcons.refresh_thick,
      emptyIcon: CupertinoIcons.cube_box,
      loadingIndicator: SizedBox(width: 1),
      loaderVerticalPadding: 1,
    );

    final fields = <String, Object? Function(SmartContextMenuStatusStyle)>{
      'titleAlign': (s) => s.titleAlign,
      'errorIcon': (s) => s.errorIcon,
      'retryIcon': (s) => s.retryIcon,
      'emptyIcon': (s) => s.emptyIcon,
      'loadingIndicator': (s) => s.loadingIndicator,
      'loaderVerticalPadding': (s) => s.loaderVerticalPadding,
    };

    const indicator = SizedBox(width: 9);
    final changes = <String, (Object, SmartContextMenuStatusStyle Function())>{
      'titleAlign': (
        TextAlign.start,
        () => original.copyWith(titleAlign: TextAlign.start),
      ),
      'errorIcon': (
        CupertinoIcons.xmark_circle,
        () => original.copyWith(errorIcon: CupertinoIcons.xmark_circle),
      ),
      'retryIcon': (
        CupertinoIcons.arrow_clockwise,
        () => original.copyWith(retryIcon: CupertinoIcons.arrow_clockwise),
      ),
      'emptyIcon': (
        CupertinoIcons.square_stack,
        () => original.copyWith(emptyIcon: CupertinoIcons.square_stack),
      ),
      'loadingIndicator': (
        indicator,
        () => original.copyWith(loadingIndicator: indicator),
      ),
      'loaderVerticalPadding': (
        9.0,
        () => original.copyWith(loaderVerticalPadding: 9),
      ),
    };

    test('covers every field', () {
      expect(changes.keys, unorderedEquals(fields.keys));
    });

    test('without arguments keeps every field', () {
      final copy = original.copyWith();
      for (final MapEntry(key: name, value: get) in fields.entries) {
        expect(get(copy), get(original), reason: name);
      }
    });

    for (final MapEntry(key: changed, value: (value, copyWith))
        in changes.entries) {
      test('changes only $changed', () {
        final copy = copyWith();
        for (final MapEntry(key: name, value: get) in fields.entries) {
          expect(
            get(copy),
            name == changed ? value : get(original),
            reason: name,
          );
        }
      });
    }
  });
}
