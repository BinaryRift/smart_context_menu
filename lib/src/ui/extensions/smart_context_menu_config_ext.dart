import 'package:flutter/cupertino.dart' show CupertinoDynamicColor;
import 'package:flutter/widgets.dart';

import '../../core/ui/styles/smart_context_menu_defaults.dart';
import '../../domain/smart_context_menu_config.dart';

extension SmartContextMenuConfigColors on SmartContextMenuConfig {
  /// The menu background resolved for the theme of [context].
  Color resolveMenuColor(BuildContext context) => CupertinoDynamicColor.resolve(
    menuColor ?? SmartContextMenuDefaults.menuColor,
    context,
  );
}
