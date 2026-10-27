import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';
import 'plant_drawing.dart';

const _g = PlantDrawing.ground;

/// Narra: the national tree. A wide umbrella crown dotted with yellow
/// flowers, on a trunk that flares out at the base.
class NarraDrawing extends PlantDrawing {
  const NarraDrawing();

  @override
  double get thumbnailTop => 26;

  static const _clusters = [
    Offset(46, 92),
    Offset(78, 62),
    Offset(124, 58),
    Offset(158, 88),
    Offset(100, 90),
    Offset(132, 110),
  ];

  @override
  void roots(Canvas c) {
    for (final (dx, depth) in const [(-60.0, 26.0), (-30.0, 44.0), (0.0, 56.0), (32.0, 42.0), (62.0, 24.0)]) {
      K.stroke(
        c,
        K.curve(Offset(100 + dx * 0.2, _g), Offset(100 + dx * 0.7, _g + depth * 0.3), Offset(100 + dx, _g + depth)),
        dx == 0 ? 6 : 4,
        K.rootFill,
        edge: AppColors.barkDark,
      );
    }
  }

  @override
  void body(Canvas c) {
    final trunk = Path()
      ..moveTo(74, _g)
      ..quadraticBezierTo(92, 186, 93, 150)
      ..lineTo(94, 112)
      ..lineTo(106, 112)
      ..lineTo(107, 150)
      ..quadraticBezierTo(108, 186, 126, _g)
      ..close();
    Sticker.shape(c, trunk, AppColors.bark, AppColors.barkDark, width: 2.5);
    K.wood(c, K.curve(const Offset(98, 124), const Offset(76, 110), const Offset(58, 104)), 5);
    K.wood(c, K.curve(const Offset(102, 122), const Offset(126, 108), const Offset(146, 104)), 5);
    K.blob(c, const [
      (Offset(100, 76), 38),
      (Offset(56, 88), 30),
      (Offset(144, 86), 30),
      (Offset(24, 100), 18),
      (Offset(176, 98), 18),
      (Offset(78, 58), 26),
      (Offset(124, 56), 26),
    ], AppColors.foliage);
    final r = math.Random(11);
    for (final p in _clusters) {
      for (var i = 0; i < 7; i++) {
        final o = p.translate((r.nextDouble() - 0.5) * 16, (r.nextDouble() - 0.5) * 12);
        K.fruit(c, o, 3.6, AppColors.narraYellow);
      }
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([for (final p in _clusters) K.circle(p, 14)]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 118)], 18),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(2, 30, 198, 124)),
    PlantPart.root: K.belowGround(),
  };
}

/// Kawayan: a clump of tall, jointed bamboo poles with leafy sprays and a
/// young shoot (labong) poking out of the ground.
class KawayanDrawing extends PlantDrawing {
  const KawayanDrawing();

  @override
  double get thumbnailTop => 10;

  static const _poles = [(78.0, 46.0, -0.05), (96.0, 24.0, 0.0), (114.0, 36.0, 0.04), (130.0, 60.0, 0.08)];
  static const _shoot = Offset(152, _g);

  @override
  void roots(Canvas c) {
    // An underground stem (rhizome) with roots hanging from it
    K.stroke(
      c,
      K.curve(const Offset(70, _g + 12), const Offset(110, _g + 20), const Offset(156, _g + 10)),
      6,
      AppColors.bark,
    );
    for (var x = 74.0; x < 156; x += 12) {
      K.stroke(
        c,
        K.curve(Offset(x, _g + 16), Offset(x - 4, _g + 30), Offset(x + 2, _g + 44)),
        1.6,
        K.rootFill,
        edge: AppColors.barkDark,
      );
    }
  }

  @override
  void body(Canvas c) {
    for (final (x, top, lean) in _poles) {
      c
        ..save()
        ..translate(x, _g)
        ..rotate(lean);
      final h = _g - top;
      final pole = RRect.fromLTRBR(-5.5, -h, 5.5, 0, const Radius.circular(5));
      c
        ..drawRRect(pole, Sticker.fill(pole.outerRect, AppColors.bamboo, lift: 0.25))
        ..drawRRect(pole, Sticker.outline(AppColors.bambooDark, width: 2));
      for (var y = -24.0; y > -h + 6; y -= 26) {
        c.drawLine(Offset(-6, y), Offset(6, y), Sticker.stroke(AppColors.bambooDark, 2.6));
      }
      c.restore();
    }
    // Leaf sprays near the tops
    for (final (x, top, lean) in _poles) {
      final tip = Offset(x + math.sin(lean) * (_g - top), top + 10);
      for (final side in [-1.0, 1.0]) {
        final twig = tip.translate(side * 16, 6);
        c.drawLine(tip.translate(0, 10), twig, Sticker.stroke(AppColors.bambooDark, 1.6));
        for (final a in [-0.5, 0.0, 0.5]) {
          K.leaf(c, twig, side * 1.1 + a, 22, 5);
        }
      }
    }
    // Young shoot: a cone of brown-gold sheaths
    final shoot = Path()
      ..moveTo(_shoot.dx - 11, _g)
      ..quadraticBezierTo(_shoot.dx - 8, _g - 22, _shoot.dx, _g - 34)
      ..quadraticBezierTo(_shoot.dx + 8, _g - 22, _shoot.dx + 11, _g)
      ..close();
    Sticker.shape(c, shoot, Color.lerp(AppColors.bark, AppColors.sunshine, 0.35)!, AppColors.barkDark, width: 2);
    for (var i = 1; i <= 3; i++) {
      final y = _g - i * 9.0;
      c.drawLine(
        Offset(_shoot.dx - 9 + i * 2, y),
        Offset(_shoot.dx + 4, y - 5),
        Sticker.stroke(AppColors.barkDark.withValues(alpha: 0.6), 1.4),
      );
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.oval(Rect.fromCenter(center: _shoot.translate(0, -16), width: 40, height: 46)),
    PlantPart.stem: K.union([
      for (final (x, top, _) in _poles) K.capsule([Offset(x, _g), Offset(x, top + 40)], 9),
    ]),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(40, 10, 172, 90)),
    PlantPart.root: K.belowGround(),
  };
}

/// Pako: an edible fern with arching fronds, a curled fiddlehead, and
/// brown spore dots under one frond.
class PakoDrawing extends PlantDrawing {
  const PakoDrawing();

  @override
  double get thumbnailTop => 30;

  static const _fronds = [(-1.0, 80.0), (-0.6, 96.0), (-0.2, 108.0), (0.2, 104.0), (0.6, 94.0), (1.0, 80.0)];

  /// The frond that shows its spores.
  static const _sporeFrond = 4;

  @override
  void roots(Canvas c) => K.fibrous(c, count: 12, depth: 38, spread: 36);

  Path _rib(double angle, double length) {
    final dir = Offset(math.sin(angle), -math.cos(angle));
    final end = const Offset(100, _g) + dir * length;
    // Fronds rise, then their tips nod over a little.
    final droop = Offset(dir.dx * 14, 14);
    return K.curve(
      const Offset(100, _g),
      const Offset(100, _g) + dir * length * 0.65 - const Offset(0, 40),
      end + droop,
    );
  }

  @override
  void body(Canvas c) {
    for (final (i, (angle, length)) in _fronds.indexed) {
      final rib = _rib(angle, length);
      c.drawPath(rib, Sticker.stroke(AppColors.foliageDark, 2.4));
      final metric = rib.computeMetrics().first;
      for (var d = 14.0; d < metric.length - 2; d += 8) {
        final t = metric.getTangentForOffset(d)!;
        final dirAngle = math.atan2(t.vector.dx, -t.vector.dy);
        final size = 15 * (1 - d / metric.length * 0.55);
        K.leaf(c, t.position, dirAngle - 1.1, size, size * 0.38);
        K.leaf(c, t.position, dirAngle + 1.1, size, size * 0.38);
        if (i == _sporeFrond) {
          // Spores: rows of brown dots on the leaflets
          for (final s in [-1.0, 1.0]) {
            final n = Offset(-t.vector.dy, t.vector.dx) * s;
            for (var k = 1; k <= 2; k++) {
              c.drawCircle(t.position + n * (size * 0.3 * k), 1.5, Sticker.solid(AppColors.barkDark));
            }
          }
        }
      }
    }
    // Fiddlehead: a young frond still curled up
    final curl = Path()..moveTo(100, _g);
    curl.quadraticBezierTo(98, _g - 30, 104, _g - 46);
    // Spiral inward around (113, ground − 46), starting at its left edge.
    const center = Offset(113, _g - 46);
    for (var a = 0.0; a < math.pi * 2.6; a += 0.3) {
      final r = 9 * (1 - a / (math.pi * 3));
      curl.lineTo(center.dx + math.cos(math.pi - a) * r, center.dy - math.sin(math.pi - a) * r);
    }
    K.green(c, curl, 3);
  }

  @override
  Map<PlantPart, Path> regions() {
    final (angle, length) = _fronds[_sporeFrond];
    final metric = _rib(angle, length).computeMetrics().first;
    final along = [for (var f = 0.4; f <= 1.0; f += 0.15) metric.getTangentForOffset(metric.length * f)!.position];
    return {
      PlantPart.special: K.capsule(along, 16),
      PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 150)], 13),
      PlantPart.leaf: K.oval(const Rect.fromLTRB(14, 70, 186, 196)),
      PlantPart.root: K.belowGround(),
    };
  }
}

/// Bakawan: a mangrove on arching stilt roots in the water, with long
/// pencil-like seedlings hanging from its branches.
class BakawanDrawing extends PlantDrawing {
  const BakawanDrawing();

  @override
  double get thumbnailTop => 26;

  static const _water = _g - 30;
  static const _seedlings = [(Offset(66, 110), 44.0), (Offset(126, 104), 50.0), (Offset(146, 118), 38.0)];

  @override
  bool get inWater => true;

  @override
  void roots(Canvas c) {
    for (var k = -3; k <= 3; k++) {
      final start = Offset(100 + k * 2.5, 140);
      final foot = Offset(100 + k * 15.0, _g + 10);
      final root = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx + k * 8, start.dy - 4, foot.dx + k * 2, _water - 26, foot.dx, foot.dy);
      K.wood(c, root, 3.2);
    }
  }

  @override
  void body(Canvas c) {
    K.wood(c, K.curve(const Offset(100, 146), const Offset(97, 126), const Offset(100, 98)), 9);
    K.wood(c, K.curve(const Offset(100, 112), const Offset(80, 104), const Offset(68, 98)), 4);
    K.wood(c, K.curve(const Offset(100, 108), const Offset(122, 100), const Offset(136, 96)), 4);
    K.blob(c, const [
      (Offset(100, 74), 36),
      (Offset(62, 86), 26),
      (Offset(140, 84), 26),
      (Offset(80, 56), 22),
      (Offset(122, 54), 22),
    ], AppColors.foliageDark);
    final r = math.Random(5);
    for (var i = 0; i < 12; i++) {
      final at = Offset(50 + r.nextDouble() * 100, 46 + r.nextDouble() * 50);
      K.leaf(c, at, -0.8 + r.nextDouble() * 1.6, 14, 7, color: AppColors.foliage);
    }
    for (final (top, len) in _seedlings) {
      final body = K.line(top, top.translate(1, len));
      c
        ..drawPath(body, Sticker.stroke(AppColors.podGreen, 6))
        ..drawPath(body, Sticker.stroke(AppColors.leaf, 3.4))
        ..drawCircle(top.translate(1, len), 3, Sticker.solid(AppColors.barkDark));
    }
  }

  @override
  List<PlantPart> get hitOrder => const [PlantPart.special, PlantPart.root, PlantPart.stem, PlantPart.leaf];

  @override
  Path glowZone(PlantPart part) =>
      part == PlantPart.root ? K.oval(const Rect.fromLTRB(46, 134, 154, 214)) : super.glowZone(part);

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([
      for (final (top, len) in _seedlings) K.capsule([top, top.translate(1, len)], 10),
    ]),
    PlantPart.root: K.union([K.oval(const Rect.fromLTRB(46, 136, 154, 204)), K.belowGround()]),
    PlantPart.stem: K.capsule([const Offset(100, 146), const Offset(100, 100)], 13),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(28, 32, 172, 112)),
  };
}

/// Kangkong: water spinach. Hollow stems creep over the water with
/// arrow-shaped leaves and pale trumpet flowers.
class KangkongDrawing extends PlantDrawing {
  const KangkongDrawing();

  @override
  double get thumbnailTop => 8;

  static const _water = _g - 30;
  static const _nodes = [
    Offset(36, _water + 2),
    Offset(72, _water - 2),
    Offset(108, _water + 1),
    Offset(146, _water - 3),
  ];
  static const _flowers = [Offset(86, 120), Offset(150, 128)];

  @override
  Path glowZone(PlantPart part) =>
      part == PlantPart.root ? K.oval(const Rect.fromLTRB(16, _water - 4, 184, _water + 42)) : super.glowZone(part);

  @override
  bool get inWater => true;

  @override
  void roots(Canvas c) {
    final root = Color.lerp(K.rootFill, const Color(0xFFFFFFFF), 0.4)!;
    for (final n in _nodes) {
      for (final dx in [-5.0, 0.0, 5.0]) {
        K.stroke(
          c,
          K.curve(n, n.translate(dx * 1.5, 18), n.translate(dx * 2.5, 34)),
          1.4,
          root,
          edge: AppColors.barkDark,
        );
      }
    }
  }

  void _arrowLeaf(Canvas c, Offset at, double angle, double l) {
    c
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(angle);
    final w = l * 0.62;
    final leaf = Path()
      ..moveTo(0, -l)
      ..cubicTo(w * 0.7, -l * 0.6, w * 0.95, -l * 0.15, w * 0.85, l * 0.18)
      ..lineTo(0, -l * 0.05)
      ..lineTo(-w * 0.85, l * 0.18)
      ..cubicTo(-w * 0.95, -l * 0.15, -w * 0.7, -l * 0.6, 0, -l)
      ..close();
    Sticker.shape(c, leaf, AppColors.foliage, AppColors.foliageDark, width: 2);
    c
      ..drawLine(
        Offset(0, -l * 0.08),
        Offset(0, -l * 0.85),
        Sticker.stroke(AppColors.foliageDark.withValues(alpha: 0.5), 1.3),
      )
      ..restore();
  }

  @override
  void body(Canvas c) {
    final runner = Path()..moveTo(14, _water + 4);
    for (final n in _nodes) {
      runner.quadraticBezierTo(n.dx - 14, n.dy - 6, n.dx, n.dy);
    }
    runner.quadraticBezierTo(170, _water - 8, 188, _water - 2);
    K.green(c, runner, 5);
    const leaves = [
      (Offset(36, _water + 2), -0.3, 34.0, 38.0),
      (Offset(72, _water - 2), 0.25, 46.0, 44.0),
      (Offset(108, _water + 1), -0.2, 54.0, 44.0),
      (Offset(146, _water - 3), 0.3, 36.0, 40.0),
      (Offset(124, _water - 1), 0.05, 24.0, 32.0),
    ];
    for (final (n, lean, stalk, size) in leaves) {
      final top = n.translate(math.sin(lean) * stalk, -stalk);
      K.green(c, K.curve(n, n.translate(0, -stalk * 0.6), top), 2.4);
      _arrowLeaf(c, top, lean, size);
    }
    for (final f in _flowers) {
      K.green(c, K.curve(Offset(f.dx - 10, _water), Offset(f.dx - 8, f.dy + 20), f.translate(0, 10)), 2);
      final trumpet = Path()
        ..moveTo(f.dx - 4, f.dy + 12)
        ..lineTo(f.dx - 13, f.dy - 4)
        ..quadraticBezierTo(f.dx, f.dy - 12, f.dx + 13, f.dy - 4)
        ..lineTo(f.dx + 4, f.dy + 12)
        ..close();
      Sticker.shape(c, trumpet, AppColors.card, AppColors.borderDeep, width: 1.8, lift: 0);
      c.drawOval(
        Rect.fromCenter(center: f.translate(0, -3), width: 14, height: 6),
        Sticker.solid(AppColors.kangkongPink),
      );
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([for (final f in _flowers) K.circle(f, 16)]),
    PlantPart.stem: K.capsule([const Offset(12, _water + 2), ..._nodes, const Offset(188, _water - 2)], 11),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(4, 70, 196, _water - 8)),
    PlantPart.root: K.belowGround(top: _water + 8),
  };
}
