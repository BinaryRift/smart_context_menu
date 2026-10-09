import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/header_slivers_tester.dart';
import '../../../helpers/menu_tester.dart';

void main() {
  testWidgets('a pinned sliver stays at the top over the preview', (
    tester,
  ) async {
    var barTaps = 0;
    var previewTaps = 0;
    await tester.pumpWidget(
      sliversMenu(
        // With the 30-tall bar and the 10 gap, the 540-tall widget and the
        // menu scroll by 72.
        targetHeight: 540,
        onPreviewTap: () => previewTaps++,
        slivers: () => [
          PinnedHeaderSliver(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => barTaps++,
              child: const SizedBox(key: ValueKey('bar'), height: 30),
            ),
          ),
          boxSliver('gap', 10),
        ],
      ),
    );
    await tester.openMenuForPointers();
    // The content scrolls, so the bar appears once the preview is in place.
    await tester.settleMenu();

    final position = tester.menuScrollPosition;
    expect(position.pixels, position.maxScrollExtent);
    final bar = find.byKey(const ValueKey('bar'));
    expect(tester.getTopLeft(bar).dy, 0);
    expect(tester.getTopLeft(previewFinder).dy, lessThan(0));

    await tester.tap(bar);
    await tester.settleMenu();

    expect(barTaps, 1);
    expect(previewTaps, 0);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('a pinned sliver pins below the status bar', (tester) async {
    // 40 logical pixels at the device pixel ratio of 3.
    tester.view.padding = const FakeViewPadding(top: 120);
    addTearDown(tester.view.resetPadding);
    await tester.pumpWidget(
      sliversMenu(
        targetHeight: 500,
        slivers: () => [
          const PinnedHeaderSliver(
            child: SizedBox(key: ValueKey('bar'), height: 30),
          ),
          boxSliver('gap', 10),
        ],
      ),
    );
    await tester.openMenuForPointers();

    final position = tester.menuScrollPosition;
    expect(position.maxScrollExtent, greaterThan(0));
    expect(position.pixels, position.maxScrollExtent);
    final bar = find.byKey(const ValueKey('bar'));
    expect(tester.getTopLeft(bar).dy, 40);

    position.jumpTo(0);
    await tester.pump();
    expect(tester.getTopLeft(bar).dy, 40 + screenPadding.top);
  });
}
