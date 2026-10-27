import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../../theme/world_themes.dart';
import '../sticker.dart';
import 'scene_layout.dart';

/// Sky gradient and the sun. Never animates, so it is painted once.
class SkyPainter extends CustomPainter {
  const SkyPainter(this.theme);

  final WorldTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final l = SceneLayout(size);
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(0, l.groundTop), [theme.skyTop, theme.skyBottom]),
    );

    final c = l.sunCenter;
    final r = l.sunRadius;
    // Soft glow rings
    canvas
      ..drawCircle(c, r * 1.9, Sticker.solid(AppColors.sunshine.withValues(alpha: 0.16)))
      ..drawCircle(c, r * 1.45, Sticker.solid(AppColors.sunshine.withValues(alpha: 0.24)));
    // Rounded rays
    final ray = Sticker.stroke(AppColors.sunshine.withValues(alpha: 0.7), r * 0.16);
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5 + 0.2;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * (r * 1.22), c + d * (r * 1.5), ray);
    }
    final disc = Rect.fromCircle(center: c, radius: r);
    canvas
      ..drawOval(disc, Sticker.fill(disc, AppColors.sunshine, lift: 0.35))
      ..drawOval(disc, Sticker.outline(AppColors.sunshineDark, width: 2.5));
    Sticker.gloss(
      canvas,
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(-r * 0.3, -r * 0.42), width: r * 0.7, height: r * 0.28),
        Radius.circular(r),
      ),
      alpha: 0.5,
    );
  }

  @override
  bool shouldRepaint(SkyPainter old) => old.theme != theme;
}

/// Puffy clouds drifting slowly to the right and wrapping around.
class CloudPainter extends CustomPainter {
  CloudPainter({required this.world, required this.drift, super.repaint});

  final int world;

  /// 0–1, one full trip across the screen.
  final double Function() drift;

  @override
  void paint(Canvas canvas, Size size) {
    final l = SceneLayout(size);
    final r = l.random(world, 3);
    final count = 3 + (l.w / 260).floor();
    for (var i = 0; i < count; i++) {
      final scale = 0.65 + r.nextDouble() * 0.55;
      final cloudW = 96 * scale;
      final speed = 0.6 + r.nextDouble() * 0.8;
      final span = l.w + cloudW * 2;
      final x = ((i / count + drift() * speed) % 1) * span - cloudW;
      final y = l.skyH * (0.18 + r.nextDouble() * 0.45);
      _cloud(canvas, Offset(x, y), scale);
    }
  }

  static void _cloud(Canvas canvas, Offset at, double s) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: at.translate(26 * s, 4 * s), radius: 18 * s))
      ..addOval(Rect.fromCircle(center: at.translate(48 * s, -6 * s), radius: 24 * s))
      ..addOval(Rect.fromCircle(center: at.translate(72 * s, 4 * s), radius: 17 * s))
      ..addRRect(
        RRect.fromLTRBR(at.dx + 8 * s, at.dy + 2 * s, at.dx + 90 * s, at.dy + 22 * s, Radius.circular(10 * s)),
      );
    final bounds = path.getBounds();
    canvas
      ..drawPath(path.shift(Offset(0, 4 * s)), Sticker.solid(AppColors.skyDark.withValues(alpha: 0.12)))
      ..drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(
            bounds.topCenter,
            bounds.bottomCenter,
            [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF), AppColors.skyTint],
            const [0, 0.55, 1],
          ),
      );
  }

  @override
  bool shouldRepaint(CloudPainter old) => old.world != world;
}
