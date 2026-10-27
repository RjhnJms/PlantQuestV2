import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';
import 'binhi_outfit.dart';
import 'binhi_stage.dart';

/// Live animation values for one frame of Binhi.
class BinhiPose {
  const BinhiPose({this.breathe = 0, this.sway = 0.5, this.blink = 0, this.hop = 0});

  /// 0–1, slow in-and-out body breathing.
  final double breathe;

  /// 0–1, plant leaning left (0) to right (1). 0.5 = upright.
  final double sway;

  /// 0 = eyes open, 1 = closed.
  final double blink;

  /// 0–1 progress through a hop. 0 = standing still.
  final double hop;
}

/// Draws Binhi, a sprout in a coral pot, in a 200×260 design box scaled to
/// the canvas. The pot stays in the same place for every stage, so layouts
/// don't jump when Binhi grows.
class BinhiPainter extends CustomPainter {
  BinhiPainter({
    required this.stage,
    required this.mood,
    required this.pose,
    this.outfit = BinhiOutfit.none,
    super.repaint,
  });

  /// Hats, glasses, neck pieces, a little friend and pot patterns (rewards).
  final BinhiOutfit outfit;

  static const designSize = Size(200, 260);

  final BinhiStage stage;
  final BinhiMood mood;

  /// Read every frame, so animation needs no widget rebuilds.
  final BinhiPose Function() pose;

  // Key points in design units.
  static const _soil = Offset(100, 154);
  static const _ground = Offset(100, 244);
  static const _leftEye = Offset(80, 197);
  static const _rightEye = Offset(120, 197);
  static const _mouth = Offset(100, 213);

  @override
  void paint(Canvas canvas, Size size) {
    final p = pose();
    final scale = math.min(size.width / designSize.width, size.height / designSize.height);
    canvas
      ..save()
      ..translate((size.width - designSize.width * scale) / 2, size.height - designSize.height * scale)
      ..scale(scale);

    final (hopY, hopSx, hopSy) = hopPose(p.hop);

    // Shadow shrinks while Binhi is in the air.
    final air = (-hopY / 28).clamp(0.0, 1.0);
    Sticker.groundShadow(canvas, _ground, 120 * (1 - 0.35 * air), 16 * (1 - 0.3 * air), AppColors.coralDark);

    // Breathing: a tiny stretch up and narrowing, anchored at the pot base.
    final b = Curves.easeInOut.transform(p.breathe);
    final sx = hopSx * (1 - 0.012 * b);
    final sy = hopSy * (1 + 0.022 * b);
    canvas
      ..save()
      ..translate(_ground.dx, _ground.dy + hopY)
      ..scale(sx, sy)
      ..translate(-_ground.dx, -_ground.dy);

    _drawPotBody(canvas);
    _drawRim(canvas);
    _drawNeck(canvas);

    canvas
      ..save()
      ..translate(_soil.dx, _soil.dy)
      ..rotate((p.sway - 0.5) * 0.09)
      ..translate(-_soil.dx, -_soil.dy);
    _drawPlant(canvas);
    canvas.restore();

    _drawFace(canvas, p.blink);
    _drawGlasses(canvas);
    if (mood == BinhiMood.worried) _drawSweat(canvas);
    _drawHat(canvas);
    _drawFriend(canvas, p);

    canvas
      ..restore()
      ..restore();
  }

  /// Squash-and-stretch hop: (vertical offset, x scale, y scale).
  static (double, double, double) hopPose(double t) {
    if (t <= 0 || t >= 1) return (0, 1, 1);
    double lerp(double a, double b, double f) => a + (b - a) * f;
    if (t < 0.15) {
      final e = Curves.easeOut.transform(t / 0.15);
      return (0, 1 + 0.12 * e, 1 - 0.14 * e);
    }
    if (t < 0.5) {
      final f = (t - 0.15) / 0.35;
      final e = Curves.easeOut.transform(f);
      final s = math.min(1.0, f * 2);
      return (-28 * e, lerp(1.12, 0.94, s), lerp(0.86, 1.08, s));
    }
    if (t < 0.8) {
      final f = (t - 0.5) / 0.3;
      final e = Curves.easeIn.transform(f);
      return (-28 * (1 - e), lerp(0.94, 1, f), lerp(1.08, 1, f));
    }
    final squash = math.sin((t - 0.8) / 0.2 * math.pi);
    return (0, 1 + 0.1 * squash, 1 - 0.12 * squash);
  }

  void _drawPotBody(Canvas canvas) {
    final body = Path()
      ..moveTo(46, 168)
      ..lineTo(154, 168)
      ..lineTo(141, 236)
      ..quadraticBezierTo(140, 243, 133, 243)
      ..lineTo(67, 243)
      ..quadraticBezierTo(60, 243, 59, 236)
      ..close();
    Sticker.shape(canvas, body, AppColors.coral, AppColors.coralDark, lift: 0.12);
    if (outfit.pattern != PotPattern.plain) _drawPattern(canvas, body);
    // Soft vertical shine on the left side of the pot.
    canvas.drawRRect(
      RRect.fromLTRBR(58, 178, 66, 222, const Radius.circular(4)),
      Sticker.solid(const Color(0xFFFFFFFF).withValues(alpha: 0.22)),
    );
  }

  void _drawRim(Canvas canvas) {
    final rim = RRect.fromLTRBR(38, 148, 162, 172, const Radius.circular(11));
    canvas
      ..drawRRect(rim, Sticker.fill(rim.outerRect, Color.lerp(AppColors.coral, AppColors.coralLight, 0.35)!))
      ..drawRRect(rim, Sticker.outline(AppColors.coralDark));
    Sticker.gloss(canvas, RRect.fromLTRBR(50, 158, 130, 162, const Radius.circular(2)), alpha: 0.45);
    // Soil showing at the top of the pot.
    final soil = Rect.fromCenter(center: _soil, width: 100, height: 10);
    canvas
      ..drawOval(soil, Sticker.solid(AppColors.soil))
      ..drawOval(
        Rect.fromCenter(center: _soil.translate(0, 1.5), width: 90, height: 6),
        Sticker.solid(AppColors.soilDark),
      );
  }

  void _drawStem(Canvas canvas, double topY, {double bend = 5}) {
    final path = Path()
      ..moveTo(_soil.dx, _soil.dy)
      ..quadraticBezierTo(_soil.dx + bend, (_soil.dy + topY) / 2, _soil.dx, topY);
    canvas
      ..drawPath(path, Sticker.stroke(AppColors.leafDark, 9))
      ..drawPath(path, Sticker.stroke(AppColors.leaf, 5))
      ..drawPath(path.shift(const Offset(-1.2, 0)), Sticker.stroke(AppColors.leafLight.withValues(alpha: 0.7), 1.6));
  }

  void _drawPlant(Canvas canvas) {
    switch (stage) {
      case BinhiStage.seed:
        _drawSeed(canvas);
      case BinhiStage.sprout:
        _drawStem(canvas, 114, bend: 4);
        Sticker.leaf(canvas, const Offset(100, 116), -0.95, 36, 14);
        Sticker.leaf(canvas, const Offset(100, 116), 0.95, 36, 14);
      case BinhiStage.sapling:
        _drawStem(canvas, 80);
        _leafPair(canvas, 130, 1.2, 24, 10);
        _leafPair(canvas, 106, 1.02, 30, 12);
        _leafPair(canvas, 82, 0.55, 34, 14);
      case BinhiStage.blooming:
        _drawStem(canvas, 66);
        _leafPair(canvas, 134, 1.22, 24, 10);
        _leafPair(canvas, 112, 1.05, 30, 12);
        _leafPair(canvas, 90, 0.9, 32, 13);
        Sticker.flower(
          canvas,
          const Offset(100, 56),
          24,
          petal: AppColors.bubblegum,
          petalOutline: AppColors.bubblegumDark,
          rotation: 0.3,
        );
    }
  }

  void _leafPair(Canvas canvas, double y, double angle, double length, double width) {
    Sticker.leaf(canvas, Offset(100, y), -angle, length, width);
    Sticker.leaf(canvas, Offset(100, y), angle, length, width);
  }

  void _drawSeed(Canvas canvas) {
    // A seed half-buried in the soil with a tiny curled shoot.
    canvas
      ..save()
      ..translate(96, 150)
      ..rotate(-0.35);
    final seed = Rect.fromCenter(center: Offset.zero, width: 22, height: 14);
    canvas
      ..drawOval(seed, Sticker.fill(seed, AppColors.bark, lift: 0.3))
      ..drawOval(seed, Sticker.outline(AppColors.barkDark, width: 2.5))
      ..restore();
    final shoot = Path()
      ..moveTo(102, 147)
      ..quadraticBezierTo(108, 134, 104, 126);
    canvas
      ..drawPath(shoot, Sticker.stroke(AppColors.leafDark, 7))
      ..drawPath(shoot, Sticker.stroke(AppColors.leaf, 3.5));
    Sticker.leaf(canvas, const Offset(104, 127), 0.75, 18, 8, vein: false);
  }

  void _drawFace(Canvas canvas, double blink) {
    const ink = AppColors.text;
    final blushAlpha = mood == BinhiMood.cheering ? 0.75 : 0.5;
    for (final x in [64.0, 136.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 210), width: 18, height: 10),
        Sticker.solid(AppColors.bubblegum.withValues(alpha: blushAlpha)),
      );
    }

    if (mood == BinhiMood.cheering) {
      // Happy closed eyes: ^ ^
      for (final e in [_leftEye, _rightEye]) {
        final arc = Path()
          ..moveTo(e.dx - 7, e.dy + 3)
          ..quadraticBezierTo(e.dx, e.dy - 8, e.dx + 7, e.dy + 3);
        canvas.drawPath(arc, Sticker.stroke(ink, 3.5));
      }
    } else if (outfit.glasses != BinhiGlasses.sunglasses && outfit.glasses != BinhiGlasses.hearts) {
      for (final e in [_leftEye, _rightEye]) {
        final open = 1 - blink;
        if (open < 0.15) {
          canvas.drawLine(e.translate(-6, 0), e.translate(6, 0), Sticker.stroke(ink, 3));
        } else {
          canvas.drawOval(Rect.fromCenter(center: e, width: 13, height: 15 * open), Sticker.solid(ink));
          if (open > 0.6) {
            canvas.drawCircle(e.translate(2.4, -2.8 * open), 2.4, Sticker.solid(const Color(0xFFFFFFFF)));
          }
        }
      }
    }

    // Eyebrows
    switch (mood) {
      case BinhiMood.encouraging:
        for (final (e, dir) in [(_leftEye, -1.0), (_rightEye, 1.0)]) {
          final brow = Path()
            ..moveTo(e.dx + 8 * dir, e.dy - 13)
            ..quadraticBezierTo(e.dx, e.dy - 18, e.dx - 7 * dir, e.dy - 14);
          canvas.drawPath(brow, Sticker.stroke(ink, 2.6));
        }
      case BinhiMood.worried:
        // Inner ends higher: a little "uh-oh" look.
        canvas
          ..drawLine(_leftEye.translate(-9, -11), _leftEye.translate(7, -17), Sticker.stroke(ink, 2.8))
          ..drawLine(_rightEye.translate(9, -11), _rightEye.translate(-7, -17), Sticker.stroke(ink, 2.8));
      case BinhiMood.happy:
      case BinhiMood.cheering:
        break;
    }

    // Mouth
    const m = _mouth;
    switch (mood) {
      case BinhiMood.happy:
        final smile = Path()
          ..moveTo(m.dx - 9, m.dy - 1)
          ..quadraticBezierTo(m.dx, m.dy + 9, m.dx + 9, m.dy - 1);
        canvas.drawPath(smile, Sticker.stroke(ink, 3.5));
      case BinhiMood.cheering:
        final open = Path()
          ..moveTo(m.dx - 11, m.dy - 3)
          ..quadraticBezierTo(m.dx, m.dy + 17, m.dx + 11, m.dy - 3)
          ..close();
        canvas
          ..drawPath(open, Sticker.solid(ink))
          ..save()
          ..clipPath(open)
          ..drawOval(
            Rect.fromCenter(center: m.translate(0, 8), width: 12, height: 7),
            Sticker.solid(AppColors.bubblegum),
          )
          ..restore()
          ..drawPath(open, Sticker.outline(ink, width: 2));
      case BinhiMood.encouraging:
        final smile = Path()
          ..moveTo(m.dx - 7, m.dy)
          ..quadraticBezierTo(m.dx, m.dy + 6, m.dx + 7, m.dy);
        canvas.drawPath(smile, Sticker.stroke(ink, 3.2));
      case BinhiMood.worried:
        final wobble = Path()
          ..moveTo(m.dx - 8, m.dy + 4)
          ..quadraticBezierTo(m.dx - 4, m.dy, m.dx, m.dy + 2)
          ..quadraticBezierTo(m.dx + 4, m.dy + 4, m.dx + 8, m.dy + 1);
        canvas.drawPath(wobble, Sticker.stroke(ink, 3));
    }
  }

  void _drawSweat(Canvas canvas) {
    final drop = Path()
      ..moveTo(151, 176)
      ..quadraticBezierTo(158, 188, 151, 192)
      ..quadraticBezierTo(144, 188, 151, 176)
      ..close();
    Sticker.shape(canvas, drop, AppColors.sky, AppColors.skyDark, lift: 0.4);
  }

  // ---- outfits ----

  /// Pattern on the lower pot, clipped to its shape and kept under the face.
  void _drawPattern(Canvas canvas, Path body) {
    canvas
      ..save()
      ..clipPath(body)
      ..clipRect(const Rect.fromLTRB(0, 222, 200, 260));
    switch (outfit.pattern) {
      case PotPattern.stripes:
        for (final y in [224.0, 236.0]) {
          canvas.drawRect(Rect.fromLTRB(40, y, 160, y + 6), Sticker.solid(AppColors.coralLight));
        }
      case PotPattern.dots:
        var i = 0;
        for (var x = 58.0; x < 146; x += 14, i++) {
          canvas.drawCircle(
            Offset(x, i.isEven ? 230 : 238),
            4,
            Sticker.solid(i % 3 == 0 ? AppColors.sunshine : AppColors.bubblegumTint),
          );
        }
      case PotPattern.banig:
        // A woven mat band: crossing light strips.
        canvas.drawRect(
          const Rect.fromLTRB(40, 222, 160, 243),
          Sticker.solid(AppColors.coralDark.withValues(alpha: 0.25)),
        );
        final strip = Sticker.stroke(AppColors.sunshineTint.withValues(alpha: 0.85), 3.2);
        for (var x = 30.0; x < 170; x += 10) {
          canvas
            ..drawLine(Offset(x, 222), Offset(x + 12, 243), strip)
            ..drawLine(Offset(x + 12, 222), Offset(x, 243), Sticker.stroke(AppColors.coralLight, 2));
        }
      case PotPattern.flowers:
        // Little five-petal flowers along the band, a leaf between each.
        var i = 0;
        for (var x = 54.0; x < 150; x += 18, i++) {
          final c = Offset(x, i.isEven ? 231 : 236);
          final petal = Sticker.solid(i.isEven ? AppColors.sunshineTint : AppColors.bubblegumTint);
          for (var k = 0; k < 5; k++) {
            final a = k * 2 * math.pi / 5 - math.pi / 2;
            canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * 3.6, 3, petal);
          }
          canvas.drawCircle(c, 2.4, Sticker.solid(AppColors.sunshineDark));
          if (x + 9 < 150) {
            canvas.drawOval(
              Rect.fromCenter(center: Offset(x + 9, i.isEven ? 238 : 229), width: 7, height: 4),
              Sticker.solid(AppColors.leafDark.withValues(alpha: 0.7)),
            );
          }
        }
      case PotPattern.jeepney:
        for (final (y, h, c) in const [
          (224.0, 5.0, AppColors.hibiscusRed),
          (230.0, 3.5, AppColors.sunshine),
          (234.5, 3.5, AppColors.skyDark),
        ]) {
          canvas.drawRect(Rect.fromLTRB(40, y, 160, y + h), Sticker.solid(c));
        }
      case PotPattern.waves:
        for (final y in [229.0, 239.0]) {
          final wave = Path()..moveTo(40, y);
          for (var x = 40.0; x < 160; x += 16) {
            wave.quadraticBezierTo(x + 4, y - 5, x + 8, y);
            wave.quadraticBezierTo(x + 12, y + 5, x + 16, y);
          }
          canvas.drawPath(wave, Sticker.stroke(AppColors.skyLight, 3.4));
        }
      case PotPattern.picnic:
        final check = Sticker.solid(AppColors.card.withValues(alpha: 0.5));
        for (var y = 222.0; y < 244; y += 8) {
          canvas.drawRect(Rect.fromLTRB(40, y, 160, y + 4), check);
        }
        for (var x = 44.0; x < 160; x += 8) {
          canvas.drawRect(Rect.fromLTRB(x, 222, x + 4, 244), check);
        }
      case PotPattern.pakwan:
        canvas
          ..drawRect(const Rect.fromLTRB(40, 222, 160, 236), Sticker.solid(const Color(0xFFFF6F7F)))
          ..drawRect(const Rect.fromLTRB(40, 236, 160, 238), Sticker.solid(AppColors.leafTint))
          ..drawRect(const Rect.fromLTRB(40, 238, 160, 244), Sticker.solid(AppColors.leaf));
        var i = 0;
        for (var x = 60.0; x < 142; x += 14, i++) {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, i.isEven ? 228 : 232), width: 3.4, height: 5),
            Sticker.solid(AppColors.text),
          );
        }
      case PotPattern.rainbow:
        for (final (i, c) in const [AppColors.hibiscusRed, AppColors.sunshine, AppColors.leaf, AppColors.sky].indexed) {
          canvas.drawRect(Rect.fromLTRB(40, 222 + i * 5.4, 160, 227.4 + i * 5.4), Sticker.solid(c));
        }
      case PotPattern.capiz:
        var i = 0;
        for (var x = 54.0; x < 150; x += 13, i++) {
          final sq = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, i.isEven ? 230 : 236), width: 10, height: 10),
            const Radius.circular(2),
          );
          canvas
            ..drawRRect(sq, Sticker.solid(const Color(0xFFF7F3FF)))
            ..drawRRect(sq, Sticker.stroke(const Color(0xFFC9B48A), 1.2))
            ..drawCircle(sq.center.translate(-2, -2), 1.4, Sticker.solid(const Color(0xFFFFFFFF)));
        }
      case PotPattern.plain:
        break;
    }
    canvas.restore();
  }

  /// White sampaguita flowers strung along the front of the rim.
  void _drawGarland(Canvas canvas) {
    final string = Path()
      ..moveTo(44, 166)
      ..quadraticBezierTo(100, 192, 156, 166);
    canvas.drawPath(string, Sticker.stroke(AppColors.leafDark, 2));
    final metric = string.computeMetrics().first;
    for (var i = 0; i <= 8; i++) {
      final at = metric.getTangentForOffset(metric.length * i / 8)!.position;
      Sticker.flower(
        canvas,
        at,
        7,
        petals: 6,
        petal: AppColors.card,
        petalOutline: AppColors.borderDeep,
        rotation: i * 0.5,
      );
    }
  }

  void _drawSunglasses(Canvas canvas) {
    const frame = AppColors.text;
    for (final e in [_leftEye, _rightEye]) {
      final lens = RRect.fromRectAndRadius(
        Rect.fromCenter(center: e.translate(0, 1), width: 26, height: 18),
        const Radius.circular(8),
      );
      canvas
        ..drawRRect(lens, Sticker.solid(frame))
        ..drawLine(e.translate(-7, -3), e.translate(-2, -6), Sticker.stroke(AppColors.skyLight, 2.4));
    }
    canvas
      ..drawLine(_leftEye.translate(13, -1), _rightEye.translate(-13, -1), Sticker.stroke(frame, 3))
      ..drawLine(_leftEye.translate(-13, -2), _leftEye.translate(-22, -6), Sticker.stroke(frame, 3))
      ..drawLine(_rightEye.translate(13, -2), _rightEye.translate(22, -6), Sticker.stroke(frame, 3));
  }

  /// A woven salakot tipped jauntily on the left side of the rim.
  void _drawSalakot(Canvas canvas) {
    canvas
      ..save()
      ..translate(70, 146)
      ..rotate(-0.28);
    final hat = Path()
      ..moveTo(-36, 6)
      ..quadraticBezierTo(0, -30, 36, 6)
      ..quadraticBezierTo(0, 12, -36, 6)
      ..close();
    const straw = Color(0xFFE2B356);
    Sticker.shape(canvas, hat, straw, AppColors.barkDark, width: 2.4);
    final weave = Sticker.stroke(AppColors.barkDark.withValues(alpha: 0.35), 1.4);
    for (var i = -2; i <= 2; i++) {
      canvas.drawLine(Offset(i * 12.0, 8), const Offset(0, -16), weave);
    }
    canvas
      ..drawCircle(const Offset(0, -16), 3.2, Sticker.solid(AppColors.coralDark))
      ..restore();
  }

  // ---- more outfits (PLAN.md §5m) ----

  void _drawNeck(Canvas canvas) {
    switch (outfit.neck) {
      case BinhiNeck.garland:
        _drawGarland(canvas);
      case BinhiNeck.bowTie:
        const c = Offset(100, 178);
        for (final side in [-1.0, 1.0]) {
          final wing = Path()
            ..moveTo(c.dx, c.dy)
            ..lineTo(c.dx + side * 18, c.dy - 9)
            ..quadraticBezierTo(c.dx + side * 22, c.dy, c.dx + side * 18, c.dy + 9)
            ..close();
          Sticker.shape(canvas, wing, AppColors.hibiscusRed, AppColors.hibiscusDark, width: 2.2);
        }
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCircle(center: c, radius: 5)),
          AppColors.hibiscusDark,
          AppColors.hibiscusDark,
          width: 1.5,
        );
      case BinhiNeck.scarf:
        final band = Path()
          ..moveTo(44, 168)
          ..quadraticBezierTo(100, 186, 156, 168)
          ..lineTo(155, 178)
          ..quadraticBezierTo(100, 196, 45, 178)
          ..close();
        Sticker.shape(canvas, band, AppColors.sky, AppColors.skyDark, width: 2.2);
        final tail = Path()
          ..moveTo(124, 180)
          ..lineTo(134, 210)
          ..lineTo(122, 208)
          ..lineTo(114, 184)
          ..close();
        Sticker.shape(canvas, tail, AppColors.sky, AppColors.skyDark, width: 2.2);
        final stitch = Path()
          ..moveTo(52, 175)
          ..quadraticBezierTo(100, 191, 148, 175);
        for (final metric in stitch.computeMetrics()) {
          for (var d = 0.0; d < metric.length; d += 9) {
            canvas.drawPath(metric.extractPath(d, d + 4.5), Sticker.stroke(const Color(0xFFFFFFFF), 1.8));
          }
        }
      case null:
        break;
    }
  }

  void _drawGlasses(Canvas canvas) {
    switch (outfit.glasses) {
      case BinhiGlasses.sunglasses:
        _drawSunglasses(canvas);
      case BinhiGlasses.round:
        final frame = Sticker.stroke(AppColors.barkDark, 3);
        for (final e in [_leftEye, _rightEye]) {
          canvas
            ..drawCircle(e, 13, Sticker.solid(const Color(0x33FFFFFF)))
            ..drawCircle(e, 13, frame);
        }
        canvas.drawPath(
          Path()
            ..moveTo(_leftEye.dx + 13, _leftEye.dy - 1)
            ..quadraticBezierTo(100, _leftEye.dy - 6, _rightEye.dx - 13, _rightEye.dy - 1),
          frame,
        );
      case BinhiGlasses.hearts:
        for (final e in [_leftEye, _rightEye]) {
          final heart = Path()
            ..moveTo(e.dx, e.dy + 11)
            ..cubicTo(e.dx - 18, e.dy, e.dx - 13, e.dy - 15, e.dx - 5, e.dy - 11)
            ..cubicTo(e.dx - 2, e.dy - 10, e.dx, e.dy - 7, e.dx, e.dy - 5)
            ..cubicTo(e.dx, e.dy - 7, e.dx + 2, e.dy - 10, e.dx + 5, e.dy - 11)
            ..cubicTo(e.dx + 13, e.dy - 15, e.dx + 18, e.dy, e.dx, e.dy + 11)
            ..close();
          Sticker.shape(canvas, heart, AppColors.hibiscusRed, AppColors.hibiscusDark, width: 2.2, lift: 0.3);
          canvas.drawCircle(e.translate(-6, -5), 2.2, Sticker.solid(const Color(0xAAFFFFFF)));
        }
        canvas.drawLine(
          _leftEye.translate(12, -2),
          _rightEye.translate(-12, -2),
          Sticker.stroke(AppColors.hibiscusDark, 3),
        );
      case BinhiGlasses.goggles:
        canvas.drawLine(
          Offset(48, _leftEye.dy - 1),
          Offset(152, _rightEye.dy - 1),
          Sticker.stroke(AppColors.barkDark, 5),
        );
        for (final e in [_leftEye, _rightEye]) {
          canvas
            ..drawCircle(e, 13, Sticker.solid(AppColors.skyLight.withValues(alpha: 0.6)))
            ..drawCircle(e, 13, Sticker.stroke(const Color(0xFF5B6474), 4.5))
            ..drawArc(
              Rect.fromCircle(center: e, radius: 8),
              3.6,
              1.1,
              false,
              Sticker.stroke(const Color(0xFFFFFFFF), 2),
            );
        }
      case null:
        break;
    }
  }

  void _drawHat(Canvas canvas) {
    switch (outfit.hat) {
      case BinhiHat.salakot:
        _drawSalakot(canvas);
      case BinhiHat.crown:
        // A ring of little flowers around the top of the rim.
        const colours = [
          AppColors.hibiscusRed,
          AppColors.sunshine,
          AppColors.card,
          AppColors.bubblegum,
          AppColors.citrusOrange,
          AppColors.card,
          AppColors.hibiscusRed,
        ];
        canvas.drawPath(
          Path()
            ..moveTo(44, 152)
            ..quadraticBezierTo(100, 144, 156, 152),
          Sticker.stroke(AppColors.leafDark, 3),
        );
        for (var i = 0; i < colours.length; i++) {
          final x = 48 + i * 17.3;
          final y = 151 - math.sin(i / (colours.length - 1) * math.pi) * 5;
          if (i < colours.length - 1) Sticker.leaf(canvas, Offset(x + 8, y + 3), 1.3, 9, 4);
          Sticker.flower(
            canvas,
            Offset(x, y),
            8,
            petal: colours[i],
            petalOutline: Sticker.darken(colours[i] == AppColors.card ? AppColors.borderDeep : colours[i], 0.2),
            rotation: i * 0.6,
          );
        }
      case BinhiHat.strawHat:
        canvas
          ..save()
          ..translate(70, 148)
          ..rotate(-0.25);
        const straw = Color(0xFFF2D27A);
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCenter(center: const Offset(0, 4), width: 78, height: 16)),
          straw,
          AppColors.barkDark,
          width: 2.4,
        );
        Sticker.shape(
          canvas,
          Path()
            ..moveTo(-22, 4)
            ..quadraticBezierTo(-22, -22, 0, -22)
            ..quadraticBezierTo(22, -22, 22, 4)
            ..close(),
          straw,
          AppColors.barkDark,
          width: 2.4,
        );
        canvas
          ..drawPath(
            Path()
              ..moveTo(-21, -2)
              ..quadraticBezierTo(0, 4, 21, -2),
            Sticker.stroke(AppColors.bubblegumDark, 5),
          )
          ..restore();
      case BinhiHat.bandana:
        final band = RRect.fromLTRBR(36, 147, 164, 165, const Radius.circular(9));
        Sticker.shape(canvas, Path()..addRRect(band), AppColors.hibiscusRed, AppColors.hibiscusDark, width: 2.4);
        for (var x = 48.0; x < 156; x += 14) {
          canvas.drawCircle(Offset(x, 156), 2, Sticker.solid(const Color(0xFFFFFFFF)));
        }
        for (final (dx, dy) in const [(14.0, -8.0), (16.0, 8.0)]) {
          final tail = Path()
            ..moveTo(160, 156)
            ..lineTo(160 + dx, 156 + dy - 4)
            ..lineTo(160 + dx - 2, 156 + dy + 4)
            ..close();
          Sticker.shape(canvas, tail, AppColors.hibiscusRed, AppColors.hibiscusDark, width: 2);
        }
      case BinhiHat.gradCap:
        canvas
          ..save()
          ..translate(72, 142)
          ..rotate(-0.2);
        const cloth = Color(0xFF2B3148);
        Sticker.shape(
          canvas,
          Path()
            ..moveTo(-18, 0)
            ..quadraticBezierTo(0, 8, 18, 0)
            ..lineTo(18, 10)
            ..quadraticBezierTo(0, 18, -18, 10)
            ..close(),
          cloth,
          cloth,
          width: 2,
        );
        Sticker.shape(
          canvas,
          Path()
            ..moveTo(-38, -4)
            ..lineTo(0, -16)
            ..lineTo(38, -4)
            ..lineTo(0, 8)
            ..close(),
          cloth,
          const Color(0xFF111628),
          width: 2,
        );
        canvas
          ..drawPath(
            Path()
              ..moveTo(0, -4)
              ..lineTo(28, 2)
              ..lineTo(28, 18),
            Sticker.stroke(AppColors.sunshine, 2.4),
          )
          ..drawCircle(const Offset(28, 21), 4, Sticker.solid(AppColors.sunshine))
          ..restore();
      case null:
        break;
    }
  }

  /// The little friend, gently moving with Binhi's breathing.
  void _drawFriend(Canvas canvas, BinhiPose p) {
    final t = p.breathe;
    final wave = math.sin(t * math.pi * 2);
    final flap = 0.55 + 0.45 * math.sin(t * math.pi * 14).abs();
    final ink = Sticker.stroke(AppColors.text, 2);
    switch (outfit.friend) {
      case BinhiFriend.butterfly:
        canvas
          ..save()
          ..translate(164 + wave * 4, 100 - wave * 6)
          ..scale(1.5)
          ..rotate(0.15 * wave);
        for (final side in [-1.0, 1.0]) {
          canvas
            ..save()
            ..scale(side * flap, 1);
          final wing = Path()
            ..moveTo(0, 0)
            ..cubicTo(12, -16, 20, -2, 10, 4)
            ..cubicTo(18, 12, 6, 18, 0, 4)
            ..close();
          Sticker.shape(canvas, wing, AppColors.bubblegum, AppColors.text, width: 1.8, lift: 0.3);
          canvas.restore();
        }
        canvas
          ..drawLine(const Offset(0, -6), const Offset(0, 10), Sticker.stroke(AppColors.text, 2.6))
          ..restore();
      case BinhiFriend.ladybug:
        canvas
          ..save()
          ..translate(150 + wave * 3, 150)
          ..scale(1.5);
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCenter(center: Offset.zero, width: 18, height: 14)),
          AppColors.hibiscusRed,
          AppColors.text,
          width: 1.8,
        );
        canvas
          ..drawLine(const Offset(0, -7), const Offset(0, 7), ink)
          ..drawCircle(const Offset(-9, 0), 4, Sticker.solid(AppColors.text))
          ..drawCircle(const Offset(-3, -2.5), 1.6, Sticker.solid(AppColors.text))
          ..drawCircle(const Offset(4, 2.5), 1.6, Sticker.solid(AppColors.text))
          ..drawCircle(const Offset(4, -3), 1.3, Sticker.solid(AppColors.text))
          ..restore();
      case BinhiFriend.bee:
        canvas
          ..save()
          ..translate(38 + wave * 5, 116 + math.sin(t * math.pi * 6) * 4)
          ..scale(1.5);
        canvas
          ..save()
          ..translate(0, -9)
          ..scale(1, flap);
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCenter(center: Offset.zero, width: 11, height: 8)),
          AppColors.skyTint,
          AppColors.sky,
          width: 1.2,
        );
        canvas.restore();
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCenter(center: Offset.zero, width: 18, height: 13)),
          AppColors.sunshine,
          AppColors.text,
          width: 1.8,
        );
        canvas
          ..drawLine(const Offset(-2, -6), const Offset(-2, 6), Sticker.stroke(AppColors.text, 2.2))
          ..drawLine(const Offset(3, -5.5), const Offset(3, 5.5), Sticker.stroke(AppColors.text, 2.2))
          ..restore();
      case BinhiFriend.bird:
        canvas
          ..save()
          ..translate(146, 134 - math.max(0, wave) * 3)
          ..scale(1.5);
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCenter(center: Offset.zero, width: 22, height: 17)),
          AppColors.sky,
          AppColors.text,
          width: 1.8,
        );
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCircle(center: const Offset(8, -7), radius: 7)),
          AppColors.sky,
          AppColors.text,
          width: 1.8,
        );
        canvas
          ..drawCircle(const Offset(10, -8), 1.6, Sticker.solid(AppColors.text))
          ..drawPath(
            Path()
              ..moveTo(15, -7)
              ..lineTo(21, -5.5)
              ..lineTo(15, -3.5)
              ..close(),
            Sticker.solid(AppColors.sunshine),
          )
          ..drawPath(
            Path()
              ..moveTo(-5, -2)
              ..quadraticBezierTo(-10, 5, 2, 5),
            Sticker.stroke(AppColors.skyDark, 2),
          )
          ..drawLine(const Offset(-2, 8), const Offset(-3, 12), ink)
          ..drawLine(const Offset(3, 8), const Offset(3, 12), ink)
          ..restore();
      case null:
        break;
    }
  }

  @override
  bool shouldRepaint(BinhiPainter old) => old.stage != stage || old.mood != mood || old.outfit != outfit;
}
