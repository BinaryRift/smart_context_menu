import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../helpers/menu_tester.dart';

void main() {
  const photoTag = 'photo';
  const pageText = 'Photo page';

  /// A centered 100-square widget with its own [Hero]; a tap on the preview
  /// opens a page with a 300-square [Hero] of the same tag at the top left.
  Widget heroMenu() {
    return CupertinoApp(
      home: Builder(
        builder: (context) => Center(
          child: SmartContextMenu(
            items: [SmartContextMenuItem.simple(title: 'Copy')],
            onPreviewTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (context) => const Align(
                  alignment: Alignment.topLeft,
                  child: Hero(
                    tag: photoTag,
                    child: SizedBox.square(
                      dimension: 300,
                      child: Text(pageText),
                    ),
                  ),
                ),
              ),
            ),
            child: const Hero(
              tag: photoTag,
              child: SizedBox.square(
                dimension: 100,
                child: Text(menuTargetText),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('opens for a child with its own hero', (tester) async {
    await tester.pumpWidget(heroMenu());

    await tester.openMenu();

    expect(tester.takeException(), isNull);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('the hero of the child flies from its place when the preview '
      'opens a page', (tester) async {
    await tester.pumpWidget(heroMenu());
    final childRect = tester.getRect(find.text(menuTargetText));
    await tester.openMenu();
    // The route ignores pointers until its transition ends.
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byType(RawImage).last);
    final rects = <Rect>[];
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 10));
      final page = find.text(pageText, skipOffstage: false);
      if (page.evaluate().isNotEmpty) rects.add(tester.getRect(page));
    }
    await tester.pumpAndSettle();

    // The page appears as the flying hero: from the place and the size of
    // the child, growing to its own.
    final firstFlying = rects.firstWhere((rect) => rect.width < 300);
    expect(firstFlying.center.dx, closeTo(childRect.center.dx, 10));
    expect(firstFlying.width, closeTo(childRect.width, 10));
    expect(
      tester.getRect(find.text(pageText)),
      const Rect.fromLTWH(0, 0, 300, 300),
    );
  });
}
