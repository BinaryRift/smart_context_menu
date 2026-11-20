// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';
import 'package:smart_context_menu/src/ui/view/item/smart_context_menu_item_view.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_divider.dart';
import 'package:smart_context_menu/src/ui/widgets/smart_context_menu_row_layout.dart';

const transparent = Color(0x00000000);
const copyIcon = CupertinoIcons.doc_on_doc;
const shareIcon = CupertinoIcons.share;
const _cellWidth = 62.0;
const defaultStyle = SmartContextMenuStyle();

/// The rows drawn in the menu.
final rowLayouts = find.byType(SmartContextMenuRowLayout);

/// The vertical dividers between the cells of rows.
final rowDividers = find.byType(SmartContextMenuRowDivider);

/// A cell with an icon and [title] that adds its title to [taps] on tap and
/// keeps the menu open unless [closeOnTap] is true.
SmartContextMenuSimpleItem rowCell(
  String title, {
  List<String>? taps,
  bool closeOnTap = false,
  bool isDisabled = false,
  bool isDestructive = false,
}) {
  return SmartContextMenuItem.simple(
    title: title,
    leading: const Icon(CupertinoIcons.circle),
    closeOnTap: closeOnTap,
    isDisabled: isDisabled,
    isDestructive: isDestructive,
    onTap: () => taps?.add(title),
  );
}

/// Whether [color] is the default color of separators.
bool isSeparatorColor(Color? color) =>
    color?.toARGB32() ==
    SmartContextMenuDefaults.separatorColor.color.toARGB32();

extension RowTester on WidgetTester {
  /// Shows [items] as cells of [size] in a row outside a menu, each
  /// 62 pixels wide. With [failed], the cells show a failed load.
  Future<void> pumpCells(
    List<SmartContextMenuItem> items, {
    SmartContextMenuRowSize size = SmartContextMenuRowSize.medium,
    SmartContextMenuConfig config = const SmartContextMenuConfig(),
    TextDirection textDirection = TextDirection.ltr,
    bool failed = false,
  }) {
    return pumpWidget(
      CupertinoApp(
        home: Directionality(
          textDirection: textDirection,
          // A column leaves the height free, as the scroll view of the menu.
          child: Column(
            children: [
              SizedBox(
                width: _cellWidth * items.length,
                child: SmartContextMenuRowLayout(
                  children: [
                    for (final item in items)
                      SmartContextMenuRowCell(
                        flex: 1,
                        child: failed
                            ? SmartContextMenuItemView.error(
                                key: ValueKey(item.id),
                                item: item,
                                config: config,
                                onRetry: () {},
                                rowSize: size,
                              )
                            : SmartContextMenuItemView(
                                key: ValueKey(item.id),
                                item: item,
                                config: config,
                                rowSize: size,
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The frame of the cell that contains [content]: its pressed area.
  Rect cellFrameOf(Finder content) => getRect(
    find.ancestor(of: content, matching: find.byType(AnimatedContainer)).first,
  );

  /// The frame of the cell that shows [title]: its pressed area.
  Rect cellRectOf(String title) => getRect(
    find
        .ancestor(
          of: find.text(title),
          matching: find.byType(AnimatedContainer),
        )
        .first,
  );
}
