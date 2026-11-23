// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

import '../../domain/demo_file.dart';
import '../../domain/file_favorites.dart';
import 'favorite_mark.dart';
import 'file_icon.dart';

/// A file in the list, with a button that opens the menu around the row.
final class FileRow extends StatelessWidget {
  final DemoFile file;
  final FileFavorites favorites;

  const FileRow({super.key, required this.file, required this.favorites});

  @override
  Widget build(BuildContext context) {
    final secondaryLabel = CupertinoDynamicColor.resolve(
      CupertinoColors.secondaryLabel,
      context,
    );

    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FileIcon(kind: file.kind, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  [
                    file.size,
                    file.folder,
                    if (file.isReadOnly) 'Read-only',
                  ].join(' · '),
                  style: TextStyle(fontSize: 13, color: secondaryLabel),
                ),
              ],
            ),
          ),
          FavoriteMark(file: file, favorites: favorites),
          CupertinoButton(
            // The row is the child of a SmartContextMenu, so the button
            // finds its menu without a controller.
            onPressed: () => SmartContextMenu.of(context).open(),
            child: const Icon(CupertinoIcons.ellipsis_circle),
          ),
        ],
      ),
    );
  }
}
