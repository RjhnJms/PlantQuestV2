import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Tells a [ConfettiLayer] to burst from a point (in the layer's own
/// coordinates).
class ConfettiController extends ChangeNotifier {
  final List<(Offset, int, double)> _pending = [];

  /// [count] pieces; 0 makes a small sparkle ring instead (gentle feel).
  void burst(Offset at, {int count = 45, double seconds = 1.6}) {
    _pending.add((at, count, seconds));
    notifyListeners();
  }
}

class _Piece {
  _Piece(this.origin, this.velocity, this.color, this.spin, this.shape, this.size);
  final Offset origin;
  final Offset velocity;
  final Color color;
  final double spin;
  final int shape; // 0 rectangle, 1 circle, 2 leaf
  final double size;
}

class _Burst {
  _Burst(this.pieces, this.seconds, this.sparkle, this.origin);
  final List<_Piece> pieces;
  final double seconds;
  final bool sparkle;
  final Offset origin;
  double t = 0;
}

/// Draws confetti bursts on top of [child]. Ignores touches. Only ticks
/// while something is in the air.
class ConfettiLayer extends StatefulWidget {
  const ConfettiLayer({super.key, required this.controller, required this.child});

  final ConfettiController controller;
  final Widget child;

  @override
  State<ConfettiLayer> createState() => _ConfettiLayerState();
}

class _ConfettiLayerState extends State<ConfettiLayer> with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(days: 1));
  final _bursts = <_Burst>[];
  final _random = math.Random();
  Duration _last = Duration.zero;

  static const _colors = [
    AppColors.leaf,
    AppColors.sunshine,
    AppColors.bubblegum,
    AppColors.sky,
    AppColors.grape,
    AppColors.coral,
    AppColors.teal,
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onBurst);
    _clock.addListener(_tick);
  }

  void _onBurst() {
    for (final (at, count, seconds) in widget.controller._pending) {
      final sparkle = count == 0;
      final n = sparkle ? 10 : count;
      _bursts.add(
        _Burst(
          [
            for (var i = 0; i < n; i++)
              _Piece(
                at,
                sparkle
                    ? Offset.fromDirection(i * math.pi * 2 / n, 140)
                    : Offset.fromDirection(
                        -math.pi / 2 + (_random.nextDouble() - 0.5) * 2.4,
                        260 + _random.nextDouble() * 420,
                      ),
                _colors[_random.nextInt(_colors.length)],
                (_random.nextDouble() - 0.5) * 16,
                sparkle ? 1 : _random.nextInt(3),
                sparkle ? 5 : 7 + _random.nextDouble() * 6,
              ),
          ],
          seconds,
          sparkle,
          at,
        ),
      );
    }
    widget.controller._pending.clear();
    if (!_clock.isAnimating) {
      _last = Duration.zero;
      _clock.forward(from: 0);
    }
  }

  void _tick() {
    final now = _clock.lastElapsedDuration ?? Duration.zero;
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    for (final b in _bursts) {
      b.t += dt;
    }
    _bursts.removeWhere((b) => b.t > b.seconds);
    if (_bursts.isEmpty) _clock.stop();
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onBurst);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (_bursts.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(child: CustomPaint(painter: _ConfettiPainter(List.of(_bursts)))),
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.bursts);

  final List<_Burst> bursts;

  static const _gravity = 900.0;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bursts) {
      final life = (b.t / b.seconds).clamp(0.0, 1.0);
      final alpha = life < 0.7 ? 1.0 : 1 - (life - 0.7) / 0.3;
      for (final p in b.pieces) {
        final paint = Paint()..color = p.color.withValues(alpha: alpha);
        if (b.sparkle) {
          // A ring of twinkles that drift out and fade.
          final ease = Curves.easeOutCubic.transform(life);
          final pos = p.origin + p.velocity * ease * 0.6;
          final r = p.size * (1 - life * 0.6);
          _star(canvas, pos, r, paint);
          continue;
        }
        final t = b.t;
        // Air drag slows the pieces so they flutter down.
        final drag = 1 - math.min(0.8, t * 0.9).toDouble();
        final pos =
            p.origin + p.velocity * t * drag + Offset(math.sin(t * 6 + p.spin) * 8, 0.5 * _gravity * t * t * 0.55);
        canvas
          ..save()
          ..translate(pos.dx, pos.dy)
          ..rotate(p.spin * t);
        switch (p.shape) {
          case 0:
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(
                  center: Offset.zero,
                  width: p.size,
                  height: p.size * 0.55 * (0.4 + 0.6 * math.cos(t * 9 + p.spin).abs()),
                ),
                const Radius.circular(2),
              ),
              paint,
            );
          case 1:
            canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
          default:
            final leaf = Path()
              ..moveTo(0, -p.size * 0.6)
              ..quadraticBezierTo(p.size * 0.5, 0, 0, p.size * 0.6)
              ..quadraticBezierTo(-p.size * 0.5, 0, 0, -p.size * 0.6);
            canvas.drawPath(leaf, paint);
        }
        canvas.restore();
      }
    }
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final rr = i.isEven ? r : r * 0.35;
      final pt = c + Offset.fromDirection(a, rr);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}
