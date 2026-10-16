import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu_example/core/data/demo_loader.dart';
import 'package:smart_context_menu_example/main.dart';
import 'package:smart_context_menu_example/pages/detail/ui/detail_page.dart';
import 'package:smart_context_menu_example/pages/files/ui/widgets/file_tile.dart';

import '../helpers/menu_tester.dart';

void main() {
  // The first one is in the grid, the second one is in the list.
  final contract = find.text('Contract.pdf').first;
  final preview = find.byType(RawImage);

  testWidgets('a long press on a file opens its menu', (tester) async {
    await tester.pumpPhoneApp();

    await tester.openMenu(contract);

    for (final title in ['Open', 'Share', 'Move to', 'Rename', 'Delete']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('Add to Favorites'), findsOneWidget);
  });

  testWidgets('Open opens the file', (tester) async {
    await tester.pumpPhoneApp();
    await tester.openMenu(contract);

    await tester.tap(find.text('Open'));
    await tester.settleMenu();
    await tester.pumpAndSettle();

    expect(find.byType(DetailPage), findsOneWidget);
    expect(find.text('Open'), findsNothing);
  });

  testWidgets('a tap on the preview opens the file', (tester) async {
    await tester.pumpPhoneApp();
    await tester.openMenu(contract);
    // The route ignores pointers until its transition ends.
    await tester.settleMenu();

    await tester.tap(preview);
    await tester.settleMenu();
    await tester.pumpAndSettle();

    expect(find.byType(DetailPage), findsOneWidget);
  });

  testWidgets('the button in a row opens the menu', (tester) async {
    await tester.pumpPhoneApp();

    await tester.tap(find.byIcon(CupertinoIcons.ellipsis_circle).first);
    await tester.settleMenu();

    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('Share opens a submenu that loads the contacts', (tester) async {
    await tester.pumpPhoneApp();
    await tester.openMenu(contract);

    await tester.tap(find.text('Share'));
    await tester.settleMenu();
    expect(find.text('Messages'), findsOneWidget);

    await tester.tap(find.text('Messages'));
    await tester.pump(demoLoadDelay);
    await tester.settleMenu();
    expect(find.text('Anna'), findsOneWidget);
  });

  testWidgets('Add to Favorites saves the file without closing the menu', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.openMenu(contract);

    await tester.tap(find.text('Add to Favorites'));
    await tester.pump();
    expect(find.text('Saving'), findsOneWidget);

    await tester.pump(demoLoadDelay);
    await tester.settleMenu();
    expect(find.text('Remove from Favorites'), findsOneWidget);
    expect(find.text('Added Contract.pdf to Favorites'), findsOneWidget);
  });

  testWidgets('demo-only actions show feedback without changing the file', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.openMenu(contract);

    await tester.tap(find.text('Delete'));
    await tester.settleMenu();

    expect(find.text('Delete Contract.pdf (demo only)'), findsOneWidget);
    expect(find.text('Contract.pdf'), findsWidgets);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Delete Contract.pdf (demo only)'), findsNothing);
  });

  testWidgets('Rename is disabled in a read-only file', (tester) async {
    await tester.pumpPhoneApp();
    await tester.openMenu(find.text('Invoice.pdf').first);

    await tester.tap(find.text('Rename'));
    await tester.settleMenu();

    expect(find.text('Rename'), findsOneWidget);
  });

  testWidgets('Download shows its progress without closing the menu', (
    tester,
  ) async {
    await tester.pumpPhoneApp();
    await tester.openMenu(contract);

    await tester.tap(find.text('Download'));
    await tester.pump();
    expect(find.text('Downloading 0%'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Downloading 10%'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.text('Remove Download'), findsOneWidget);
  });

  testWidgets('a tablet shows two rows of six recent files', (tester) async {
    tester.view.physicalSize = const Size(1668, 2388);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ExampleApp());

    expect(find.byType(FileTile), findsNWidgets(12));
  });
}
