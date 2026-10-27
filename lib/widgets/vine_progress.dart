import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The loading screen's progress (PLAN.md D18): a vine growing left to
/// right as [progress] goes 0 → 1, leaves popping out along it and a
/// flower at the growing tip, over a pale track for the whole way.
class VineProgressPainter extends CustomPainter {
  const VineProgressPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final mid = s.height / 2;
    final path = Path()..moveTo(6, mid);
    for (var x = 6.0; x <= s.width - 6; x += 4) {
      path.lineTo(x, mid + math.sin(x / 34) * 9);
    }
    // A pale track for the whole way.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.35),
    );
    final metric = path.computeMetrics().first;
    final grown = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(
      grown,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = AppColors.foliageDark,
    );
    // Leaves every so often, on alternate sides.
    for (var d = 26.0, i = 0; d < metric.length * progress; d += 30, i++) {
      final t = metric.getTangentForOffset(d)!;
      final side = i.isEven ? -1.0 : 1.0;
      final normal = Offset(-t.vector.dy, t.vector.dx) * side;
      final c = t.position + normal * 9;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(math.atan2(normal.dy, normal.dx));
      final leaf = Rect.fromCenter(center: Offset.zero, width: 18, height: 10);
      canvas.drawOval(leaf, Paint()..color = AppColors.leafLight);
      canvas.drawOval(
        leaf,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = AppColors.foliageDark,
      );
      canvas.restore();
    }
    // A flower at the growing tip.
    final tip = metric.getTangentForOffset(metric.length * progress)!.position;
    for (var k = 0; k < 5; k++) {
      final a = k * 2 * math.pi / 5 - math.pi / 2;
      canvas.drawCircle(tip + Offset(math.cos(a), math.sin(a)) * 7, 6, Paint()..color = AppColors.bubblegum);
    }
    canvas.drawCircle(tip, 5, Paint()..color = AppColors.sunshine);
  }

  @override
  bool shouldRepaint(VineProgressPainter old) => old.progress != progress;
}
