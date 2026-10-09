import 'package:flutter/cupertino.dart';

import '../../domain/chat_message.dart';
import '../chat_colors.dart';

/// The pin and the reactions under [message].
final class MessageFooter extends StatelessWidget {
  final ChatMessage message;
  final bool isPinned;

  const MessageFooter({
    super.key,
    required this.message,
    required this.isPinned,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPinned && message.reactions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (isPinned)
            Icon(
              CupertinoIcons.pin_fill,
              size: 14,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.systemGrey,
                context,
              ),
            ),
          for (final MapEntry(key: reaction, value: count)
              in message.reactions.entries)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CupertinoDynamicColor.resolve(
                  ChatColors.bubble,
                  context,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$reaction $count',
                style: const TextStyle(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
