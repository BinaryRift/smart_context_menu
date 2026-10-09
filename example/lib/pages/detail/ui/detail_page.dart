import 'package:flutter/cupertino.dart';

/// The page that menus open: [title] in the navigation bar
/// and [child] in the middle.
final class DetailPage extends StatelessWidget {
  final String title;
  final Widget child;

  const DetailPage({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      child: SafeArea(child: Center(child: child)),
    );
  }
}
