import 'dart:math' as math;

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import 'binhi_outfit.dart';

/// The scene behind Binhi in his corner on Home and in the Shop
/// (PLAN.md §5m). Fills whatever it is given; the caller clips it (a circle
/// on Home, a rounded card in the Shop). [BinhiSpot.meadow] paints nothing.
class BinhiSpotPainter extends CustomPainter {
  const BinhiSpotPainter(this.spot);

  final BinhiSpot spot;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Paint solid(Color c) => Paint()..color = c;
    Paint gradient(List<Color> colors, double top, double bottom) =>
        Paint()..shader = ui.Gradient.linear(Offset(0, top), Offset(0, bottom), colors);
    switch (spot) {
      case BinhiSpot.meadow:
        return;
      case BinhiSpot.beach:
        canvas
          ..drawRect(
            Rect.fromLTWH(0, 0, w, h * 0.55),
            gradient(const [Color(0xFF8FD3FF), Color(0xFFD8F1FF)], 0, h * 0.55),
          )
          ..drawCircle(Offset(w * 0.78, h * 0.2), h * 0.09, solid(const Color(0xFFFFD95A)))
          ..drawRect(Rect.fromLTWH(0, h * 0.55, w, h * 0.14), solid(AppColors.sky))
          ..drawRect(Rect.fromLTWH(0, h * 0.62, w, h * 0.03), solid(const Color(0x66FFFFFF)))
          ..drawRect(Rect.fromLTWH(0, h * 0.69, w, h * 0.31), solid(const Color(0xFFF6DFA6)));
        final foam = Path()..moveTo(0, h * 0.69);
        for (var x = 0.0; x < w; x += w / 6) {
          foam.quadraticBezierTo(x + w / 12, h * 0.66, x + w / 6, h * 0.69);
        }
        canvas.drawPath(
          foam,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = h * 0.02
            ..color = const Color(0xFFFFFFFF),
        );
      case BinhiSpot.terraces:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), gradient(const [Color(0xFFBFE9FF), Color(0xFFE8F7FF)], 0, h * 0.4));
        const greens = [Color(0xFF9BD15A), Color(0xFF7BC25B), Color(0xFFA6E58A), Color(0xFF6FB34A), Color(0xFF8FD16A)];
        for (var i = 0; i < 5; i++) {
          final top = h * (0.34 + i * 0.13);
          final step = Path()
            ..moveTo(0, top + h * 0.03)
            ..quadraticBezierTo(w * 0.5, top - h * 0.04, w, top + h * 0.02)
            ..lineTo(w, h)
            ..lineTo(0, h)
            ..close();
          canvas
            ..drawPath(step, solid(greens[i]))
            ..drawPath(
              Path()
                ..moveTo(0, top + h * 0.03)
                ..quadraticBezierTo(w * 0.5, top - h * 0.04, w, top + h * 0.02),
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5
                ..color = const Color(0x553E7A2E),
            );
        }
      case BinhiSpot.night:
        canvas
          ..drawRect(Rect.fromLTWH(0, 0, w, h), gradient(const [Color(0xFF26305A), Color(0xFF3E4C86)], 0, h))
          ..drawCircle(Offset(w * 0.76, h * 0.22), h * 0.1, solid(const Color(0xFFFFF6C9)))
          ..drawCircle(Offset(w * 0.8, h * 0.19), h * 0.085, solid(const Color(0xFF2E3A6C)));
        // Fireflies near the grass.
        final r = math.Random(4);
        for (var i = 0; i < 6; i++) {
          final o = Offset(r.nextDouble() * w, h * (0.55 + r.nextDouble() * 0.3));
          canvas
            ..drawCircle(o, h * 0.03, solid(const Color(0x33FFF59A)))
            ..drawCircle(o, h * 0.012, solid(const Color(0xFFFFF59A)));
        }
        canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w, h * 0.18), solid(const Color(0xFF2E5A3A)));
      case BinhiSpot.fiesta:
        canvas.drawRect(Rect.fromLTWH(0, 0, w, h), gradient(const [Color(0xFFFFF1C7), Color(0xFFFFE3B0)], 0, h));
        const flags = [AppColors.hibiscusRed, AppColors.sunshine, AppColors.sky, AppColors.leaf, AppColors.grape];
        for (final row in [0.1, 0.24]) {
          final y0 = h * row;
          final rope = Path()
            ..moveTo(0, y0)
            ..quadraticBezierTo(w / 2, y0 + h * 0.08, w, y0);
          canvas.drawPath(
            rope,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = AppColors.barkDark,
          );
          const n = 9;
          for (var i = 0; i < n; i++) {
            final t = (i + 0.5) / n;
            final x = w * t;
            final y = y0 + h * 0.08 * 4 * t * (1 - t) * 0.5;
            canvas.drawPath(
              Path()
                ..moveTo(x - w * 0.035, y)
                ..lineTo(x + w * 0.035, y)
                ..lineTo(x, y + h * 0.08)
                ..close(),
              solid(flags[(i + (row > 0.2 ? 2 : 0)) % flags.length]),
            );
          }
        }
    }
  }

  @override
  bool shouldRepaint(BinhiSpotPainter old) => old.spot != spot;
}
