// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../../../helpers/appearance_tester.dart';
import '../../../../helpers/row_tester.dart';

void main() {
  group('medium', () {
    testWidgets('shows the leading above the title', (tester) async {
      await tester.pumpCells([
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(copyIcon),
        ),
      ]);

      final icon = tester.getRect(find.byIcon(copyIcon));
      final title = tester.getRect(find.text('Copy'));
      final cell = tester.cellFrameOf(find.text('Copy'));
      expect(
        icon.top - cell.top,
        SmartContextMenuDefaults.rowMediumItemPadding.top,
      );
      expect(
        title.top - icon.bottom,
        SmartContextMenuDefaults.rowItemChildrenGap,
      );
      expect(icon.center.dx, cell.center.dx);
      expect(title.center.dx, cell.center.dx);
      expect(
        tester.itemPaddingOf('Copy'),
        SmartContextMenuDefaults.rowMediumItemPadding,
      );
    });

    testWidgets('shows only the title without a leading', (tester) async {
      await tester.pumpCells([SmartContextMenuItem.simple(title: '2×')]);

      expect(find.text('2×'), findsOneWidget);
    });

    testWidgets('shows only the leading without a title', (tester) async {
      await tester.pumpCells([
        SmartContextMenuItem.simple(leading: const Icon(copyIcon)),
      ]);

      expect(find.byIcon(copyIcon), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('centers the title in up to titleMaxLines lines', (
      tester,
    ) async {
      await tester.pumpCells([
        SmartContextMenuItem.simple(title: 'Add to Favorites'),
      ]);

      final title = tester.widget<Text>(find.text('Add to Favorites'));
      expect(title.textAlign, TextAlign.center);
      expect(title.maxLines, SmartContextMenuDefaults.titleMaxLines);
      expect(title.overflow, TextOverflow.ellipsis);
    });

    testWidgets('keeps the content of a lower cell at the top', (tester) async {
      await tester.pumpCells([
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(copyIcon),
        ),
        SmartContextMenuItem.simple(
          title: 'Share with everyone',
          leading: const Icon(shareIcon),
        ),
      ]);

      final copy = tester.getRect(find.byIcon(copyIcon));
      final share = tester.getRect(find.byIcon(shareIcon));
      expect(copy.top, share.top);
      expect(
        tester.getTopLeft(find.text('Copy')).dy,
        tester.getTopLeft(find.text('Share with everyone')).dy,
      );
      expect(
        tester.cellFrameOf(find.text('Copy')).height,
        tester.cellFrameOf(find.text('Share with everyone')).height,
      );
    });
  });

  group('small', () {
    testWidgets('shows only the leading, labeled with the title', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpCells([
        SmartContextMenuItem.simple(
          title: 'Copy',
          leading: const Icon(copyIcon),
        ),
      ], size: SmartContextMenuRowSize.small);

      expect(find.byIcon(copyIcon), findsOneWidget);
      expect(find.text('Copy'), findsNothing);
      expect(find.bySemanticsLabel('Copy'), findsOneWidget);
      expect(
        tester
            .widget<AnimatedContainer>(
              find
                  .ancestor(
                    of: find.byIcon(copyIcon),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first,
            )
            .padding,
        SmartContextMenuDefaults.rowSmallItemPadding,
      );
      semantics.dispose();
    });

    testWidgets('shows the title without a leading', (tester) async {
      await tester.pumpCells([
        SmartContextMenuItem.simple(title: '0.5×'),
      ], size: SmartContextMenuRowSize.small);

      expect(find.text('0.5×'), findsOneWidget);
    });
  });

  testWidgets('does not show the trailing', (tester) async {
    for (final size in SmartContextMenuRowSize.values) {
      await tester.pumpCells([
        SmartContextMenuItem.simple(
          title: 'Alerts',
          leading: const Icon(copyIcon),
          trailing: const Text('On'),
        ),
      ], size: size);

      expect(find.text('On'), findsNothing, reason: '$size');
    }
  });
}
