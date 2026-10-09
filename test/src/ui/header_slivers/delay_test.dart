import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../helpers/header_slivers_tester.dart';
import '../../../helpers/menu_tester.dart';

/// The widget and the menu do not fit on the 600-tall screen,
/// so the content scrolls as the menu opens.
const double _tallTarget = 540;

void main() {
  late SmartContextMenuHeaderDetails header;
  void onHeader(SmartContextMenuHeaderDetails value) => header = value;

  Animation<double> routeAnimation(WidgetTester tester) =>
      ModalRoute.of(tester.element(find.text('Copy')))!.animation!;

  AnimationStatus routeStatus(WidgetTester tester) =>
      routeAnimation(tester).status;

  /// Long-presses the widget and returns how far the menu has opened and
  /// the value of the header animation in every frame while it opens.
  Future<List<(double, double)>> openAndTrace(WidgetTester tester) async {
    await tester.longPress(find.text(menuTargetText));
    final frames = <(double, double)>[];
    for (var i = 0; i < 12; i++) {
      await tester.settleMenu(frames: 1);
      if (find.text('Copy').evaluate().isEmpty) continue;
      frames.add((routeAnimation(tester).value, header.animation.value));
    }
    return frames;
  }

  testWidgets('without a delay, the slivers appear with the menu', (
    tester,
  ) async {
    await tester.pumpWidget(headerMenu(onHeader: onHeader));

    final frames = await openAndTrace(tester);

    final opening = frames.where((frame) => frame.$1 < 1);
    expect(opening.any((frame) => frame.$2 > 0), isTrue);
    expect(frames.last.$2, 1);
  });

  testWidgets('with a delay, the slivers wait for it from the opening', (
    tester,
  ) async {
    await tester.pumpWidget(
      headerMenu(
        onHeader: onHeader,
        headerSliversDelay: const Duration(seconds: 2),
      ),
    );
    await tester.openMenu();
    await tester.settleMenu();
    expect(routeStatus(tester), AnimationStatus.completed);
    expect(header.animation.value, 0);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));

    expect(header.animation.value, 1);
  });

  testWidgets('if the content scrolls, the slivers wait until the preview '
      'is nearly in place', (tester) async {
    await tester.pumpWidget(
      headerMenu(onHeader: onHeader, targetHeight: _tallTarget),
    );

    final frames = await openAndTrace(tester);

    // The slivers start when the menu has opened three quarters of the way.
    final early = frames.where((frame) => frame.$1 < 3 / 4);
    expect(early, isNotEmpty);
    expect(early.every((frame) => frame.$2 == 0), isTrue);
    expect(frames.last.$2, 1);
  });

  testWidgets('if the content scrolls, a longer delay still applies', (
    tester,
  ) async {
    await tester.pumpWidget(
      headerMenu(
        onHeader: onHeader,
        targetHeight: _tallTarget,
        headerSliversDelay: const Duration(seconds: 2),
      ),
    );
    await tester.openMenu();
    await tester.pump(const Duration(milliseconds: 500));
    expect(header.animation.value, 0);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));
    expect(header.animation.value, 1);
  });

  testWidgets('if the content is scrolled, the slivers hide at once', (
    tester,
  ) async {
    await tester.pumpWidget(
      headerMenu(onHeader: onHeader, targetHeight: _tallTarget),
    );
    await tester.openMenu();
    await tester.settleMenu();
    expect(tester.menuScrollPosition.pixels, greaterThan(0));
    expect(header.animation.value, 1);

    header.close();
    await tester.pump();

    expect(header.animation.value, 0);
    await tester.settleMenu();
  });

  testWidgets('if the content is not scrolled, the slivers hide with the '
      'menu', (tester) async {
    await tester.pumpWidget(headerMenu(onHeader: onHeader));
    await tester.openMenu();

    header.close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(header.animation.value, greaterThan(0));
    expect(header.animation.value, lessThan(1));
    await tester.settleMenu();
  });

  testWidgets('closed before the delay is over, the slivers never appear', (
    tester,
  ) async {
    await tester.pumpWidget(
      headerMenu(
        onHeader: onHeader,
        headerSliversDelay: const Duration(seconds: 2),
      ),
    );
    await tester.openMenu();
    final animation = header.animation;

    header.close();
    await tester.settleMenu();
    await tester.pump(const Duration(seconds: 2));

    expect(animation.value, 0);
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('a tap on the slivers before they appear closes the menu', (
    tester,
  ) async {
    var headerTaps = 0;
    await tester.pumpWidget(
      headerMenu(
        onHeaderTap: () => headerTaps++,
        headerSliversDelay: const Duration(seconds: 2),
      ),
    );
    await tester.openMenuForPointers();

    await tester.tapAt(tester.getCenter(headerFinder));
    await tester.settleMenu();

    expect(headerTaps, 0);
    expect(find.text('Copy'), findsNothing);
  });
}
