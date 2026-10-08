import 'package:flutter/cupertino.dart';

final class DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? height;

  const DemoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = CupertinoTheme.of(context).textTheme;

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
      child: Column(
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
      ),
    );
  }
}
