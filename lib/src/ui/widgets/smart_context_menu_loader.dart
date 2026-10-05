import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

/// The loader row of a submenu that loads its items.
final class SmartContextMenuLoader extends StatelessWidget {
  final double verticalPadding;

  const SmartContextMenuLoader({super.key, required this.verticalPadding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      alignment: Alignment.center,
      child: const CupertinoActivityIndicator(radius: 12),
    );
  }
}
