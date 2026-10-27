import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../theme/app_colors.dart';

/// Binhi's daily gift: a coral box with a sunshine ribbon and bow, filling
/// its box. [open] lifts the lid off to one side.
class GiftBoxPainter extends CustomPainter {
  const GiftBoxPainter({this.open = false});

  final bool open;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final box = Rect.fromLTWH(w * 0.1, h * 0.42, w * 0.8, h * 0.55);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.025)
      ..color = AppColors.coralDark;
    final ribbon = Paint()..color = AppColors.sunshine;
    canvas.drawRRect(RRect.fromRectAndRadius(box, Radius.circular(w * 0.06)), Paint()..color = AppColors.coral);
    canvas.drawRRect(RRect.fromRectAndRadius(box, Radius.circular(w * 0.06)), outline);
    canvas.drawRect(Rect.fromLTWH(w * 0.43, h * 0.42, w * 0.14, h * 0.55), ribbon);
    canvas.save();
    if (open) {
      canvas.translate(w * 0.28, -h * 0.12);
      canvas.rotate(0.35);
    }
    final lid = Rect.fromLTWH(w * 0.04, h * 0.3, w * 0.92, h * 0.17);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, Radius.circular(w * 0.05)), Paint()..color = AppColors.coralLight);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, Radius.circular(w * 0.05)), outline);
    canvas.drawRect(Rect.fromLTWH(w * 0.43, h * 0.3, w * 0.14, h * 0.17), ribbon);
    canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.3, h * 0.22), ribbon);
    canvas.drawOval(Rect.fromLTWH(w * 0.5, h * 0.1, w * 0.3, h * 0.22), ribbon);
    canvas.drawCircle(Offset(w * 0.5, h * 0.25), w * 0.07, Paint()..color = AppColors.sunshineDark);
    canvas.restore();
  }

  @override
  bool shouldRepaint(GiftBoxPainter old) => old.open != open;
}
