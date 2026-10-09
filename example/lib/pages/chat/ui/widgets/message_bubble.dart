import 'package:flutter/cupertino.dart';

import '../../domain/chat_message.dart';

const _imageWidth = 260.0;

/// The text or the photo of [message].
final class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);

    if (message.image case final image?) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: _imageWidth,
          child: AspectRatio(
            aspectRatio: image.aspectRatio,
            child: Image.asset(image.path, fit: BoxFit.cover),
          ),
        ),
      );
    }

    final isMine = message.isMine;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          isMine ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
          context,
        ),
        borderRadius: borderRadius,
      ),
      child: Text(
        message.text!,
        style: TextStyle(
          color: isMine
              ? CupertinoColors.white
              : CupertinoDynamicColor.resolve(CupertinoColors.label, context),
        ),
      ),
    );
  }
}
