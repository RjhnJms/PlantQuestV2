import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../theme/app_colors.dart';

/// A sky-blue watering can, filling its box. [pouring] tips it forward
/// with drops falling from the spout.
class WateringCanPainter extends CustomPainter {
  const WateringCanPainter({this.pouring = false});

  final bool pouring;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    canvas.save();
    if (pouring) {
      canvas.translate(w / 2, h / 2);
      canvas.rotate(-0.5);
      canvas.translate(-w / 2, -h / 2);
    }
    final dark = Paint()
      ..color = AppColors.skyDark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Spout, handle, body, rose.
    canvas.drawLine(Offset(w * 0.35, h * 0.62), Offset(w * 0.08, h * 0.32), dark..strokeWidth = w * 0.1);
    canvas.drawArc(
      Rect.fromLTWH(w * 0.45, h * 0.2, w * 0.42, h * 0.46),
      -math.pi * 0.9,
      math.pi * 1.2,
      false,
      dark..strokeWidth = w * 0.08,
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.3, h * 0.42, w * 0.5, h * 0.48),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(body, Paint()..color = AppColors.sky);
    canvas.drawRRect(
      body,
      Paint()
        ..color = AppColors.skyDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, w * 0.04),
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.36, h * 0.48, w * 0.08, h * 0.34),
      Paint()..color = AppColors.skyLight.withValues(alpha: 0.8),
    );
    canvas.drawCircle(Offset(w * 0.08, h * 0.32), w * 0.07, Paint()..color = AppColors.skyDark);
    canvas.restore();
    if (pouring) {
      final drop = Paint()..color = AppColors.sky;
      for (final (x, y) in [(0.04, 0.6), (0.12, 0.78), (-0.02, 0.92)]) {
        canvas.drawOval(Rect.fromCenter(center: Offset(w * x, h * y), width: w * 0.08, height: w * 0.13), drop);
      }
    }
  }

  @override
  bool shouldRepaint(WateringCanPainter old) => old.pouring != pouring;
}
