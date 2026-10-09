import 'package:flutter/cupertino.dart';

/// A message field at the bottom of the chat; it does not send messages.
final class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.separator,
              context,
            ),
            width: 0,
          ),
        ),
      ),
      child: const Row(
        children: [
          Expanded(child: CupertinoTextField(placeholder: 'Message')),
          CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 8),
            onPressed: null,
            child: Icon(CupertinoIcons.arrow_up_circle_fill, size: 32),
          ),
        ],
      ),
    );
  }
}
