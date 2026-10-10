import 'package:flutter/cupertino.dart';

const _colors = [
  CupertinoColors.systemBlue,
  CupertinoColors.systemGreen,
  CupertinoColors.systemOrange,
  CupertinoColors.systemPink,
  CupertinoColors.systemPurple,
  CupertinoColors.systemTeal,
  CupertinoColors.systemIndigo,
];

/// A round avatar with the initials of [name] on a color picked by the
/// name, so the same person always has the same color.
final class PersonAvatar extends StatelessWidget {
  final String name;
  final double size;

  const PersonAvatar({super.key, required this.name, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final words = name.split(' ');
    final initials = words.take(2).map((word) => word[0]).join();
    final seed = name.codeUnits.fold(0, (sum, unit) => sum + unit);
    final color = CupertinoDynamicColor.resolve(
      _colors[seed % _colors.length],
      context,
    );
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.75), color],
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.white,
        ),
      ),
    );
  }
}
