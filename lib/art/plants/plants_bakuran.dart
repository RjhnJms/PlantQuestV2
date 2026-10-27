import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';
import 'plant_drawing.dart';

const _g = PlantDrawing.ground;

/// Sampaguita: a bushy shrub with paired oval leaves and white star flowers.
class SampaguitaDrawing extends PlantDrawing {
  const SampaguitaDrawing();

  @override
  double get thumbnailTop => 50;

  static const _tips = [Offset(76, 96), Offset(100, 74), Offset(126, 94)];
  static const _flowers = [Offset(76, 90), Offset(100, 68), Offset(126, 88), Offset(88, 122), Offset(114, 116)];

  @override
  void roots(Canvas c) => K.fibrous(c, count: 7, depth: 40, spread: 34);

  @override
  void body(Canvas c) {
    for (final tip in _tips) {
      K.green(c, K.curve(const Offset(100, _g), Offset((100 + tip.dx) / 2, 150), tip), 3.4);
    }
    for (final tip in _tips) {
      for (var i = 1; i <= 4; i++) {
        final f = i / 5;
        final at = Offset.lerp(const Offset(100, _g - 20), tip, f)!;
        K.leaf(c, at, -1.15, 17, 7.5);
        K.leaf(c, at, 1.15, 17, 7.5);
      }
    }
    for (final (i, f) in _flowers.indexed) {
      Sticker.flower(
        c,
        f,
        i < 3 ? 11 : 9,
        petals: 6,
        petal: AppColors.card,
        petalOutline: AppColors.borderDeep,
        rotation: i * 0.4,
      );
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([for (final f in _flowers) K.circle(f, 15)]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 150)], 13),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(52, 70, 150, 182)),
    PlantPart.root: K.belowGround(),
  };
}

/// Gumamela: a woody shrub with broad leaves and a big red hibiscus.
class GumamelaDrawing extends PlantDrawing {
  const GumamelaDrawing();

  @override
  double get thumbnailTop => 40;

  static const _flower = Offset(114, 80);

  @override
  void roots(Canvas c) => K.taproot(c, depth: 52);

  @override
  void body(Canvas c) {
    K.wood(c, K.curve(const Offset(100, _g), const Offset(98, 160), const Offset(100, 124)), 6);
    K.wood(c, K.curve(const Offset(100, 132), const Offset(84, 118), const Offset(72, 98)), 4);
    K.wood(c, K.curve(const Offset(100, 128), const Offset(112, 108), const Offset(116, 92)), 4);
    const leaves = [
      (Offset(100, 168), -1.3, 26.0),
      (Offset(100, 160), 1.25, 26.0),
      (Offset(92, 124), -1.1, 25.0),
      (Offset(80, 108), -0.6, 24.0),
      (Offset(72, 100), 0.4, 22.0),
      (Offset(106, 116), 1.2, 25.0),
      (Offset(110, 140), 1.4, 24.0),
      (Offset(96, 142), -1.45, 22.0),
    ];
    for (final (at, a, len) in leaves) {
      K.leaf(c, at, a, len, 12, color: AppColors.foliageDark);
    }
    // Bud
    final bud = Path()
      ..moveTo(72, 99)
      ..quadraticBezierTo(64, 88, 70, 80)
      ..quadraticBezierTo(78, 88, 72, 99);
    Sticker.shape(c, bud, AppColors.hibiscusRed, AppColors.hibiscusDark, width: 2);
    // Big hibiscus with its long center "tube"
    Sticker.flower(
      c,
      _flower,
      32,
      petal: AppColors.hibiscusRed,
      petalOutline: AppColors.hibiscusDark,
      heart: AppColors.hibiscusDark,
      heartOutline: AppColors.hibiscusDark,
      rotation: 0.2,
    );
    c.drawLine(_flower, _flower.translate(18, -24), Sticker.stroke(AppColors.sunshineDark, 3));
    for (var i = 0; i < 5; i++) {
      c.drawCircle(_flower.translate(13 + i * 1.5, -18 - i * 1.6), 2, Sticker.solid(AppColors.sunshine));
    }
    c.drawCircle(_flower.translate(19, -26), 3, Sticker.solid(AppColors.hibiscusDark));
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([K.circle(_flower, 36), K.circle(const Offset(70, 90), 12)]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 128), const Offset(76, 102)], 12),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(50, 90, 150, 190)),
    PlantPart.root: K.belowGround(),
  };
}

/// Makahiya: a low, spreading plant with feathery leaves and pink puffs.
class MakahiyaDrawing extends PlantDrawing {
  const MakahiyaDrawing();

  @override
  double get thumbnailTop => 48;

  static const _tips = [Offset(42, 150), Offset(100, 112), Offset(158, 146)];
  static const _puffs = [Offset(54, 134), Offset(106, 98), Offset(150, 128)];

  @override
  void roots(Canvas c) => K.taproot(c, depth: 46, thickness: 4.5);

  /// One feathery leaf. [fold] (0–1) closes its leaflets up against the
  /// middle and lets it droop, the way a real makahiya does when touched.
  void _feather(Canvas c, Offset base, double angle, double length, double fold) {
    c
      ..save()
      ..translate(base.dx, base.dy)
      ..rotate(angle * (1 + 0.45 * fold));
    c.drawLine(Offset.zero, Offset(0, -length), Sticker.stroke(AppColors.stemRed, 1.8));
    final open = 1.25 - 1.05 * fold;
    for (var i = 1; i <= 8; i++) {
      final y = -length * i / 9;
      K.leaf(c, Offset(0, y), -open, 8, 3.2);
      K.leaf(c, Offset(0, y), open, 8, 3.2);
    }
    c.restore();
  }

  @override
  void body(Canvas c) => bodyTouched(c, fold: 0);

  @override
  void bodyTouched(Canvas c, {required double fold}) {
    for (final tip in _tips) {
      K.stroke(c, K.curve(const Offset(100, _g), Offset((100 + tip.dx) / 2, tip.dy - 6), tip), 3, AppColors.stemRed);
    }
    const feathers = [
      (Offset(64, 160), -0.9),
      (Offset(48, 150), -0.3),
      (Offset(96, 132), -0.5),
      (Offset(102, 120), 0.45),
      (Offset(136, 158), 0.9),
      (Offset(154, 148), 0.3),
      (Offset(80, 178), -1.25),
      (Offset(122, 176), 1.25),
    ];
    for (final (at, a) in feathers) {
      _feather(c, at, a, 34, fold);
    }
    for (final p in _puffs) {
      for (var i = 0; i < 18; i++) {
        final a = i * math.pi / 9;
        final d = Offset(math.cos(a), math.sin(a));
        c
          ..drawLine(p, p + d * 10, Sticker.stroke(AppColors.bubblegumDark, 1.4))
          ..drawCircle(p + d * 10.5, 1.6, Sticker.solid(AppColors.bubblegum));
      }
      c.drawCircle(p, 4, Sticker.solid(AppColors.bubblegum));
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([for (final p in _puffs) K.circle(p, 16)]),
    PlantPart.stem: K.union([
      for (final tip in _tips)
        K.capsule([const Offset(100, _g - 4), Offset.lerp(const Offset(100, _g), tip, 0.6)!], 10),
    ]),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(20, 96, 180, 196)),
    PlantPart.root: K.belowGround(),
  };
}

/// Kalamansi: a small tree with a round crown and little green-orange fruits.
class KalamansiDrawing extends PlantDrawing {
  const KalamansiDrawing();

  @override
  double get thumbnailTop => 40;

  static const _fruits = [
    (Offset(74, 104), false),
    (Offset(98, 82), true),
    (Offset(126, 100), false),
    (Offset(112, 124), true),
    (Offset(84, 128), false),
    (Offset(136, 76), false),
  ];

  @override
  void roots(Canvas c) => K.taproot(c, depth: 54);

  @override
  void body(Canvas c) {
    K.wood(c, K.curve(const Offset(100, _g), const Offset(96, 172), const Offset(100, 140)), 8);
    K.wood(c, K.curve(const Offset(100, 150), const Offset(86, 140), const Offset(82, 128)), 4);
    K.blob(c, const [
      (Offset(100, 100), 44),
      (Offset(66, 110), 26),
      (Offset(134, 108), 26),
      (Offset(80, 76), 26),
      (Offset(122, 74), 26),
      (Offset(100, 132), 26),
    ], AppColors.foliageDark);
    // Small glossy leaves on the crown
    final r = math.Random(4);
    for (var i = 0; i < 16; i++) {
      final a = r.nextDouble() * math.pi * 2;
      final d = r.nextDouble() * 46;
      K.leaf(c, Offset(100 + math.cos(a) * d, 104 + math.sin(a) * d * 0.8), a, 11, 5, color: AppColors.foliage);
    }
    for (final (p, ripe) in _fruits) {
      K.fruit(c, p, 7, ripe ? AppColors.citrusOrange : AppColors.leaf);
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([for (final (p, _) in _fruits) K.circle(p, 13)]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(100, 146)], 13),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(36, 48, 164, 158)),
    PlantPart.root: K.belowGround(),
  };
}

/// Malunggay: a slim tree with lacy, tiny round leaves and long pods.
class MalunggayDrawing extends PlantDrawing {
  const MalunggayDrawing();

  @override
  double get thumbnailTop => 20;

  static const _pods = [
    (Offset(70, 116), Offset(64, 172)),
    (Offset(132, 108), Offset(140, 166)),
    (Offset(110, 98), Offset(114, 148)),
  ];

  @override
  void roots(Canvas c) => K.taproot(c, depth: 58, thickness: 7.5);

  void _sprig(Canvas c, Offset from, Offset ctrl, Offset to) {
    final path = K.curve(from, ctrl, to);
    c.drawPath(path, Sticker.stroke(AppColors.leafDark, 1.6));
    final metric = path.computeMetrics().first;
    for (var d = 8.0; d < metric.length; d += 7) {
      final t = metric.getTangentForOffset(d)!;
      final n = Offset(-t.vector.dy, t.vector.dx);
      for (final side in [-1.0, 1.0]) {
        final o = t.position + n * side * 5;
        final rect = Rect.fromCircle(center: o, radius: 3.4);
        c
          ..drawOval(rect, Sticker.solid(AppColors.leaf))
          ..drawOval(rect, Sticker.outline(AppColors.leafDark, width: 1));
      }
    }
  }

  @override
  void body(Canvas c) {
    final trunk = Color.lerp(AppColors.bark, const Color(0xFFFFFFFF), 0.35)!;
    K.stroke(c, K.curve(const Offset(100, _g), const Offset(106, 130), const Offset(98, 62)), 7, trunk);
    K.stroke(c, K.curve(const Offset(101, 110), const Offset(80, 96), const Offset(64, 108)), 3, trunk);
    K.stroke(c, K.curve(const Offset(102, 96), const Offset(122, 84), const Offset(138, 98)), 3, trunk);
    const sprigs = [
      (Offset(98, 64), Offset(70, 52), Offset(46, 80)),
      (Offset(98, 64), Offset(128, 50), Offset(154, 78)),
      (Offset(98, 64), Offset(96, 40), Offset(84, 34)),
      (Offset(98, 64), Offset(104, 42), Offset(120, 36)),
      (Offset(64, 108), Offset(44, 104), Offset(36, 128)),
      (Offset(138, 98), Offset(160, 96), Offset(166, 120)),
      (Offset(101, 110), Offset(92, 122), Offset(80, 140)),
    ];
    for (final (a, b, d) in sprigs) {
      _sprig(c, a, b, d);
    }
    for (final (top, bottom) in _pods) {
      K.stroke(c, K.curve(top, Offset(top.dx - 2, (top.dy + bottom.dy) / 2), bottom), 4, AppColors.podGreen);
    }
  }

  @override
  Map<PlantPart, Path> regions() => {
    PlantPart.special: K.union([
      for (final (a, b) in _pods) K.capsule([a, b], 10),
    ]),
    PlantPart.stem: K.capsule([const Offset(100, _g), const Offset(102, 120), const Offset(98, 70)], 12),
    PlantPart.leaf: K.oval(const Rect.fromLTRB(30, 24, 172, 146)),
    PlantPart.root: K.belowGround(),
  };
}
