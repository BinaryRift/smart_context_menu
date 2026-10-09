import 'package:flutter/foundation.dart';

import 'chat_message.dart';
import 'demo_chat.dart';

/// The messages with the pins and reactions that the menus change.
final class Chat extends ChangeNotifier {
  final messages = demoMessages();
  final _pinned = <ChatMessage>{};

  bool isPinned(ChatMessage message) => _pinned.contains(message);

  void togglePin(ChatMessage message) {
    if (!_pinned.remove(message)) _pinned.add(message);
    notifyListeners();
  }

  void react(ChatMessage message, String reaction) {
    message.reactions.update(reaction, (count) => count + 1, ifAbsent: () => 1);
    notifyListeners();
  }
}
