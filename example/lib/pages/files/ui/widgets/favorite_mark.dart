import 'package:flutter/cupertino.dart';

import '../../domain/demo_file.dart';
import '../../domain/file_favorites.dart';

/// A heart next to [file] while it is a favorite.
final class FavoriteMark extends StatelessWidget {
  final DemoFile file;
  final FileFavorites favorites;

  const FavoriteMark({super.key, required this.file, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) => favorites.contains(file)
          ? const Icon(
              CupertinoIcons.heart_fill,
              size: 16,
              color: CupertinoColors.systemPink,
            )
          : const SizedBox.shrink(),
    );
  }
}
