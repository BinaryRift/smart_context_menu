import 'package:flutter/foundation.dart';

/// How long a simulated network load takes.
const demoLoadDelay = Duration(milliseconds: 800);

/// Simulates network loads of the demo menus.
class DemoLoader {
  /// Whether every other load fails, so the retry item can be checked.
  bool failEveryOther = false;

  int _attempt = 0;

  Future<void> load(String what) async {
    _attempt++;
    debugPrint('$what: loading');
    await Future<void>.delayed(demoLoadDelay);
    if (failEveryOther && _attempt.isOdd) {
      debugPrint('$what: failed');
      throw Exception('$what: failed');
    }
  }
}
