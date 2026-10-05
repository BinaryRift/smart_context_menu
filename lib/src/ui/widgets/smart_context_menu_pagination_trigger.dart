import 'package:flutter/widgets.dart';

import 'smart_context_menu_loader.dart';

/// The loader row at the end of a paginated submenu.
///
/// Calls [onVisible] once it is built.
final class SmartContextMenuPaginationTrigger extends StatefulWidget {
  final VoidCallback onVisible;
  final double loaderVerticalPadding;

  const SmartContextMenuPaginationTrigger({
    super.key,
    required this.onVisible,
    required this.loaderVerticalPadding,
  });

  @override
  State<SmartContextMenuPaginationTrigger> createState() =>
      _SmartContextMenuPaginationTriggerState();
}

final class _SmartContextMenuPaginationTriggerState
    extends State<SmartContextMenuPaginationTrigger> {
  @override
  void initState() {
    super.initState();
    // Trigger loading. ListView builds children lazily, so initState runs
    // only when the user scrolls to the end of the list.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onVisible());
  }

  @override
  Widget build(BuildContext context) =>
      SmartContextMenuLoader(verticalPadding: widget.loaderVerticalPadding);
}
