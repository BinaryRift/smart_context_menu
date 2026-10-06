import 'package:flutter_test/flutter_test.dart';

import 'package:smart_context_menu_example/main.dart';

void main() {
  testWidgets('shows the demo menus', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('All submenu types'), findsOneWidget);
    expect(find.text('Near the bottom edge'), findsOneWidget);
  });
}
