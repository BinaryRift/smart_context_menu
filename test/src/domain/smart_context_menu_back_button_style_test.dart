// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  test('has its defaults', () {
    const style = SmartContextMenuBackButtonStyle();

    expect(style.decoration, isNull);
    expect(style.backgroundColor, isNull);
    expect(style.blur, SmartContextMenuBlur.strong);
    expect(style.borderRadius, SmartContextMenuDefaults.backButtonBorderRadius);
    expect(style.foregroundColor, isNull);
    expect(style.titleStyle, SmartContextMenuDefaults.backButtonTitleStyle);
    expect(style.icon, SmartContextMenuDefaults.backIcon);
  });

  group('copyWith', () {
    const original = SmartContextMenuBackButtonStyle(
      decoration: BoxDecoration(color: Color(0xFF000001)),
      backgroundColor: Color(0x66000003),
      blur: SmartContextMenuBlur(1),
      borderRadius: BorderRadius.all(Radius.circular(1)),
      foregroundColor: Color(0xFF000002),
      titleStyle: TextStyle(fontSize: 11),
      icon: CupertinoIcons.back,
    );

    final fields = <String, Object? Function(SmartContextMenuBackButtonStyle)>{
      'decoration': (s) => s.decoration,
      'backgroundColor': (s) => s.backgroundColor,
      'blur': (s) => s.blur,
      'borderRadius': (s) => s.borderRadius,
      'foregroundColor': (s) => s.foregroundColor,
      'titleStyle': (s) => s.titleStyle,
      'icon': (s) => s.icon,
    };

    const decoration = BoxDecoration(color: Color(0xFF000009));
    const blur = SmartContextMenuBlur(9);
    const radius = BorderRadius.all(Radius.circular(9));
    const color = Color(0xFFFFFFFF);
    const titleStyle = TextStyle(fontSize: 19);
    final changes =
        <String, (Object, SmartContextMenuBackButtonStyle Function())>{
          'decoration': (
            decoration,
            () => original.copyWith(decoration: decoration),
          ),
          'backgroundColor': (
            color,
            () => original.copyWith(backgroundColor: color),
          ),
          'blur': (blur, () => original.copyWith(blur: blur)),
          'borderRadius': (
            radius,
            () => original.copyWith(borderRadius: radius),
          ),
          'foregroundColor': (
            color,
            () => original.copyWith(foregroundColor: color),
          ),
          'titleStyle': (
            titleStyle,
            () => original.copyWith(titleStyle: titleStyle),
          ),
          'icon': (
            CupertinoIcons.left_chevron,
            () => original.copyWith(icon: CupertinoIcons.left_chevron),
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

    test('preserves the background color when passed null', () {
      expect(
        original.copyWith(backgroundColor: null).backgroundColor,
        original.backgroundColor,
      );
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
