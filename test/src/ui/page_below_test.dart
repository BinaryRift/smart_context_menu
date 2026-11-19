// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  testWidgets('the page below a plain PageRoute stays in place', (
    tester,
  ) async {
    late Animation<double> secondaryAnimation;
    await tester.pumpWidget(
      CupertinoApp(
        onGenerateRoute: (_) => PageRouteBuilder<void>(
          pageBuilder: (context, _, secondary) {
            secondaryAnimation = secondary;
            return Center(
              child: SmartContextMenu(
                items: [SmartContextMenuItem.simple(title: 'Copy')],
                child: const Text(menuTargetText),
              ),
            );
          },
        ),
      ),
    );
    await tester.openMenu();

    expect(find.text('Copy'), findsOneWidget);
    expect(secondaryAnimation.value, 0);
  });
}
