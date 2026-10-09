import 'package:flutter/cupertino.dart';

import '../../domain/demo_file.dart';
import '../../domain/file_favorites.dart';
import 'favorite_mark.dart';
import 'file_icon.dart';

/// A file in the grid.
final class FileTile extends StatelessWidget {
  final DemoFile file;
  final FileFavorites favorites;

  const FileTile({super.key, required this.file, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FileIcon(kind: file.kind, size: 48),
                const SizedBox(height: 8),
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: FavoriteMark(file: file, favorites: favorites),
          ),
        ],
      ),
    );
  }
}
