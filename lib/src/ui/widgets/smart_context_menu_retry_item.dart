import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../view/smart_context_menu_item_view.dart';

/// The item that retries a failed submenu or page load.
///
/// Its content is the error content of [SmartContextMenuItemView].
final class SmartContextMenuRetryItem extends StatelessWidget {
  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;
  final VoidCallback onRetry;

  const SmartContextMenuRetryItem({
    super.key,
    required this.config,
    required this.hoverController,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SmartContextMenuItemView.error(
      key: ServiceItemKey.retry,
      onRetry: onRetry,
      config: config,
      hoverController: hoverController,
      item: SmartContextMenuItem.simple(),
    );
  }
}
