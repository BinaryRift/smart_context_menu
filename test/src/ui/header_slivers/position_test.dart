import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/header_slivers_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('keeps the preview in place when the slivers fit above it', (
    tester,
  ) async {
    await tester.pumpWidget(headerMenu());
    final targetTop = tester.getTopLeft(find.text(menuTargetText)).dy;
    await tester.openMenu();

    expect(tester.getTopLeft(previewFinder).dy, moreOrLessEquals(targetTop));
    expect(tester.getBottomLeft(headerFinder).dy, moreOrLessEquals(targetTop));
  });

  testWidgets('moves the preview down when the slivers do not fit above it', (
    tester,
  ) async {
    await tester.pumpWidget(
      headerMenu(alignment: Alignment.topCenter, headerHeight: 60),
    );
    final targetTop = tester.getTopLeft(find.text(menuTargetText)).dy;
    await tester.openMenu();

    expect(
      tester.getTopLeft(headerFinder).dy,
      moreOrLessEquals(screenPadding.top),
    );
    expect(
      tester.getTopLeft(previewFinder).dy,
      moreOrLessEquals(screenPadding.top + 60),
    );
    expect(tester.getTopLeft(previewFinder).dy, greaterThan(targetTop));
  });

  // The 420-tall widget and the menu fit on the 600-tall screen alone,
  // but not with a 150-tall header.
  testWidgets('does not scroll a widget that fits without slivers', (
    tester,
  ) async {
    await tester.pumpWidget(headerMenu(targetHeight: 420, headerHeight: null));
    await tester.openMenu();

    expect(tester.menuScrollPosition.maxScrollExtent, 0);
  });

  testWidgets('scrolls the slivers out at the top when they do not fit', (
    tester,
  ) async {
    await tester.pumpWidget(headerMenu(targetHeight: 420, headerHeight: 150));
    await tester.openMenu();

    // The menu is at the bottom edge, the preview right above it.
    final position = tester.menuScrollPosition;
    expect(position.maxScrollExtent, greaterThan(0));
    expect(position.pixels, position.maxScrollExtent);
    expect(tester.getTopLeft(headerFinder).dy, lessThan(screenPadding.top));

    // The route ignores pointers until its transition ends.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(headerFinder, const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(tester.menuScrollPosition.pixels, 0);
    expect(
      tester.getTopLeft(headerFinder).dy,
      moreOrLessEquals(screenPadding.top),
    );
  });

  testWidgets('keeps the menu at the bottom edge for a tall widget', (
    tester,
  ) async {
    // The 530-tall widget and the menu do not fit even without the header.
    await tester.pumpWidget(headerMenu(targetHeight: 530, headerHeight: 60));
    await tester.openMenu();

    final position = tester.menuScrollPosition;
    expect(position.pixels, position.maxScrollExtent);
    expect(tester.getBottomLeft(find.text('Copy')).dy, lessThan(600));
    // Scrolled out of the viewport, so the default finder skips it.
    final header = find.byKey(const ValueKey(headerText), skipOffstage: false);
    expect(tester.getBottomLeft(header).dy, lessThan(0));

    // Both the preview and the menu block drags, so scroll from code.
    position.jumpTo(0);
    await tester.pump();
    expect(
      tester.getTopLeft(headerFinder).dy,
      moreOrLessEquals(screenPadding.top),
    );
  });

  testWidgets('keeps the preview in place below all of them', (tester) async {
    await tester.pumpWidget(
      sliversMenu(slivers: () => [boxSliver('a', 20), boxSliver('b', 30)]),
    );
    final targetTop = tester.getTopLeft(find.text(menuTargetText)).dy;
    await tester.openMenu();

    expect(tester.getTopLeft(previewFinder).dy, moreOrLessEquals(targetTop));
    expect(
      tester.getBottomLeft(find.byKey(const ValueKey('b'))).dy,
      moreOrLessEquals(targetTop),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('a'))).dy,
      moreOrLessEquals(targetTop - 50),
    );
  });

  testWidgets('recounts the height when the builder returns fewer', (
    tester,
  ) async {
    var count = 2;
    await tester.pumpWidget(
      sliversMenu(
        slivers: () => [boxSliver('a', 20), if (count > 1) boxSliver('b', 30)],
      ),
    );
    final targetTop = tester.getTopLeft(find.text(menuTargetText)).dy;
    await tester.openMenu();

    count = 1;
    // A new screen size rebuilds the open menu.
    tester.view.physicalSize = tester.view.physicalSize + const Offset(0, 1);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.settleMenu();

    expect(find.byKey(const ValueKey('b')), findsNothing);
    expect(
      tester.getBottomLeft(find.byKey(const ValueKey('a'))).dy,
      moreOrLessEquals(tester.getTopLeft(previewFinder).dy),
    );
    expect(tester.getTopLeft(previewFinder).dy, moreOrLessEquals(targetTop));
  });
}
