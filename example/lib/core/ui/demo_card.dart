// ignore: deprecated_member_use
import 'package:flutter/cupertino.dart';

final class DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? height;

  /// Shown at the end of the card, after the texts.
  final Widget? trailing;

  const DemoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.height,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.textStyle),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.textStyle.copyWith(
            fontSize: 13,
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.secondaryLabel,
              context,
            ),
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemGroupedBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: switch (trailing) {
        final trailing? => Row(
          children: [
            Expanded(child: texts),
            trailing,
          ],
        ),
        null => texts,
      },
    );
  }
}
