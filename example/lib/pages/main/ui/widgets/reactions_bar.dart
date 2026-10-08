import 'package:flutter/cupertino.dart';

const _reactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

/// A row of reactions to show above a message.
final class ReactionsBar extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const ReactionsBar({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
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
    );
  }
}
