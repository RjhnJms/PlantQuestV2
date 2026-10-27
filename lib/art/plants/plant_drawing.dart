import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';
import 'plant_touch.dart';

/// The four parts kids tap on Plant details. [special] is the flower,
/// fruit, grain, shoot, spores or seedling (see `SpecialPart`).
enum PlantPart { root, stem, leaf, special }

/// How a plant is shown.
enum PlantMode {
  /// Cards and quiz answers: the plant on a little mound, no roots.
  thumbnail,

  /// Plant details: a soil cut-away with the roots showing.
  detail,

  /// Like [thumbnail] but with no mound, for plants standing in a pot or a
  /// garden bed that draws its own soil.
  planted,
}

/// One plant's artwork in a 200 × 262 design box. The ground line is at
/// y = 200; roots live below it.
abstract class PlantDrawing {
  const PlantDrawing();

  static const ground = 200.0;
  static const designSize = Size(200, 262);

  /// Visible area in thumbnail mode (no roots). Every thumbnail has this
  /// shape; [thumbnailTop] zooms in on short plants.
  static const thumbnailRect = Rect.fromLTRB(0, 8, 200, 214);

  /// Top of the thumbnail crop. Short plants crop lower so they fill their
  /// card; wide plants must keep it small enough not to clip their sides.
  double get thumbnailTop => thumbnailRect.top;

  Rect get thumbnailCrop {
    final h = thumbnailRect.bottom - thumbnailTop;
    final w = h * thumbnailRect.width / thumbnailRect.height;
    return Rect.fromLTRB(100 - w / 2, thumbnailTop, 100 + w / 2, thumbnailRect.bottom);
  }

  /// Where the glow goes when a part is picked. Defaults to the tap zone,
  /// except roots, which glow in a soft spot around them, not the whole soil.
  Path glowZone(PlantPart part) =>
      part == PlantPart.root ? K.oval(const Rect.fromLTRB(42, 196, 158, 256)) : regions()[part]!;

  /// Water plants stand in water instead of soil.
  bool get inWater => false;

  /// Roots. Drawn after the soil, so they show in the cut-away.
  void roots(Canvas c);

  /// Everything above the ground.
  void body(Canvas c);

  /// [body] while the plant reacts to a touch; [fold] (0–1) is how far a
  /// makahiya has folded its leaves. Other plants just draw [body].
  void bodyTouched(Canvas c, {required double fold}) => body(c);

  /// Generous tap zones in design units. Thin parts get wide zones.
  Map<PlantPart, Path> regions();

  /// When zones overlap, the earlier part wins.
  List<PlantPart> get hitOrder => const [PlantPart.special, PlantPart.stem, PlantPart.leaf, PlantPart.root];

  PlantPart? hitTest(Offset designPoint) {
    final zones = regions();
    for (final part in hitOrder) {
      if (zones[part]?.contains(designPoint) ?? false) return part;
    }
    return null;
  }
}

/// Small drawing kit shared by all plant drawings.
abstract final class K {
  static const g = PlantDrawing.ground;

  static final rootFill = Color.lerp(AppColors.bark, const Color(0xFFFFFFFF), 0.5)!;

  /// A stroke with a darker edge and a lighter core, e.g. stems and twigs.
  static void stroke(Canvas c, Path path, double width, Color color, {Color? edge}) {
    c
      ..drawPath(path, Sticker.stroke(edge ?? Sticker.darken(color, 0.3), width + 2.6))
      ..drawPath(path, Sticker.lineArt ? Sticker.paper(width) : Sticker.stroke(color, width));
  }

  static void green(Canvas c, Path path, double width) =>
      stroke(c, path, width, AppColors.leaf, edge: AppColors.leafDark);

  static void wood(Canvas c, Path path, double width) =>
      stroke(c, path, width, AppColors.bark, edge: AppColors.barkDark);

  static Path curve(Offset a, Offset ctrl, Offset b) => Path()
    ..moveTo(a.dx, a.dy)
    ..quadraticBezierTo(ctrl.dx, ctrl.dy, b.dx, b.dy);

  static Path line(Offset a, Offset b) => Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy);

  static void leaf(
    Canvas c,
    Offset base,
    double angle,
    double length,
    double width, {
    Color color = AppColors.foliage,
  }) => Sticker.leaf(c, base, angle, length, width, color: color, outlineColor: Sticker.darken(color, 0.32));

  /// A cluster of circles drawn as one soft blob (tree crowns, bushes).
  static void blob(Canvas c, List<(Offset, double)> circles, Color color) {
    final path = Path();
    for (final (o, r) in circles) {
      path.addOval(Rect.fromCircle(center: o, radius: r));
    }
    for (final (o, r) in circles) {
      c.drawCircle(o, r, Sticker.outline(Sticker.darken(color, 0.28), width: 5));
    }
    c.drawPath(path, Sticker.fill(path.getBounds(), color, lift: 0.22));
  }

  /// A round fruit with a shine.
  static void fruit(Canvas c, Offset o, double r, Color color) {
    final rect = Rect.fromCircle(center: o, radius: r);
    c
      ..drawOval(rect, Sticker.fill(rect, color, lift: 0.3))
      ..drawOval(rect, Sticker.outline(Sticker.darken(color, 0.3), width: 1.8))
      ..drawCircle(
        o.translate(-r * 0.35, -r * 0.35),
        r * 0.25,
        Sticker.solid(const Color(0xFFFFFFFF).withValues(alpha: 0.6)),
      );
  }

  /// A main root going down with little side roots.
  static void taproot(Canvas c, {double depth = 54, double x = 100, double thickness = 6}) {
    final tip = Offset(x + 3, g + depth);
    final main = curve(Offset(x, g), Offset(x - 5, g + depth * 0.5), tip);
    final r = math.Random(depth.round());
    for (var i = 0; i < 4; i++) {
      final y = g + 10 + i * depth * 0.2;
      for (final side in [-1.0, 1.0]) {
        final len = (22 - i * 3.5) * (0.8 + r.nextDouble() * 0.4);
        stroke(
          c,
          curve(Offset(x, y), Offset(x + side * len * 0.6, y + 2), Offset(x + side * len, y + 10 + r.nextDouble() * 6)),
          1.8,
          rootFill,
          edge: AppColors.barkDark,
        );
      }
    }
    stroke(c, main, thickness, rootFill, edge: AppColors.barkDark);
  }

  /// Many thin roots fanning out (grasses, palms, ferns, bananas).
  static void fibrous(Canvas c, {int count = 9, double depth = 46, double x = 100, double spread = 46}) {
    for (var i = 0; i < count; i++) {
      final f = count == 1 ? 0.5 : i / (count - 1);
      final dx = (f - 0.5) * 2 * spread;
      final end = Offset(x + dx, g + depth * (0.7 + 0.3 * math.sin(f * math.pi)));
      final path = Path()
        ..moveTo(x + dx * 0.1, g)
        ..cubicTo(x + dx * 0.3, g + 14, x + dx * 0.9 + (i.isEven ? 4 : -4), g + depth * 0.5, end.dx, end.dy);
      stroke(c, path, 2, rootFill, edge: AppColors.barkDark);
    }
  }

  // ---- tap zones ----

  static Path circle(Offset o, double r) => Path()..addOval(Rect.fromCircle(center: o, radius: r));

  static Path oval(Rect rect) => Path()..addOval(rect);

  /// A fat line: generous zone for something thin like a stem.
  static Path capsule(List<Offset> points, double radius) {
    final path = Path();
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final steps = math.max(1, ((b - a).distance / (radius * 0.6)).ceil());
      for (var s = 0; s <= steps; s++) {
        path.addOval(Rect.fromCircle(center: Offset.lerp(a, b, s / steps)!, radius: radius));
      }
    }
    return path;
  }

  static Path union(List<Path> paths) {
    final out = Path();
    for (final p in paths) {
      out.addPath(p, Offset.zero);
    }
    return out;
  }

  /// The whole soil cut-away under the ground line (the "root" zone).
  static Path belowGround({double top = g}) => Path()..addRect(Rect.fromLTRB(-200, top, 400, 300));
}

/// Paints a [PlantDrawing] in a given [mode], with an optional glowing
/// [highlight] and an all-one-color [silhouette] for locked plants.
class PlantPainter extends CustomPainter {
  const PlantPainter({
    required this.drawing,
    this.mode = PlantMode.thumbnail,
    this.highlight,
    this.silhouette = false,
    this.glow = 1,
    this.touch,
    this.effect,
  });

  final PlantDrawing drawing;
  final PlantMode mode;
  final PlantPart? highlight;
  final bool silhouette;

  /// 0–1 strength of the highlight glow (animated by the widget).
  final double glow;

  /// A touch the plant is reacting to (PLAN.md §5j), and how it reacts.
  final PlantTouch? touch;
  final TouchEffect? effect;

  static const silhouetteColor = Color(0xFFD8CCB2);

  Rect get viewRect => mode != PlantMode.detail ? drawing.thumbnailCrop : Offset.zero & PlantDrawing.designSize;

  /// Canvas point to design point, for hit testing taps.
  Offset toDesign(Offset local, Size size) {
    final (scale, dx, dy) = _fit(size);
    return Offset((local.dx - dx) / scale, (local.dy - dy) / scale);
  }

  (double, double, double) _fit(Size size) {
    final v = viewRect;
    final scale = math.min(size.width / v.width, size.height / v.height);
    final dx = (size.width - v.width * scale) / 2 - v.left * scale;
    final dy = (size.height - v.height * scale) / 2 - v.top * scale;
    return (scale, dx, dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (scale, dx, dy) = _fit(size);
    canvas
      ..save()
      ..translate(dx, dy)
      ..scale(scale)
      // Keep roots and branches inside the frame (sides stay open so the
      // soil can reach the card edges).
      ..clipRect(Rect.fromLTRB(-1000, viewRect.top, 1000, viewRect.bottom));

    if (mode == PlantMode.detail) {
      _cutAway(canvas, size, scale, dx);
    } else if (mode == PlantMode.thumbnail) {
      _mound(canvas);
    }

    if (silhouette) {
      canvas.saveLayer(viewRect.inflate(40), Paint());
      drawing.body(canvas);
      canvas
        ..drawPaint(
          Paint()
            ..color = silhouetteColor
            ..blendMode = BlendMode.srcIn,
        )
        ..restore();
    } else {
      if (highlight != null && glow > 0) _glow(canvas);
      if (mode == PlantMode.detail || drawing.inWater) drawing.roots(canvas);
      final touch = this.touch;
      if (touch == null) {
        drawing.body(canvas);
      } else {
        // The plant wobbles from its base, then the little effect plays.
        canvas
          ..save()
          ..translate(100, K.g)
          ..transform((Matrix4.identity()..setEntry(0, 1, touch.sway)).storage)
          ..translate(-100, -K.g);
        drawing.bodyTouched(canvas, fold: effect == TouchEffect.fold ? touch.fold : 0);
        canvas.restore();
        if (effect != null) touch.paint(canvas, effect!);
      }
    }
    canvas.restore();
  }

  void _glow(Canvas canvas) {
    final zone = drawing.glowZone(highlight!);
    canvas
      ..drawPath(
        zone,
        Paint()
          ..color = AppColors.sunshine.withValues(alpha: 0.55 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawPath(zone, Sticker.solid(AppColors.sunshineTint.withValues(alpha: 0.5 * glow)));
  }

  void _mound(Canvas canvas) {
    final mound = Rect.fromCenter(center: const Offset(100, K.g + 2), width: 128, height: 18);
    if (drawing.inWater) {
      canvas
        ..drawOval(mound.inflate(4), Sticker.fill(mound, AppColors.water, lift: 0.3))
        ..drawOval(mound.inflate(4), Sticker.outline(AppColors.waterDark, width: 2));
    } else {
      canvas.drawOval(mound, Sticker.solid(silhouette ? silhouetteColor : AppColors.soilLight));
    }
  }

  void _cutAway(Canvas canvas, Size size, double scale, double dx) {
    // Soil spans the full canvas width, not just the design box.
    final left = -dx / scale - 4;
    final right = (size.width - dx) / scale + 4;
    final soil = Rect.fromLTRB(left, K.g, right, PlantDrawing.designSize.height + 20);
    canvas.drawRect(
      soil,
      Paint()..shader = ui.Gradient.linear(soil.topCenter, soil.bottomCenter, [AppColors.soilLight, AppColors.soilMid]),
    );
    // Wavy top layer and a few pebbles
    final top = Path()..moveTo(left, K.g);
    for (var x = left; x < right; x += 24) {
      top.quadraticBezierTo(x + 6, K.g - 5, x + 12, K.g - 1);
      top.quadraticBezierTo(x + 18, K.g + 2, x + 24, K.g);
    }
    canvas.drawPath(top, Sticker.stroke(Sticker.darken(AppColors.soilLight, 0.12), 3));
    final pebble = Sticker.solid(Sticker.darken(AppColors.soilMid, 0.12));
    for (final p in const [Offset(30, 222), Offset(168, 236), Offset(56, 250), Offset(150, 214), Offset(18, 244)]) {
      canvas.drawOval(Rect.fromCenter(center: p, width: 7, height: 5), pebble);
    }
    if (drawing.inWater) {
      final water = Rect.fromLTRB(left, K.g - 30, right, K.g + 2);
      canvas
        ..drawRect(
          water,
          Paint()
            ..shader = ui.Gradient.linear(water.topCenter, water.bottomCenter, [
              AppColors.water.withValues(alpha: 0.75),
              AppColors.waterDark.withValues(alpha: 0.85),
            ]),
        )
        ..drawLine(
          Offset(left, K.g - 30),
          Offset(right, K.g - 30),
          Sticker.stroke(const Color(0xFFFFFFFF).withValues(alpha: 0.8), 2.5),
        );
    }
  }

  @override
  bool shouldRepaint(PlantPainter old) =>
      old.drawing != drawing ||
      old.mode != mode ||
      old.highlight != highlight ||
      old.silhouette != silhouette ||
      old.glow != glow ||
      old.touch?.t != touch?.t ||
      old.touch?.fold != touch?.fold;
}
