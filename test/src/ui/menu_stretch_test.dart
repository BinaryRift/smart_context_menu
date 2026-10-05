import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

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
}
