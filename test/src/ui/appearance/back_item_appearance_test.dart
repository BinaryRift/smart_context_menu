import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/appearance_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('uses the text style in bold', (tester) async {
    await tester.pumpMenu(config: customConfig, items: submenuItems());
    await tester.openSubmenu();

    final back = tester.titleStyleOf(customConfig.labels.back);
    expect(back.fontFamily, 'Custom');
    expect(back.fontSize, 13);
    expect(back.fontWeight, FontWeight.w600);
    expect(back.color, isSameColorAs(customStyle.titleStyle.color!));
  });

  testWidgets('merges the back button text style', (tester) async {
    await tester.pumpMenu(
      config: customConfig.copyWith(
        style: customStyle.copyWith(
          backButtonTitleStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Color(0xFF0000FF),
          ),
        ),
      ),
      items: submenuItems(),
    );
    await tester.openSubmenu();

    final back = tester.titleStyleOf(customConfig.labels.back);
    expect(back.fontFamily, 'Custom');
    expect(back.fontSize, 20);
    expect(back.fontWeight, FontWeight.w300);
    expect(back.color, isSameColorAs(const Color(0xFF0000FF)));
  });

  testWidgets('back button color takes precedence over the text style', (
    tester,
  ) async {
    const backColor = Color(0xFF00FF00);
    await tester.pumpMenu(
      config: customConfig.copyWith(
        style: customStyle.copyWith(
          backButtonColor: backColor,
          backButtonTitleStyle: const TextStyle(color: Color(0xFF0000FF)),
        ),
      ),
      items: submenuItems(),
    );
    await tester.openSubmenu();

    expect(
      tester.titleStyleOf(customConfig.labels.back).color,
      isSameColorAs(backColor),
    );
  });

  testWidgets('applies the back item color', (tester) async {
    const backColor = Color(0xFF0000FF);
    await tester.pumpMenu(
      config: customConfig.copyWith(
        style: customStyle.copyWith(
          backButtonColor: backColor,
          defaultIconColor: const Color(0xFF000006),
        ),
      ),
      items: submenuItems(),
    );
    await tester.openSubmenu();

    final back = tester.titleStyleOf(customConfig.labels.back);
    expect(back.fontFamily, 'Custom');
    expect(back.fontWeight, FontWeight.w600);
    expect(back.color, isSameColorAs(backColor));

    final icon = tester.widget<Icon>(
      find.byIcon(SmartContextMenuDefaults.backIcon).first,
    );
    expect(icon.color, isSameColorAs(backColor));
  });
}
