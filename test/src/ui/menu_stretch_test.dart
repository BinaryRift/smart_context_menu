import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_blur_box.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_shadow_box.dart';

import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('dragging over an item does not rebuild it', (tester) async {
    var builds = 0;

    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(
          closeOnTap: false,
          onTap: () {},
          customBuilder: (context, state) {
            builds++;
            return const Text('Item');
          },
        ),
      ],
    );
    await tester.openMenu();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Item')),
    );
    await tester.pump();
    final buildsAfterPress = builds;

    for (var i = 1; i <= 5; i++) {
      await gesture.moveBy(const Offset(4, 0));
      await tester.pump();
    }

    expect(builds, buildsAfterPress);

    await gesture.up();
    await tester.settleMenu();
  });

  testWidgets('the preview follows the stretched menu', (tester) async {
    await tester.pumpMenu(
      items: [
        SmartContextMenuItem.simple(
          title: 'Item',
          closeOnTap: false,
          onTap: () {},
        ),
      ],
    );
    await tester.openMenu();

    Offset previewOffset() {
      final transform = tester.widget<Transform>(
        find
            .descendant(
              of: find.byType(TweenAnimationBuilder<Offset>),
              matching: find.byType(Transform),
            )
            .first,
      );
      final translation = transform.transform.getTranslation();
      return Offset(translation.x, translation.y);
    }

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Item')),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0));
    await tester.pumpAndSettle();

    expect(previewOffset().dx, greaterThan(0));
    expect(previewOffset().dy, 0);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(previewOffset(), Offset.zero);
  });

  testWidgets('the blur and the shadow follow the stretched menu', (
    tester,
  ) async {
    await tester.pumpMenu(
      config: const SmartContextMenuConfig(
        style: SmartContextMenuStyle(menuBlur: SmartContextMenuBlur.small),
      ),
      items: [
        SmartContextMenuItem.simple(
          title: 'Item',
          closeOnTap: false,
          onTap: () {},
        ),
      ],
    );
    await tester.openMenu();

    final blur = find.byType(SmartContextMenuBlurBox);
    final shadow = find.byType(SmartContextMenuShadowBox);
    final blurCenter = tester.getCenter(blur);
    final shadowCenter = tester.getCenter(shadow);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Item')),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(40, 0));
    await tester.pumpAndSettle();

    expect(tester.getCenter(blur).dx, greaterThan(blurCenter.dx));
    expect(tester.getCenter(shadow).dx, greaterThan(shadowCenter.dx));

    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.getCenter(blur), blurCenter);
    expect(tester.getCenter(shadow), shadowCenter);
  });
}
