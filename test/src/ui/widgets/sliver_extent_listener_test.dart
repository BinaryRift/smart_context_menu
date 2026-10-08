import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/src/ui/widgets/sliver_extent_listener.dart';

Widget _scrollView({
  required double height,
  required ValueChanged<double> onExtentChanged,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: CustomScrollView(
      slivers: [
        SliverExtentListener(
          onExtentChanged: onExtentChanged,
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: height)),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            ],
          ),
        ),
      ],
    ),
  );
}

void main() {
  testWidgets('reports the extent after the first frame', (tester) async {
    final extents = <double>[];
    await tester.pumpWidget(
      _scrollView(height: 40, onExtentChanged: extents.add),
    );

    expect(extents, [50]);
  });

  testWidgets('reports a new extent when it changes', (tester) async {
    final extents = <double>[];
    await tester.pumpWidget(
      _scrollView(height: 40, onExtentChanged: extents.add),
    );
    await tester.pumpWidget(
      _scrollView(height: 70, onExtentChanged: extents.add),
    );

    expect(extents, [50, 80]);
  });

  testWidgets('does not report the same extent again', (tester) async {
    final extents = <double>[];
    await tester.pumpWidget(
      _scrollView(height: 40, onExtentChanged: extents.add),
    );
    await tester.pumpWidget(
      _scrollView(height: 40, onExtentChanged: extents.add),
    );
    await tester.pump();

    expect(extents, [50]);
  });
}
