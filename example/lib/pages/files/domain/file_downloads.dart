import 'dart:async';

import 'package:flutter/foundation.dart';

import 'demo_file.dart';

const _tick = Duration(milliseconds: 500);
const _step = 10;

/// Downloads of files that keep running after the menu closes.
final class FileDownloads extends ChangeNotifier {
  final _percents = <DemoFile, int>{};
  final _timers = <DemoFile, Timer>{};

  bool isRunning(DemoFile file) => _timers.containsKey(file);

  bool isDone(DemoFile file) => _percents[file] == 100;

  int percent(DemoFile file) => _percents[file] ?? 0;

  void start(DemoFile file) {
    _percents[file] = 0;
    _timers[file] = Timer.periodic(_tick, (timer) {
      _percents[file] = percent(file) + _step;
      if (isDone(file)) {
        timer.cancel();
        _timers.remove(file);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void remove(DemoFile file) {
    _percents.remove(file);
    notifyListeners();
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
