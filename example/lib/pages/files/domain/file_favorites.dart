import 'package:flutter/foundation.dart';

import '../../../core/data/demo_loader.dart';
import 'demo_file.dart';

/// Favorite files, saved with a delay like a network request.
final class FileFavorites extends ChangeNotifier {
  final _favorites = <DemoFile>{};
  final _saving = <DemoFile>{};

  bool contains(DemoFile file) => _favorites.contains(file);

  bool isSaving(DemoFile file) => _saving.contains(file);

  Future<void> toggle(DemoFile file) async {
    _saving.add(file);
    notifyListeners();
    await Future<void>.delayed(demoLoadDelay);
    if (!_favorites.remove(file)) _favorites.add(file);
    _saving.remove(file);
    notifyListeners();
  }
}
