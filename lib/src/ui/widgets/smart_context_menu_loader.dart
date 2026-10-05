import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

import '../../core/ui/styles/smart_context_menu_defaults.dart';

/// The loader row of a submenu that loads its items.
final class SmartContextMenuLoader extends StatelessWidget {
  const SmartContextMenuLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: SmartContextMenuDefaults.loaderVerticalPadding,
      ),
      alignment: Alignment.center,
      child: const CupertinoActivityIndicator(radius: 12),
    );
  }
}
