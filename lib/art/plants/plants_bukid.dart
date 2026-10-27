import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';
import 'plant_drawing.dart';

const _g = PlantDrawing.ground;

/// Palay: a clump of long grass blades with drooping heads of golden grain.
class PalayDrawing extends PlantDrawing {
  const PalayDrawing();

  @override
  double get thumbnailTop => 8;

  static const _stalks = [(Offset(88, 72), -1.0), (Offset(104, 60), 1.0), (Offset(120, 76), 1.0)];

  @override
  void roots(Canvas c) => K.fibrous(c, count: 13, depth: 44, spread: 40);

  @override
  void body(Canvas c) {
    for (final a in [-0.75, -0.5, -0.25, 0.25, 0.5, 0.75]) {
      K.leaf(c, const Offset(100, _g), a, 104 - a.abs() * 30, 5.5);
    }
    for (final (top, side) in _stalks) {
      K.green(c, K.curve(const Offset(100, _g), Offset(top.dx - side * 4, 140), top), 2.4);
    }
    for (final (top, side) in _stalks) {
      // Grain head bending over to one side
      final head = K.curve(top, top.translate(side * 20, -6), top.translate(side * 26, 34));
      c.drawPath(head, Sticker.stroke(AppColors.sunshineDark, 1.8));
      final metric = head.computeMetrics().first;
      for (var d = 4.0; d < metric.length; d += 5.5) {
        final t = metric.getTangentForOffset(d)!;
        final n = Offset(-t.vector.dy, t.vector.dx);
        for (final s in [-1.0, 1.0]) {
          final rect = Rect.fromCenter(center: t.position + n * s * 3.4, width: 4.6, height: 6.4);
          c
            ..drawOval(rect, Sticker.solid(AppColors.riceGold))
            ..drawOval(rect, Sticker.outline(AppColors.sunshineDark, width: 1));
        }
      }
    }
    K.leaf(c, const Offset(100, _g), -0.08, 112, 5, color: AppColors.foliageDark);
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([
      for (final (top, side) in _stalks)
        K.capsule([top, top.translate(side * 22, 4), top.translate(side * 26, 34)], 12),
    ]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 130)], 12),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(20, 100, 180, 200)),
    PlantPart.root: K.belowGround(),
  };
}

/// Mango: a big tree with a dome of long leaves and hanging mangoes.
class MangoDrawing extends PlantDrawing {
  const MangoDrawing();

  @override
  double get thumbnailTop => 24;

  static const _mangoes = [Offset(66, 138), Offset(116, 146), Offset(146, 126)];

  @override
  void roots(Canvas c) => K.taproot(c, depth: 58, thickness: 9);

  @override
  void body(Canvas c) {
    K.wood(c, K.curve(const Offset(100, _g), const Offset(94, 170), const Offset(100, 120)), 13);
    K.wood(c, K.curve(const Offset(99, 140), const Offset(80, 128), const Offset(70, 112)), 6);
    K.wood(c, K.curve(const Offset(101, 136), const Offset(122, 124), const Offset(132, 108)), 6);
    K.blob(c, const [
      (Offset(100, 84), 48),
      (Offset(56, 100), 32),
      (Offset(144, 98), 32),
      (Offset(74, 62), 30),
      (Offset(128, 60), 30),
      (Offset(100, 116), 28),
    ], AppColors.foliageDark);
    final r = math.Random(7);
    for (var i = 0; i < 14; i++) {
      final at = Offset(36 + r.nextDouble() * 128, 46 + r.nextDouble() * 76);
      K.leaf(c, at, -0.6 + r.nextDouble() * 1.2, 18, 5, color: AppColors.foliage);
    }
    for (final m in _mangoes) {
      c.drawLine(m.translate(0, -16), m.translate(0, -8), Sticker.stroke(AppColors.barkDark, 2));
      c
        ..save()
        ..translate(m.dx, m.dy)
        ..rotate(0.35);
      final body = Path()
        ..moveTo(0, -11)
        ..cubicTo(11, -11, 12, 8, 2, 13)
        ..cubicTo(-9, 16, -11, 0, -6, -6)
        ..close();
      c.drawPath(body, Sticker.fill(body.getBounds(), AppColors.mangoYellow, lift: 0.3));
      if (!Sticker.lineArt) {
        c.drawPath(
          body,
          Paint()
            ..shader = RadialGradient(
              colors: [AppColors.mangoOrange.withValues(alpha: 0.85), AppColors.mangoOrange.withValues(alpha: 0)],
            ).createShader(Rect.fromCircle(center: const Offset(4, 8), radius: 12)),
        );
      }
      c
        ..drawPath(body, Sticker.outline(Sticker.darken(AppColors.mangoOrange, 0.25), width: 1.8))
        ..restore();
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([for (final m in _mangoes) K.circle(m, 16)]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 128)], 15),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(20, 30, 180, 140)),
    PlantPart.root: K.belowGround(),
  };
}

/// Saba: a banana plant with huge paddle leaves, a bunch and a purple heart.
class SabaDrawing extends PlantDrawing {
  const SabaDrawing();

  @override
  double get thumbnailTop => 10;

  @override
  void roots(Canvas c) {
    final corm = Rect.fromCenter(center: const Offset(100, _g + 10), width: 40, height: 22);
    K.fibrous(c, count: 11, depth: 48, spread: 46);
    c
      ..drawOval(corm, Sticker.fill(corm, AppColors.bark, lift: 0.3))
      ..drawOval(corm, Sticker.outline(AppColors.barkDark, width: 2));
  }

  void _paddle(Canvas c, Offset base, double angle, double length) {
    K.leaf(c, base, angle, length, 22, color: AppColors.foliage);
    // Little tears in the leaf edge, like real banana leaves
    c
      ..save()
      ..translate(base.dx, base.dy)
      ..rotate(angle);
    final cut = Sticker.stroke(AppColors.foliageDark, 1.4);
    for (var i = 0; i < 3; i++) {
      final y = -length * (0.35 + i * 0.18);
      c.drawLine(Offset(4, y), Offset(15, y + 6), cut);
    }
    c.restore();
  }

  @override
  void body(Canvas c) {
    final stem = Path()
      ..moveTo(86, _g)
      ..lineTo(92, 108)
      ..quadraticBezierTo(100, 102, 108, 108)
      ..lineTo(114, _g)
      ..close();
    Sticker.shape(c, stem, Color.lerp(AppColors.leaf, AppColors.bark, 0.35)!, AppColors.barkDark, width: 2.5);
    for (final x in [96.0, 104.0]) {
      c.drawLine(
        Offset(x, 190),
        Offset(x + (x - 100) * 0.2, 116),
        Sticker.stroke(AppColors.barkDark.withValues(alpha: 0.3), 1.5),
      );
    }
    _paddle(c, const Offset(100, 110), -1.25, 88);
    _paddle(c, const Offset(100, 108), -0.45, 84);
    _paddle(c, const Offset(100, 108), 0.5, 82);
    // Bunch stalk, bananas and the purple heart (puso)
    K.green(c, K.curve(const Offset(104, 112), const Offset(128, 116), const Offset(136, 168)), 3);
    for (var row = 0; row < 3; row++) {
      for (var i = 0; i < 4; i++) {
        final base = Offset(124 + i * 5.0, 128 + row * 11.0);
        final banana = K.curve(base, base.translate(-10, 4), base.translate(-14, -6));
        c
          ..drawPath(banana, Sticker.stroke(Sticker.darken(AppColors.bananaYellow, 0.35), 7.5))
          ..drawPath(banana, Sticker.stroke(AppColors.bananaYellow, 5));
      }
    }
    final heart = Path()
      ..moveTo(136, 160)
      ..quadraticBezierTo(146, 172, 137, 186)
      ..quadraticBezierTo(128, 172, 136, 160)
      ..close();
    Sticker.shape(c, heart, AppColors.bananaHeart, Sticker.darken(AppColors.bananaHeart, 0.3), width: 2);
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([K.oval(const Rect.fromLTRB(104, 116, 152, 192))]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 112)], 16),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(10, 14, 190, 120)),
    PlantPart.root: K.belowGround(),
  };
}

/// Mongo: a small bushy plant with three-part leaves and slim dark pods.
class MongoDrawing extends PlantDrawing {
  const MongoDrawing();

  @override
  double get thumbnailTop => 60;

  static const _pods = [Offset(76, 128), Offset(126, 120), Offset(104, 102)];

  @override
  void roots(Canvas c) {
    K.taproot(c, depth: 48, thickness: 4.5);
    // Little nodules on the roots (they help feed the soil)
    for (final p in const [Offset(88, 214), Offset(114, 222), Offset(94, 232), Offset(110, 208)]) {
      K.fruit(c, p, 2.6, Color.lerp(AppColors.bark, const Color(0xFFFFFFFF), 0.25)!);
    }
  }

  void _trifoliate(Canvas c, Offset at, double angle) {
    c
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(angle);
    c.drawLine(Offset.zero, const Offset(0, -10), Sticker.stroke(AppColors.leafDark, 1.6));
    K.leaf(c, const Offset(0, -10), 0, 22, 9);
    K.leaf(c, const Offset(0, -10), -1.2, 18, 8);
    K.leaf(c, const Offset(0, -10), 1.2, 18, 8);
    c.restore();
  }

  @override
  void body(Canvas c) {
    K.green(c, K.curve(const Offset(100, _g), const Offset(96, 150), const Offset(100, 100)), 3.6);
    K.green(c, K.curve(const Offset(99, 160), const Offset(80, 150), const Offset(72, 132)), 2.4);
    K.green(c, K.curve(const Offset(100, 150), const Offset(120, 140), const Offset(128, 124)), 2.4);
    const leaves = [
      (Offset(100, 102), 0.0),
      (Offset(72, 134), -0.7),
      (Offset(128, 126), 0.7),
      (Offset(97, 170), -1.2),
      (Offset(102, 158), 1.2),
      (Offset(86, 146), -0.4),
    ];
    for (final (at, a) in leaves) {
      _trifoliate(c, at, a);
    }
    for (final p in _pods) {
      for (var i = 0; i < 3; i++) {
        final start = p.translate(i * 4.0 - 4, 0);
        K.stroke(
          c,
          K.curve(start, start.translate(i * 3.0 - 3, 12), start.translate(i * 6.0 - 6, 26)),
          3.6,
          AppColors.podGreen,
        );
      }
    }
    for (final f in const [Offset(90, 112), Offset(116, 108)]) {
      Sticker.flower(
        c,
        f,
        5,
        petal: AppColors.sunshine,
        petalOutline: AppColors.sunshineDark,
        heart: AppColors.leafLight,
      );
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([
      for (final p in _pods) K.capsule([p, p.translate(0, 26)], 13),
    ]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 150)], 12),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(40, 70, 160, 190)),
    PlantPart.root: K.belowGround(),
  };
}

/// Niyog: a coconut palm with a tall ringed trunk, feather fronds and coconuts.
class NiyogDrawing extends PlantDrawing {
  const NiyogDrawing();

  @override
  double get thumbnailTop => 8;

  static const _crown = Offset(114, 56);
  static const _nuts = [Offset(106, 70), Offset(120, 72), Offset(113, 82)];

  @override
  void roots(Canvas c) => K.fibrous(c, count: 15, depth: 44, spread: 30);

  void _frond(Canvas c, double angle, double length) {
    c
      ..save()
      ..translate(_crown.dx, _crown.dy)
      ..rotate(angle);
    final rib = K.curve(Offset.zero, Offset(length * 0.5, -length * 0.25), Offset(length, length * 0.25));
    c.drawPath(rib, Sticker.stroke(AppColors.foliageDark, 3));
    final metric = rib.computeMetrics().first;
    for (var d = 8.0; d < metric.length; d += 5) {
      final t = metric.getTangentForOffset(d)!;
      final n = Offset(-t.vector.dy, t.vector.dx);
      final len = 15 * (1 - d / metric.length * 0.6);
      for (final s in [-1.0, 1.0]) {
        c.drawLine(t.position, t.position + n * s * len + t.vector * 6, Sticker.stroke(AppColors.foliage, 2.4));
      }
    }
    c.restore();
  }

  @override
  void body(Canvas c) {
    final trunk = Path()
      ..moveTo(92, _g)
      ..cubicTo(96, 140, 104, 100, 110, 58)
      ..lineTo(118, 58)
      ..cubicTo(112, 104, 108, 150, 110, _g)
      ..close();
    Sticker.shape(c, trunk, AppColors.palmTrunk, AppColors.barkDark, width: 2.5);
    final ring = Sticker.stroke(AppColors.barkDark.withValues(alpha: 0.45), 1.6);
    for (var y = 70.0; y < 196; y += 11) {
      // Trunk edges run from x 110–118 at the crown to 92–110 at the ground.
      final f = (y - 58) / (_g - 58);
      final left = 110 - f * 18;
      final right = 118 - f * 8;
      c.drawLine(Offset(left + 1.5, y), Offset(right - 1.5, y + 2), ring);
    }
    for (final (a, len) in const [
      (math.pi + 0.35, 66.0),
      (math.pi - 0.35, 60.0),
      (math.pi + 1.05, 50.0),
      (-0.35, 64.0),
      (0.35, 60.0),
      (-1.1, 48.0),
      (math.pi * 1.5, 40.0),
    ]) {
      _frond(c, a, len);
    }
    for (final n in _nuts) {
      K.fruit(c, n, 9, AppColors.coconutGreen);
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([for (final n in _nuts) K.circle(n, 14)]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(104, 140), const Offset(113, 90)], 14),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(28, 4, 196, 104)),
    PlantPart.root: K.belowGround(),
  };
}
