import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_info.dart';
import '../art/binhi/binhi.dart';
import '../art/garden/garden_art.dart';
import '../game/garden.dart';
import '../art/icons/kid_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/vine_progress.dart';

/// Progress bar ideas for the Sunrise loading screen, each drawn in the
/// screen's green bottom half at [progress] (preview only; drawn to PNGs by
/// tool/render_progress_test.dart).
enum ProgressStyle {
  bar,
  vine,
  leaves,
  trail,
  stages,
  bloom,
  bamboo,
  stones,
  kubo,
  butterfly,
  rice,
  basket,
  caterpillar,
  pond,
  rainbow,
}

class ProgressMock extends StatelessWidget {
  const ProgressMock({super.key, required this.style, this.progress = 0.6});

  final ProgressStyle style;
  final double progress;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.leaf,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Text('The sun is almost up!', style: AppText.title.copyWith(color: Colors.white, fontSize: 26)),
          const SizedBox(height: 14),
          SizedBox(
            height: 70,
            child: Center(
              child: switch (style) {
                ProgressStyle.bar => AppProgressBar(
                  value: progress,
                  height: 18,
                  color: AppColors.sunshine,
                  trackColor: Colors.white.withValues(alpha: 0.6),
                  duration: Duration.zero,
                ),
                ProgressStyle.vine => SizedBox.expand(child: CustomPaint(painter: VineProgressPainter(progress))),
                ProgressStyle.leaves => _Leaves(progress),
                ProgressStyle.trail => _Trail(progress),
                ProgressStyle.stages => _Stages(progress),
                ProgressStyle.bloom => SizedBox.square(
                  dimension: 70,
                  child: CustomPaint(painter: _BloomPainter(progress)),
                ),
                ProgressStyle.bamboo => SizedBox.expand(child: CustomPaint(painter: _BambooPainter(progress))),
                ProgressStyle.stones => _Stones(progress),
                ProgressStyle.kubo => SizedBox(
                  width: 110,
                  height: 70,
                  child: CustomPaint(painter: _KuboPainter(progress)),
                ),
                ProgressStyle.butterfly => SizedBox.expand(child: CustomPaint(painter: _ButterflyTrail(progress))),
                ProgressStyle.rice => SizedBox.expand(child: CustomPaint(painter: _RicePainter(progress))),
                ProgressStyle.basket => SizedBox(
                  width: 160,
                  height: 70,
                  child: CustomPaint(painter: _BasketPainter(progress)),
                ),
                ProgressStyle.caterpillar => SizedBox.expand(
                  child: CustomPaint(painter: _CaterpillarPainter(progress)),
                ),
                ProgressStyle.pond => SizedBox(
                  width: 200,
                  height: 70,
                  child: CustomPaint(painter: _PondFillPainter(progress)),
                ),
                ProgressStyle.rainbow => SizedBox(
                  width: 200,
                  height: 70,
                  child: CustomPaint(painter: _RainbowPainter(progress)),
                ),
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('DEVELOPED BY', style: AppText.label.copyWith(letterSpacing: 1.6, color: Colors.white)),
          for (final name in AppInfo.developers)
            Text(name, style: AppText.heading.copyWith(fontSize: 17, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Version ${AppInfo.version}', style: AppText.bodySmall.copyWith(color: Colors.white70)),
        ],
      ),
    ),
  );
}

/// Five leaves that turn green one by one.
class _Leaves extends StatelessWidget {
  const _Leaves(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    final filled = (progress * 5).floor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 5; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: i < filled ? 0.95 : 0.35),
              shape: BoxShape.circle,
            ),
            child: KidIconView(KidIcon.leaf, size: 38, muted: i >= filled),
          ),
      ],
    );
  }
}

/// Binhi hopping along a dotted trail toward a little garden gate.
class _Trail extends StatelessWidget {
  const _Trail(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      const binhi = 56.0;
      final x = (c.maxWidth - 44 - binhi) * progress;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 30,
            top: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 16; i++)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i / 15 <= progress ? AppColors.sunshine : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const Positioned(right: 0, top: 22, child: KidIconView(KidIcon.home, size: 42)),
          Positioned(
            left: x,
            top: -4,
            child: const Binhi(stage: BinhiStage.sprout, size: binhi, reduceMotion: true),
          ),
        ],
      );
    },
  );
}

/// Seed, sprout, sapling and flower: Binhi's stages light up in turn.
class _Stages extends StatelessWidget {
  const _Stages(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    const stages = BinhiStage.values;
    final lit = (progress * stages.length).floor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (i, st) in stages.indexed) ...[
          if (i > 0)
            Container(
              width: 22,
              height: 5,
              decoration: BoxDecoration(
                color: i <= lit ? AppColors.sunshine : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          Opacity(
            opacity: i <= lit ? 1 : 0.4,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: i <= lit ? 0.95 : 0.6),
                shape: BoxShape.circle,
                border: Border.all(color: i == lit ? AppColors.sunshine : Colors.transparent, width: 3),
              ),
              child: Center(child: Binhi(stage: st, size: 50, reduceMotion: true)),
            ),
          ),
        ],
      ],
    );
  }
}

/// A flower opening petal by petal (eight petals, one per eighth).
class _BloomPainter extends CustomPainter {
  const _BloomPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final shown = progress * 8;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      // The petal now opening grows in; later ones are faint outlines.
      final grow = (shown - i).clamp(0.0, 1.0);
      final centre = c + Offset(math.cos(a), math.sin(a)) * 20;
      final r = Rect.fromCenter(center: centre, width: 22, height: 30);
      canvas.save();
      canvas.translate(centre.dx, centre.dy);
      canvas.rotate(a + math.pi / 2);
      canvas.translate(-centre.dx, -centre.dy);
      if (grow > 0) {
        canvas.drawOval(
          Rect.fromCenter(center: centre, width: 22 * grow, height: 30 * grow),
          Paint()..color = AppColors.bubblegum,
        );
      }
      canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: grow > 0 ? 0.9 : 0.5),
      );
      canvas.restore();
    }
    canvas.drawCircle(c, 12, Paint()..color = AppColors.sunshine);
    canvas.drawCircle(
      c,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.sunshineDark,
    );
  }

  @override
  bool shouldRepaint(_BloomPainter old) => old.progress != progress;
}

/// A row of bamboo stalks growing up one after another.
class _BambooPainter extends CustomPainter {
  const _BambooPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    const count = 9;
    final gap = s.width / count;
    final grown = progress * count;
    for (var i = 0; i < count; i++) {
      final g = (grown - i).clamp(0.0, 1.0);
      final x = gap * (i + 0.5);
      final full = s.height * (0.7 + 0.3 * ((i * 7) % 3) / 2);
      final h = math.max(6.0, full * g);
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x - 7, s.height - h, 14, h), const Radius.circular(6));
      canvas.drawRRect(r, Paint()..color = g > 0 ? AppColors.bamboo : Colors.white.withValues(alpha: 0.3));
      if (g <= 0) continue;
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.bambooDark,
      );
      for (var y = s.height - 18; y > s.height - h + 6; y -= 18) {
        canvas.drawRect(Rect.fromLTWH(x - 6, y, 12, 3), Paint()..color = AppColors.bambooDark);
      }
      if (g >= 1) {
        // A leaf on top of each full-grown stalk.
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x + 9, s.height - h + 6), width: 16, height: 7),
          Paint()..color = AppColors.leafLight,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BambooPainter old) => old.progress != progress;
}

/// Stepping stones across a little stream, filling in as Binhi's path.
class _StonesPainter extends CustomPainter {
  const _StonesPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final mid = s.height * 0.62;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, mid - 14, s.width, 28), const Radius.circular(14)),
      Paint()..color = AppColors.sky.withValues(alpha: 0.7),
    );
    const count = 7;
    final lit = (progress * count).floor();
    for (var i = 0; i < count; i++) {
      final x = s.width * (i + 0.5) / count;
      final r = Rect.fromCenter(center: Offset(x, mid + (i.isEven ? -3 : 3)), width: 38, height: 22);
      canvas.drawOval(r, Paint()..color = i < lit ? const Color(0xFFE6DFCF) : Colors.white.withValues(alpha: 0.35));
      canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = i < lit ? const Color(0xFFADA28A) : Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_StonesPainter old) => old.progress != progress;
}

/// The stones with Binhi hopping onto the newest one.
class _Stones extends StatelessWidget {
  const _Stones(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      const count = 7;
      final lit = math.max((progress * count).floor(), 1);
      final x = c.maxWidth * (lit - 0.5) / count;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _StonesPainter(progress))),
          Positioned(
            left: x - 24,
            top: c.maxHeight * 0.62 - 50,
            child: const Binhi(stage: BinhiStage.sprout, size: 48, reduceMotion: true),
          ),
        ],
      );
    },
  );
}

/// The bahay kubo going up in four steps: stilts, floor, walls, roof.
class _KuboPainter extends CustomPainter {
  const _KuboPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final step = (progress * 4).floor();
    final ghost = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.5);
    final w = s.width;
    final h = s.height;
    final stilts = [
      for (final x in [0.18, 0.5, 0.82]) Rect.fromLTWH(w * x - 3, h * 0.66, 6, h * 0.34),
    ];
    final floor = Rect.fromLTWH(w * 0.08, h * 0.6, w * 0.84, h * 0.08);
    final wall = Rect.fromLTWH(w * 0.12, h * 0.36, w * 0.76, h * 0.25);
    final roof = Path()
      ..moveTo(w * 0.0, h * 0.4)
      ..lineTo(w * 0.5, h * 0.02)
      ..lineTo(w * 1.0, h * 0.4)
      ..close();
    // Built parts in colour, the rest as a white outline still to build.
    for (final r in stilts) {
      step >= 1 ? canvas.drawRect(r, Paint()..color = AppColors.barkDark) : canvas.drawRect(r, ghost);
    }
    step >= 2 ? canvas.drawRect(floor, Paint()..color = AppColors.bark) : canvas.drawRect(floor, ghost);
    if (step >= 3) {
      canvas.drawRect(wall, Paint()..color = const Color(0xFFE8C98A));
      canvas.drawRect(
        Rect.fromLTWH(wall.left + wall.width * 0.6, wall.top + 5, wall.width * 0.22, wall.height * 0.5),
        Paint()..color = AppColors.barkDark,
      );
    } else {
      canvas.drawRect(wall, ghost);
    }
    step >= 4 ? canvas.drawPath(roof, Paint()..color = const Color(0xFFD9A441)) : canvas.drawPath(roof, ghost);
  }

  @override
  bool shouldRepaint(_KuboPainter old) => old.progress != progress;
}

/// A butterfly fluttering along a looping dotted line, leaving dots behind.
class _ButterflyTrail extends CustomPainter {
  const _ButterflyTrail(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final path = Path()..moveTo(8, s.height * 0.6);
    for (var x = 8.0; x <= s.width - 8; x += 4) {
      path.lineTo(x, s.height * 0.6 + math.sin(x / 26) * 14);
    }
    final m = path.computeMetrics().first;
    for (var d = 0.0; d < m.length; d += 14) {
      final pos = m.getTangentForOffset(d)!.position;
      final done = d <= m.length * progress;
      canvas.drawCircle(
        pos,
        done ? 3.6 : 2.6,
        Paint()..color = done ? AppColors.sunshine : Colors.white.withValues(alpha: 0.45),
      );
    }
    final at = m.getTangentForOffset(m.length * progress)!.position;
    canvas.save();
    canvas.translate(at.dx - 17, at.dy - 32);
    const GardenDecoPainter(GardenDeco.butterfly, color: AppColors.bubblegum).paint(canvas, const Size(34, 34));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ButterflyTrail old) => old.progress != progress;
}

/// Rice seedlings planted one by one in a flooded paddy row.
class _RicePainter extends CustomPainter {
  const _RicePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final ground = s.height * 0.78;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, ground - 6, s.width, 18), const Radius.circular(9)),
      Paint()..color = const Color(0xFF8FB5CC),
    );
    const count = 10;
    final planted = progress * count;
    final blade = Paint()
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final x = s.width * (i + 0.5) / count;
      final g = (planted - i).clamp(0.0, 1.0);
      if (g <= 0) {
        canvas.drawCircle(Offset(x, ground), 3, Paint()..color = Colors.white.withValues(alpha: 0.5));
        continue;
      }
      blade.color = AppColors.foliageDark;
      final h = 34 * g;
      for (final (dx, lean) in [(-4.0, -9.0), (0.0, 0.0), (4.0, 9.0)]) {
        canvas.drawLine(Offset(x + dx * 0.4, ground), Offset(x + dx + lean * g, ground - h), blade);
      }
      if (g >= 1) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x + 6, ground - h - 2), width: 7, height: 11),
          Paint()..color = AppColors.mangoYellow,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RicePainter old) => old.progress != progress;
}

/// A woven basket filling with mangoes and kalamansi.
class _BasketPainter extends CustomPainter {
  const _BasketPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    const fruit = [
      (0.3, 0.5, AppColors.mangoYellow),
      (0.5, 0.52, AppColors.citrusOrange),
      (0.7, 0.5, AppColors.mangoOrange),
      (0.4, 0.3, AppColors.coconutGreen),
      (0.6, 0.3, AppColors.mangoYellow),
      (0.5, 0.12, AppColors.citrusOrange),
    ];
    final shown = (progress * fruit.length).floor();
    for (final (i, (x, y, c)) in fruit.indexed) {
      if (i >= shown) break;
      final r = Rect.fromCenter(center: Offset(w * x, h * y), width: 26, height: 22);
      canvas.drawOval(r, Paint()..color = c);
      canvas.drawOval(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Color.lerp(c, Colors.black, 0.3)!,
      );
      canvas.drawOval(
        Rect.fromLTWH(r.left + 5, r.top + 4, 7, 4),
        Paint()..color = Colors.white.withValues(alpha: 0.55),
      );
    }
    final basket = Path()
      ..moveTo(w * 0.12, h * 0.55)
      ..lineTo(w * 0.88, h * 0.55)
      ..lineTo(w * 0.78, h * 0.98)
      ..lineTo(w * 0.22, h * 0.98)
      ..close();
    canvas.drawPath(basket, Paint()..color = AppColors.bark);
    canvas.save();
    canvas.clipPath(basket);
    final weave = Paint()
      ..color = AppColors.barkDark
      ..strokeWidth = 2;
    for (var y = h * 0.62; y < h; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(w, y), weave);
    }
    for (var x = 0.0; x < w; x += 12) {
      canvas.drawLine(Offset(x, h * 0.55), Offset(x + 6, h), weave..color = AppColors.barkDark.withValues(alpha: 0.5));
    }
    canvas.restore();
    canvas.drawPath(
      basket,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = AppColors.soilDark,
    );
  }

  @override
  bool shouldRepaint(_BasketPainter old) => old.progress != progress;
}

/// A caterpillar inching along a leaf, growing a segment at a time.
class _CaterpillarPainter extends CustomPainter {
  const _CaterpillarPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final mid = s.height * 0.62;
    // A long leaf to crawl on.
    final leaf = Path()
      ..moveTo(0, mid + 12)
      ..quadraticBezierTo(s.width * 0.5, mid - 6, s.width, mid + 12)
      ..quadraticBezierTo(s.width * 0.5, mid + 30, 0, mid + 12)
      ..close();
    canvas.drawPath(leaf, Paint()..color = AppColors.leafLight.withValues(alpha: 0.7));
    const seg = 18.0;
    final count = math.max(1, (progress * (s.width / seg - 2)).floor());
    for (var i = 0; i < count; i++) {
      final x = 14 + i * seg * 0.8;
      final y = mid - 4 + math.sin(i * 0.9) * 3;
      canvas.drawCircle(Offset(x, y), seg / 2, Paint()..color = i.isEven ? AppColors.leaf : AppColors.leafLight);
      canvas.drawCircle(
        Offset(x, y),
        seg / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.foliageDark,
      );
    }
    // The head, with eyes and two antennae.
    final hx = 14 + count * seg * 0.8 + 4;
    final head = Offset(hx, mid - 8);
    canvas.drawCircle(head, 12, Paint()..color = AppColors.sunshine);
    canvas.drawCircle(
      head,
      12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.sunshineDark,
    );
    for (final dx in [-4.0, 4.0]) {
      canvas.drawCircle(head + Offset(dx, -2), 2.2, Paint()..color = AppColors.text);
      canvas.drawLine(
        head + Offset(dx, -11),
        head + Offset(dx * 2, -20),
        Paint()
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = AppColors.text,
      );
    }
  }

  @override
  bool shouldRepaint(_CaterpillarPainter old) => old.progress != progress;
}

/// A little pond filling up, lily pads rising with the water.
class _PondFillPainter extends CustomPainter {
  const _PondFillPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final rim = Rect.fromLTWH(4, 8, s.width - 8, s.height - 12);
    canvas.drawOval(rim, Paint()..color = const Color(0xFFDCD3C0));
    final inner = rim.deflate(8);
    canvas.drawOval(inner, Paint()..color = AppColors.soil.withValues(alpha: 0.5));
    canvas.save();
    canvas.clipPath(Path()..addOval(inner));
    final level = inner.bottom - inner.height * progress;
    canvas.drawRect(Rect.fromLTRB(inner.left, level, inner.right, inner.bottom), Paint()..color = AppColors.sky);
    canvas.drawRect(
      Rect.fromLTRB(inner.left, level, inner.right, level + 3),
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );
    for (final dx in [0.3, 0.62]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(inner.left + inner.width * dx, level + 5), width: 26, height: 10),
        Paint()..color = AppColors.leaf,
      );
    }
    canvas.restore();
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFFADA28A),
    );
  }

  @override
  bool shouldRepaint(_PondFillPainter old) => old.progress != progress;
}

/// A rainbow whose colours arrive one band at a time.
class _RainbowPainter extends CustomPainter {
  const _RainbowPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    const bands = [
      Color(0xFFF26B6B),
      Color(0xFFFFA94D),
      Color(0xFFFFD93D),
      Color(0xFF7ED957),
      Color(0xFF5DB7F5),
      Color(0xFF9B7BEA),
    ];
    final shown = progress * bands.length;
    final centre = Offset(s.width / 2, s.height);
    for (final (i, c) in bands.indexed) {
      final g = (shown - i).clamp(0.0, 1.0);
      final r = s.height - 6 - i * 9.0;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: r),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(alpha: 0.3),
      );
      if (g > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: centre, radius: r),
          math.pi,
          math.pi * g,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..color = c,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RainbowPainter old) => old.progress != progress;
}
