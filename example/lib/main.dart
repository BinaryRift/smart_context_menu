import 'package:flutter/cupertino.dart';

import 'submenu_demo_page.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: 'smart_context_menu',
      home: SubmenuDemoPage(),
    );
  }
}
