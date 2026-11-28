// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:smart_context_menu/smart_context_menu.dart';

const _reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

/// A row of reactions to show above a message.
final class ReactionsBar extends StatelessWidget {
  final ValueChanged<String> onSelected;
  final Animation<double> opacity;

  const ReactionsBar({
    super.key,
    required this.opacity,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SmartContextMenuPanel(
      borderRadius: BorderRadius.circular(24),
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final reaction in _reactions)
              CupertinoButton(
                padding: const EdgeInsets.all(6),
                minimumSize: const Size.square(36),
                onPressed: () => onSelected(reaction),
                child: Text(reaction, style: const TextStyle(fontSize: 26)),
              ),
          ],
        ),
      ),
    );
  }
}
