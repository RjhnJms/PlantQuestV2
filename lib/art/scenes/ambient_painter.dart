import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../../theme/world_themes.dart';
import '../sticker.dart';
import 'land_painter.dart';
import 'scene_layout.dart';

/// Small moving life: swaying grass and rice, butterflies, birds and water
/// ripples. Only this layer repaints every frame.
class AmbientPainter extends CustomPainter {
  AmbientPainter({required this.world, required this.time, super.repaint});

  final int world;

  /// Seconds since the scene started. Fixed at 0 with less motion.
  final double Function() time;

  WorldTheme get t => WorldTheme.of(world);

  @override
  void paint(Canvas canvas, Size size) {
    final l = SceneLayout(size);
    final s = time();
    switch (world) {
      case 1:
        _tufts(canvas, l, s, t.nearLight, Sticker.darken(t.near, 0.18));
        _birds(canvas, l, s, 1);
        _butterflies(canvas, l, s, [AppColors.bubblegum, AppColors.sunshine, AppColors.grape]);
      case 2:
        _rice(canvas, l, s);
        _birds(canvas, l, s, 3);
        _butterflies(canvas, l, s, [AppColors.coral]);
      default:
        _ripples(canvas, l, s);
        _birds(canvas, l, s, 2);
        _butterflies(canvas, l, s, [AppColors.sky, AppColors.sunshine]);
    }
  }

  void _tufts(Canvas canvas, SceneLayout l, double s, Color light, Color dark) {
    final pts = l.scatter(world, 11, spacing: 88, top: l.groundTop + 60);
    for (final p in pts) {
      final sway = math.sin(s * 1.6 + p.dx * 0.05 + p.dy * 0.03) * 3;
      for (final (dx, h) in [(-5.0, 13.0), (0.0, 18.0), (5.0, 12.0)]) {
        final blade = Path()
          ..moveTo(p.dx + dx * 0.4, p.dy)
          ..quadraticBezierTo(p.dx + dx, p.dy - h * 0.6, p.dx + dx * 1.4 + sway, p.dy - h);
        canvas
          ..drawPath(blade, Sticker.stroke(dark, 4))
          ..drawPath(blade, Sticker.stroke(light, 2));
      }
    }
  }

  void _rice(Canvas canvas, SceneLayout l, double s) {
    final stalk = Sticker.stroke(AppColors.leafDark, 2.2);
    final grain = Sticker.solid(t.detail);
    final grainLine = Sticker.outline(Sticker.darken(t.detail, 0.25), width: 1);
    var row = 0;
    for (var y = l.groundTop + 34; y < l.h; y += 46, row++) {
      for (var x = (row.isEven ? 14.0 : 34.0); x < l.w; x += 40) {
        final sway = math.sin(s * 1.4 + x * 0.04 + row) * 3.5;
        for (final dx in [-4.0, 0.0, 4.0]) {
          final top = Offset(x + dx * 1.6 + sway, y - 22 - (dx == 0 ? 4 : 0));
          final blade = Path()
            ..moveTo(x + dx * 0.4, y)
            ..quadraticBezierTo(x + dx, y - 12, top.dx, top.dy);
          canvas.drawPath(blade, stalk);
        }
        // A drooping head of grain on the middle stalk
        final head = Offset(x + sway, y - 26);
        for (var i = 0; i < 3; i++) {
          final g = Rect.fromCenter(center: head.translate(2.5 + i * 2.2, i * 3.2), width: 3.6, height: 5);
          canvas
            ..drawOval(g, grain)
            ..drawOval(g, grainLine);
        }
      }
    }
  }

  void _ripples(Canvas canvas, SceneLayout l, double s) {
    final shine = Sticker.stroke(const Color(0xFFFFFFFF).withValues(alpha: 0.65), 2.4);
    var i = 0;
    for (var y = l.groundTop + 30; y < l.h; y += 38, i++) {
      final cx = LandPainter.riverX(l, y);
      final drift = math.sin(s * 0.9 + i) * 8;
      final len = 10 + (i % 3) * 5.0;
      canvas.drawLine(Offset(cx - len / 2 + drift, y), Offset(cx + len / 2 + drift, y), shine);
    }
  }

  void _birds(Canvas canvas, SceneLayout l, double s, int count) {
    final ink = Sticker.stroke(AppColors.text.withValues(alpha: 0.55), 2.2);
    for (var i = 0; i < count; i++) {
      final speed = 0.018 + i * 0.006;
      final x = ((s * speed + i * 0.37) % 1.3 - 0.15) * l.w;
      final y = l.skyH * (0.25 + i * 0.12) + math.sin(s * 0.8 + i) * 6;
      final flap = math.sin(s * 7 + i * 2) * 4;
      final bird = Path()
        ..moveTo(x - 8, y - 1 + flap)
        ..quadraticBezierTo(x - 4, y - 4, x, y)
        ..quadraticBezierTo(x + 4, y - 4, x + 8, y - 1 + flap);
      canvas.drawPath(bird, ink);
    }
  }

  void _butterflies(Canvas canvas, SceneLayout l, double s, List<Color> colors) {
    final r = l.random(world, 17);
    for (var i = 0; i < colors.length; i++) {
      final baseX = l.w * (0.15 + r.nextDouble() * 0.7);
      final baseY = l.groundTop + 30 + r.nextDouble() * math.max(40.0, (l.h - l.groundTop) * 0.6);
      final phase = r.nextDouble() * 6;
      final c = Offset(baseX + math.sin(s * 0.45 + phase) * l.w * 0.12, baseY + math.sin(s * 1.1 + phase) * 16);
      final heading = math.cos(s * 0.45 + phase) >= 0 ? 1.0 : -1.0;
      final open = 0.35 + 0.65 * math.sin(s * 11 + phase).abs();
      _butterfly(canvas, c, colors[i], open, heading);
    }
  }

  static void _butterfly(Canvas canvas, Offset c, Color color, double open, double heading) {
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..scale(heading, 1);
    final line = Sticker.outline(Sticker.darken(color, 0.25), width: 1.4);
    for (final side in [-1.0, 1.0]) {
      final upper = Rect.fromCenter(center: Offset(side * 5 * open, -3), width: 9 * open + 1, height: 9);
      final lower = Rect.fromCenter(center: Offset(side * 4 * open, 4), width: 7 * open + 1, height: 6);
      canvas
        ..drawOval(upper, Sticker.fill(upper, color, lift: 0.35))
        ..drawOval(upper, line)
        ..drawOval(lower, Sticker.solid(color))
        ..drawOval(lower, line);
    }
    canvas
      ..drawLine(const Offset(0, -6), const Offset(0, 6), Sticker.stroke(AppColors.text, 2))
      ..restore();
  }

  @override
  bool shouldRepaint(AmbientPainter old) => old.world != world;
}
