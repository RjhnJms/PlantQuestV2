import 'package:flutter/material.dart';

/// Swells and settles its child each time [trigger] changes (e.g. a right
/// answer card, a path stop opening).
class PopIn extends StatefulWidget {
  const PopIn({super.key, required this.trigger, required this.child, this.scale = 1.08});

  final Object? trigger;
  final double scale;
  final Widget child;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(PopIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Up quickly, dip a touch below 1, then settle: a springy pop.
        final t = _c.value;
        final peak = widget.scale;
        final s = t < 0.3
            ? 1 + (peak - 1) * Curves.easeOut.transform(t / 0.3)
            : t < 0.65
            ? peak + (0.98 - peak) * Curves.easeInOut.transform((t - 0.3) / 0.35)
            : 0.98 + 0.02 * Curves.easeOut.transform((t - 0.65) / 0.35);
        return Transform.scale(scale: _c.isAnimating || t > 0 && t < 1 ? s : 1.0, child: child);
      },
      child: widget.child,
    );
  }
}
