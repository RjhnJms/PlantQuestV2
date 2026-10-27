import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../art/icons/kid_icon.dart';
import '../../theme/app_sizes.dart';

/// Sends leaves flying along an arc from one point to another inside a
/// [FlyingLeavesLayer] (e.g. from a right answer to the leaf counter).
class FlyingLeavesController extends ChangeNotifier {
  final List<(Offset, Offset, int, VoidCallback?)> _pending = [];

  /// [onEachArrive] runs as every leaf lands (tick the counter, play a sound).
  void fly({required Offset from, required Offset to, int count = 5, VoidCallback? onEachArrive}) {
    _pending.add((from, to, count, onEachArrive));
    notifyListeners();
  }
}

class _Flight {
  _Flight(this.from, this.to, this.delay, this.lift, this.onArrive);
  final Offset from;
  final Offset to;
  final double delay;
  final double lift;
  final VoidCallback? onArrive;
  bool arrived = false;
}

class FlyingLeavesLayer extends StatefulWidget {
  const FlyingLeavesLayer({super.key, required this.controller, required this.child});

  final FlyingLeavesController controller;
  final Widget child;

  @override
  State<FlyingLeavesLayer> createState() => _FlyingLeavesLayerState();
}

class _FlyingLeavesLayerState extends State<FlyingLeavesLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(days: 1));
  final _flights = <_Flight>[];
  final _random = math.Random();
  double _now = 0;

  static const _flightSeconds = 0.75;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onFly);
    _clock.addListener(_tick);
  }

  void _onFly() {
    for (final (from, to, count, cb) in widget.controller._pending) {
      for (var i = 0; i < count; i++) {
        _flights.add(
          _Flight(
            from + Offset((_random.nextDouble() - 0.5) * 40, (_random.nextDouble() - 0.5) * 30),
            to,
            _now + i * 0.09,
            90 + _random.nextDouble() * 70,
            cb,
          ),
        );
      }
    }
    widget.controller._pending.clear();
    if (!_clock.isAnimating) _clock.forward(from: 0);
  }

  void _tick() {
    _now = (_clock.lastElapsedDuration ?? Duration.zero).inMicroseconds / 1e6;
    for (final f in _flights) {
      if (!f.arrived && _now - f.delay >= _flightSeconds) {
        f.arrived = true;
        f.onArrive?.call();
      }
    }
    _flights.removeWhere((f) => f.arrived);
    if (_flights.isEmpty) {
      _clock.stop();
      _now = 0;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onFly);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        for (final f in _flights)
          if (_now >= f.delay) _leafAt(f, ((_now - f.delay) / _flightSeconds).clamp(0.0, 1.0)),
      ],
    );
  }

  Widget _leafAt(_Flight f, double t) {
    final e = Curves.easeInOutCubic.transform(t);
    // Arc: rise above the straight line, then dive into the counter.
    final straight = Offset.lerp(f.from, f.to, e)!;
    final pos = straight - Offset(0, math.sin(e * math.pi) * f.lift);
    final scale = 1.25 - 0.55 * e;
    return Positioned(
      left: pos.dx - 14,
      top: pos.dy - 14,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: e * math.pi * 2,
          child: Transform.scale(
            scale: scale,
            child: const KidIconView(KidIcon.leaf, size: AppSizes.iconMedium),
          ),
        ),
      ),
    );
  }
}
