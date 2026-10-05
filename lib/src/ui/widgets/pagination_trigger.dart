part of '../view/smart_context_menu_view.dart';

final class _PaginationTrigger extends StatefulWidget {
  final VoidCallback onVisible;
  final Widget child;
  const _PaginationTrigger({
    super.key,
    required this.onVisible,
    required this.child,
  });

  @override
  State<_PaginationTrigger> createState() => _PaginationTriggerState();
}

final class _PaginationTriggerState extends State<_PaginationTrigger> {
  @override
  void initState() {
    super.initState();
    // Trigger loading. ListView builds children lazily, so initState runs
    // only when the user scrolls to the end of the list.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onVisible());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}