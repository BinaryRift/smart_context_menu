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
      // The border and the shadow set the bar apart from the preview
      // scrolling under it.
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.separator,
            context,
          ),
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
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
