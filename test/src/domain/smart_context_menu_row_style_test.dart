import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('has its defaults', () {
    const style = SmartContextMenuRowStyle();

    expect(style.padding, EdgeInsets.zero);
    expect(style.childrenGap, 0);
    expect(
      style.smallItemPadding,
      SmartContextMenuDefaults.rowSmallItemPadding,
    );
    expect(
      style.mediumItemPadding,
      SmartContextMenuDefaults.rowMediumItemPadding,
    );
    expect(style.itemChildrenGap, SmartContextMenuDefaults.rowItemChildrenGap);
    expect(style.titleStyle, SmartContextMenuDefaults.rowTitleStyle);
    expect(style.dividerIndent, 0);
    expect(style.dividerEndIndent, 0);
  });

  group('copyWith', () {
    const original = SmartContextMenuRowStyle(
      padding: EdgeInsets.all(1),
      childrenGap: 1,
      smallItemPadding: EdgeInsets.all(1),
      mediumItemPadding: EdgeInsets.all(1),
      itemChildrenGap: 1,
      titleStyle: TextStyle(fontSize: 11),
      dividerIndent: 1,
      dividerEndIndent: 1,
    );

    final fields = <String, Object? Function(SmartContextMenuRowStyle)>{
      'padding': (s) => s.padding,
      'childrenGap': (s) => s.childrenGap,
      'smallItemPadding': (s) => s.smallItemPadding,
      'mediumItemPadding': (s) => s.mediumItemPadding,
      'itemChildrenGap': (s) => s.itemChildrenGap,
      'titleStyle': (s) => s.titleStyle,
      'dividerIndent': (s) => s.dividerIndent,
      'dividerEndIndent': (s) => s.dividerEndIndent,
    };

    const padding = EdgeInsets.all(9);
    const titleStyle = TextStyle(fontSize: 19);
    final changes = <String, (Object, SmartContextMenuRowStyle Function())>{
      'padding': (padding, () => original.copyWith(padding: padding)),
      'childrenGap': (9.0, () => original.copyWith(childrenGap: 9)),
      'smallItemPadding': (
        padding,
        () => original.copyWith(smallItemPadding: padding),
      ),
      'mediumItemPadding': (
        padding,
        () => original.copyWith(mediumItemPadding: padding),
      ),
      'itemChildrenGap': (9.0, () => original.copyWith(itemChildrenGap: 9)),
      'titleStyle': (
        titleStyle,
        () => original.copyWith(titleStyle: titleStyle),
      ),
      'dividerIndent': (9.0, () => original.copyWith(dividerIndent: 9)),
      'dividerEndIndent': (9.0, () => original.copyWith(dividerEndIndent: 9)),
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
