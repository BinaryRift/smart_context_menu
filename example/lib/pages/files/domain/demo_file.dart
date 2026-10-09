import 'package:flutter/cupertino.dart';

enum DemoFileKind {
  pdf(CupertinoIcons.doc_richtext, CupertinoColors.systemRed),
  text(CupertinoIcons.doc_text, CupertinoColors.systemBlue),
  sheet(CupertinoIcons.table, CupertinoColors.systemGreen),
  image(CupertinoIcons.photo, CupertinoColors.systemOrange),
  archive(CupertinoIcons.archivebox, CupertinoColors.systemGrey);

  final IconData icon;
  final CupertinoDynamicColor color;

  const DemoFileKind(this.icon, this.color);
}

final class DemoFile {
  final String name;
  final DemoFileKind kind;
  final String size;
  final String folder;

  /// Whether the file cannot be renamed.
  final bool isReadOnly;

  const DemoFile(
    this.name,
    this.kind, {
    required this.size,
    required this.folder,
    this.isReadOnly = false,
  });
}
