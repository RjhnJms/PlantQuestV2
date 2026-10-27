import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';

/// What a plant does when a child touches it on its details page
/// (PLAN.md §5j). Every plant also sways a little.
enum TouchEffect {
  /// Makahiya: the leaflets fold shut, then slowly open again.
  fold,

  /// Sampaguita: little wisps of scent float up.
  scent,

  /// Gumamela (kids make bubbles from it) and Bakawan (air from its roots).
  bubbles,

  /// Narra: yellow flowers rain down.
  petals,

  /// Malunggay and the trees: a few leaves flutter down.
  leaves,

  /// Palay: golden grains drop.
  grains,

  /// Mongo: seeds hop out of the pods.
  seeds,

  /// Kangkong: rings spread on the water.
  ripple,
}

/// One touch, as the painter needs it.
class PlantTouch {
  const PlantTouch({required this.at, required this.t, required this.fold});

  /// Where the finger landed, in design units.
  final Offset at;

  /// 0 → 1 as the sway and the little effect play.
  final double t;

  /// Makahiya only: 0 open → 1 folded shut.
  final double fold;

  /// The whole plant leans from its base: a quick wobble that settles.
  double get sway => math.sin(t * math.pi * 3) * 0.07 * (1 - t);

  /// Which reaction each plant has.
  static TouchEffect effectOf(String plantId) => switch (plantId) {
    'makahiya' => TouchEffect.fold,
    'sampaguita' => TouchEffect.scent,
    'gumamela' || 'bakawan' => TouchEffect.bubbles,
    'narra' => TouchEffect.petals,
    'palay' => TouchEffect.grains,
    'mongo' => TouchEffect.seeds,
    'kangkong' => TouchEffect.ripple,
    _ => TouchEffect.leaves,
  };

  /// How long the makahiya stays folded before it opens again (the sway
  /// and the other effects are shorter).
  static const duration = Duration(milliseconds: 4200);
  static const effectShare = 0.4;

  /// The touch at [elapsed] (0–1 of [duration]).
  static PlantTouch after(Offset point, double elapsed) {
    final t = (elapsed / effectShare).clamp(0.0, 1.0);
    // Shut fast, stay shut, then open slowly, like the real plant.
    final fold = elapsed < 0.06
        ? elapsed / 0.06
        : elapsed < 0.6
        ? 1.0
        : 1 - (elapsed - 0.6) / 0.4;
    return PlantTouch(at: point, t: t, fold: fold.clamp(0.0, 1.0));
  }

  /// Draws [effect] over the plant (design units).
  void paint(Canvas c, TouchEffect effect, {Color leafColor = AppColors.leaf}) {
    if (t >= 1) return;
    final fade = (1 - t).clamp(0.0, 1.0);
    final rnd = math.Random(at.dx.round() * 31 + at.dy.round());
    switch (effect) {
      case TouchEffect.fold:
        break;
      case TouchEffect.scent:
        final edge = Sticker.stroke(AppColors.bubblegumDark.withValues(alpha: 0.6 * fade), 5);
        final line = Sticker.stroke(AppColors.bubblegumTint.withValues(alpha: fade), 3);
        for (var i = 0; i < 3; i++) {
          final x0 = at.dx + (i - 1) * 16;
          final rise = 6 + t * 60;
          final path = Path()..moveTo(x0, at.dy - rise);
          for (var k = 1; k <= 8; k++) {
            path.lineTo(x0 + math.sin(k * 1.1 + i + t * 6) * 6, at.dy - rise - k * 5);
          }
          c
            ..drawPath(path, edge)
            ..drawPath(path, line);
        }
      case TouchEffect.bubbles:
        for (var i = 0; i < 6; i++) {
          final r = 6.0 + rnd.nextDouble() * 6;
          final o = at + Offset((rnd.nextDouble() - 0.5) * 50 + math.sin(t * 8 + i) * 5, -t * (55 + i * 14));
          c
            ..drawCircle(o, r, Sticker.solid(AppColors.skyLight.withValues(alpha: 0.5 * fade)))
            ..drawCircle(o, r, Sticker.stroke(AppColors.skyDark.withValues(alpha: 0.9 * fade), 2))
            ..drawCircle(
              o + Offset(-r * 0.35, -r * 0.35),
              r * 0.25,
              Sticker.solid(const Color(0xFFFFFFFF).withValues(alpha: fade)),
            );
        }
      case TouchEffect.petals || TouchEffect.leaves || TouchEffect.grains:
        final color = switch (effect) {
          TouchEffect.petals => AppColors.narraYellow,
          TouchEffect.grains => AppColors.mangoYellow,
          _ => leafColor,
        };
        final size = effect == TouchEffect.grains ? const Size(6, 9) : const Size(15, 8);
        for (var i = 0; i < 8; i++) {
          final drift = (rnd.nextDouble() - 0.5) * 50;
          final o = at + Offset(drift * t + math.sin(t * 9 + i) * 6, t * (40 + rnd.nextDouble() * 40));
          c
            ..save()
            ..translate(o.dx, o.dy)
            ..rotate(t * 6 + i);
          final r = Rect.fromCenter(center: Offset.zero, width: size.width, height: size.height);
          c
            ..drawOval(r, Sticker.solid(color.withValues(alpha: fade)))
            ..drawOval(r, Sticker.stroke(Sticker.darken(color, 0.3).withValues(alpha: fade), 1))
            ..restore();
        }
      case TouchEffect.seeds:
        for (var i = 0; i < 5; i++) {
          final dir = (i - 2) * 0.5;
          final o = at + Offset(dir * 40 * t, -math.sin(t * math.pi) * (24 + i * 4) + t * 20);
          c
            ..drawCircle(o, 4.5, Sticker.solid(AppColors.leafDark.withValues(alpha: fade)))
            ..drawCircle(o + const Offset(-1, -1), 1, Sticker.solid(const Color(0xFFFFFFFF).withValues(alpha: fade)));
        }
      case TouchEffect.ripple:
        for (var i = 0; i < 3; i++) {
          final p = (t * 1.4 - i * 0.2).clamp(0.0, 1.0);
          if (p <= 0) continue;
          c.drawOval(
            Rect.fromCenter(center: Offset(at.dx, 200), width: 20 + p * 120, height: 6 + p * 24),
            Sticker.stroke(AppColors.skyLight.withValues(alpha: (1 - p) * 0.9), 2.4),
          );
        }
    }
  }
}
