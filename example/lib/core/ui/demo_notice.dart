import 'dart:async';

import 'package:flutter/cupertino.dart';

/// Brief feedback for actions in the example app.
final class DemoNotice extends StatefulWidget {
  final Widget child;
  static final _key = GlobalKey<_DemoNoticeState>();
  static void show(String message) => _key.currentState?.show(message);

  DemoNotice({required this.child}) : super(key: _key);

  @override
  State<DemoNotice> createState() => _DemoNoticeState();
}

final class _DemoNoticeState extends State<DemoNotice> {
  Timer? _timer;
  String? _message;
  int _generation = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [widget.child, _buildOverlay()]);
  }

  Widget _buildOverlay() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 0,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 88),
        child: IgnorePointer(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 180),
            transitionBuilder: _buildTransition,
            child: _buildNotice(),
          ),
        ),
      ),
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    final slide = Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }

  Widget _buildNotice() {
    final message = _message;
    if (message == null) return const SizedBox.shrink();

    return Center(
      key: ValueKey(_generation),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF3634A3),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Semantics(
              liveRegion: true,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: CupertinoTheme.of(
                  context,
                ).textTheme.textStyle.copyWith(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void show(String message) {
    _timer?.cancel();
    setState(() {
      _message = message;
      _generation++;
    });
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _message = null);
    });
  }
}
