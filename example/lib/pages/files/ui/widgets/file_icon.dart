import 'package:flutter/cupertino.dart';

import '../../domain/demo_file.dart';

/// The icon of [kind] on a rounded square of its color.
final class FileIcon extends StatelessWidget {
  final DemoFileKind kind;
  final double size;

  const FileIcon({super.key, required this.kind, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(kind.color, context),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(kind.icon, size: size * 0.55, color: CupertinoColors.white),
    );
  }
}
