import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

void main() {
  group('copyWith', () {
    const original = SmartContextMenuStyle(
      menuColor: Color(0xFF000001),
      borderColor: Color(0xFF000002),
      borderRadius: BorderRadius.all(Radius.circular(1)),
      menuDecoration: BoxDecoration(color: Color(0xFF000003)),
      menuBlur: SmartContextMenuBlur(1),
      menuShadows: [BoxShadow(blurRadius: 1)],
      backgroundColor: Color(0xFF000004),
      backgroundBlur: SmartContextMenuBlur(2),
      backButtonBlur: SmartContextMenuBlur(3),
      backButtonBorderRadius: BorderRadius.all(Radius.circular(2)),
      backButtonColor: Color(0xFF00000A),
      backButtonTitleStyle: TextStyle(fontSize: 12),
      itemPadding: EdgeInsets.all(1),
      itemChildrenGap: 1,
      titleStyle: TextStyle(fontSize: 11),
      titleMaxLines: 1,
      disabledForegroundColor: Color(0xFF000005),
      destructiveColor: Color(0xFF000006),
      disabledBackgroundColor: Color(0xFF000007),
      highlightColor: Color(0xFF00000B),
      dividerColor: Color(0xFF000008),
      dividerThickness: 1,
      dividerIndent: 1,
      dividerEndIndent: 1,
      separatorHeight: 1,
      separatorColor: Color(0xFF00000C),
      defaultIconSize: 11,
      defaultIconColor: Color(0xFF000009),
      submenuIcon: Icons.arrow_forward_ios,
      backIcon: Icons.arrow_back_ios_new,
      loaderVerticalPadding: 11,
    );

    final fields = <String, Object? Function(SmartContextMenuStyle)>{
      'menuColor': (s) => s.menuColor,
      'borderColor': (s) => s.borderColor,
      'borderRadius': (s) => s.borderRadius,
      'menuDecoration': (s) => s.menuDecoration,
      'menuBlur': (s) => s.menuBlur,
      'menuShadows': (s) => s.menuShadows,
      'backgroundColor': (s) => s.backgroundColor,
      'backgroundBlur': (s) => s.backgroundBlur,
      'backButtonBlur': (s) => s.backButtonBlur,
      'backButtonBorderRadius': (s) => s.backButtonBorderRadius,
      'backButtonColor': (s) => s.backButtonColor,
      'backButtonTitleStyle': (s) => s.backButtonTitleStyle,
      'itemPadding': (s) => s.itemPadding,
      'itemChildrenGap': (s) => s.itemChildrenGap,
      'titleStyle': (s) => s.titleStyle,
      'titleMaxLines': (s) => s.titleMaxLines,
      'disabledForegroundColor': (s) => s.disabledForegroundColor,
      'destructiveColor': (s) => s.destructiveColor,
      'disabledBackgroundColor': (s) => s.disabledBackgroundColor,
      'highlightColor': (s) => s.highlightColor,
      'dividerColor': (s) => s.dividerColor,
      'dividerThickness': (s) => s.dividerThickness,
      'dividerIndent': (s) => s.dividerIndent,
      'dividerEndIndent': (s) => s.dividerEndIndent,
      'separatorHeight': (s) => s.separatorHeight,
      'separatorColor': (s) => s.separatorColor,
      'defaultIconSize': (s) => s.defaultIconSize,
      'defaultIconColor': (s) => s.defaultIconColor,
      'submenuIcon': (s) => s.submenuIcon,
      'backIcon': (s) => s.backIcon,
      'loaderVerticalPadding': (s) => s.loaderVerticalPadding,
    };

    const color = Color(0xFFFFFFFF);
    const radius = BorderRadius.all(Radius.circular(9));
    const blur = SmartContextMenuBlur(9);
    const decoration = BoxDecoration(color: color);
    const titleStyle = TextStyle(fontSize: 19);
    final changes = <String, (Object, SmartContextMenuStyle Function())>{
      'menuColor': (color, () => original.copyWith(menuColor: color)),
      'borderColor': (color, () => original.copyWith(borderColor: color)),
      'borderRadius': (radius, () => original.copyWith(borderRadius: radius)),
      'menuDecoration': (
        decoration,
        () => original.copyWith(menuDecoration: decoration),
      ),
      'menuBlur': (blur, () => original.copyWith(menuBlur: blur)),
      'menuShadows': (
        const <BoxShadow>[],
        () => original.copyWith(menuShadows: const []),
      ),
      'backgroundColor': (
        color,
        () => original.copyWith(backgroundColor: color),
      ),
      'backgroundBlur': (blur, () => original.copyWith(backgroundBlur: blur)),
      'backButtonBlur': (blur, () => original.copyWith(backButtonBlur: blur)),
      'backButtonBorderRadius': (
        radius,
        () => original.copyWith(backButtonBorderRadius: radius),
      ),
      'backButtonColor': (
        color,
        () => original.copyWith(backButtonColor: color),
      ),
      'itemPadding': (
        const EdgeInsets.all(9),
        () => original.copyWith(itemPadding: const EdgeInsets.all(9)),
      ),
      'itemChildrenGap': (9.0, () => original.copyWith(itemChildrenGap: 9)),
      'titleStyle': (titleStyle, () => original.copyWith(titleStyle: titleStyle)),
      'backButtonTitleStyle': (
        titleStyle,
        () => original.copyWith(backButtonTitleStyle: titleStyle),
      ),
      'titleMaxLines': (9, () => original.copyWith(titleMaxLines: 9)),
      'disabledForegroundColor': (
        color,
        () => original.copyWith(disabledForegroundColor: color),
      ),
      'destructiveColor': (
        color,
        () => original.copyWith(destructiveColor: color),
      ),
      'disabledBackgroundColor': (
        color,
        () => original.copyWith(disabledBackgroundColor: color),
      ),
      'highlightColor': (
        color,
        () => original.copyWith(highlightColor: color),
      ),
      'dividerColor': (color, () => original.copyWith(dividerColor: color)),
      'dividerThickness': (9.0, () => original.copyWith(dividerThickness: 9)),
      'dividerIndent': (9.0, () => original.copyWith(dividerIndent: 9)),
      'dividerEndIndent': (9.0, () => original.copyWith(dividerEndIndent: 9)),
      'separatorHeight': (9.0, () => original.copyWith(separatorHeight: 9)),
      'separatorColor': (
        color,
        () => original.copyWith(separatorColor: color),
      ),
      'defaultIconSize': (19.0, () => original.copyWith(defaultIconSize: 19)),
      'defaultIconColor': (
        color,
        () => original.copyWith(defaultIconColor: color),
      ),
      'submenuIcon': (
        CupertinoIcons.chevron_right,
        () => original.copyWith(submenuIcon: CupertinoIcons.chevron_right),
      ),
      'backIcon': (
        CupertinoIcons.chevron_left,
        () => original.copyWith(backIcon: CupertinoIcons.chevron_left),
      ),
      'loaderVerticalPadding': (
        19.0,
        () => original.copyWith(loaderVerticalPadding: 19),
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
