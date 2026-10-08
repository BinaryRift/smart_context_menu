import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/header_slivers_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('runs to 1 as the menu opens and back to 0 as it closes', (
    tester,
  ) async {
    late SmartContextMenuHeaderDetails header;
    await tester.pumpWidget(headerMenu(onHeader: (value) => header = value));
    await tester.openMenu();
    final animation = header.animation;
    expect(animation.value, 1);

    header.close();
    await tester.pump();
    expect(animation.status, AnimationStatus.reverse);

    await tester.settleMenu();
    expect(animation.value, 0);
  });

  testWidgets('the slivers fade with the menu by default', (tester) async {
    await tester.pumpWidget(headerMenu());
    await tester.openMenu();

    expect(
      find.ancestor(
        of: headerFinder,
        matching: find.byType(SliverFadeTransition),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the slivers do not fade with fadeHeaderSlivers off', (
    tester,
  ) async {
    await tester.pumpWidget(headerMenu(fadeHeaderSlivers: false));
    await tester.openMenu();

    expect(
      find.ancestor(
        of: headerFinder,
        matching: find.byType(SliverFadeTransition),
      ),
      findsNothing,
    );
  });
}
