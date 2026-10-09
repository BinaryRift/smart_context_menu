import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import 'menu_tester.dart';

const String headerText = 'Header';

final headerItems = [SmartContextMenuItem.simple(title: 'Copy')];
final previewFinder = find.byType(RawImage).last;
final headerFinder = find.byKey(const ValueKey(headerText));

final screenPadding = const SmartContextMenuConfig().screenPadding;

/// A menu for a 100-wide widget placed by [alignment], with a 60-wide header
/// lined up by [SmartContextMenuHeaderDetails.alignment].
///
/// Without [headerHeight], the menu has no header.
Widget headerMenu({
  Alignment alignment = Alignment.center,
  double targetHeight = 40,
  double? headerHeight = 20,
  ValueChanged<SmartContextMenuHeaderDetails>? onHeader,
  VoidCallback? onHeaderTap,
  SmartContextMenuConfig config = const SmartContextMenuConfig(),
  List<SmartContextMenuItem>? items,
  bool fadeHeaderSlivers = true,
  Duration headerSliversDelay = Duration.zero,
}) {
  return CupertinoApp(
    home: Padding(
      padding: const EdgeInsets.all(30),
      child: Align(
        alignment: alignment,
        child: SmartContextMenu(
          items: items ?? headerItems,
          config: config,
          fadeHeaderSlivers: fadeHeaderSlivers,
          headerSliversDelay: headerSliversDelay,
          headerSliversBuilder: headerHeight == null
              ? null
              : (context, header) {
                  onHeader?.call(header);
                  return [
                    SliverToBoxAdapter(
                      child: Align(
                        alignment: header.alignment,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onHeaderTap,
                          child: SizedBox(
                            key: const ValueKey(headerText),
                            width: 60,
                            height: headerHeight,
                            child: const Text(headerText),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
          child: SizedBox(
            width: 100,
            height: targetHeight,
            child: const Text(menuTargetText),
          ),
        ),
      ),
    ),
  );
}

/// A menu for a centered widget of [targetHeight] with the slivers from
/// [slivers] above it.
Widget sliversMenu({
  required List<Widget> Function() slivers,
  double targetHeight = 40,
  VoidCallback? onPreviewTap,
}) {
  return CupertinoApp(
    home: Center(
      child: SmartContextMenu(
        items: headerItems,
        onPreviewTap: onPreviewTap,
        headerSliversBuilder: (context, header) => slivers(),
        child: SizedBox(
          width: 100,
          height: targetHeight,
          child: const Text(menuTargetText),
        ),
      ),
    ),
  );
}

/// A sliver with a box of [height] found by [key].
Widget boxSliver(String key, double height) {
  return SliverToBoxAdapter(
    child: SizedBox(key: ValueKey(key), height: height),
  );
}

extension HeaderSliversTester on WidgetTester {
  /// Opens the menu and waits until it takes pointers.
  Future<void> openMenuForPointers() async {
    await openMenu();
    // The route ignores pointers until its transition ends.
    await pump(const Duration(milliseconds: 100));
  }

  /// The position of the scroll view of the open menu.
  ScrollPosition get menuScrollPosition {
    return state<ScrollableState>(find.byType(Scrollable).first).position;
  }
}
