import 'package:flutter/material.dart';

class TappableScale extends StatefulWidget {
  const TappableScale({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.97,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<TappableScale> createState() => _TappableScaleState();
}

class _TappableScaleState extends State<TappableScale> {
  final ValueNotifier<double> _scaleNotifier = ValueNotifier<double>(1.0);

  @override
  void dispose() {
    _scaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleNotifier.value = widget.scale,
      onTapUp: (_) {
        _scaleNotifier.value = 1.0;
        widget.onTap();
      },
      onTapCancel: () => _scaleNotifier.value = 1.0,
      child: ValueListenableBuilder<double>(
        valueListenable: _scaleNotifier,
        builder: (context, scale, child) {
          return AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
