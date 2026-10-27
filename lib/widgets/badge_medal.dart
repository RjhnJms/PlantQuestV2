import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../art/icons/kid_icon.dart';
import '../art/sticker.dart';

/// How far a badge is.
enum BadgeState { earned, inProgress, locked }

/// A round medal on two ribbons, with a Sticker icon in the middle.
/// Earned medals are gold; others are a soft faded version.
class BadgeMedal extends StatelessWidget {
  const BadgeMedal({
    super.key,
    required this.icon,
    required this.color,
    this.state = BadgeState.earned,
    this.size = 84,
  });

  final KidIcon icon;

  /// The ribbon color (each badge has its own).
  final Color color;
  final BadgeState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final earned = state == BadgeState.earned;
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(child: CustomPaint(painter: _MedalPainter(earned ? color : const Color(0xFFD9D2C4), earned))),
          Positioned(
            top: size * 0.17,
            child: Opacity(
              opacity: earned ? 1 : 0.55,
              child: KidIconView(icon, size: size * 0.46, muted: !earned),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalPainter extends CustomPainter {
  _MedalPainter(this.ribbon, this.earned);

  final Color ribbon;
  final bool earned;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w / 2, w * 0.42);
    final r = w * 0.38;
    // Two ribbon tails under the medal.
    for (final side in [-1.0, 1.0]) {
      final tail = Path()
        ..moveTo(c.dx + side * r * 0.2, c.dy + r * 0.4)
        ..lineTo(c.dx + side * r * 0.85, c.dy + r * 1.55)
        ..lineTo(c.dx + side * r * 0.5, c.dy + r * 1.35)
        ..lineTo(c.dx + side * r * 0.3, c.dy + r * 1.62)
        ..lineTo(c.dx - side * r * 0.15, c.dy + r * 0.6)
        ..close();
      Sticker.shape(canvas, tail, ribbon, Sticker.darken(ribbon, 0.35), width: 2);
    }
    const gold = Color(0xFFFFC93C);
    const goldDark = Color(0xFFD99A00);
    final face = earned ? gold : const Color(0xFFEDE6D6);
    final edge = earned ? goldDark : const Color(0xFFCFC5B0);
    // White sticker edge, scalloped rim, then the face.
    final rim = Path();
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi / 12;
      final rr = i.isEven ? r * 1.06 : r * 0.98;
      final p = c + Offset(rr * math.cos(a), rr * math.sin(a));
      i == 0 ? rim.moveTo(p.dx, p.dy) : rim.lineTo(p.dx, p.dy);
    }
    rim.close();
    canvas.drawPath(rim, Sticker.stroke(Colors.white, 5));
    Sticker.shape(canvas, rim, face, edge, width: 2);
    canvas.drawCircle(c, r * 0.78, Paint()..color = earned ? const Color(0xFFFFF1C7) : const Color(0xFFF6F1E6));
    canvas.drawCircle(c, r * 0.78, Sticker.stroke(edge.withValues(alpha: 0.6), 1.5));
  }

  @override
  bool shouldRepaint(_MedalPainter old) => old.ribbon != ribbon || old.earned != earned;
}
