import 'dart:math' as math;
import 'dart:ui';

import '../theme/app_colors.dart';

/// Shared drawing helpers for the "sticker" style (PLAN.md §9, D9):
/// soft gradient, lighter top, slightly darker outline, rounded joins,
/// colored (never grey) shadows.
abstract final class Sticker {
  static const outlineWidth = 3.0;

  static const _white = Color(0xFFFFFFFF);

  /// Ink for colouring-page outlines.
  static const ink = Color(0xFF2B3148);

  /// While true, drawings come out as a colouring page (PLAN.md §5l):
  /// fills turn white, outlines and lines turn to [ink], see-through
  /// shines vanish. Only set it around a synchronous drawing call.
  static bool lineArt = false;

  /// A white line that stays white in [lineArt] (the inside of a stem).
  static Paint paper(double width) => _line(_white, width);

  /// Fill that is a little lighter at the top of [bounds].
  static Paint fill(Rect bounds, Color color, {double lift = 0.22}) =>
      lineArt ? (Paint()..color = _white) : _gradient(bounds, color, lift);

  static Paint _gradient(Rect bounds, Color color, double lift) => Paint()
    ..shader = Gradient.linear(
      bounds.topCenter,
      bounds.bottomCenter,
      [Color.lerp(color, _white, lift)!, color, darken(color, 0.04)],
      const [0, 0.55, 1],
    );

  /// Edge lines around shapes.
  static Paint outline(Color color, {double width = outlineWidth}) => stroke(color, width);

  /// Round-capped lines (stems, rays, veins).
  static Paint stroke(Color color, double width) => _line(lineArt ? ink.withValues(alpha: color.a) : color, width);

  static Paint _line(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = color;

  static Paint solid(Color color) =>
      Paint()..color = !lineArt ? color : (color.a < 0.95 ? const Color(0x00000000) : ink);

  /// Draws [path] filled with a sticker gradient and outlined.
  static void shape(
    Canvas canvas,
    Path path,
    Color color,
    Color outlineColor, {
    double lift = 0.22,
    double width = outlineWidth,
  }) {
    canvas
      ..drawPath(path, fill(path.getBounds(), color, lift: lift))
      ..drawPath(path, outline(outlineColor, width: width));
  }

  /// Like [shape], with the outline a darker shade of [color].
  static void auto(Canvas canvas, Path path, Color color, {double width = outlineWidth, double lift = 0.22}) =>
      shape(canvas, path, color, darken(color, 0.25), lift: lift, width: width);

  /// Soft colored shadow ellipse on the ground.
  static void groundShadow(Canvas canvas, Offset center, double width, double height, Color tint) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height),
      Paint()
        ..color = tint.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  /// A gentle white gloss stripe, the "highlight on the top of each shape".
  static void gloss(Canvas canvas, RRect rrect, {double alpha = 0.4}) {
    if (lineArt) return;
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: alpha));
  }

  static Color darken(Color c, double amount) => Color.lerp(c, const Color(0xFF000000), amount)!;

  /// An almond-shaped leaf whose base is at [base], pointing along [angle]
  /// (0 = straight up, positive = clockwise).
  static void leaf(
    Canvas canvas,
    Offset base,
    double angle,
    double length,
    double width, {
    Color color = AppColors.leaf,
    Color outlineColor = AppColors.leafDark,
    bool vein = true,
  }) {
    canvas
      ..save()
      ..translate(base.dx, base.dy)
      ..rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(width * 0.95, -length * 0.18, width * 0.8, -length * 0.8, 0, -length)
      ..cubicTo(-width * 0.8, -length * 0.8, -width * 0.95, -length * 0.18, 0, 0)
      ..close();
    final bounds = Rect.fromLTRB(-width, -length, width, 0);
    canvas.drawPath(path, fill(bounds, color, lift: 0.28));
    canvas.drawPath(path, outline(outlineColor, width: 2.5));
    if (vein) {
      canvas.drawLine(
        Offset(0, -length * 0.12),
        Offset(0, -length * 0.78),
        stroke(outlineColor.withValues(alpha: 0.45), 1.6),
      );
    }
    canvas.restore();
  }

  /// A five-petal flower centered at [center].
  static void flower(
    Canvas canvas,
    Offset center,
    double radius, {
    required Color petal,
    required Color petalOutline,
    Color heart = AppColors.sunshine,
    Color heartOutline = AppColors.sunshineDark,
    int petals = 5,
    double rotation = 0,
  }) {
    for (var i = 0; i < petals; i++) {
      final a = rotation + i * 2 * math.pi / petals;
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(a);
      final rect = Rect.fromCenter(center: Offset(0, -radius * 0.55), width: radius * 0.8, height: radius * 1.05);
      final path = Path()..addOval(rect);
      canvas.drawPath(path, fill(rect, petal, lift: 0.3));
      canvas
        ..drawPath(path, outline(petalOutline, width: 2.2))
        ..restore();
    }
    final heartRect = Rect.fromCircle(center: center, radius: radius * 0.38);
    canvas
      ..drawOval(heartRect, fill(heartRect, heart))
      ..drawOval(heartRect, outline(heartOutline, width: 2))
      ..drawCircle(
        center.translate(-radius * 0.12, -radius * 0.12),
        radius * 0.1,
        solid(const Color(0xFFFFFFFF).withValues(alpha: 0.7)),
      );
  }
}
