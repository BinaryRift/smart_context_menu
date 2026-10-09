import 'package:flutter/cupertino.dart';

import '../../domain/chat_message.dart';
import '../chat_colors.dart';

const _imageWidth = 260.0;

/// The text or the photo of [message].
final class MessageBubble extends StatelessWidget {
  /// The corner radius of the bubble and of the photo.
  static const cornerRadius = 18.0;

  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(cornerRadius);

    if (message.image case final image?) {
      // Flies to the photo page, tagged with the message.
      return Hero(
        tag: message,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: SizedBox(
            width: _imageWidth,
            child: AspectRatio(
              aspectRatio: image.aspectRatio,
              child: Image.asset(image.path, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }

    final isMine = message.isMine;
    // At most three quarters of the width of the chat.
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            isMine ? ChatColors.myBubble : ChatColors.bubble,
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
      ),
    );
  }
}
