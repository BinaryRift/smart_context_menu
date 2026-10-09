import 'package:flutter/widgets.dart';

import '../../domain/smart_context_menu_config.dart';
import '../../domain/smart_context_menu_item.dart';
import '../keys/service_item_key.dart';
import '../state/smart_context_menu_hover_controller.dart';
import '../view/smart_context_menu_item_view.dart';

/// The row that retries a failed submenu or page load.
///
/// Shows [item], or a default [SmartContextMenuItem.error], with the retry
/// title and icon unless the item has its own.
final class SmartContextMenuRetryRow extends StatelessWidget {
  final SmartContextMenuErrorItem? item;
  final SmartContextMenuConfig config;
  final SmartContextMenuHoverController hoverController;
  final VoidCallback onRetry;

  const SmartContextMenuRetryRow({
    super.key,
    required this.item,
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
      item: item ?? SmartContextMenuItem.error(),
    );
  }
}
