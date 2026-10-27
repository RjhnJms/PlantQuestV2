import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';

/// PlantQuest's own icons, drawn from simple shapes in a 48 × 48 box so one
/// drawing can be shown in different styles (see [KidIconStyle]).
enum KidIcon {
  home,
  plants,
  quiz,
  shop,
  profile,
  leaf,
  sun,
  trophy,
  lock,
  speaker,
  settings,
  check,
  idea,
  label,
  grow,
  match,
  crayon,
  // Controls.
  back,
  next,
  arrow,
  close,
  play,
  edit,
  restart,
  book,
  voice,
  sparkle,
  tap,
  learn,
  earned,
  offline,
  tick,
  empty,
  // What plants are known for (Match it).
  garland,
  bubbles,
  hand,
  drink,
  soup,
  rice,
  pot,
  turon,
  mango,
  drop,
  tree,
  waves,
  salad,
  plate,
}

/// How the shapes are painted.
enum KidIconStyle {
  /// Thick outline and a white die-cut edge, like the plant art and Binhi.
  sticker('Sticker', 'Outlined, like the plants and Binhi'),

  /// Shiny and rounded, no outline.
  glossy('Glossy', 'Shiny, soft and bubbly'),

  /// Calm two-tone shapes on a soft round tile.
  flat('Flat', 'Simple two-tone, calm');

  const KidIconStyle(this.title, this.line);
  final String title;
  final String line;
}

/// One shape of an icon: filled, or a stroke of [width].
class _Part {
  const _Part(this.path, this.color, {this.width});

  final Path path;
  final Color color;

  /// Null means filled.
  final double? width;
  bool get isStroke => width != null;
}

class KidIconView extends StatelessWidget {
  const KidIconView(
    this.icon, {
    super.key,
    this.size = AppSizes.iconMedium,
    this.style = KidIconStyle.sticker,
    this.muted = false,
  });

  final KidIcon icon;
  final double size;
  final KidIconStyle style;

  /// Greyed out (unselected tabs, locked things).
  final bool muted;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: KidIconPainter(icon, style: style, muted: muted),
    ),
  );
}

class KidIconPainter extends CustomPainter {
  KidIconPainter(this.icon, {this.style = KidIconStyle.sticker, this.muted = false});

  final KidIcon icon;
  final KidIconStyle style;
  final bool muted;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 48;
    canvas
      ..save()
      ..translate((size.width - 48 * s) / 2, (size.height - 48 * s) / 2)
      ..scale(s);
    var parts = _parts(icon);
    if (muted) {
      parts = [
        for (final p in parts) _Part(p.path, Color.lerp(p.color, const Color(0xFFB9B3C8), 0.75)!, width: p.width),
      ];
    }
    switch (style) {
      case KidIconStyle.sticker:
        _sticker(canvas, parts);
      case KidIconStyle.glossy:
        _glossy(canvas, parts);
      case KidIconStyle.flat:
        _flat(canvas, parts);
    }
    canvas.restore();
  }

  static Color _dark(Color c, [double t = 0.38]) => Color.lerp(c, const Color(0xFF1E2433), t)!;
  static Color _light(Color c, [double t = 0.45]) => Color.lerp(c, Colors.white, t)!;

  void _sticker(Canvas canvas, List<_Part> parts) {
    // White die-cut edge around everything, with a soft drop.
    final rim = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final drop = Paint()
      ..color = const Color(0x33263046)
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    for (final p in parts) {
      final w = (p.width ?? 0) + 7;
      canvas.drawPath(p.path.shift(const Offset(0, 1.5)), drop..strokeWidth = w);
      if (!p.isStroke) canvas.drawPath(p.path.shift(const Offset(0, 1.5)), Paint()..color = const Color(0x33263046));
    }
    for (final p in parts) {
      canvas.drawPath(p.path, rim..strokeWidth = (p.width ?? 0) + 7);
      if (!p.isStroke) canvas.drawPath(p.path, Paint()..color = Colors.white);
    }
    for (final p in parts) {
      if (p.isStroke) {
        canvas.drawPath(p.path, _strokePaint(_dark(p.color, 0.15), p.width!));
        continue;
      }
      final b = p.path.getBounds();
      canvas
        ..drawPath(
          p.path,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_light(p.color, 0.25), p.color],
            ).createShader(b),
        )
        ..drawPath(p.path, _strokePaint(_dark(p.color), 2.2));
    }
  }

  void _glossy(Canvas canvas, List<_Part> parts) {
    for (final p in parts) {
      if (p.isStroke) {
        canvas.drawPath(p.path, _strokePaint(_dark(p.color, 0.1), p.width! + 0.6));
        continue;
      }
      final b = p.path.getBounds();
      canvas.drawPath(
        p.path,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.5),
            radius: 1.1,
            colors: [_light(p.color, 0.55), p.color, _dark(p.color, 0.22)],
            stops: const [0, 0.55, 1],
          ).createShader(b),
      );
      // A soft shine on the top-left of big shapes.
      if (b.width > 12 && b.height > 10) {
        canvas
          ..save()
          ..clipPath(p.path)
          ..drawOval(
            Rect.fromLTWH(b.left + b.width * 0.12, b.top + b.height * 0.06, b.width * 0.5, b.height * 0.3),
            Paint()..color = Colors.white.withValues(alpha: 0.45),
          )
          ..restore();
      }
    }
  }

  void _flat(Canvas canvas, List<_Part> parts) {
    // A soft round tile in the icon's own color.
    // The tile takes the color of the biggest shape.
    double area(_Part p) => p.isStroke ? 0 : p.path.getBounds().width * p.path.getBounds().height;
    final main = parts.reduce((a, b) => area(b) > area(a) ? b : a).color;
    canvas.drawCircle(const Offset(24, 24), 23, Paint()..color = _light(main, 0.78));
    canvas
      ..save()
      ..translate(24, 24)
      ..scale(0.78)
      ..translate(-24, -24);
    for (final p in parts) {
      canvas.drawPath(p.path, p.isStroke ? _strokePaint(_dark(p.color, 0.2), p.width!) : (Paint()..color = p.color));
    }
    canvas.restore();
  }

  static Paint _strokePaint(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  bool shouldRepaint(KidIconPainter old) => old.icon != icon || old.style != style || old.muted != muted;
}

// ---------------------------------------------------------------- shapes

Path _rr(double l, double t, double r, double b, double radius) =>
    Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));

Path _poly(List<Offset> points) => Path()..addPolygon(points, true);

Path _circle(double x, double y, double r) => Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

/// A leaf from [base] to [tip], [width] wide at its middle.
Path _leafPath(Offset base, Offset tip, double width) {
  final d = tip - base;
  final n = Offset(-d.dy, d.dx) / d.distance * width / 2;
  final m1 = base + d * 0.35;
  final m2 = base + d * 0.75;
  return Path()
    ..moveTo(base.dx, base.dy)
    ..cubicTo(m1.dx + n.dx, m1.dy + n.dy, m2.dx + n.dx, m2.dy + n.dy, tip.dx, tip.dy)
    ..cubicTo(m2.dx - n.dx, m2.dy - n.dy, m1.dx - n.dx, m1.dy - n.dy, base.dx, base.dy)
    ..close();
}

Path _line(List<Offset> points) {
  final p = Path()..moveTo(points.first.dx, points.first.dy);
  for (final o in points.skip(1)) {
    p.lineTo(o.dx, o.dy);
  }
  return p;
}

List<_Part> _parts(KidIcon icon) => switch (icon) {
  // A bahay kubo on stilts.
  KidIcon.home => [
    _Part(_rr(12, 37, 15.5, 44, 1.5), AppColors.barkDark),
    _Part(_rr(32.5, 37, 36, 44, 1.5), AppColors.barkDark),
    _Part(_rr(10, 21, 38, 39, 3), AppColors.bamboo),
    _Part(_rr(20, 27, 28, 39, 2), AppColors.bark),
    _Part(
      Path()
        ..moveTo(3, 24)
        ..quadraticBezierTo(24, 1, 45, 24)
        ..close(),
      AppColors.riceGold,
    ),
  ],
  // A flower.
  KidIcon.plants => [
    _Part(_line(const [Offset(24, 26), Offset(24, 44)]), AppColors.foliage, width: 3.5),
    _Part(_leafPath(const Offset(24, 40), const Offset(10, 32), 8), AppColors.leaf),
    _Part(() {
      var p = Path();
      for (var i = 0; i < 5; i++) {
        final a = -math.pi / 2 + i * 2 * math.pi / 5;
        p = Path.combine(PathOperation.union, p, _circle(24 + 8 * math.cos(a), 18 + 8 * math.sin(a), 7));
      }
      return p;
    }(), AppColors.bubblegum),
    _Part(_circle(24, 18, 5), AppColors.sunshine),
  ],
  // A puzzle piece.
  KidIcon.quiz => [
    _Part(
      Path.combine(
        PathOperation.union,
        Path.combine(PathOperation.union, _rr(8, 14, 38, 42, 5), _circle(23, 12, 6.5)),
        _circle(40, 28, 6.5),
      ),
      AppColors.grape,
    ),
  ],
  // A market stall with a striped awning.
  KidIcon.shop => [
    _Part(_rr(9, 20, 39, 42, 3), AppColors.sunshineTint),
    _Part(_rr(19, 28, 29, 42, 2), AppColors.coral),
    for (var i = 0; i < 4; i++)
      _Part(
        Path()
          ..moveTo(6 + i * 9.0, 9)
          ..lineTo(15 + i * 9.0, 9)
          ..lineTo(15 + i * 9.0, 18)
          ..arcToPoint(Offset(6 + i * 9.0, 18), radius: const Radius.circular(4.5))
          ..close(),
        i.isEven ? AppColors.coral : AppColors.sunshine,
      ),
  ],
  // A kid with a cap.
  KidIcon.profile => [
    _Part(
      Path()
        ..moveTo(9, 46)
        ..quadraticBezierTo(9, 32, 24, 32)
        ..quadraticBezierTo(39, 32, 39, 46)
        ..close(),
      AppColors.sky,
    ),
    _Part(_circle(24, 20, 11), AppColors.skinMedium),
    _Part(
      Path()
        ..moveTo(12, 18)
        ..quadraticBezierTo(13, 7, 24, 7)
        ..quadraticBezierTo(35, 7, 36, 16)
        ..lineTo(42, 17)
        ..quadraticBezierTo(42, 20, 36, 20)
        ..lineTo(12, 20)
        ..close(),
      AppColors.coral,
    ),
  ],
  KidIcon.leaf => [
    _Part(_leafPath(const Offset(9, 41), const Offset(41, 7), 20), AppColors.leaf),
    _Part(_line(const [Offset(11, 39), Offset(33, 15)]), AppColors.leafDark, width: 2),
  ],
  KidIcon.sun => [
    for (var i = 0; i < 8; i++)
      _Part(
        _line([
          Offset(24 + 15 * math.cos(i * math.pi / 4), 24 + 15 * math.sin(i * math.pi / 4)),
          Offset(24 + 21 * math.cos(i * math.pi / 4), 24 + 21 * math.sin(i * math.pi / 4)),
        ]),
        AppColors.sunshineDark,
        width: 3.5,
      ),
    _Part(_circle(24, 24, 11), AppColors.sunshine),
  ],
  KidIcon.trophy => [
    _Part(
      Path()
        ..moveTo(15, 12)
        ..quadraticBezierTo(7, 12, 8, 19)
        ..quadraticBezierTo(9, 25, 16, 25),
      AppColors.sunshineDark,
      width: 3,
    ),
    _Part(
      Path()
        ..moveTo(33, 12)
        ..quadraticBezierTo(41, 12, 40, 19)
        ..quadraticBezierTo(39, 25, 32, 25),
      AppColors.sunshineDark,
      width: 3,
    ),
    _Part(_rr(21, 28, 27, 37, 1), AppColors.sunshineDark),
    _Part(_rr(14, 36, 34, 43, 2.5), AppColors.bark),
    _Part(
      Path()
        ..moveTo(13, 7)
        ..lineTo(35, 7)
        ..lineTo(34, 20)
        ..quadraticBezierTo(33, 30, 24, 30)
        ..quadraticBezierTo(15, 30, 14, 20)
        ..close(),
      AppColors.sunshine,
    ),
  ],
  KidIcon.lock => [
    _Part(
      Path()
        ..moveTo(16, 22)
        ..lineTo(16, 16)
        ..arcToPoint(const Offset(32, 16), radius: const Radius.circular(8))
        ..lineTo(32, 22),
      AppColors.textMuted,
      width: 4.5,
    ),
    _Part(_rr(10, 21, 38, 43, 5), AppColors.grapeInk),
    _Part(_circle(24, 30, 3.2), AppColors.grapeTint),
    _Part(_rr(22.6, 30, 25.4, 37, 1.4), AppColors.grapeTint),
  ],
  KidIcon.speaker => [
    _Part(
      _line(const [Offset(7, 19), Offset(15, 19), Offset(25, 10), Offset(25, 38), Offset(15, 29), Offset(7, 29)])
        ..close(),
      AppColors.sky,
    ),
    _Part(
      Path()..addArc(Rect.fromCircle(center: const Offset(25, 24), radius: 8), -0.9, 1.8),
      AppColors.skyDark,
      width: 3,
    ),
    _Part(
      Path()..addArc(Rect.fromCircle(center: const Offset(25, 24), radius: 15), -0.9, 1.8),
      AppColors.skyDark,
      width: 3,
    ),
  ],
  KidIcon.settings => [
    _Part(() {
      final p = Path();
      for (var i = 0; i < 16; i++) {
        final r = i.isEven ? 20.0 : 15.0;
        final a = i * math.pi / 8 + math.pi / 16;
        final o = Offset(24 + r * math.cos(a), 24 + r * math.sin(a));
        i == 0 ? p.moveTo(o.dx, o.dy) : p.lineTo(o.dx, o.dy);
      }
      return Path.combine(PathOperation.difference, p..close(), _circle(24, 24, 6));
    }(), AppColors.grapeInk),
  ],
  KidIcon.check => [
    _Part(_circle(24, 24, 19), AppColors.leaf),
    _Part(_line(const [Offset(15, 24), Offset(22, 31), Offset(33, 17)]), AppColors.card, width: 4.5),
  ],
  KidIcon.idea => [
    _Part(_rr(18, 33, 30, 42, 3), AppColors.textMuted),
    _Part(
      Path()
        ..moveTo(17, 32)
        ..quadraticBezierTo(9, 26, 10, 18)
        ..quadraticBezierTo(12, 6, 24, 6)
        ..quadraticBezierTo(36, 6, 38, 18)
        ..quadraticBezierTo(39, 26, 31, 32)
        ..close(),
      AppColors.sunshine,
    ),
  ],
  KidIcon.label => [
    _Part(
      Path.combine(
        PathOperation.difference,
        _line(const [Offset(5, 15), Offset(30, 15), Offset(43, 24), Offset(30, 33), Offset(5, 33)])..close(),
        _circle(30, 24, 3),
      ),
      AppColors.sky,
    ),
  ],
  KidIcon.grow => [
    _Part(_rr(12, 36, 36, 44, 4), AppColors.soilMid),
    _Part(_line(const [Offset(24, 38), Offset(24, 20)]), AppColors.foliage, width: 3.5),
    _Part(_leafPath(const Offset(24, 24), const Offset(8, 12), 11), AppColors.leaf),
    _Part(_leafPath(const Offset(24, 21), const Offset(41, 8), 12), AppColors.leaf),
  ],
  KidIcon.match => [_Part(_circle(17, 24, 12), AppColors.sunshine), _Part(_circle(31, 24, 12), AppColors.coral)],
  KidIcon.crayon => [
    _Part(_poly(const [Offset(7, 35), Offset(28, 14), Offset(34, 20), Offset(13, 41)]), AppColors.coral),
    _Part(_poly(const [Offset(13, 29), Offset(23, 19), Offset(29, 25), Offset(19, 35)]), AppColors.card),
    _Part(_poly(const [Offset(28, 14), Offset(41, 7), Offset(34, 20)]), AppColors.coral),
  ],

  // ------------------------------------------------------------ controls
  KidIcon.back => [
    _Part(_line(const [Offset(29, 10), Offset(15, 24), Offset(29, 38)]), AppColors.text, width: 6),
  ],
  KidIcon.next => [
    _Part(_line(const [Offset(19, 10), Offset(33, 24), Offset(19, 38)]), AppColors.grapeInk, width: 6),
  ],
  KidIcon.arrow => [
    _Part(_line(const [Offset(8, 24), Offset(38, 24)]), AppColors.text, width: 5.5),
    _Part(_line(const [Offset(27, 13), Offset(39, 24), Offset(27, 35)]), AppColors.text, width: 5.5),
  ],
  KidIcon.close => [
    _Part(_line(const [Offset(13, 13), Offset(35, 35)]), AppColors.text, width: 6),
    _Part(_line(const [Offset(35, 13), Offset(13, 35)]), AppColors.text, width: 6),
  ],
  KidIcon.play => [
    _Part(
      Path()
        ..moveTo(15, 9)
        ..quadraticBezierTo(12, 9, 12, 13)
        ..lineTo(12, 35)
        ..quadraticBezierTo(12, 39, 15, 38)
        ..lineTo(38, 26)
        ..quadraticBezierTo(40, 24, 38, 22)
        ..close(),
      AppColors.leaf,
    ),
  ],
  KidIcon.edit => [
    _Part(
      Path()
        ..moveTo(31, 7)
        ..lineTo(41, 17)
        ..lineTo(18, 40)
        ..lineTo(8, 40)
        ..lineTo(8, 30)
        ..close(),
      AppColors.sunshine,
    ),
    _Part(
      Path()
        ..moveTo(31, 7)
        ..lineTo(41, 17)
        ..lineTo(37, 21)
        ..lineTo(27, 11)
        ..close(),
      AppColors.coral,
    ),
    _Part(_line(const [Offset(8, 40), Offset(8, 34), Offset(14, 40)])..close(), AppColors.text),
  ],
  KidIcon.restart => [
    _Part(
      Path()..addArc(Rect.fromCircle(center: const Offset(24, 25), radius: 14), -2.2, 5.0),
      AppColors.coral,
      width: 5,
    ),
    _Part(_line(const [Offset(6, 9), Offset(10, 20), Offset(20, 14)])..close(), AppColors.coral),
  ],
  KidIcon.book => [
    _Part(
      Path()
        ..moveTo(24, 13)
        ..quadraticBezierTo(15, 7, 5, 10)
        ..lineTo(5, 38)
        ..quadraticBezierTo(15, 35, 24, 41)
        ..close(),
      AppColors.teal,
    ),
    _Part(
      Path()
        ..moveTo(24, 13)
        ..quadraticBezierTo(33, 7, 43, 10)
        ..lineTo(43, 38)
        ..quadraticBezierTo(33, 35, 24, 41)
        ..close(),
      AppColors.tealTint,
    ),
  ],
  KidIcon.voice => [
    _Part(
      Path()
        ..addRRect(RRect.fromLTRBR(5, 7, 43, 34, const Radius.circular(10)))
        ..moveTo(12, 32)
        ..lineTo(10, 43)
        ..lineTo(22, 33)
        ..close(),
      AppColors.grape,
    ),
    for (final x in [16.0, 24.0, 32.0]) _Part(_circle(x, 20.5, 3), AppColors.card),
  ],
  KidIcon.sparkle => [
    _Part(_star4(const Offset(20, 26), 16), AppColors.sunshine),
    _Part(_star4(const Offset(37, 11), 8), AppColors.bubblegum),
  ],
  KidIcon.tap => [
    _Part(_circle(22, 12, 7), AppColors.grapeTint),
    _Part(
      Path()
        ..addRRect(RRect.fromLTRBR(18, 10, 26, 30, const Radius.circular(4)))
        ..addRRect(RRect.fromLTRBR(13, 24, 38, 44, const Radius.circular(9))),
      AppColors.skinMedium,
    ),
  ],
  KidIcon.learn => [
    _Part(_line(const [Offset(36, 22), Offset(36, 34)]), AppColors.sunshineDark, width: 2.5),
    _Part(_rr(13, 22, 35, 34, 4), AppColors.grapeInk),
    _Part(_line(const [Offset(3, 18), Offset(24, 9), Offset(45, 18), Offset(24, 27)])..close(), AppColors.grape),
  ],
  KidIcon.earned => [
    _Part(_line(const [Offset(24, 40), Offset(24, 12)]), AppColors.grapeInk, width: 6),
    _Part(_line(const [Offset(12, 22), Offset(24, 9), Offset(36, 22)]), AppColors.grapeInk, width: 6),
  ],
  KidIcon.offline => [
    _Part(
      Path()..addArc(Rect.fromCircle(center: const Offset(24, 36), radius: 22), -2.4, 1.66),
      AppColors.textMuted,
      width: 4,
    ),
    _Part(
      Path()..addArc(Rect.fromCircle(center: const Offset(24, 36), radius: 12), -2.4, 1.66),
      AppColors.textMuted,
      width: 4,
    ),
    _Part(_circle(24, 36, 3.5), AppColors.textMuted),
    _Part(_line(const [Offset(9, 9), Offset(39, 41)]), AppColors.coral, width: 4),
  ],
  KidIcon.tick => [
    _Part(_line(const [Offset(10, 25), Offset(20, 35), Offset(38, 13)]), AppColors.leafDark, width: 6.5),
  ],
  KidIcon.empty => [_Part(_circle(24, 24, 16), AppColors.borderDeep, width: 4)],

  // ------------------------------------------------- what plants are for
  KidIcon.garland => [
    _Part(Path()..addOval(Rect.fromCircle(center: const Offset(24, 24), radius: 15)), AppColors.foliage, width: 2.5),
    for (var i = 0; i < 7; i++)
      _Part(
        _circle(24 + 15 * math.cos(i * 2 * math.pi / 7), 24 + 15 * math.sin(i * 2 * math.pi / 7), 5),
        AppColors.sunshineTint,
      ),
  ],
  KidIcon.bubbles => [
    _Part(_circle(18, 28, 12), AppColors.skyLight),
    _Part(_circle(34, 16, 8), AppColors.bubblegumTint),
    _Part(_circle(36, 36, 5), AppColors.skyLight),
  ],
  KidIcon.hand => [
    _Part(
      Path()
        ..addRRect(RRect.fromLTRBR(11, 22, 37, 44, const Radius.circular(10)))
        ..addRRect(RRect.fromLTRBR(11, 11, 17, 30, const Radius.circular(3)))
        ..addRRect(RRect.fromLTRBR(18, 6, 24, 28, const Radius.circular(3)))
        ..addRRect(RRect.fromLTRBR(25, 7, 31, 28, const Radius.circular(3)))
        ..addRRect(RRect.fromLTRBR(32, 12, 38, 30, const Radius.circular(3))),
      AppColors.skinLightMedium,
    ),
  ],
  KidIcon.drink => [
    _Part(_line(const [Offset(12, 8), Offset(36, 8), Offset(32, 43), Offset(16, 43)])..close(), AppColors.skyTint),
    _Part(_line(const [Offset(14, 20), Offset(34, 20), Offset(32, 43), Offset(16, 43)])..close(), AppColors.leafLight),
    _Part(_circle(33, 11, 6), AppColors.leaf),
  ],
  KidIcon.soup => [
    for (final x in [17.0, 24.0, 31.0])
      _Part(
        Path()
          ..moveTo(x, 18)
          ..quadraticBezierTo(x - 3, 13, x, 9)
          ..quadraticBezierTo(x + 3, 5, x, 2),
        AppColors.textMuted,
        width: 2.5,
      ),
    _Part(_bowl(), AppColors.coral),
    _Part(_leafPath(const Offset(17, 23), const Offset(26, 20), 5), AppColors.leaf),
  ],
  KidIcon.rice => [
    _Part(
      Path()
        ..moveTo(9, 24)
        ..quadraticBezierTo(24, 8, 39, 24)
        ..close(),
      AppColors.card,
    ),
    _Part(_bowl(), AppColors.sky),
  ],
  KidIcon.pot => [
    _Part(_rr(19, 8, 29, 12, 2), AppColors.textMuted),
    _Part(_rr(8, 12, 40, 18, 3), AppColors.grapeInk),
    _Part(_rr(10, 18, 38, 40, 6), AppColors.grapeInk),
    _Part(_rr(4, 21, 10, 26, 2), AppColors.grapeDark),
    _Part(_rr(38, 21, 44, 26, 2), AppColors.grapeDark),
  ],
  KidIcon.turon => [
    _Part(_line(const [Offset(6, 42), Offset(40, 8)]), AppColors.bark, width: 3),
    for (final c in const [Offset(18, 30), Offset(30, 18)])
      _Part(
        Path()..addRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 16, height: 12), const Radius.circular(6)),
        ),
        AppColors.mangoOrange,
      ),
  ],
  KidIcon.mango => [
    _Part(
      Path()
        ..moveTo(25, 9)
        ..quadraticBezierTo(41, 10, 40, 28)
        ..quadraticBezierTo(38, 43, 22, 42)
        ..quadraticBezierTo(8, 40, 10, 27)
        ..quadraticBezierTo(12, 15, 25, 9)
        ..close(),
      AppColors.mangoYellow,
    ),
    _Part(_leafPath(const Offset(25, 9), const Offset(34, 3), 6), AppColors.leaf),
  ],
  KidIcon.drop => [
    _Part(
      Path()
        ..moveTo(24, 5)
        ..quadraticBezierTo(39, 22, 38, 30)
        ..arcToPoint(const Offset(10, 30), radius: const Radius.circular(14))
        ..quadraticBezierTo(9, 22, 24, 5)
        ..close(),
      AppColors.water,
    ),
  ],
  KidIcon.tree => [
    _Part(_rr(21, 26, 27, 44, 2), AppColors.bark),
    _Part(
      Path.combine(
        PathOperation.union,
        Path.combine(PathOperation.union, _circle(24, 16, 11), _circle(14, 24, 9)),
        _circle(34, 24, 9),
      ),
      AppColors.foliage,
    ),
  ],
  KidIcon.waves => [
    for (final y in [16.0, 26.0, 36.0])
      _Part(
        Path()
          ..moveTo(5, y)
          ..quadraticBezierTo(10, y - 5, 15, y)
          ..quadraticBezierTo(20, y + 5, 25, y)
          ..quadraticBezierTo(30, y - 5, 35, y)
          ..quadraticBezierTo(40, y + 5, 44, y),
        AppColors.waterDark,
        width: 4,
      ),
  ],
  KidIcon.salad => [
    _Part(_leafPath(const Offset(24, 24), const Offset(10, 8), 10), AppColors.foliage),
    _Part(_leafPath(const Offset(24, 24), const Offset(36, 6), 10), AppColors.leaf),
    _Part(_circle(30, 20, 4), AppColors.hibiscusRed),
    _Part(_bowl(), AppColors.card),
  ],
  KidIcon.plate => [
    _Part(_circle(24, 26, 18), AppColors.card),
    _Part(_circle(24, 26, 11), AppColors.foliage),
    _Part(_leafPath(const Offset(18, 30), const Offset(30, 20), 7), AppColors.leafLight),
  ],
};

/// A four-point sparkle.
Path _star4(Offset c, double r) => Path()
  ..moveTo(c.dx, c.dy - r)
  ..quadraticBezierTo(c.dx + r * 0.15, c.dy - r * 0.15, c.dx + r, c.dy)
  ..quadraticBezierTo(c.dx + r * 0.15, c.dy + r * 0.15, c.dx, c.dy + r)
  ..quadraticBezierTo(c.dx - r * 0.15, c.dy + r * 0.15, c.dx - r, c.dy)
  ..quadraticBezierTo(c.dx - r * 0.15, c.dy - r * 0.15, c.dx, c.dy - r)
  ..close();

/// A round bowl seen from the side.
Path _bowl() => Path()
  ..moveTo(6, 24)
  ..lineTo(42, 24)
  ..quadraticBezierTo(41, 41, 24, 42)
  ..quadraticBezierTo(7, 41, 6, 24)
  ..close();
