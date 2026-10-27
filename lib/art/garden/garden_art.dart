import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../content/plant_catalog.dart';
import '../../game/garden.dart';
import '../../game/weather.dart';
import '../../theme/app_colors.dart';
import '../plants/plant_view.dart';

/// My Garden's drawings (PLAN.md §5d), in the app's sticker style: dark
/// outlines, a lighter side facing the sun, soft shadows.

/// The fixed garden: sky, trees and hedge at the back, the family's bahay
/// kubo with bamboo steps, and the sandy path. Drawn in
/// [GardenLayout.size] and scaled to fit the width. The sky follows the
/// [weather] (PLAN.md §5f); [rainbow] (after watering Binhi) arcs over the
/// trees and clears the rain away, leaving puddles.
///
/// The garden is painted in two layers so the moving parts stay cheap:
/// [GardenLayer.sky] (sky, sun, clouds and the trees behind the hedge,
/// repainted as [t] runs so they drift and sway) and [GardenLayer.ground]
/// (everything from the hedge down, painted once).
class GardenGroundPainter extends CustomPainter {
  const GardenGroundPainter({
    this.weather = GardenWeather.sunny,
    this.rainbow = false,
    this.puddles = false,
    this.layer = GardenLayer.all,
    this.t = 0,
  });

  final GardenWeather weather;
  final bool rainbow;
  final GardenLayer layer;

  /// The garden's life loop, 0 → 1 (see [GardenLife]).
  final double t;

  /// Rain puddles on the grass (they stay after the rain stops).
  final bool puddles;

  /// Raining right now (a rainbow means the rain has stopped).
  bool get raining => weather == GardenWeather.rainy && !rainbow;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / GardenLayout.size.width;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(k);
    // On a tall screen the grass carries on below the garden.
    _paint(canvas, Size(GardenLayout.size.width, size.height / k));
    canvas.restore();
  }

  void _paint(Canvas canvas, Size s) {
    final w = s.width;
    if (layer != GardenLayer.ground) {
      _sky(canvas, w);
      // Trees behind the hedge, their crowns swaying a little.
      for (final (i, (x, r)) in [(223.0, 34.0), (338.0, 48.0), (274.0, 40.0)].indexed) {
        canvas.drawRect(Rect.fromLTWH(x - 5, 100, 10, 40), Paint()..color = AppColors.bark);
        _crown(canvas, Offset(x + GardenLife.wave(t, 1, i * 0.3) * 2.5, 94), r);
      }
      if (!raining) _birds(canvas);
    }
    if (layer == GardenLayer.sky) return;
    final hedge = Path()..moveTo(0, 148);
    for (var x = 0.0; x <= w; x += 28) {
      hedge.quadraticBezierTo(x + 14, 124, x + 28, 148);
    }
    hedge
      ..lineTo(w, 177)
      ..lineTo(0, 177)
      ..close();
    outlined(canvas, hedge, AppColors.foliage, AppColors.foliageDark);
    // Grass, lighter near the back.
    final grass = Rect.fromLTWH(0, 165, w, s.height - 165);
    canvas.drawRect(
      grass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.leafLight, AppColors.leaf],
        ).createShader(grass),
    );
    _path(canvas);
    if (puddles || weather == GardenWeather.rainy) _puddles(canvas);
    // Flower border along the open side of the hedge.
    const border = [Colors.white, AppColors.bubblegum, AppColors.sunshine];
    for (var i = 9; i < 16; i++) {
      flowerAt(canvas, Offset(w * (i + 0.5) / 16, i.isEven ? 180 : 186), border[i % 3]);
    }
    _kubo(canvas);
    _tufts(canvas, s);
  }

  void _sky(Canvas canvas, double w) {
    final sky = Rect.fromLTWH(0, 0, w, 155);
    final colors = switch ((weather, rainbow)) {
      (GardenWeather.rainy, false) => const [Color(0xFF8A9DB2), Color(0xFFCAD5DF)],
      (GardenWeather.rainy, true) || (GardenWeather.cloudy, _) => const [Color(0xFF9FCBE8), Color(0xFFE3EEF5)],
      _ => const [AppColors.sky, AppColors.skyTint],
    };
    canvas.drawRect(
      sky,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(sky),
    );
    // The sun always shows (peeking on grey days) so it can be tapped.
    _sun(canvas, sunCentre);
    if (rainbow) _rainbow(canvas);
    // Clouds drift a little (taps still find them: they never go far).
    for (final (i, (o, cw, color)) in cloudsFor(weather, rainbow: rainbow).indexed) {
      _cloud(canvas, o + Offset(GardenLife.wave(t, 1, i * 0.27) * 6, 0), cw, color: color);
    }
  }

  /// Two birds gliding across the sky in the first part of each loop.
  void _birds(Canvas canvas) {
    final p = t / 0.45;
    if (p >= 1) return;
    final bird = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.text.withValues(alpha: 0.55);
    for (final (lag, y) in [(0.0, 64.0), (0.07, 76.0)]) {
      final q = p - lag;
      if (q < 0) continue;
      final x = -20 + q * 400;
      final flap = math.sin(q * 60) * 4;
      final o = Offset(x, y + math.sin(q * 7) * 6);
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 9, o.dy - 2 - flap)
          ..quadraticBezierTo(o.dx - 4, o.dy - 5 - flap, o.dx, o.dy)
          ..quadraticBezierTo(o.dx + 4, o.dy - 5 - flap, o.dx + 9, o.dy - 2 - flap),
        bird,
      );
    }
  }

  static const sunCentre = Offset(318, 34);

  /// The clouds for a weather, as (position, width, colour) in design units.
  /// They keep clear of the sun so a child can always tap it.
  static List<(Offset, double, Color)> cloudsFor(GardenWeather weather, {bool rainbow = false}) {
    if (rainbow) {
      // After the rain: two small clouds that keep clear of the rainbow.
      return const [(Offset(32, 14), 60, Colors.white), (Offset(250, 0), 54, Colors.white)];
    }
    const soft = Color(0xFFF4F7FA);
    const grey = Color(0xFFB7C3CF);
    const dark = Color(0xFF9DAAB8);
    return switch (weather) {
      GardenWeather.sunny => const [(Offset(230, 34), 84, Colors.white), (Offset(108, 30), 54, Colors.white)],
      GardenWeather.cloudy => const [
        (Offset(60, 22), 100, soft),
        (Offset(190, 40), 120, Colors.white),
        (Offset(255, 8), 70, soft),
        (Offset(130, 8), 80, Colors.white),
      ],
      GardenWeather.rainy => const [
        (Offset(60, 14), 120, dark),
        (Offset(195, 26), 140, grey),
        (Offset(258, 4), 64, dark),
        (Offset(130, 0), 100, grey),
      ],
    };
  }

  /// Whether a tap at design point [p] lands on the sun.
  static bool hitsSun(Offset p) => (p - sunCentre).distance <= 34;

  /// Whether a tap at design point [p] lands on a cloud (with a little
  /// extra room for small fingers).
  static bool hitsCloud(Offset p, GardenWeather weather, {bool rainbow = false}) {
    for (final (o, cw, _) in cloudsFor(weather, rainbow: rainbow)) {
      final h = cw * 0.3;
      if (Rect.fromLTRB(o.dx - cw / 2, o.dy - h * 0.8, o.dx + cw / 2, o.dy + h).inflate(10).contains(p)) return true;
    }
    return false;
  }

  void _sun(Canvas canvas, Offset c) {
    canvas.drawCircle(
      c,
      30,
      Paint()
        ..color = AppColors.sunshine.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    final ray = Paint()
      ..color = AppColors.sunshine
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      // The rays turn slowly (an eighth of a turn per loop, so it joins up).
      final a = i * math.pi / 4 + math.pi / 8 + t * math.pi / 4;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * 21, c + d * 28, ray);
    }
    outlinedOval(canvas, Rect.fromCircle(center: c, radius: 16), AppColors.sunshine, AppColors.sunshineDark);
  }

  /// A soft rainbow arcing over the trees, from behind the kubo roof.
  void _rainbow(Canvas canvas) {
    const bands = [
      Color(0xFFF26B6B),
      Color(0xFFFFA94D),
      Color(0xFFFFD93D),
      Color(0xFF7ED957),
      Color(0xFF5DB7F5),
      Color(0xFF9B7BEA),
    ];
    const centre = Offset(180, 192);
    canvas.save();
    canvas.clipRect(const Rect.fromLTWH(0, 0, 360, 150));
    for (final (i, c) in bands.indexed) {
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: 176 - i * 8.0),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.5
          ..color = c.withValues(alpha: 0.8),
      );
    }
    canvas.restore();
  }

  /// Rain puddles on the grass and the path.
  void _puddles(Canvas canvas) {
    for (final (x, y, w) in [(150.0, 300.0, 34.0), (40.0, 640.0, 46.0), (205.0, 760.0, 40.0), (330.0, 410.0, 30.0)]) {
      final r = Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.36);
      canvas.drawOval(r.inflate(2), Paint()..color = const Color(0xFF8FB5CC).withValues(alpha: 0.5));
      canvas.drawOval(r, Paint()..color = const Color(0xFFB9DDF2));
      canvas.drawOval(
        Rect.fromLTWH(r.left + r.width * 0.2, r.top + r.height * 0.25, r.width * 0.35, r.height * 0.25),
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  static Path get walk => Path()
    ..moveTo(115, 230)
    ..cubicTo(150, 440, 240, 660, 170, 1020);

  void _path(Canvas canvas) {
    final walk = GardenGroundPainter.walk;
    canvas.drawPath(
      walk,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 46
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD8C8A2),
    );
    canvas.drawPath(
      walk,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFF1E6CB),
    );
    final pebble = Paint()..color = const Color(0xFFCDBB93);
    for (final metric in walk.computeMetrics()) {
      for (var d = 40.0; d < metric.length; d += 46) {
        final t = metric.getTangentForOffset(d)!;
        final side = (d ~/ 46).isEven ? 1.0 : -1.0;
        final o = t.position + Offset(-t.vector.dy, t.vector.dx) * 11 * side;
        canvas.drawOval(Rect.fromCenter(center: o, width: 7, height: 4.5), pebble);
      }
    }
  }

  /// The family's bahay kubo (owner picked "Classic" with the duyan, see
  /// docs/previews/kubo/): layered nipa roof, woven sawali walls, a window
  /// with its awning propped open, and in the shade between the stilts a
  /// hammock, a banga jar and a sleepy cat. Drawn in its own units (the
  /// preview's) and fitted so the ladder lands on the path.
  void _kubo(Canvas canvas) {
    canvas
      ..save()
      ..translate(108, 228)
      ..scale(0.92)
      ..translate(-180, -196);
    const ink = Color(0xFF5B3A1E);
    const nipa = Color(0xFFD9A441), nipaDark = Color(0xFFB98328);
    const bamboo = Color(0xFFE8C98A), bambooDark = Color(0xFFC9A464);
    const wood = Color(0xFF8A5A2B), woodLight = Color(0xFFA47532);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = ink;
    Paint fill(Color c) => Paint()..color = c;
    void shape(Path p, Color c) => canvas
      ..drawPath(p, fill(c))
      ..drawPath(p, line);
    Path box(double l, double t, double r, double b, [double radius = 2]) =>
        Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));
    void stroke(Offset a, Offset b, Color c, double w) => canvas.drawLine(
      a,
      b,
      Paint()
        ..color = c
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round,
    );
    Paint curve(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..color = c;

    // Shade on the grass, darker right under the house.
    canvas
      ..drawOval(Rect.fromCenter(center: const Offset(180, 196), width: 200, height: 18), fill(const Color(0x382E6B2A)))
      ..drawRect(const Rect.fromLTRB(96, 132, 264, 194), fill(const Color(0x2E3E7A36)));

    // Bamboo stilts with nodes.
    for (final (x, w) in const [(104.0, 9.0), (150.0, 7.0), (210.0, 7.0), (256.0, 9.0)]) {
      shape(box(x - w / 2, 130, x + w / 2, 194), woodLight);
      for (var y = 142.0; y < 192; y += 14) {
        stroke(Offset(x - w / 2, y), Offset(x + w / 2, y), ink, 1.4);
      }
    }

    // A banga water jar.
    shape(
      Path()
        ..moveTo(116, 186)
        ..cubicTo(112, 174, 120, 168, 126, 168)
        ..cubicTo(132, 168, 140, 174, 136, 186)
        ..close(),
      const Color(0xFFC9653B),
    );
    shape(box(120, 164, 132, 169), const Color(0xFFB5522B));

    // The duyan, slung between the two right stilts.
    canvas.drawPath(
      Path()
        ..moveTo(212, 146)
        ..cubicTo(222, 176, 244, 176, 254, 146),
      curve(const Color(0xFFE86A7A), 3),
    );
    shape(
      Path()
        ..moveTo(212, 146)
        ..cubicTo(222, 170, 244, 170, 254, 146)
        ..cubicTo(246, 178, 220, 178, 212, 146)
        ..close(),
      const Color(0xFFFF8FB1),
    );
    canvas
      ..drawPath(
        Path()
          ..moveTo(217, 156)
          ..cubicTo(225, 166, 241, 166, 249, 156),
        curve(Colors.white, 2.4),
      )
      ..drawPath(
        Path()
          ..moveTo(220, 163)
          ..cubicTo(228, 171, 238, 171, 246, 163),
        curve(const Color(0xFF4FA8D8), 2.4),
      );

    // A cat asleep in the shade.
    const cat = Color(0xFFF2A541);
    canvas.drawPath(
      Path()
        ..moveTo(142, 189)
        ..cubicTo(134, 186, 134, 194, 141, 193),
      curve(ink, 2.2),
    );
    shape(Path()..addOval(Rect.fromCenter(center: const Offset(154, 190), width: 26, height: 13)), cat);
    shape(
      Path()
        ..moveTo(162, 181)
        ..lineTo(164, 175)
        ..lineTo(167, 180)
        ..lineTo(170, 175)
        ..lineTo(171, 182)
        ..close(),
      cat,
    );
    shape(Path()..addOval(Rect.fromCircle(center: const Offset(166, 185), radius: 6)), cat);
    canvas.drawPath(
      Path()
        ..moveTo(163, 185)
        ..quadraticBezierTo(164.5, 186.5, 166, 185)
        ..moveTo(167, 185)
        ..quadraticBezierTo(168.5, 186.5, 170, 185),
      curve(ink, 1.2),
    );

    // Floor beam and woven sawali walls.
    shape(box(92, 128, 268, 137), const Color(0xFFB9893F));
    const wall = Rect.fromLTRB(100, 80, 260, 130);
    canvas
      ..drawRect(wall, fill(bamboo))
      ..save()
      ..clipRect(wall);
    final weave = fill(bambooDark);
    final weaveSoft = fill(bambooDark.withValues(alpha: 0.7));
    for (var y = wall.top; y < wall.bottom; y += 12) {
      for (var x = wall.left; x < wall.right; x += 12) {
        canvas
          ..drawRRect(RRect.fromLTRBR(x + 1, y + 2, x + 5, y + 10, const Radius.circular(1)), weave)
          ..drawRRect(RRect.fromLTRBR(x + 6, y + 1, x + 11, y + 5, const Radius.circular(1)), weaveSoft)
          ..drawRRect(RRect.fromLTRBR(x + 6, y + 7, x + 11, y + 11, const Radius.circular(1)), weaveSoft);
      }
    }
    canvas
      ..restore()
      ..drawRect(wall, line);

    // Door.
    shape(box(175, 88, 201, 130), wood);
    canvas.drawCircle(const Offset(196, 110), 1.8, fill(bamboo));

    // Window with its nipa awning propped open on a stick.
    shape(box(214, 96, 252, 120, 0), const Color(0xFF4A2E16));
    stroke(const Offset(233, 96), const Offset(233, 120), woodLight, 2.4);
    stroke(const Offset(214, 108), const Offset(252, 108), woodLight, 2.4);
    shape(box(211, 119, 255, 123), bambooDark);
    shape(
      Path()
        ..moveTo(212, 96)
        ..lineTo(254, 96)
        ..lineTo(259, 110)
        ..lineTo(207, 110)
        ..close(),
      nipa,
    );
    stroke(const Offset(214, 101), const Offset(252, 101), nipaDark, 1.4);
    stroke(const Offset(211, 105), const Offset(255, 105), nipaDark, 1.4);
    stroke(const Offset(218, 120), const Offset(210, 110), const Color(0xFF7A5226), 2.5);

    // Layered nipa roof with ragged straw edges.
    const bl = Offset(80, 86), br = Offset(280, 86), tr = Offset(232, 26), tl = Offset(128, 26);
    final roof = Path()
      ..moveTo(tl.dx, tl.dy)
      ..lineTo(tr.dx, tr.dy)
      ..lineTo(br.dx, br.dy);
    const teeth = 25;
    for (var k = 1; k <= teeth; k++) {
      roof
        ..lineTo(br.dx + (bl.dx - br.dx) * (k - 0.5) / teeth, bl.dy + 6)
        ..lineTo(br.dx + (bl.dx - br.dx) * k / teeth, bl.dy);
    }
    roof.close();
    canvas
      ..drawPath(roof, fill(nipa))
      ..save()
      ..clipPath(roof);
    final straw = Paint()
      ..color = const Color(0xB3E9BD5E)
      ..strokeWidth = 1.2;
    for (var k = 0; k < 26; k++) {
      final t = (k + 0.5) / 26;
      canvas.drawLine(
        Offset.lerp(tl, tr, t)! + const Offset(0, 3),
        Offset.lerp(bl, br, t)! - const Offset(0, 4),
        straw,
      );
    }
    final row = curve(nipaDark, 2)..strokeJoin = StrokeJoin.round;
    for (final t in const [1 / 3, 2 / 3]) {
      final a = Offset.lerp(tl, bl, t)!, b = Offset.lerp(tr, br, t)!;
      final n = ((b.dx - a.dx) / 9).round();
      final z = Path()..moveTo(a.dx, a.dy);
      for (var k = 1; k <= n; k++) {
        z
          ..lineTo(a.dx + (b.dx - a.dx) * (k - 0.5) / n, a.dy + 4)
          ..lineTo(a.dx + (b.dx - a.dx) * k / n, a.dy);
      }
      canvas.drawPath(z, row);
    }
    canvas
      ..restore()
      ..drawPath(roof, line);
    stroke(const Offset(124, 26), const Offset(236, 26), nipaDark, 7);
    canvas.drawLine(const Offset(124, 26), const Offset(236, 26), curve(ink, 1.5));

    // Bamboo ladder from the door down to the path.
    const top = Offset(188, 134), foot = Offset(188, 198);
    final rail = curve(const Color(0xFF7A5226), 5);
    canvas
      ..drawLine(top - const Offset(10, 0), foot - const Offset(14, 0), rail)
      ..drawLine(top + const Offset(10, 0), foot + const Offset(14, 0), rail);
    for (var i = 1; i <= 4; i++) {
      final o = Offset.lerp(top, foot, i / 5)!;
      final half = 12 + 2 * i / 5;
      stroke(o - Offset(half, 0), o + Offset(half, 0), bambooDark, 4);
    }
    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset o, double w, {Color color = Colors.white}) {
    final p = Paint()..color = color;
    final h = w * 0.3;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w / 2, o.dy, w, h), Radius.circular(h / 2)), p);
    canvas.drawCircle(Offset(o.dx - w * 0.14, o.dy + 2), h * 0.6, p);
    canvas.drawCircle(Offset(o.dx + w * 0.12, o.dy - 2), h * 0.8, p);
  }

  /// A round tree crown, lighter on the sunny side.
  void _crown(Canvas canvas, Offset c, double r) {
    final p = Path()
      ..addOval(Rect.fromCircle(center: c, radius: r))
      ..addOval(Rect.fromCircle(center: c + Offset(-r * 0.6, r * 0.25), radius: r * 0.65))
      ..addOval(Rect.fromCircle(center: c + Offset(r * 0.6, r * 0.25), radius: r * 0.65));
    canvas.drawPath(p, Paint()..color = AppColors.foliage);
    canvas.save();
    canvas.clipPath(p);
    canvas.drawCircle(
      c + Offset(-r * 0.4, -r * 0.45),
      r * 0.85,
      Paint()..color = Color.lerp(AppColors.foliage, Colors.white, 0.16)!,
    );
    canvas.drawCircle(
      c + Offset(r * 0.5, r * 0.7),
      r * 0.8,
      Paint()..color = Color.lerp(AppColors.foliage, Colors.black, 0.12)!,
    );
    canvas.restore();
    outlined(canvas, p, Colors.transparent, AppColors.foliageDark);
  }

  void _tufts(Canvas canvas, Size s) {
    final rnd = math.Random(7);
    final p = Paint()
      ..color = AppColors.foliageDark.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 34; i++) {
      final o = Offset(rnd.nextDouble() * s.width, 250 + rnd.nextDouble() * (GardenLayout.size.height - 260));
      for (final dx in [-5.0, 0.0, 5.0]) {
        canvas.drawLine(o, o + Offset(dx * 1.3, -10 - dx.abs() * 0.4), p);
      }
    }
  }

  @override
  bool shouldRepaint(GardenGroundPainter old) =>
      old.weather != weather ||
      old.rainbow != rainbow ||
      old.puddles != puddles ||
      old.layer != layer ||
      (layer != GardenLayer.ground && old.t != t);
}

/// Rain over the whole garden (drawn above the plants): a soft grey veil,
/// slanted streaks that fall as [t] loops 0 → 1, and rings on the pond.
class GardenRainPainter extends CustomPainter {
  const GardenRainPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF52657A).withValues(alpha: 0.12));
    final k = size.width / GardenLayout.size.width;
    canvas.save();
    canvas.scale(k);
    final h = size.height / k;
    final streak = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final rnd = math.Random(3);
    const fall = 60.0;
    for (var i = 0; i < 160; i++) {
      final x = rnd.nextDouble() * 400 - 20;
      final y0 = rnd.nextDouble() * h;
      final y = (y0 + t * fall * 4) % h;
      canvas.drawLine(Offset(x - y * 0.12, y), Offset(x - y * 0.12 - 3, y + 11), streak);
    }
    // Rings on the pond.
    const pond = GardenLayout.pond;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final (i, (x, y)) in [(0.3, 0.72), (0.55, 0.66), (0.72, 0.8), (0.42, 0.85)].indexed) {
      final p = (t * 2 + i / 4) % 1;
      ring.color = Colors.white.withValues(alpha: 0.8 * (1 - p));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(pond.left + pond.width * x, pond.top + pond.height * y),
          width: 4 + p * 18,
          height: 2 + p * 7,
        ),
        ring,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(GardenRainPainter old) => old.t != t;
}

/// The pond with its stone rim, a lily pad and reeds.
class GardenPondPainter extends CustomPainter {
  const GardenPondPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final r = Rect.fromLTWH(w * 0.04, h * 0.48, w * 0.92, h * 0.46);
    final rnd = math.Random(2);
    for (var i = 0; i < 16; i++) {
      final a = i * 2 * math.pi / 16;
      final o = r.center + Offset(math.cos(a) * r.width / 2, math.sin(a) * r.height / 2);
      outlinedOval(
        canvas,
        Rect.fromCenter(center: o, width: w * (0.12 + rnd.nextDouble() * 0.05), height: h * 0.08),
        const Color(0xFFDCD3C0),
        const Color(0xFFADA28A),
      );
    }
    outlinedOval(canvas, r.deflate(4), AppColors.sky, AppColors.skyDark);
    canvas.drawOval(
      Rect.fromLTWH(r.left + r.width * 0.15, r.top + r.height * 0.18, r.width * 0.4, r.height * 0.22),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
    outlinedOval(
      canvas,
      Rect.fromCenter(center: Offset(w * 0.6, h * 0.82), width: w * 0.18, height: h * 0.08),
      AppColors.leaf,
      AppColors.leafDark,
    );
    canvas.drawCircle(Offset(w * 0.62, h * 0.8), w * 0.03, Paint()..color = AppColors.bubblegum);
    final reed = Paint()
      ..color = AppColors.foliageDark
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final (x, top) in [(0.9, 0.3), (0.94, 0.36), (0.86, 0.38)]) {
      canvas.drawLine(Offset(w * x, h * 0.6), Offset(w * x, h * top), reed);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.885, h * 0.3, w * 0.03, h * 0.1), const Radius.circular(4)),
      Paint()..color = AppColors.barkDark,
    );
  }

  @override
  bool shouldRepaint(GardenPondPainter old) => false;
}

/// A decoration, filling its box ([GardenDeco.butterfly] takes a [color]).
class GardenDecoPainter extends CustomPainter {
  const GardenDecoPainter(this.deco, {this.color = AppColors.bubblegum});

  final GardenDeco deco;
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    switch (deco) {
      case GardenDeco.bench:
        for (final x in [0.2, 0.72]) {
          outlinedRRect(
            canvas,
            RRect.fromRectAndRadius(Rect.fromLTWH(w * x, h * 0.6, w * 0.08, h * 0.32), const Radius.circular(3)),
            AppColors.barkDark,
            AppColors.soilDark,
          );
        }
        for (final y in [0.28, 0.41]) {
          outlinedRRect(
            canvas,
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * y, w * 0.8, h * 0.1), const Radius.circular(5)),
            AppColors.bark,
            AppColors.barkDark,
          );
        }
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.04, h * 0.57, w * 0.92, h * 0.11), const Radius.circular(5)),
          AppColors.bark,
          AppColors.barkDark,
        );
        canvas.drawLine(
          Offset(w * 0.14, h * 0.31),
          Offset(w * 0.5, h * 0.31),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.35)
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
      case GardenDeco.fence:
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.45, w, h * 0.1), const Radius.circular(3)),
          AppColors.bark,
          AppColors.barkDark,
        );
        for (var i = 0; i < 4; i++) {
          final x = w * (0.04 + i * 0.25);
          final p = Path()
            ..moveTo(x, h * 0.95)
            ..lineTo(x, h * 0.3)
            ..lineTo(x + w * 0.08, h * 0.18)
            ..lineTo(x + w * 0.16, h * 0.3)
            ..lineTo(x + w * 0.16, h * 0.95)
            ..close();
          outlined(canvas, p, Colors.white, AppColors.borderDeep);
        }
      case GardenDeco.butterfly:
        final c = s.center(Offset.zero);
        final dark = Color.lerp(color, Colors.black, 0.3)!;
        for (final sx in [-1.0, 1.0]) {
          outlinedOval(
            canvas,
            Rect.fromCenter(center: c + Offset(sx * w * 0.2, -w * 0.12), width: w * 0.42, height: w * 0.46),
            color,
            dark,
          );
          outlinedOval(
            canvas,
            Rect.fromCenter(center: c + Offset(sx * w * 0.15, w * 0.18), width: w * 0.28, height: w * 0.3),
            color,
            dark,
          );
          canvas.drawCircle(
            c + Offset(sx * w * 0.2, -w * 0.14),
            w * 0.07,
            Paint()..color = Colors.white.withValues(alpha: 0.7),
          );
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: w * 0.1, height: w * 0.62), Radius.circular(w)),
          Paint()..color = AppColors.text,
        );
      case GardenDeco.palayok:
        final pot = Path()
          ..moveTo(w * 0.3, h * 0.35)
          ..quadraticBezierTo(w * 0.02, h * 0.62, w * 0.3, h * 0.95)
          ..lineTo(w * 0.7, h * 0.95)
          ..quadraticBezierTo(w * 0.98, h * 0.62, w * 0.7, h * 0.35)
          ..close();
        outlined(canvas, pot, const Color(0xFFC8713F), AppColors.soilDark);
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.24, h * 0.28, w * 0.52, h * 0.1), const Radius.circular(4)),
          const Color(0xFFB45F31),
          AppColors.soilDark,
        );
        canvas.drawLine(
          Offset(w * 0.2, h * 0.6),
          Offset(w * 0.8, h * 0.6),
          Paint()
            ..color = const Color(0xFFF2C46B)
            ..strokeWidth = 3,
        );
      case GardenDeco.stones:
        // Three flat stones, nearest biggest.
        for (final (x, y, rw) in [(0.3, 0.62, 0.34), (0.66, 0.76, 0.38), (0.36, 0.92, 0.44)]) {
          final r = Rect.fromCenter(center: Offset(w * x, h * y), width: w * rw, height: h * rw * 0.42);
          outlinedOval(canvas, r, const Color(0xFFE6DFCF), const Color(0xFFADA28A));
          canvas.drawOval(
            Rect.fromLTWH(r.left + r.width * 0.18, r.top + r.height * 0.18, r.width * 0.4, r.height * 0.3),
            Paint()..color = Colors.white.withValues(alpha: 0.5),
          );
        }
      case GardenDeco.birdbath:
        // Stone pedestal and basin with water and a little maya bird.
        const stone = Color(0xFFDCD3C0);
        const stoneDark = Color(0xFFADA28A);
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.32, h * 0.88, w * 0.36, h * 0.09), const Radius.circular(4)),
          stone,
          stoneDark,
        );
        final stem = Path()
          ..moveTo(w * 0.42, h * 0.88)
          ..lineTo(w * 0.45, h * 0.6)
          ..lineTo(w * 0.55, h * 0.6)
          ..lineTo(w * 0.58, h * 0.88)
          ..close();
        outlined(canvas, stem, stone, stoneDark);
        final bowl = Path()
          ..moveTo(w * 0.08, h * 0.5)
          ..quadraticBezierTo(w * 0.5, h * 0.78, w * 0.92, h * 0.5)
          ..close();
        outlined(canvas, bowl, stone, stoneDark);
        outlinedOval(canvas, Rect.fromLTWH(w * 0.08, h * 0.44, w * 0.84, h * 0.13), AppColors.skyLight, stoneDark);
        // Maya bird on the rim.
        final bird = Paint()..color = const Color(0xFFA5714A);
        canvas.drawOval(Rect.fromLTWH(w * 0.58, h * 0.3, w * 0.24, h * 0.16), bird);
        canvas.drawCircle(Offset(w * 0.78, h * 0.3), w * 0.07, bird);
        canvas.drawCircle(Offset(w * 0.8, h * 0.29), w * 0.015, Paint()..color = AppColors.text);
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.84, h * 0.29)
            ..lineTo(w * 0.9, h * 0.31)
            ..lineTo(w * 0.84, h * 0.33)
            ..close(),
          Paint()..color = AppColors.sunshineDark,
        );
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.6, h * 0.36)
            ..lineTo(w * 0.48, h * 0.32)
            ..lineTo(w * 0.6, h * 0.42)
            ..close(),
          Paint()..color = const Color(0xFF7A5134),
        );
      case GardenDeco.lamp:
        // A garden post with a capiz-shell lantern.
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3, h * 0.9, w * 0.4, h * 0.07), const Radius.circular(3)),
          AppColors.barkDark,
          AppColors.soilDark,
        );
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, h * 0.36, w * 0.1, h * 0.56), const Radius.circular(3)),
          AppColors.bark,
          AppColors.barkDark,
        );
        // Lantern: a glowing pale square of capiz panes under a little roof.
        final glow = Paint()
          ..color = AppColors.sunshine.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(w * 0.5, h * 0.24), w * 0.3, glow);
        final box = Rect.fromLTWH(w * 0.3, h * 0.12, w * 0.4, h * 0.25);
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(box, const Radius.circular(4)),
          const Color(0xFFFFF4D6),
          AppColors.barkDark,
        );
        final pane = Paint()
          ..color = const Color(0xFFE8D7A8)
          ..strokeWidth = 1.5;
        canvas.drawLine(Offset(box.center.dx, box.top + 2), Offset(box.center.dx, box.bottom - 2), pane);
        canvas.drawLine(Offset(box.left + 2, box.center.dy), Offset(box.right - 2, box.center.dy), pane);
        final roof = Path()
          ..moveTo(w * 0.24, h * 0.13)
          ..lineTo(w * 0.5, h * 0.02)
          ..lineTo(w * 0.76, h * 0.13)
          ..close();
        outlined(canvas, roof, AppColors.barkDark, AppColors.soilDark);
      case GardenDeco.swing:
        // A wooden A-frame swing with a plank seat on ropes.
        final post = Paint()
          ..color = AppColors.bark
          ..strokeWidth = w * 0.07
          ..strokeCap = StrokeCap.round;
        final postEdge = Paint()
          ..color = AppColors.barkDark
          ..strokeWidth = w * 0.07 + 4
          ..strokeCap = StrokeCap.round;
        for (final (top, l, r) in [(0.1, 0.04, 0.2), (0.9, 0.8, 0.96)]) {
          for (final p in [postEdge, post]) {
            canvas.drawLine(Offset(w * top, h * 0.14), Offset(w * l, h * 0.96), p);
            canvas.drawLine(Offset(w * top, h * 0.14), Offset(w * r, h * 0.96), p);
          }
        }
        for (final p in [postEdge, post]) {
          canvas.drawLine(Offset(w * 0.08, h * 0.12), Offset(w * 0.92, h * 0.12), p);
        }
        final rope = Paint()
          ..color = const Color(0xFFB59A7A)
          ..strokeWidth = 2.2;
        canvas.drawLine(Offset(w * 0.36, h * 0.13), Offset(w * 0.36, h * 0.7), rope);
        canvas.drawLine(Offset(w * 0.64, h * 0.13), Offset(w * 0.64, h * 0.7), rope);
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3, h * 0.68, w * 0.4, h * 0.07), const Radius.circular(3)),
          AppColors.coral,
          AppColors.coralDark,
        );
      case GardenDeco.carabao:
        // A friendly carabao statue on a low plinth.
        const hide = Color(0xFF7F8A99);
        const hideDark = Color(0xFF4F5866);
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06, h * 0.86, w * 0.88, h * 0.1), const Radius.circular(5)),
          const Color(0xFFDCD3C0),
          const Color(0xFFADA28A),
        );
        for (final x in [0.2, 0.34, 0.6, 0.74]) {
          outlinedRRect(
            canvas,
            RRect.fromRectAndRadius(Rect.fromLTWH(w * x, h * 0.66, w * 0.09, h * 0.21), const Radius.circular(3)),
            hide,
            hideDark,
          );
        }
        outlinedRRect(
          canvas,
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.14, h * 0.42, w * 0.7, h * 0.32), Radius.circular(h * 0.14)),
          hide,
          hideDark,
        );
        // Head, horns, ear, eye, nose.
        final horn = Path()
          ..moveTo(w * 0.7, h * 0.36)
          ..quadraticBezierTo(w * 0.6, h * 0.16, w * 0.78, h * 0.12)
          ..quadraticBezierTo(w * 0.68, h * 0.22, w * 0.76, h * 0.34)
          ..close();
        outlined(canvas, horn, const Color(0xFFE9E2D2), hideDark);
        final horn2 = Path()
          ..moveTo(w * 0.86, h * 0.36)
          ..quadraticBezierTo(w * 0.98, h * 0.18, w * 0.84, h * 0.12)
          ..quadraticBezierTo(w * 0.92, h * 0.22, w * 0.82, h * 0.34)
          ..close();
        outlined(canvas, horn2, const Color(0xFFE9E2D2), hideDark);
        outlinedOval(canvas, Rect.fromLTWH(w * 0.66, h * 0.3, w * 0.26, h * 0.3), hide, hideDark);
        outlinedOval(canvas, Rect.fromLTWH(w * 0.74, h * 0.48, w * 0.2, h * 0.14), const Color(0xFF9AA4B2), hideDark);
        canvas.drawCircle(Offset(w * 0.76, h * 0.42), w * 0.02, Paint()..color = AppColors.text);
        canvas.drawCircle(Offset(w * 0.82, h * 0.42), w * 0.02, Paint()..color = AppColors.text);
        canvas.drawLine(
          Offset(w * 0.18, h * 0.5),
          Offset(w * 0.06, h * 0.64),
          Paint()
            ..color = hideDark
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(w * 0.22, h * 0.5),
          Offset(w * 0.5, h * 0.48),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.3)
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  @override
  bool shouldRepaint(GardenDecoPainter old) => old.deco != deco || old.color != color;
}

/// A terracotta pot filling its box.
class PotPainter extends CustomPainter {
  const PotPainter();

  @override
  void paint(Canvas canvas, Size s) {
    const clay = Color(0xFFE07A4F);
    const clayDark = Color(0xFFA9492A);
    final r = Offset.zero & s;
    final rimH = r.height * 0.24;
    final body = Path()
      ..moveTo(r.left + r.width * 0.06, r.top + rimH)
      ..lineTo(r.right - r.width * 0.06, r.top + rimH)
      ..lineTo(r.right - r.width * 0.18, r.bottom)
      ..lineTo(r.left + r.width * 0.18, r.bottom)
      ..close();
    outlined(canvas, body, clay, clayDark);
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
      Rect.fromLTWH(r.left, r.top + rimH + r.height * 0.36, r.width, r.height * 0.1),
      Paint()..color = const Color(0xFFC9633C),
    );
    canvas.drawRect(
      Rect.fromLTWH(r.left + r.width * 0.2, r.top + rimH, r.width * 0.08, r.height),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.restore();
    outlinedRRect(
      canvas,
      RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, r.width, rimH), Radius.circular(rimH * 0.35)),
      const Color(0xFFEB8C60),
      clayDark,
    );
  }

  @override
  bool shouldRepaint(PotPainter old) => false;
}

/// The front of a wooden garden bed with soil on top, filling its box.
class BedPainter extends CustomPainter {
  const BedPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final r = Offset.zero & s;
    final soilH = r.height * 0.4;
    outlinedRRect(
      canvas,
      RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, r.width, soilH * 1.6), Radius.circular(soilH * 0.5)),
      AppColors.soil,
      AppColors.soilDark,
    );
    final crumb = Paint()..color = AppColors.soilDark;
    for (var i = 0; i < 14; i++) {
      canvas.drawCircle(
        Offset(r.left + 14 + i * (r.width - 28) / 13, r.top + soilH * (i.isEven ? 0.45 : 0.7)),
        2,
        crumb,
      );
    }
    outlinedRRect(
      canvas,
      RRect.fromRectAndRadius(
        Rect.fromLTWH(r.left, r.top + soilH, r.width, r.height - soilH),
        const Radius.circular(8),
      ),
      AppColors.bark,
      AppColors.barkDark,
    );
    final plank = Paint()
      ..color = AppColors.barkDark.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    final mid = r.top + soilH + (r.height - soilH) / 2;
    canvas.drawLine(Offset(r.left + 10, mid), Offset(r.right - 10, mid), plank);
    for (final x in [r.left + 4, r.right - 14]) {
      outlinedRRect(
        canvas,
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, r.top + soilH - 4, 10, r.height - soilH + 4),
          const Radius.circular(3),
        ),
        AppColors.barkDark,
        AppColors.soilDark,
      );
    }
    canvas.drawLine(
      Offset(r.left + 20, r.top + soilH + 6),
      Offset(r.left + r.width * 0.45, r.top + soilH + 6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(BedPainter old) => false;
}

/// Which part of the garden a [GardenGroundPainter] paints.
enum GardenLayer { all, sky, ground }

/// The garden's gentle life (PLAN.md §5g): one loop drives the swaying,
/// drifting clouds, turning sun rays, birds and butterflies. Every motion
/// fits a whole number of times into the loop, so it never jumps.
abstract final class GardenLife {
  static const loop = Duration(seconds: 8);

  /// A smooth -1…1 wave that goes round [times] per loop, shifted by
  /// [phase] (0–1).
  static double wave(double t, int times, double phase) => math.sin(2 * math.pi * (t * times + phase));
}

/// Leans [child] from its base, back and forth, as the garden's life loop
/// runs: a plant in the breeze. Without [life] it stands still.
class Sway extends StatelessWidget {
  const Sway({super.key, required this.life, required this.child, this.amount = 0.05, this.phase = 0, this.times = 2});

  final ValueListenable<double>? life;
  final Widget child;

  /// How far it leans (a skew; 0.05 is a gentle breeze).
  final double amount;
  final double phase;
  final int times;

  /// A steady 0–1 phase for a plant, so plants don't sway in step.
  static double phaseOf(String id) => (id.codeUnits.fold(0, (a, c) => a * 31 + c) % 997) / 997;

  @override
  Widget build(BuildContext context) {
    final l = life;
    if (l == null) return child;
    return ValueListenableBuilder<double>(
      valueListenable: l,
      child: child,
      builder: (context, t, child) => Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.skewX(amount * GardenLife.wave(t, times, phase)),
        child: child,
      ),
    );
  }
}

/// Two butterflies fluttering around the garden (they hide in the rain).
/// Drawn over the plants, in design units like the ground.
class GardenButterflyPainter extends CustomPainter {
  const GardenButterflyPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / GardenLayout.size.width;
    for (final (cx, cy, rx, ry, phase, color) in [
      (120.0, 330.0, 70.0, 40.0, 0.0, AppColors.bubblegum),
      (250.0, 690.0, 60.0, 50.0, 0.5, AppColors.sunshine),
    ]) {
      final x = cx + rx * GardenLife.wave(t, 1, phase);
      final y = cy + ry * GardenLife.wave(t, 2, phase + 0.1);
      // Facing the way it flies.
      final dir = math.cos(2 * math.pi * (t + phase)) >= 0 ? 1.0 : -1.0;
      final flap = 0.35 + 0.65 * GardenLife.wave(t, 24, phase).abs();
      const box = 30.0;
      canvas.save();
      canvas.translate(x * k, y * k);
      canvas.scale(k * dir * flap, k);
      canvas.translate(-box / 2, -box / 2);
      GardenDecoPainter(GardenDeco.butterfly, color: color).paint(canvas, const Size(box, box));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(GardenButterflyPainter old) => old.t != t;
}

/// One half of the garden's bamboo gate, filling its box; [left] is the
/// door that closes from the left.
class BambooDoorPainter extends CustomPainter {
  const BambooDoorPainter({required this.left});
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    const pole = 22.0;
    final fill = Paint()..color = AppColors.bamboo;
    final dark = Paint()..color = AppColors.bambooDark;
    final edge = Paint()
      ..color = AppColors.bambooDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    for (var x = left ? size.width - pole : 0.0; left ? x > -pole : x < size.width; x += left ? -pole : pole) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, -10, pole - 2, size.height + 20),
        const Radius.circular(8),
      );
      canvas.drawRRect(r, fill);
      canvas.drawRRect(r, edge);
      // Joints along each pole.
      for (var y = 60.0 + (x / pole % 3) * 40; y < size.height; y += 140) {
        canvas.drawRect(Rect.fromLTWH(x + 2, y, pole - 4, 4), dark);
      }
      canvas.drawRect(Rect.fromLTWH(x + 5, 0, 3, size.height), Paint()..color = Colors.white.withValues(alpha: 0.25));
    }
    // Two cross bars tied on.
    for (final y in [size.height * 0.3, size.height * 0.7]) {
      final bar = RRect.fromRectAndRadius(Rect.fromLTWH(-4, y, size.width + 8, 18), const Radius.circular(8));
      canvas.drawRRect(bar, Paint()..color = AppColors.bambooDark);
    }
    // The edge where the doors meet.
    final rim = left ? size.width - 6 : 0.0;
    canvas.drawRect(Rect.fromLTWH(rim, 0, 6, size.height), Paint()..color = AppColors.barkDark);
  }

  @override
  bool shouldRepaint(BambooDoorPainter old) => old.left != left;
}

/// A soft oval shadow on the grass.
class GroundShadow extends StatelessWidget {
  const GroundShadow({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.elliptical(100, 40)),
      color: Colors.black.withValues(alpha: 0.12),
    ),
  );
}

/// A plant growing in a clay pot, filling a square box.
class PottedPlant extends StatelessWidget {
  const PottedPlant({super.key, required this.plant, this.life, this.touches = 0, this.reduceMotion = false});
  final PlantInfo plant;

  /// When given, the plant sways in its pot (the pot stays still).
  final ValueListenable<double>? life;

  /// Each new count makes the plant react to a tap (PLAN.md §5j).
  final int touches;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final b = c.maxHeight;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: b * 0.18, right: b * 0.18, bottom: -b * 0.04, height: b * 0.12, child: const GroundShadow()),
          Positioned(
            left: -b * 0.1,
            right: -b * 0.1,
            top: -b * 0.2,
            bottom: b * 0.26,
            child: Sway(
              life: life,
              amount: 0.06,
              phase: Sway.phaseOf(plant.id),
              child: PlantView(
                plant: plant,
                mode: PlantMode.planted,
                react: true,
                touches: touches,
                reduceMotion: reduceMotion,
              ),
            ),
          ),
          Positioned(
            left: b * 0.2,
            right: b * 0.2,
            bottom: 0,
            height: b * 0.4,
            child: const CustomPaint(painter: PotPainter()),
          ),
        ],
      );
    },
  );
}

/// The garden bed with a crop in each slot ([GardenLayout.bedPlants]); an
/// empty slot (null) is bare soil waiting for its plant.
class GardenBedView extends StatelessWidget {
  const GardenBedView({super.key, required this.plants, this.life, this.touches = 0, this.reduceMotion = false});
  final List<PlantInfo?> plants;

  /// When given, the crops sway in the breeze, each a little out of step.
  final ValueListenable<double>? life;

  /// Each new count makes the crops react to a tap (PLAN.md §5j).
  final int touches;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final b = c.maxHeight;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, right: 0, bottom: -b * 0.04, height: b * 0.12, child: const GroundShadow()),
          Positioned(
            left: c.maxWidth * 0.04,
            right: c.maxWidth * 0.04,
            top: -b * 0.14,
            bottom: b * 0.3,
            child: Row(
              children: [
                for (final (i, p) in plants.indexed)
                  Expanded(
                    child: p == null
                        ? const SizedBox()
                        : Sway(
                            life: life,
                            amount: 0.07,
                            phase: i * 0.35,
                            child: PlantView(
                              plant: p,
                              mode: PlantMode.planted,
                              react: true,
                              touches: touches,
                              reduceMotion: reduceMotion,
                            ),
                          ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: b * 0.42,
            child: const CustomPaint(painter: BedPainter()),
          ),
        ],
      );
    },
  );
}

void outlined(Canvas canvas, Path p, Color fill, Color line) {
  canvas.drawPath(p, Paint()..color = fill);
  canvas.drawPath(
    p,
    Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round,
  );
}

void outlinedOval(Canvas canvas, Rect r, Color fill, Color line) => outlined(canvas, Path()..addOval(r), fill, line);

void outlinedRRect(Canvas canvas, RRect r, Color fill, Color line) => outlined(canvas, Path()..addRRect(r), fill, line);

void flowerAt(Canvas canvas, Offset o, Color color) {
  final petal = Paint()..color = color;
  final edge = Paint()
    ..color = Color.lerp(color, Colors.black, 0.25)!
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  for (var k = 0; k < 5; k++) {
    final a = k * 2 * math.pi / 5 - math.pi / 2;
    final c = o + Offset(math.cos(a), math.sin(a)) * 4;
    canvas.drawCircle(c, 3.4, petal);
    canvas.drawCircle(c, 3.4, edge);
  }
  canvas.drawCircle(o, 2.6, Paint()..color = AppColors.sunshineDark);
}
