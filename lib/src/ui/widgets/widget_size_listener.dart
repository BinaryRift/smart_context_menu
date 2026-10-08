import 'package:flutter/material.dart';

final class WidgetSizeListener extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChanged;

  const WidgetSizeListener({
    super.key,
    required this.child,
    required this.onSizeChanged,
  });

  @override
  State<WidgetSizeListener> createState() => _WidgetSizeListenerState();
}

final class _WidgetSizeListenerState extends State<WidgetSizeListener> {
  Size? _lastSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measure();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: _onNotification,
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }

  bool _onNotification(SizeChangedLayoutNotification notification) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measure();
    });

    return false;
  }

  void _measure() {
    if (!mounted) return;

    final size = context.size;
    if (size == null) return;

    if (_lastSize == size) return;

    _lastSize = size;
    widget.onSizeChanged(size);
  }
}
