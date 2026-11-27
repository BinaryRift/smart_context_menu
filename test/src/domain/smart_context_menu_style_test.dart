// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

/// The fields of a back item style, comparable by value.
Object backFields(SmartContextMenuBackButtonStyle s) => (
  s.decoration,
  s.backgroundColor,
  s.blur,
  s.borderRadius,
  s.foregroundColor,
  s.titleStyle,
  s.icon,
);

/// The fields of a status style, comparable by value.
Object statusFields(SmartContextMenuStatusStyle s) => (
  s.titleAlign,
  s.errorIcon,
  s.retryIcon,
  s.emptyIcon,
  s.loadingIndicator,
  s.loaderVerticalPadding,
);

void main() {
  test('defaults to Glass and keeps both styles when changing the surface', () {
    const defaultStyle = SmartContextMenuStyle();
    const customGlass = SmartContextMenuGlassStyle(refraction: 2);
    const customStandard = SmartContextMenuStandardStyle(
      blur: SmartContextMenuBlur.small,
      showEdgeHighlight: false,
    );

    expect(defaultStyle.surface, SmartContextMenuSurface.glass);
    expect(defaultStyle.glassStyle.blur.sigmaX, 2);
    expect(defaultStyle.glassStyle.blur.sigmaY, 2);
    expect(defaultStyle.standardStyle.blur, isNull);
    expect(defaultStyle.standardStyle.border.width, 1);
    expect(defaultStyle.standardStyle.showEdgeHighlight, isTrue);
    final style = defaultStyle.copyWith(
      glassStyle: customGlass,
      standardStyle: customStandard,
    );
    final standard = style.copyWith(surface: SmartContextMenuSurface.standard);
    expect(standard.surface, SmartContextMenuSurface.standard);
    expect(standard.glassStyle, same(customGlass));
    expect(standard.standardStyle, same(customStandard));
    final glass = standard.copyWith(surface: SmartContextMenuSurface.glass);
    expect(glass.surface, SmartContextMenuSurface.glass);
    expect(glass.glassStyle, same(customGlass));
    expect(glass.standardStyle, same(customStandard));
  });

  test('glass styles compare by value', () {
    const tint = Color(0x90778899);
    const style = SmartContextMenuGlassStyle(color: tint, refraction: 2);
    final copy = const SmartContextMenuGlassStyle().copyWith(
      color: tint,
      refraction: 2,
    );

    expect(copy, style);
    expect(copy.hashCode, style.hashCode);
    expect(copy.copyWith(color: const Color(0x00FFFFFF)), isNot(style));
    expect(copy.copyWith(refraction: 0), isNot(style));
    final withoutBlur = copy.copyWith(blur: SmartContextMenuBlur.none);
    expect(withoutBlur.blur.sigmaX, 0);
    expect(withoutBlur, isNot(style));
    expect(
      withoutBlur.copyWith(blur: SmartContextMenuBlur(style.blur.sigmaX)),
      style,
    );
    final withoutHighlight = copy.copyWith(edgeHighlight: 0);
    expect(withoutHighlight.color, tint);
    expect(withoutHighlight.refraction, 2);
    expect(withoutHighlight, isNot(style));

    expect(copy.border, BorderSide.none);
    const border = BorderSide(color: Color(0x6633FF99), width: 2);
    final withBorder = copy.copyWith(border: border);
    expect(withBorder.border, border);
    expect(withBorder, isNot(style));
    expect(withBorder.copyWith(border: BorderSide.none), copy);
  });

  test('legacy Standard setters update a configured Standard style', () {
    const base = SmartContextMenuStyle(
      standardStyle: SmartContextMenuStandardStyle(
        border: BorderSide(width: 3, strokeAlign: BorderSide.strokeAlignCenter),
        showEdgeHighlight: false,
      ),
    );
    const color = Color(0xFF123456);
    final copy = base.copyWith(borderColor: color);
    expect(copy.borderColor, color);
    expect(copy.standardStyle.border.color, color);
    expect(copy.standardStyle.border.width, 3);
    expect(copy.standardStyle.border.strokeAlign, BorderSide.strokeAlignCenter);
    expect(copy.standardStyle.showEdgeHighlight, isFalse);
  });

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
      backButtonStyle: SmartContextMenuBackButtonStyle(blur: null),
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
      dividersBetweenItems: true,
      separatorThickness: 1,
      separatorColor: Color(0xFF00000C),
      rowStyle: SmartContextMenuRowStyle(childrenGap: 1),
      statusStyle: SmartContextMenuStatusStyle(titleAlign: TextAlign.end),
      defaultIconSize: 11,
      defaultIconColor: Color(0xFF000009),
      submenuIcon: Icons.arrow_forward_ios,
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
      'backButtonStyle': (s) => backFields(s.backButtonStyle),
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
      'dividersBetweenItems': (s) => s.dividersBetweenItems,
      'separatorThickness': (s) => s.separatorThickness,
      'separatorColor': (s) => s.separatorColor,
      'rowStyle': (s) => s.rowStyle,
      'statusStyle': (s) => statusFields(s.statusStyle),
      'defaultIconSize': (s) => s.defaultIconSize,
      'defaultIconColor': (s) => s.defaultIconColor,
      'submenuIcon': (s) => s.submenuIcon,
    };

    const color = Color(0xFFFFFFFF);
    const radius = BorderRadius.all(Radius.circular(9));
    const blur = SmartContextMenuBlur(9);
    const decoration = BoxDecoration(color: color);
    const titleStyle = TextStyle(fontSize: 19);
    const backButtonStyle = SmartContextMenuBackButtonStyle(
      backgroundColor: Color(0x660A84FF),
      blur: blur,
    );
    const rowStyle = SmartContextMenuRowStyle(childrenGap: 9);
    const statusStyle = SmartContextMenuStatusStyle(loaderVerticalPadding: 9);
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
      'backButtonStyle': (
        backFields(backButtonStyle),
        () => original.copyWith(backButtonStyle: backButtonStyle),
      ),
      'itemPadding': (
        const EdgeInsets.all(9),
        () => original.copyWith(itemPadding: const EdgeInsets.all(9)),
      ),
      'itemChildrenGap': (9.0, () => original.copyWith(itemChildrenGap: 9)),
      'titleStyle': (
        titleStyle,
        () => original.copyWith(titleStyle: titleStyle),
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
      'highlightColor': (color, () => original.copyWith(highlightColor: color)),
      'dividerColor': (color, () => original.copyWith(dividerColor: color)),
      'dividerThickness': (9.0, () => original.copyWith(dividerThickness: 9)),
      'dividerIndent': (9.0, () => original.copyWith(dividerIndent: 9)),
      'dividerEndIndent': (9.0, () => original.copyWith(dividerEndIndent: 9)),
      'dividersBetweenItems': (
        false,
        () => original.copyWith(dividersBetweenItems: false),
      ),
      'separatorThickness': (
        9.0,
        () => original.copyWith(separatorThickness: 9),
      ),
      'separatorColor': (color, () => original.copyWith(separatorColor: color)),
      'rowStyle': (rowStyle, () => original.copyWith(rowStyle: rowStyle)),
      'statusStyle': (
        statusFields(statusStyle),
        () => original.copyWith(statusStyle: statusStyle),
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

  group('deprecated back item and status fields', () {
    const indicator = SizedBox(width: 1);

    test('without them the groups have their defaults', () {
      const style = SmartContextMenuStyle();
      expect(
        backFields(style.backButtonStyle),
        backFields(const SmartContextMenuBackButtonStyle()),
      );
      expect(
        statusFields(style.statusStyle),
        statusFields(const SmartContextMenuStatusStyle()),
      );
    });

    test('set the fields of the groups and are read from them', () {
      const style = SmartContextMenuStyle(
        backButtonBlur: SmartContextMenuBlur(3),
        backButtonBorderRadius: BorderRadius.all(Radius.circular(2)),
        backButtonColor: Color(0xFF000001),
        backButtonTitleStyle: TextStyle(fontSize: 12),
        backIcon: Icons.arrow_back_ios_new,
        statusTitleAlign: TextAlign.end,
        errorIcon: Icons.error,
        retryIcon: Icons.refresh,
        emptyIcon: Icons.inbox,
        loadingIndicator: indicator,
        loaderVerticalPadding: 11,
      );
      const back = SmartContextMenuBackButtonStyle(
        blur: SmartContextMenuBlur(3),
        borderRadius: BorderRadius.all(Radius.circular(2)),
        foregroundColor: Color(0xFF000001),
        titleStyle: TextStyle(fontSize: 12),
        icon: Icons.arrow_back_ios_new,
      );
      const status = SmartContextMenuStatusStyle(
        titleAlign: TextAlign.end,
        errorIcon: Icons.error,
        retryIcon: Icons.refresh,
        emptyIcon: Icons.inbox,
        loadingIndicator: indicator,
        loaderVerticalPadding: 11,
      );
      expect(backFields(style.backButtonStyle), backFields(back));
      expect(statusFields(style.statusStyle), statusFields(status));

      expect(style.backButtonBlur, back.blur);
      expect(style.backButtonBorderRadius, back.borderRadius);
      expect(style.backButtonColor, back.foregroundColor);
      expect(style.backButtonTitleStyle, back.titleStyle);
      expect(style.backIcon, back.icon);
      expect(style.statusTitleAlign, status.titleAlign);
      expect(style.errorIcon, status.errorIcon);
      expect(style.retryIcon, status.retryIcon);
      expect(style.emptyIcon, status.emptyIcon);
      expect(style.loadingIndicator, status.loadingIndicator);
      expect(style.loaderVerticalPadding, status.loaderVerticalPadding);
    });

    test('backButtonBlur set to null turns the blur off', () {
      const style = SmartContextMenuStyle(backButtonBlur: null);
      expect(style.backButtonStyle.blur, isNull);
    });

    test('copyWith with them changes only those fields of the groups', () {
      const original = SmartContextMenuStyle(
        backButtonStyle: SmartContextMenuBackButtonStyle(
          foregroundColor: Color(0xFF000001),
        ),
        statusStyle: SmartContextMenuStatusStyle(errorIcon: Icons.error),
      );
      final copy = original.copyWith(
        backIcon: Icons.arrow_back_ios_new,
        emptyIcon: Icons.inbox,
      );
      expect(
        backFields(copy.backButtonStyle),
        backFields(
          const SmartContextMenuBackButtonStyle(
            foregroundColor: Color(0xFF000001),
            icon: Icons.arrow_back_ios_new,
          ),
        ),
      );
      expect(
        statusFields(copy.statusStyle),
        statusFields(
          const SmartContextMenuStatusStyle(
            errorIcon: Icons.error,
            emptyIcon: Icons.inbox,
          ),
        ),
      );
    });

    test('copyWith keeps the groups built from them', () {
      const original = SmartContextMenuStyle(
        backButtonColor: Color(0xFF000001),
        statusTitleAlign: TextAlign.start,
      );
      final copy = original.copyWith(menuColor: const Color(0xFF000002));
      expect(copy.backButtonStyle.foregroundColor, const Color(0xFF000001));
      expect(copy.statusStyle.titleAlign, TextAlign.start);
    });

    test('cannot be set together with the group', () {
      expect(
        () => SmartContextMenuStyle(
          backButtonStyle: const SmartContextMenuBackButtonStyle(),
          backButtonColor: const Color(0xFF000001),
        ),
        throwsAssertionError,
      );
      expect(
        () => SmartContextMenuStyle(
          statusStyle: const SmartContextMenuStatusStyle(),
          loadingIndicator: indicator,
        ),
        throwsAssertionError,
      );
      expect(
        () => const SmartContextMenuStyle().copyWith(
          backButtonStyle: const SmartContextMenuBackButtonStyle(),
          backButtonBlur: SmartContextMenuBlur.none,
        ),
        throwsAssertionError,
      );
      expect(
        () => const SmartContextMenuStyle().copyWith(
          statusStyle: const SmartContextMenuStatusStyle(),
          errorIcon: Icons.error,
        ),
        throwsAssertionError,
      );
    });
  });

  test('separatorHeight remains a compatible alias', () {
    const style = SmartContextMenuStyle(separatorHeight: 3);
    expect(style.separatorThickness, 3);
    expect(style.separatorHeight, 3);

    final copy = style.copyWith(separatorHeight: 4);
    expect(copy.separatorThickness, 4);

    expect(
      SmartContextMenuDefaults.separatorHeight,
      SmartContextMenuDefaults.separatorThickness,
    );
  });

  test('separatorThickness takes precedence over the old name', () {
    const style = SmartContextMenuStyle(
      separatorThickness: 2,
      separatorHeight: 1,
    );
    expect(style.separatorThickness, 2);

    final copy = style.copyWith(separatorThickness: 4, separatorHeight: 3);
    expect(copy.separatorThickness, 4);
  });
}
