import 'dart:math' as math;
import 'dart:ui';

/// Shared geometry so every layer of a scene agrees on where the sky ends
/// and things stand. Works for short headers and tall path sections.
class SceneLayout {
  SceneLayout(this.size);

  final Size size;

  double get w => size.width;
  double get h => size.height;

  /// Height of the open sky band.
  double get skyH => (h * 0.32).clamp(math.min(110.0, h * 0.6), math.max(110.0, w * 0.62));

  /// Where the near ground starts.
  double get groundTop => math.min(skyH + 52, h * 0.85);

  /// Sun center and radius.
  Offset get sunCenter => Offset(w * 0.84, skyH * 0.26 + 4);
  double get sunRadius => (w * 0.075).clamp(18.0, 34.0);

  /// Same "random" numbers every frame and every launch, per world.
  math.Random random(int world, int salt) => math.Random(world * 7919 + salt);

  /// Evenly spread points on the ground with a little jitter, so details
  /// never clump or leave big empty gaps.
  List<Offset> scatter(int world, int salt, {required double spacing, double top = 0, double margin = 12}) {
    final r = random(world, salt);
    final start = top == 0 ? groundTop + spacing * 0.5 : top;
    final points = <Offset>[];
    var row = 0;
    for (var y = start; y < h - margin; y += spacing * 0.8, row++) {
      final shift = row.isEven ? 0.0 : spacing / 2;
      for (var x = margin + shift; x < w - margin; x += spacing) {
        points.add(Offset(x + (r.nextDouble() - 0.5) * spacing * 0.6, y + (r.nextDouble() - 0.5) * spacing * 0.5));
      }
    }
    return points;
  }
}
