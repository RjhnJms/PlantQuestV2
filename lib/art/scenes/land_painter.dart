import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../../theme/world_themes.dart';
import '../sticker.dart';
import 'scene_layout.dart';

/// Which slice of the land to draw. Far and mid layers scroll slower than
/// the path (parallax); near is the ground the path sits on.
enum LandLayer { far, mid, near }

/// Static land for one world and layer. Painted once and cached.
class LandPainter extends CustomPainter {
  const LandPainter({required this.world, required this.layer});

  final int world;
  final LandLayer layer;

  WorldTheme get t => WorldTheme.of(world);

  /// Center of Kalikasan's river at height [y]. Shared with the ripples.
  static double riverX(SceneLayout l, double y) => l.w * 0.52 + math.sin(y / 150 + 0.6) * l.w * 0.2;
  static const riverWidth = 64.0;

  @override
  void paint(Canvas canvas, Size size) {
    final l = SceneLayout(size);
    switch ((world, layer)) {
      case (1, LandLayer.far):
        _bakuranHills(canvas, l);
      case (1, LandLayer.mid):
        _fence(canvas, l);
      case (1, LandLayer.near):
        _ground(canvas, l);
        _flowers(canvas, l);
      case (2, LandLayer.far):
        _mountains(canvas, l);
      case (2, LandLayer.mid):
        _terraces(canvas, l);
      case (2, LandLayer.near):
        _ground(canvas, l, stripes: false);
        _paddyRows(canvas, l);
      case (_, LandLayer.far):
        _canopy(canvas, l);
      case (_, LandLayer.mid):
        _mangroves(canvas, l);
      case (_, LandLayer.near):
        _ground(canvas, l);
        _river(canvas, l);
        _ferns(canvas, l);
    }
  }

  // ---- shared ----

  void _land(Canvas canvas, Path path, Color color) =>
      Sticker.shape(canvas, path, color, Sticker.darken(color, 0.14), lift: 0.12, width: 2.5);

  /// A smooth closed band whose top edge passes through [tops] and which
  /// fills down to the bottom of the canvas.
  Path _wavyTop(SceneLayout l, List<Offset> tops) {
    final path = Path()..moveTo(-10, l.h + 10);
    path.lineTo(tops.first.dx, tops.first.dy);
    for (var i = 0; i < tops.length - 1; i++) {
      final a = tops[i];
      final b = tops[i + 1];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      path.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
    }
    path
      ..lineTo(tops.last.dx, tops.last.dy)
      ..lineTo(l.w + 10, l.h + 10)
      ..close();
    return path;
  }

  void _ground(Canvas canvas, SceneLayout l, {bool stripes = true}) {
    final top = l.groundTop;
    final path = _wavyTop(l, [
      for (var i = 0; i <= 6; i++) Offset(-10 + (l.w + 20) * i / 6, top + math.sin(i * 1.7 + world) * 5),
    ]);
    canvas.drawPath(
      path,
      Paint()..shader = ui.Gradient.linear(Offset(0, top), Offset(0, top + 140), [t.nearLight, t.near]),
    );
    canvas.drawPath(path, Sticker.outline(Sticker.darken(t.near, 0.12), width: 2.5));
    if (stripes) {
      final stripe = Sticker.solid(t.nearLight.withValues(alpha: 0.35));
      for (var y = top + 90; y < l.h; y += 110) {
        canvas.drawRRect(RRect.fromLTRBR(-20, y, l.w + 20, y + 34, const Radius.circular(17)), stripe);
      }
    }
  }

  void _lollipopTree(Canvas canvas, Offset base, double s, Color crown) {
    canvas.drawLine(base, base.translate(0, -16 * s), Sticker.stroke(AppColors.barkDark, 5 * s));
    canvas.drawLine(base, base.translate(0, -16 * s), Sticker.stroke(AppColors.bark, 3 * s));
    final r = Rect.fromCircle(center: base.translate(0, -24 * s), radius: 12 * s);
    canvas
      ..drawOval(r, Sticker.fill(r, crown, lift: 0.25))
      ..drawOval(r, Sticker.outline(Sticker.darken(crown, 0.2), width: 2));
  }

  // ---- Bakuran (backyard) ----

  void _bakuranHills(Canvas canvas, SceneLayout l) {
    final y0 = l.skyH * 0.8;
    _land(
      canvas,
      _wavyTop(l, [
        Offset(-10, y0 + 18),
        Offset(l.w * 0.22, y0 - 24),
        Offset(l.w * 0.45, y0 + 8),
        Offset(l.w * 0.66, y0 - 14),
        Offset(l.w * 0.88, y0 + 4),
        Offset(l.w + 10, y0 - 6),
      ]),
      t.far,
    );
    _lollipopTree(canvas, Offset(l.w * 0.24, y0 - 18), 0.9, t.mid);
    _lollipopTree(canvas, Offset(l.w * 0.66, y0 - 8), 0.75, t.mid);
    final y1 = l.skyH + 16;
    _land(
      canvas,
      _wavyTop(l, [
        Offset(-10, y1 - 6),
        Offset(l.w * 0.3, y1 - 26),
        Offset(l.w * 0.55, y1 + 4),
        Offset(l.w * 0.8, y1 - 18),
        Offset(l.w + 10, y1 + 2),
      ]),
      t.mid,
    );
  }

  void _fence(Canvas canvas, SceneLayout l) {
    final bottom = l.groundTop + 6;
    final wood = Color.lerp(AppColors.bark, const Color(0xFFFFFFFF), 0.35)!;
    final woodLine = AppColors.barkDark.withValues(alpha: 0.75);
    for (final y in [bottom - 26, bottom - 12]) {
      final rail = RRect.fromLTRBR(-10, y, l.w + 10, y + 6, const Radius.circular(3));
      canvas
        ..drawRRect(rail, Sticker.solid(wood))
        ..drawRRect(rail, Sticker.outline(woodLine, width: 1.8));
    }
    for (var x = 6.0; x < l.w; x += 24) {
      final picket = Path()
        ..moveTo(x, bottom)
        ..lineTo(x, bottom - 30)
        ..quadraticBezierTo(x + 6.5, bottom - 40, x + 13, bottom - 30)
        ..lineTo(x + 13, bottom)
        ..close();
      Sticker.shape(canvas, picket, wood, woodLine, width: 1.8, lift: 0.3);
    }
    // Bushes with flowers in front of the fence
    final r = l.random(world, 5);
    final bushColor = Sticker.darken(t.mid, 0.08);
    for (var x = r.nextDouble() * 50; x < l.w; x += 110 + r.nextDouble() * 70) {
      final c = Offset(x, bottom - 4);
      final blob = Path()
        ..addOval(Rect.fromCircle(center: c.translate(-14, 0), radius: 13))
        ..addOval(Rect.fromCircle(center: c.translate(0, -8), radius: 16))
        ..addOval(Rect.fromCircle(center: c.translate(15, 0), radius: 12));
      canvas
        ..drawPath(blob, Sticker.outline(Sticker.darken(bushColor, 0.18), width: 4))
        ..drawPath(blob, Sticker.fill(blob.getBounds(), bushColor, lift: 0.25));
      for (var i = 0; i < 3; i++) {
        Sticker.flower(
          canvas,
          c.translate(-12 + i * 12.0, -6 - (i == 1 ? 8 : 0)),
          4.5,
          petal: i.isEven ? t.detail : t.detailAlt,
          petalOutline: Sticker.darken(i.isEven ? t.detail : t.detailAlt, 0.2),
          heart: const Color(0xFFFFFFFF),
          heartOutline: AppColors.border,
        );
      }
    }
  }

  void _flowers(Canvas canvas, SceneLayout l) {
    final pts = l.scatter(world, 7, spacing: 74, top: l.groundTop + 34);
    final colors = [t.detail, t.detailAlt, AppColors.card, AppColors.grape];
    for (var i = 0; i < pts.length; i++) {
      final c = colors[i % colors.length];
      canvas.drawLine(pts[i], pts[i].translate(0, 8), Sticker.stroke(Sticker.darken(t.near, 0.2), 2));
      Sticker.flower(
        canvas,
        pts[i],
        5.5,
        petal: c,
        petalOutline: c == AppColors.card ? AppColors.borderDeep : Sticker.darken(c, 0.2),
        rotation: i * 0.7,
      );
    }
  }

  // ---- Bukid (farm) ----

  void _mountains(Canvas canvas, SceneLayout l) {
    final s = l.skyH;
    // Peaks stay below the sun, even when parallax lifts them.
    _land(
      canvas,
      _wavyTop(l, [
        Offset(-10, s * 0.86),
        Offset(l.w * 0.16, s * 0.56),
        Offset(l.w * 0.34, s * 0.8),
        Offset(l.w * 0.54, s * 0.5),
        Offset(l.w * 0.76, s * 0.78),
        Offset(l.w * 0.95, s * 0.66),
        Offset(l.w + 10, s * 0.74),
      ]),
      t.far,
    );
  }

  void _terraces(Canvas canvas, SceneLayout l) {
    final top = l.skyH - 8;
    final bottom = l.groundTop + 8;
    const bands = 5;
    final colors = [t.mid, Color.lerp(t.mid, t.near, 0.55)!, Sticker.darken(t.mid, 0.04), t.nearLight, t.mid];
    for (var i = 0; i < bands; i++) {
      final y = top + (bottom - top) * i / bands;
      final band = _wavyTop(l, [
        for (var k = 0; k <= 5; k++) Offset(-10 + (l.w + 20) * k / 5, y + math.sin(k * 1.3 + i * 0.9) * 7),
      ]);
      _land(canvas, band, colors[i]);
      if (i == 1) _nipaHut(canvas, Offset(l.w * 0.2, y + 6));
    }
  }

  void _nipaHut(Canvas canvas, Offset base) {
    final stilt = Sticker.stroke(AppColors.barkDark, 3);
    canvas
      ..drawLine(base.translate(-13, 0), base.translate(-13, -10), stilt)
      ..drawLine(base.translate(13, 0), base.translate(13, -10), stilt);
    final body = RRect.fromLTRBR(base.dx - 17, base.dy - 28, base.dx + 17, base.dy - 9, const Radius.circular(3));
    canvas
      ..drawRRect(body, Sticker.fill(body.outerRect, Color.lerp(AppColors.bark, const Color(0xFFFFFFFF), 0.4)!))
      ..drawRRect(body, Sticker.outline(AppColors.barkDark, width: 2))
      ..drawRRect(
        RRect.fromLTRBR(base.dx - 4, base.dy - 22, base.dx + 5, base.dy - 9, const Radius.circular(2)),
        Sticker.solid(AppColors.barkDark),
      );
    final roof = Path()
      ..moveTo(base.dx - 25, base.dy - 26)
      ..quadraticBezierTo(base.dx, base.dy - 56, base.dx + 25, base.dy - 26)
      ..close();
    Sticker.shape(canvas, roof, t.detail, Sticker.darken(t.detail, 0.25), width: 2);
  }

  void _paddyRows(Canvas canvas, SceneLayout l) {
    final water = Sticker.stroke(AppColors.skyLight.withValues(alpha: 0.75), 3);
    final edge = Sticker.stroke(Sticker.darken(t.near, 0.1), 1.5);
    for (var y = l.groundTop + 40; y < l.h; y += 46) {
      final row = Path()..moveTo(-10, y);
      for (var x = 0.0; x <= l.w + 20; x += 40) {
        row.quadraticBezierTo(x + 10, y + math.sin(x / 50 + y) * 3, x + 20, y);
      }
      canvas
        ..drawPath(row, water)
        ..drawPath(row.shift(const Offset(0, 3)), edge);
    }
  }

  // ---- Kalikasan (nature) ----

  void _canopy(Canvas canvas, SceneLayout l) {
    for (final (row, color, dy) in [(0, t.far, 0.9), (1, Color.lerp(t.far, t.mid, 0.5)!, 1.06)]) {
      final r = l.random(world, 20 + row);
      final crowns = Path();
      final y = l.skyH * dy;
      for (var x = -20.0; x < l.w + 40; x += 30 + r.nextDouble() * 14) {
        crowns.addOval(Rect.fromCircle(center: Offset(x, y + r.nextDouble() * 12), radius: 24 + r.nextDouble() * 16));
      }
      crowns.addRect(Rect.fromLTRB(-20, y, l.w + 20, l.h));
      canvas
        ..drawPath(crowns, Sticker.outline(Sticker.darken(color, 0.15), width: 5))
        ..drawPath(crowns, Sticker.fill(Rect.fromLTRB(0, y - 40, l.w, y + 60), color, lift: 0.18));
    }
  }

  void _mangroves(Canvas canvas, SceneLayout l) {
    final base = l.groundTop - 6;
    final r = l.random(world, 9);
    // Shallow lagoon water the mangroves stand in; the river flows out of it.
    final lagoon = RRect.fromLTRBR(-20, base - 16, l.w + 20, base + 14, const Radius.circular(14));
    canvas
      ..drawRRect(
        lagoon,
        Paint()
          ..shader = ui.Gradient.linear(lagoon.outerRect.topCenter, lagoon.outerRect.bottomCenter, [
            t.detailAlt,
            t.detail,
          ]),
      )
      ..drawRRect(lagoon, Sticker.outline(AppColors.tealDark, width: 2.5));
    final root = Sticker.stroke(AppColors.barkDark, 3.2);
    final rootLight = Sticker.stroke(AppColors.bark, 1.6);
    for (var x = 30 + r.nextDouble() * 30; x < l.w; x += 95 + r.nextDouble() * 40) {
      final trunkTop = Offset(x, base - 30);
      // Arching prop roots: the mangrove's "legs"
      for (var k = -2; k <= 2; k++) {
        final foot = Offset(x + k * 9.0, base + 4);
        final root0 = Path()
          ..moveTo(x + k * 2.0, base - 18)
          ..quadraticBezierTo(x + k * 10.0, base - 16, foot.dx, foot.dy);
        canvas
          ..drawPath(root0, root)
          ..drawPath(root0, rootLight);
      }
      canvas
        ..drawLine(Offset(x, base - 16), trunkTop, Sticker.stroke(AppColors.barkDark, 6))
        ..drawLine(Offset(x, base - 16), trunkTop, Sticker.stroke(AppColors.bark, 3.4));
      final crown = Path()
        ..addOval(Rect.fromCircle(center: trunkTop.translate(-14, -4), radius: 16))
        ..addOval(Rect.fromCircle(center: trunkTop.translate(0, -16), radius: 19))
        ..addOval(Rect.fromCircle(center: trunkTop.translate(15, -4), radius: 15));
      canvas
        ..drawPath(crown, Sticker.outline(Sticker.darken(t.mid, 0.2), width: 4))
        ..drawPath(crown, Sticker.fill(crown.getBounds(), t.mid, lift: 0.28));
    }
  }

  void _river(Canvas canvas, SceneLayout l) {
    final left = <Offset>[];
    final right = <Offset>[];
    for (var y = l.groundTop - 2; y <= l.h + 20; y += 12) {
      final cx = riverX(l, y);
      final wobble = riverWidth / 2 + math.sin(y / 60) * 6;
      left.add(Offset(cx - wobble, y));
      right.add(Offset(cx + wobble, y));
    }
    final path = Path()..addPolygon([...left, ...right.reversed], true);
    final bounds = path.getBounds();
    canvas
      ..drawPath(
        path,
        Paint()..shader = ui.Gradient.linear(bounds.topCenter, bounds.bottomCenter, [t.detailAlt, t.detail]),
      )
      ..drawPath(path, Sticker.outline(AppColors.tealDark, width: 2.5));
    // A lighter current down the middle
    final current = Path()..moveTo(riverX(l, l.groundTop), l.groundTop);
    for (var y = l.groundTop; y <= l.h; y += 12) {
      current.lineTo(riverX(l, y) - 6, y);
    }
    canvas.drawPath(current, Sticker.stroke(const Color(0xFFFFFFFF).withValues(alpha: 0.22), 10));
  }

  void _ferns(Canvas canvas, SceneLayout l) {
    final pts = l.scatter(world, 13, spacing: 96, top: l.groundTop + 40);
    final leaf = Sticker.darken(t.mid, 0.02);
    for (final p in pts) {
      if ((p.dx - riverX(l, p.dy)).abs() < riverWidth) continue; // keep ferns out of the water
      // A pako frond: an arching stem with little leaflets
      for (final side in [-1.0, 1.0]) {
        final tip = p.translate(side * 20, -22);
        final stem = Path()
          ..moveTo(p.dx, p.dy)
          ..quadraticBezierTo(p.dx + side * 4, p.dy - 22, tip.dx, tip.dy);
        canvas.drawPath(stem, Sticker.stroke(Sticker.darken(leaf, 0.25), 2));
        for (var i = 1; i <= 4; i++) {
          final f = i / 5;
          final at = Offset(p.dx + (tip.dx - p.dx) * f * f + side * 4 * f, p.dy + (tip.dy - p.dy) * math.sqrt(f));
          final size = 9 - i * 1.2;
          Sticker.leaf(canvas, at, side * 0.4 - 0.9, size, size * 0.4, color: leaf, vein: false);
          Sticker.leaf(canvas, at, side * 0.4 + 0.9, size, size * 0.4, color: leaf, vein: false);
        }
      }
    }
  }

  @override
  bool shouldRepaint(LandPainter old) => old.world != world || old.layer != layer;
}
