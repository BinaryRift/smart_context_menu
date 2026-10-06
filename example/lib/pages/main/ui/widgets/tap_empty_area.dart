import 'package:flutter/cupertino.dart';

/// An empty area with a hint that calls [onDoubleTap] when tapped.
final class TapEmptyArea extends StatelessWidget {
  final VoidCallback onDoubleTap;

  const TapEmptyArea({super.key, required this.onDoubleTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTap: onDoubleTap,
      child: SizedBox(
        width: 80,
        child: Center(
          child: Text(
            'Double tap here',
            textAlign: TextAlign.center,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 13,
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondaryLabel,
                context,
              ),
            ),
          ),
        ),
      ),
    );
  }
}