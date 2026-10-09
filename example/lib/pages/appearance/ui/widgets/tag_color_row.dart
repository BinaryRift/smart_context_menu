import 'package:flutter/cupertino.dart';

const _colors = [
  CupertinoColors.systemRed,
  CupertinoColors.systemOrange,
  CupertinoColors.systemGreen,
  CupertinoColors.systemBlue,
  CupertinoColors.systemPurple,
];

/// A title and a row of colors to pick, marking the [selected] one.
final class TagColorRow extends StatelessWidget {
  final ValueNotifier<Color> selected;

  /// The color of the title and of the mark around the selected color.
  final Color foregroundColor;

  const TagColorRow({
    super.key,
    required this.selected,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Tag',
            style: TextStyle(fontSize: 17, color: foregroundColor),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: selected,
          builder: (context, selectedColor, _) => Row(
            children: [
              for (final color in _colors)
                GestureDetector(
                  onTap: () => selected.value = color,
                  child: Container(
                    key: ValueKey(color),
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: CupertinoDynamicColor.resolve(color, context),
                      shape: BoxShape.circle,
                      border: color == selectedColor
                          ? Border.all(color: foregroundColor, width: 2)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
