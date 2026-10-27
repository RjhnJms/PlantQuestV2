import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';
import 'avatar_spec.dart';

/// How the avatars are drawn. The app uses [outfits] (PLAN.md D15); the
/// others stay for the comparison sheets in tool/render_avatars_test.dart.
enum AvatarLook {
  now('Now', 'Today\'s avatars'),
  polished('A · Polished', 'Sparkly eyes, a smile, a sunny background'),
  outfits('B · Filipino outfits', 'Polished, in barong, uniforms and Filipiniana');

  const AvatarLook(this.title, this.line);
  final String title;
  final String line;
}

enum _Outfit { barong, schoolTie, schoolBow, scout, jersey, filipiniana }

/// Draws a kid's head-and-shoulders portrait in a circle, in a 100×100
/// design box scaled to the canvas.
///
/// Layers, back to front: background, back hair, neck, shirt, braid, ears,
/// head, face, front hair, accessories.
class AvatarPainter extends CustomPainter {
  const AvatarPainter(this.spec, {this.look = AvatarLook.outfits});

  final AvatarSpec spec;
  final AvatarLook look;

  bool get _fancy => look != AvatarLook.now;

  static const _w = 1.8; // outline width in design units
  static const _head = Offset(50, 47);
  static const _leftEye = Offset(42.5, 51);
  static const _rightEye = Offset(57.5, 51);

  Color get _hairLine => Sticker.darken(spec.hair, 0.3);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 100;
    canvas
      ..save()
      ..translate((size.width - 100 * s) / 2, (size.height - 100 * s) / 2)
      ..scale(s);

    final circle = Rect.fromCircle(center: const Offset(50, 50), radius: 50);
    canvas.drawOval(circle, Sticker.fill(circle, spec.background, lift: 0.35));
    if (_fancy) _rays(canvas, circle);
    canvas
      ..save()
      ..clipPath(Path()..addOval(circle));

    _backHair(canvas);
    _neckAndShirt(canvas);
    if (look == AvatarLook.outfits) _outfit(canvas);
    if (look == AvatarLook.polished) _badge(canvas);
    if (spec.hairStyle == HairStyle.braid) _braid(canvas);
    _headAndFace(canvas);
    _frontHair(canvas);
    if (_fancy) _hairShine(canvas);
    _accessories(canvas);

    canvas.restore();
    if (_fancy) {
      // A white sticker rim with a thin colored line, like the plant tiles.
      canvas
        ..drawCircle(const Offset(50, 50), 48.2, Sticker.stroke(const Color(0xFFFFFFFF), 3.6))
        ..drawCircle(const Offset(50, 50), 49.6, Sticker.stroke(Sticker.darken(spec.background, 0.18), 1.2));
    }
    canvas.restore();
  }

  void _hairShape(Canvas canvas, Path path) => Sticker.shape(canvas, path, spec.hair, _hairLine, width: _w, lift: 0.18);

  void _hairBlobs(Canvas canvas, List<(Offset, double)> blobs) {
    final path = Path();
    for (final (c, r) in blobs) {
      path.addOval(Rect.fromCircle(center: c, radius: r));
    }
    // Outline the blobs first, then fill over the inner seams so the
    // cluster reads as one soft shape.
    for (final (c, r) in blobs) {
      canvas.drawCircle(c, r, Sticker.outline(_hairLine, width: _w * 2));
    }
    canvas.drawPath(path, Sticker.fill(path.getBounds(), spec.hair, lift: 0.18));
  }

  void _backHair(Canvas canvas) {
    switch (spec.hairStyle) {
      case HairStyle.afro:
        _hairBlobs(canvas, [
          for (var a = 150.0; a <= 390; a += 30)
            (_head.translate(22 * math.cos(a * math.pi / 180), -4 + 21 * math.sin(a * math.pi / 180)), 11.5),
          (_head.translate(0, -6), 25),
        ]);
      case HairStyle.longBangs:
        _hairShape(canvas, Path()..addRRect(RRect.fromLTRBR(23, 26, 77, 86, const Radius.circular(22))));
      case HairStyle.pigtails:
        _hairShape(canvas, Path()..addOval(Rect.fromCenter(center: const Offset(21, 56), width: 16, height: 24)));
        _hairShape(canvas, Path()..addOval(Rect.fromCenter(center: const Offset(79, 56), width: 16, height: 24)));
      case HairStyle.puffs:
        _hairBlobs(canvas, [(const Offset(30, 25), 13), (const Offset(70, 25), 13)]);
      case HairStyle.ponytail:
        _hairShape(
          canvas,
          Path()
            ..moveTo(64, 28)
            ..cubicTo(90, 26, 92, 60, 82, 76)
            ..quadraticBezierTo(77, 58, 68, 44)
            ..close(),
        );
      case HairStyle.bob:
        _hairShape(
          canvas,
          Path()
            ..moveTo(25, 66)
            ..cubicTo(19, 30, 33, 18, 50, 18)
            ..cubicTo(67, 18, 81, 30, 75, 66)
            ..quadraticBezierTo(70, 70, 66, 65)
            ..lineTo(34, 65)
            ..quadraticBezierTo(30, 70, 25, 66)
            ..close(),
        );
      case HairStyle.braid:
        _hairShape(canvas, Path()..addRRect(RRect.fromLTRBR(26, 26, 74, 70, const Radius.circular(20))));
      case HairStyle.cap:
      case HairStyle.spiky:
      case HairStyle.sidePart:
      case HairStyle.curlyTop:
      case HairStyle.bowl:
        break;
    }
  }

  void _neckAndShirt(Canvas canvas) {
    Sticker.auto(canvas, Path()..addRect(const Rect.fromLTRB(43.5, 58, 56.5, 80)), spec.skin, width: _w, lift: 0);
    final shirt = Path()
      ..moveTo(12, 102)
      ..lineTo(15, 90)
      ..quadraticBezierTo(19, 76, 35, 74)
      ..lineTo(42, 74)
      ..quadraticBezierTo(50, 83, 58, 74)
      ..lineTo(65, 74)
      ..quadraticBezierTo(81, 76, 85, 90)
      ..lineTo(88, 102)
      ..close();
    Sticker.auto(canvas, shirt, spec.shirt, width: _w);
    // Collar trim
    final collar = Path()
      ..moveTo(42, 74)
      ..quadraticBezierTo(50, 83, 58, 74);
    canvas.drawPath(collar, Sticker.stroke(Color.lerp(spec.shirt, const Color(0xFFFFFFFF), 0.5)!, 2.4));
  }

  void _braid(Canvas canvas) {
    for (var i = 0; i < 4; i++) {
      final c = Offset(70 + i * 1.6, 64 + i * 8.5);
      final rect = Rect.fromCenter(center: c, width: 11 - i * 0.8, height: 10);
      canvas
        ..drawOval(rect, Sticker.fill(rect, spec.hair, lift: 0.25))
        ..drawOval(rect, Sticker.outline(_hairLine, width: _w));
    }
    // Tie at the end of the braid
    canvas.drawCircle(const Offset(75.5, 96), 3, Sticker.solid(spec.accent));
  }

  void _headAndFace(Canvas canvas) {
    final skinLine = Sticker.darken(spec.skin, 0.28);
    for (final x in [29.5, 70.5]) {
      final ear = Rect.fromCircle(center: Offset(x, 51), radius: 5.5);
      canvas
        ..drawOval(ear, Sticker.solid(spec.skin))
        ..drawOval(ear, Sticker.outline(skinLine, width: _w));
    }
    final head = Rect.fromCenter(center: _head, width: 42, height: 46);
    canvas
      ..drawOval(head, Sticker.fill(head, spec.skin, lift: 0.14))
      ..drawOval(head, Sticker.outline(skinLine, width: _w));

    // Blush
    for (final x in [36.5, 63.5]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 57.5), width: 7.5, height: 4.2),
        Sticker.solid(AppColors.bubblegum.withValues(alpha: spec.skin.computeLuminance() < 0.2 ? 0.6 : 0.45)),
      );
    }
    // Eyes with a sparkle (bigger and shinier in the new looks)
    for (final e in [_leftEye, _rightEye]) {
      if (_fancy) {
        canvas
          ..drawOval(Rect.fromCenter(center: e, width: 6.4, height: 7.6), Sticker.solid(AppColors.text))
          ..drawCircle(e.translate(1.3, -1.6), 1.6, Sticker.solid(const Color(0xFFFFFFFF)))
          ..drawCircle(e.translate(-1.4, 1.8), 0.8, Sticker.solid(const Color(0xFFFFFFFF)));
        if (spec.isGirl) {
          final side = e.dx < 50 ? -1.0 : 1.0;
          canvas.drawLine(
            e.translate(side * 3.0, -2.6),
            e.translate(side * 4.6, -3.8),
            Sticker.stroke(AppColors.text, 1.1),
          );
        }
      } else {
        canvas
          ..drawOval(Rect.fromCenter(center: e, width: 5.2, height: 6.2), Sticker.solid(AppColors.text))
          ..drawCircle(e.translate(1.1, -1.3), 1.15, Sticker.solid(const Color(0xFFFFFFFF)));
      }
    }
    // Brows
    final brow = Sticker.stroke(_hairLine, 1.7);
    canvas
      ..drawLine(const Offset(39.5, 45.2), const Offset(45.2, 44.4), brow)
      ..drawLine(const Offset(54.8, 44.4), const Offset(60.5, 45.2), brow);
    if (_fancy) {
      // A little nose and a happy open smile.
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(50, 55.2), width: 3.4, height: 2.4),
        0.3,
        2.5,
        false,
        Sticker.stroke(skinLine, 1.2),
      );
      final mouth = Path()
        ..moveTo(44.6, 58.6)
        ..quadraticBezierTo(50, 59.6, 55.4, 58.6)
        ..quadraticBezierTo(54.6, 65, 50, 65)
        ..quadraticBezierTo(45.4, 65, 44.6, 58.6)
        ..close();
      canvas
        ..drawPath(mouth, Sticker.solid(const Color(0xFF7A2E3A)))
        ..save()
        ..clipPath(mouth)
        ..drawOval(
          Rect.fromCenter(center: const Offset(50, 65), width: 7, height: 4.6),
          Sticker.solid(AppColors.coralLight),
        )
        ..restore()
        ..drawPath(mouth, Sticker.stroke(AppColors.text, 1.2));
      return;
    }
    // Smile
    final smile = Path()
      ..moveTo(45, 58.6)
      ..quadraticBezierTo(50, 63.2, 55, 58.6);
    canvas.drawPath(smile, Sticker.stroke(AppColors.text, 1.9));
  }

  /// Hairline running from the right temple across the forehead to the
  /// left temple. Most front-hair shapes close with it.
  Path _topCap({double hairline = 36, double side = 52}) => Path()
    ..moveTo(28.5, side)
    ..cubicTo(25, 28, 37, 20.5, 50, 20.5)
    ..cubicTo(63, 20.5, 75, 28, 71.5, side)
    ..lineTo(70, hairline + 6)
    ..quadraticBezierTo(50, hairline - 4, 30, hairline + 6)
    ..close();

  void _frontHair(Canvas canvas) {
    switch (spec.hairStyle) {
      case HairStyle.cap:
        // Short sides peeking out under the cap
        _hairShape(
          canvas,
          Path()
            ..moveTo(29, 52)
            ..quadraticBezierTo(28, 41, 33, 37)
            ..lineTo(67, 37)
            ..quadraticBezierTo(72, 41, 71, 52)
            ..lineTo(68, 44)
            ..lineTo(32, 44)
            ..close(),
        );
        _cap(canvas);
      case HairStyle.spiky:
        final path = Path()..moveTo(29, 48);
        const center = Offset(50, 44);
        var i = 0;
        for (var a = 188.0; a <= 352; a += 20.5, i++) {
          final r = i.isEven ? 24.0 : 31.0;
          final rad = a * math.pi / 180;
          path.lineTo(center.dx + r * math.cos(rad), center.dy + r * math.sin(rad));
        }
        path
          ..lineTo(71, 48)
          ..lineTo(70, 42)
          ..quadraticBezierTo(60, 33, 50, 37)
          ..quadraticBezierTo(40, 33, 30, 42)
          ..close();
        _hairShape(canvas, path);
      case HairStyle.afro:
        _hairBlobs(canvas, [for (var x = 33.0; x <= 67; x += 8.5) (Offset(x, 31 + (x - 50).abs() * 0.18), 6.5)]);
      case HairStyle.sidePart:
        _hairShape(
          canvas,
          Path()
            ..moveTo(28.5, 52)
            ..cubicTo(25, 29, 36, 20.5, 51, 20.5)
            ..cubicTo(66, 20.5, 76, 29, 71.5, 52)
            ..lineTo(70, 43)
            ..quadraticBezierTo(66, 35, 56, 34)
            ..quadraticBezierTo(44, 36, 37, 31)
            ..quadraticBezierTo(32, 39, 30.5, 48)
            ..close(),
        );
      case HairStyle.curlyTop:
        _hairShape(canvas, _topCap(hairline: 32, side: 46));
        _hairBlobs(canvas, [
          for (var a = 196.0; a <= 344; a += 21)
            (_head.translate(21 * math.cos(a * math.pi / 180), -3 + 21 * math.sin(a * math.pi / 180)), 6.8),
        ]);
      case HairStyle.bowl:
        _hairShape(
          canvas,
          Path()
            ..moveTo(28, 54)
            ..cubicTo(24, 26, 39, 19, 50, 19)
            ..cubicTo(61, 19, 76, 26, 72, 54)
            ..lineTo(70, 43)
            ..quadraticBezierTo(50, 47, 30, 43)
            ..close(),
        );
      case HairStyle.longBangs:
        _hairShape(
          canvas,
          Path()
            ..moveTo(28, 54)
            ..cubicTo(25, 26, 38, 20, 50, 20)
            ..cubicTo(62, 20, 75, 26, 72, 54)
            ..lineTo(70, 41)
            ..quadraticBezierTo(62, 41, 58, 34)
            ..quadraticBezierTo(52, 42, 42, 40)
            ..quadraticBezierTo(34, 39, 30, 46)
            ..close(),
        );
      case HairStyle.pigtails:
      case HairStyle.braid:
        _hairShape(canvas, _topCap(hairline: 34));
        canvas.drawLine(const Offset(50, 21.5), const Offset(50, 31), Sticker.stroke(_hairLine, 1.4));
      case HairStyle.puffs:
        _hairShape(canvas, _topCap(hairline: 33, side: 48));
      case HairStyle.ponytail:
        _hairShape(
          canvas,
          Path()
            ..moveTo(28.5, 50)
            ..cubicTo(26, 28, 38, 20.5, 51, 20.5)
            ..cubicTo(64, 20.5, 74, 28, 71.5, 50)
            ..lineTo(70, 41)
            ..quadraticBezierTo(58, 30, 41, 34)
            ..quadraticBezierTo(33, 37, 30, 45)
            ..close(),
        );
      case HairStyle.bob:
        _hairShape(
          canvas,
          Path()
            ..moveTo(29, 47)
            ..cubicTo(28, 26, 40, 20.5, 50, 20.5)
            ..cubicTo(60, 20.5, 72, 26, 71, 47)
            ..lineTo(70, 40)
            ..lineTo(30, 40)
            ..close(),
        );
    }
  }

  void _cap(Canvas canvas) {
    final dome = Path()
      ..moveTo(27, 41)
      ..cubicTo(26, 16, 74, 16, 73, 41)
      ..quadraticBezierTo(50, 35, 27, 41)
      ..close();
    final brim = Path()
      ..moveTo(50, 39)
      ..quadraticBezierTo(74, 31, 88, 39)
      ..quadraticBezierTo(76, 45, 56, 42)
      ..close();
    Sticker.auto(canvas, brim, Sticker.darken(spec.accent, 0.08), width: _w);
    Sticker.auto(canvas, dome, spec.accent, width: _w);
    final badge = Rect.fromCircle(center: const Offset(46, 30), radius: 4);
    canvas
      ..drawOval(badge, Sticker.solid(AppColors.sunshine))
      ..drawOval(badge, Sticker.outline(AppColors.sunshineDark, width: 1.2))
      ..drawCircle(const Offset(50, 20.5), 2.2, Sticker.solid(Sticker.darken(spec.accent, 0.15)));
  }

  void _accessories(Canvas canvas) {
    final a = spec.accessories;
    if (a.contains(Accessory.hairTies)) {
      final ties = switch (spec.hairStyle) {
        HairStyle.pigtails => [const Offset(25, 45), const Offset(75, 45)],
        HairStyle.puffs => [const Offset(36, 33), const Offset(64, 33)],
        HairStyle.ponytail => [const Offset(70, 31)],
        _ => const <Offset>[],
      };
      for (final t in ties) {
        final r = Rect.fromCircle(center: t, radius: 3.4);
        canvas
          ..drawOval(r, Sticker.fill(r, spec.accent, lift: 0.3))
          ..drawOval(r, Sticker.outline(Sticker.darken(spec.accent, 0.25), width: 1.2));
      }
    }
    if (a.contains(Accessory.headband)) {
      final band = Path()
        ..moveTo(29.5, 40)
        ..quadraticBezierTo(50, 14, 70.5, 40);
      canvas
        ..drawPath(band, Sticker.stroke(Sticker.darken(spec.accent, 0.25), 6))
        ..drawPath(band, Sticker.stroke(spec.accent, 4));
    }
    if (a.contains(Accessory.sprout)) {
      final stem = Path()
        ..moveTo(50, 22)
        ..quadraticBezierTo(51.5, 16, 50, 11);
      canvas
        ..drawPath(stem, Sticker.stroke(AppColors.leafDark, 3.6))
        ..drawPath(stem, Sticker.stroke(AppColors.leaf, 1.8));
      Sticker.leaf(canvas, const Offset(50, 12), -1.0, 11, 4.5, vein: false);
      Sticker.leaf(canvas, const Offset(50, 12), 1.0, 11, 4.5, vein: false);
    }
    if (a.contains(Accessory.flowerClip)) {
      // A little white sampaguita in her hair.
      Sticker.flower(
        canvas,
        const Offset(35, 30),
        7.5,
        petal: AppColors.card,
        petalOutline: AppColors.borderDeep,
        rotation: 0.4,
      );
    }
    if (a.contains(Accessory.glasses)) {
      final frame = Sticker.stroke(AppColors.text, 1.5);
      for (final e in [_leftEye, _rightEye]) {
        canvas
          ..drawCircle(e, 6.2, Sticker.solid(const Color(0xFFFFFFFF).withValues(alpha: 0.18)))
          ..drawCircle(e, 6.2, frame);
      }
      canvas
        ..drawLine(const Offset(48.7, 50.5), const Offset(51.3, 50.5), frame)
        ..drawLine(const Offset(36.3, 50), const Offset(30.5, 48.5), frame)
        ..drawLine(const Offset(63.7, 50), const Offset(69.5, 48.5), frame);
    }
  }

  // ------------------------------------------------------------ new looks

  /// Soft sun rays and two tiny leaves behind the kid.
  void _rays(Canvas canvas, Rect circle) {
    canvas
      ..save()
      ..clipPath(Path()..addOval(circle));
    final ray = Sticker.solid(const Color(0xFFFFFFFF).withValues(alpha: 0.28));
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      canvas.drawPath(
        Path()
          ..moveTo(50, 42)
          ..lineTo(50 + 80 * math.cos(a - 0.12), 42 + 80 * math.sin(a - 0.12))
          ..lineTo(50 + 80 * math.cos(a + 0.12), 42 + 80 * math.sin(a + 0.12))
          ..close(),
        ray,
      );
    }
    Sticker.leaf(canvas, const Offset(14, 30), -0.6, 9, 4, vein: false);
    Sticker.leaf(canvas, const Offset(86, 26), 0.7, 8, 3.6, vein: false);
    canvas.restore();
  }

  /// A white streak of shine on the hair.
  void _hairShine(Canvas canvas) {
    if (spec.hairStyle == HairStyle.cap) return;
    final shine = Path()
      ..moveTo(36, 30)
      ..quadraticBezierTo(42, 23.5, 51, 23.2);
    canvas.drawPath(shine, Sticker.stroke(const Color(0xFFFFFFFF).withValues(alpha: 0.55), 2.2));
  }

  /// A PlantQuest leaf badge on the shirt.
  void _badge(Canvas canvas) {
    final c = Rect.fromCircle(center: const Offset(63, 89), radius: 5);
    canvas
      ..drawOval(c, Sticker.solid(const Color(0xFFFFFFFF)))
      ..drawOval(c, Sticker.outline(Sticker.darken(spec.shirt, 0.3), width: 1.1));
    Sticker.leaf(canvas, const Offset(61.5, 91.5), 0.7, 6, 2.6, vein: false);
  }

  /// Filipino clothes over the shirt shape.
  void _outfit(Canvas canvas) {
    final shirt = Path()
      ..moveTo(12, 102)
      ..lineTo(15, 90)
      ..quadraticBezierTo(19, 76, 35, 74)
      ..lineTo(42, 74)
      ..quadraticBezierTo(50, 83, 58, 74)
      ..lineTo(65, 74)
      ..quadraticBezierTo(81, 76, 85, 90)
      ..lineTo(88, 102)
      ..close();
    const white = Color(0xFFFFFFFF);
    switch (_outfitFor(spec.id)) {
      case _Outfit.barong:
        // Sheer cream barong with embroidery down the front.
        Sticker.auto(canvas, shirt, const Color(0xFFF7EFD8), width: _w);
        final stitch = Sticker.stroke(const Color(0xFFC9B27A), 1.1);
        for (final x in [44.0, 56.0]) {
          canvas.drawLine(Offset(x, 82), Offset(x, 102), stitch);
        }
        for (var y = 84.0; y < 102; y += 4) {
          canvas
            ..drawCircle(Offset(44, y), 1.2, stitch)
            ..drawCircle(Offset(56, y), 1.2, stitch);
        }
        for (final y in [86.0, 92.0, 98.0]) {
          canvas.drawCircle(Offset(50, y), 1.3, Sticker.solid(const Color(0xFFB79A55)));
        }
      case _Outfit.schoolTie:
        Sticker.auto(canvas, shirt, white, width: _w);
        final tie = Path()
          ..moveTo(47.5, 78)
          ..lineTo(52.5, 78)
          ..lineTo(54, 98)
          ..lineTo(50, 102)
          ..lineTo(46, 98)
          ..close();
        Sticker.auto(canvas, tie, spec.shirt, width: 1.2);
        for (final side in [-1.0, 1.0]) {
          Sticker.auto(
            canvas,
            Path()
              ..moveTo(50, 77)
              ..lineTo(50 + side * 9, 74)
              ..lineTo(50 + side * 6, 82)
              ..close(),
            white,
            width: 1.2,
          );
        }
      case _Outfit.schoolBow:
        Sticker.auto(canvas, shirt, white, width: _w);
        for (final side in [-1.0, 1.0]) {
          Sticker.auto(
            canvas,
            Path()
              ..moveTo(50, 80)
              ..quadraticBezierTo(50 + side * 4, 75, 50 + side * 9, 77)
              ..quadraticBezierTo(50 + side * 8, 83, 50, 81)
              ..close(),
            spec.accent,
            width: 1.2,
          );
        }
        canvas.drawCircle(const Offset(50, 80.5), 2.2, Sticker.solid(Sticker.darken(spec.accent, 0.2)));
      case _Outfit.scout:
        Sticker.auto(canvas, shirt, AppColors.foliage, width: _w);
        final scarf = Path()
          ..moveTo(38, 75)
          ..lineTo(62, 75)
          ..lineTo(50, 96)
          ..close();
        Sticker.auto(canvas, scarf, AppColors.sunshine, width: 1.2);
        canvas.drawCircle(const Offset(50, 82), 2.6, Sticker.outline(AppColors.bark, width: 1.8));
      case _Outfit.jersey:
        Sticker.auto(canvas, shirt, spec.shirt, width: _w);
        canvas.drawPath(
          Path()
            ..moveTo(42, 74)
            ..lineTo(50, 84)
            ..lineTo(58, 74),
          Sticker.stroke(white, 2.6),
        );
        // Sporty stripes on the shoulders (a number is too small to read).
        for (final side in [-1.0, 1.0]) {
          canvas.drawLine(Offset(50 + side * 22, 77), Offset(50 + side * 33, 86), Sticker.stroke(white, 2.6));
        }
      case _Outfit.filipiniana:
        Sticker.auto(canvas, shirt, spec.shirt, width: _w);
        // Butterfly sleeves standing up on the shoulders.
        for (final side in [-1.0, 1.0]) {
          final sleeve = Path()
            ..moveTo(50 + side * 13, 76)
            ..quadraticBezierTo(50 + side * 22, 64, 50 + side * 33, 74)
            ..quadraticBezierTo(50 + side * 30, 82, 50 + side * 18, 84)
            ..close();
          Sticker.auto(canvas, sleeve, Color.lerp(spec.shirt, white, 0.55)!, width: 1.2);
          canvas.drawLine(
            Offset(50 + side * 18, 75),
            Offset(50 + side * 24, 79),
            Sticker.stroke(Sticker.darken(spec.shirt, 0.15), 0.9),
          );
        }
    }
  }

  static _Outfit _outfitFor(String id) => switch (id) {
    'boy_cap' || 'girl_braid' => _Outfit.jersey,
    'boy_spiky' || 'boy_curltop' => _Outfit.barong,
    'boy_curly' || 'boy_bowl' => _Outfit.schoolTie,
    'boy_sidepart' || 'girl_puffs' => _Outfit.scout,
    'girl_pigtails' || 'girl_bob' => _Outfit.schoolBow,
    _ => _Outfit.filipiniana,
  };

  @override
  bool shouldRepaint(AvatarPainter old) => old.spec != spec || old.look != look;
}
