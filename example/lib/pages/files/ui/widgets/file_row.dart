import 'package:flutter/cupertino.dart';

import '../../domain/demo_file.dart';
import '../../domain/file_favorites.dart';
import 'favorite_mark.dart';
import 'file_icon.dart';

/// A file in the list, with a button that calls [onMore].
final class FileRow extends StatelessWidget {
  final DemoFile file;
  final FileFavorites favorites;
  final VoidCallback onMore;

  const FileRow({
    super.key,
    required this.file,
    required this.favorites,
    required this.onMore,
  });

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
            onPressed: onMore,
            child: const Icon(CupertinoIcons.ellipsis_circle),
          ),
        ],
      ),
    );
  }
}
