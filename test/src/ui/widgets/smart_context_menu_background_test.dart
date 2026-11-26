import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_background.dart';

import '../../../helpers/menu_tester.dart';

void main() {
  final menuBackground = find.byType(SmartContextMenuBackground);
  final screenBlur = find.descendant(
    of: menuBackground,
    matching: find.byType(BackdropFilter),
  );

  testWidgets('dims the screen without a blur by default', (tester) async {
    await tester.pumpMenu(items: [SmartContextMenuItem.simple(title: 'Item')]);
    await tester.openMenu();

    final dimming = find.descendant(
      of: menuBackground,
      matching: find.byType(FadeTransition),
    );
    expect(tester.widget<FadeTransition>(dimming).opacity.value, 1);
    expect(screenBlur, findsNothing);
  });

  testWidgets('blurs the screen when the style requests it', (tester) async {
    await tester.pumpMenu(
      items: [SmartContextMenuItem.simple(title: 'Item')],
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(
          backgroundBlur: SmartContextMenuBlur.medium,
        ),
      ),
    );
    await tester.openMenu();

    expect(screenBlur, findsOneWidget);
  });

  Widget background(Animation<double> animation) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SmartContextMenuBackground(
        animation: animation,
        color: const Color(0x42000000),
        blur: SmartContextMenuBlur.medium,
      ),
    );
  }

  testWidgets('keeps the blur out of the fade', (tester) async {
    await tester.pumpWidget(background(const AlwaysStoppedAnimation(0.5)));

    // On the web, a backdrop filter under an opacity layer is not drawn.
    expect(
      find.ancestor(
        of: find.byType(BackdropFilter),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(BackdropFilter),
        matching: find.byType(FadeTransition),
      ),
      findsOneWidget,
    );
  });

  testWidgets('grows the blur with the animation', (tester) async {
    final animation = AnimationController(vsync: tester);
    addTearDown(animation.dispose);
    await tester.pumpWidget(background(animation));
    String filter() => tester
        .widget<BackdropFilter>(find.byType(BackdropFilter))
        .filter
        .toString();

    final hidden = filter();
    animation.value = 1;
    await tester.pump();

    expect(filter(), isNot(hidden));
  });
}
