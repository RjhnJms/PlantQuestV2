import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_info.dart';
import '../art/binhi/binhi.dart';
import '../art/garden/garden_art.dart';
import '../art/watering_can.dart';
import '../art/icons/kid_icon.dart';
import '../art/scenes/world_scene.dart';
import '../art/plants/plant_view.dart';
import '../content/plant_catalog.dart';
import '../content/plant_content.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/sprout_logo.dart';

/// Loading screen ideas, drawn still at [progress] (preview only; drawn to
/// PNGs by tool/render_loading_test.dart).
enum LoadingStyle { garden, grow, worlds, sunrise, parade, splash, gate, water, leaf }

class LoadingMock extends StatelessWidget {
  const LoadingMock({super.key, required this.style, this.progress = 0.6});

  final LoadingStyle style;
  final double progress;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: switch (style) {
      LoadingStyle.garden => _Garden(progress),
      LoadingStyle.grow => _Grow(progress),
      LoadingStyle.worlds => _Worlds(progress),
      LoadingStyle.sunrise => _Sunrise(progress),
      LoadingStyle.parade => _Parade(progress),
      LoadingStyle.splash => _Splash(progress),
      LoadingStyle.gate => _Gate(progress),
      LoadingStyle.water => _Water(progress),
      LoadingStyle.leaf => _LeafFill(progress),
    },
  );
}

/// A: the Backyard fills the screen, Binhi stands in the grass, and five
/// leaves fill in as it loads.
class _Garden extends StatelessWidget {
  const _Garden(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    final filled = (progress * 5).floor();
    return Stack(
      children: [
        const Positioned.fill(child: WorldScene(world: 1, parallax: false, reduceMotion: true)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.gutter),
            child: Column(
              children: [
                const SizedBox(height: AppSizes.gapXl),
                _whiteCard(
                  Column(
                    children: [
                      const SproutLogo(size: 48),
                      Text(AppInfo.name, style: AppText.display.copyWith(color: AppColors.leafDark, fontSize: 40)),
                      Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Spacer(),
                const Binhi(stage: BinhiStage.blooming, size: 150, reduceMotion: true),
                const SizedBox(height: AppSizes.gapL),
                _whiteCard(
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < 5; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: KidIconView(KidIcon.leaf, size: AppSizes.iconLarge, muted: i >= filled),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.gapS),
                      Text('Growing your garden…', style: AppText.heading.copyWith(color: AppColors.leafDark)),
                      const SizedBox(height: AppSizes.gapM),
                      const _Credits(small: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// B: a calm cream page. Binhi grows from a seed to a flower inside the
/// same growth ring as Home, with a fun fact to read while waiting.
class _Grow extends StatelessWidget {
  const _Grow(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    final stage = progress < 0.3
        ? BinhiStage.seed
        : progress < 0.55
        ? BinhiStage.sprout
        : progress < 0.85
        ? BinhiStage.sapling
        : BinhiStage.blooming;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.gapXxl),
            const SproutLogo(size: 40, withName: true, nameSize: 38),
            Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.textMuted)),
            const Spacer(),
            SizedBox.square(
              dimension: 230,
              child: CustomPaint(
                painter: _RingPainter(progress),
                child: Center(child: Binhi(stage: stage, size: 150, reduceMotion: true)),
              ),
            ),
            const SizedBox(height: AppSizes.gapM),
            Text('${(progress * 100).round()}%', style: AppText.title.copyWith(color: AppColors.leafDark)),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.gapL),
              decoration: BoxDecoration(
                color: AppColors.sunshineTint,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const KidIconView(KidIcon.idea),
                  const SizedBox(width: AppSizes.gapM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Did you know?', style: AppText.heading.copyWith(color: AppColors.sunshineDark)),
                        Text(PlantContent.of('makahiya').funFact, style: AppText.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.gapXl),
            const _Credits(),
            const SizedBox(height: AppSizes.gapL),
          ],
        ),
      ),
    );
  }
}

/// C: a peek at all three worlds, and Binhi hops along the loading path.
class _Worlds extends StatelessWidget {
  const _Worlds(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.gapL),
            Expanded(
              flex: 10,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                      child: Column(
                        children: [
                          for (final w in [1, 2, 3])
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: w < 3 ? 4 : 0),
                                child: WorldScene(world: w, parallax: false, reduceMotion: true),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -34,
                    child: Center(
                      child: _whiteCard(
                        const SproutLogo(size: 40, withName: true, nameSize: 36),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 46),
            Text('3 worlds · 15 plants to discover', style: AppText.heading.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: AppSizes.gapXl),
            LayoutBuilder(
              builder: (context, c) {
                const binhi = 64.0;
                return SizedBox(
                  height: binhi + 22,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 0,
                        width: c.maxWidth,
                        child: AppProgressBar(value: progress, height: 18, duration: Duration.zero),
                      ),
                      Positioned(
                        left: (c.maxWidth - binhi) * progress,
                        bottom: 10,
                        child: const Binhi(stage: BinhiStage.sprout, size: binhi, reduceMotion: true),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.gapS),
            Text('Binhi is on the way…', style: AppText.label.copyWith(color: AppColors.leafDark)),
            const Spacer(flex: 2),
            const _Credits(),
            const SizedBox(height: AppSizes.gapL),
          ],
        ),
      ),
    );
  }
}

/// D: morning comes. The sun rises over the hills as it loads and the sky
/// turns from dawn pink to blue; Binhi waits on the hilltop.
class _Sunrise extends StatelessWidget {
  const _Sunrise(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final hillTop = c.maxHeight * 0.58;
        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // Blue spreads down the sky as the sun rises.
                    colors: const [AppColors.sky, AppColors.coralTint, AppColors.sunshineTint],
                    stops: [0, 0.3 + 0.4 * progress, 1],
                  ),
                ),
              ),
            ),
            // The sun climbs from behind the hill.
            Positioned(
              left: c.maxWidth * 0.62 - 70,
              top: hillTop - 40 - progress * 190,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.sunshine,
                  border: Border.all(color: AppColors.sunshineDark, width: 4),
                  boxShadow: [
                    BoxShadow(color: AppColors.sunshine.withValues(alpha: 0.6), blurRadius: 50, spreadRadius: 20),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: hillTop,
              child: CustomPaint(painter: _HillsPainter()),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: hillTop - 112,
              child: const Center(child: Binhi(stage: BinhiStage.sprout, size: 130, reduceMotion: true)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
                child: Column(
                  children: [
                    const SizedBox(height: AppSizes.gapXl),
                    const SproutLogo(size: 40, withName: true, nameSize: 40),
                    Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.text)),
                    const Spacer(),
                    Text(
                      progress < 0.5 ? 'Good morning, explorer!' : 'The sun is almost up!',
                      style: AppText.title.copyWith(color: Colors.white, fontSize: 26),
                    ),
                    const SizedBox(height: AppSizes.gapM),
                    AppProgressBar(
                      value: progress,
                      height: 18,
                      color: AppColors.sunshine,
                      trackColor: Colors.white.withValues(alpha: 0.6),
                      duration: Duration.zero,
                    ),
                    const SizedBox(height: AppSizes.gapXl),
                    const _Credits(onDark: true),
                    const SizedBox(height: AppSizes.gapL),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, 60)
      ..quadraticBezierTo(size.width * 0.25, -10, size.width * 0.55, 40)
      ..quadraticBezierTo(size.width * 0.8, 80, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = AppColors.leafLight);
    final front = Path()
      ..moveTo(0, 90)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width, 90)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = AppColors.leaf);
  }

  @override
  bool shouldRepaint(_HillsPainter old) => false;
}

/// E: all 15 plants wait as mystery shadows and colour in one by one as it
/// loads, a sneak peek of everything to discover.
class _Parade extends StatelessWidget {
  const _Parade(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    final shown = (progress * PlantCatalog.all.length).round();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.gapXl),
            const SproutLogo(size: 40, withName: true, nameSize: 38),
            Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: AppSizes.gapXl),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) => GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSizes.gapS,
                  crossAxisSpacing: AppSizes.gapS,
                  childAspectRatio: (c.maxWidth - 2 * AppSizes.gapS) / 3 / ((c.maxHeight - 4 * AppSizes.gapS) / 5),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (final (i, p) in PlantCatalog.all.indexed)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: i < shown ? p.tileColor : AppColors.track.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        ),
                        child: PlantView(plant: p, locked: i >= shown),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.gapM),
            Text('$shown of 15 plants are waking up…', style: AppText.heading.copyWith(color: AppColors.leafDark)),
            const SizedBox(height: AppSizes.gapL),
            const _Credits(),
            const SizedBox(height: AppSizes.gapL),
          ],
        ),
      ),
    );
  }
}

/// F: bold and simple. A big green page, a white logo, Binhi peeking up
/// from the bottom and three bouncing dots.
class _Splash extends StatelessWidget {
  const _Splash(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    final lit = (progress * 3).floor();
    return ColoredBox(
      color: AppColors.leaf,
      child: Stack(
        children: [
          // Soft big circles for depth.
          Positioned(top: -80, left: -60, child: _blob(260, AppColors.leafLight.withValues(alpha: 0.35))),
          Positioned(top: 260, right: -90, child: _blob(220, AppColors.leafDark.withValues(alpha: 0.25))),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Center(child: SproutLogo(size: 70)),
                ),
                const SizedBox(height: AppSizes.gapL),
                Text(AppInfo.name, style: AppText.display.copyWith(color: Colors.white, fontSize: 48)),
                Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.leafTint)),
                const SizedBox(height: AppSizes.gapXl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        width: 18,
                        height: 18,
                        transform: Matrix4.translationValues(0, i == lit ? -8 : 0, 0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= lit ? Colors.white : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
                const Spacer(flex: 2),
                const _Credits(onDark: true),
                const SizedBox(height: AppSizes.gapM),
                // Binhi peeks up from the bottom edge.
                const SizedBox(
                  height: 170,
                  child: OverflowBox(
                    maxHeight: 200,
                    alignment: Alignment.topCenter,
                    child: Binhi(stage: BinhiStage.blooming, size: 170, reduceMotion: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

/// G: a bamboo gate swings open onto Binhi's garden as it loads.
class _Gate extends StatelessWidget {
  const _Gate(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final open = Curves.easeInOut.transform(progress);
      final door = c.maxWidth / 2 * (1 - open * 0.82);
      return Stack(
        children: [
          // The garden behind the gate (the same drawing as My Garden).
          const Positioned.fill(child: CustomPaint(painter: GardenGroundPainter())),
          Positioned(
            left: 0,
            right: 0,
            bottom: c.maxHeight * 0.24,
            child: const Center(child: Binhi(stage: BinhiStage.sapling, size: 120, reduceMotion: true)),
          ),
          // Two bamboo doors sliding apart.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: door,
            child: const CustomPaint(painter: BambooDoorPainter(left: true)),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: door,
            child: const CustomPaint(painter: BambooDoorPainter(left: false)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.gutter),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.gapL),
                  _whiteCard(
                    Column(
                      children: [
                        const SproutLogo(size: 40, withName: true, nameSize: 38),
                        Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  const Spacer(),
                  _whiteCard(
                    Column(
                      children: [
                        Text(
                          progress < 0.5 ? 'Opening the garden gate…' : 'Come in!',
                          style: AppText.heading.copyWith(color: AppColors.leafDark),
                        ),
                        const SizedBox(height: AppSizes.gapS),
                        AppProgressBar(value: progress, height: 16, duration: Duration.zero),
                        const SizedBox(height: AppSizes.gapM),
                        const _Credits(small: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// H: Binhi gets watered; the can pours and five drops fill up as it loads.
class _Water extends StatelessWidget {
  const _Water(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    final filled = (progress * 5).floor();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.gapXxl),
            const SproutLogo(size: 40, withName: true, nameSize: 38),
            Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.textMuted)),
            const Spacer(),
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(color: AppColors.skyTint, shape: BoxShape.circle),
                    ),
                  ),
                  const Positioned(
                    bottom: 30,
                    child: Binhi(stage: BinhiStage.sapling, size: 160, mood: BinhiMood.cheering, reduceMotion: true),
                  ),
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: SizedBox.square(
                      dimension: 110,
                      child: CustomPaint(painter: WateringCanPainter(pouring: true)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.gapXl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: KidIconView(KidIcon.drop, size: AppSizes.iconLarge, muted: i >= filled),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.gapS),
            Text('Watering Binhi…', style: AppText.heading.copyWith(color: AppColors.skyDark)),
            const Spacer(),
            const _Credits(),
            const SizedBox(height: AppSizes.gapL),
          ],
        ),
      ),
    );
  }
}

/// I: a big leaf fills with green like a glass of water; the first plants
/// peek up along the bottom.
class _LeafFill extends StatelessWidget {
  const _LeafFill(this.progress);
  final double progress;

  @override
  Widget build(BuildContext context) {
    final plants = PlantCatalog.inWorld(1);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 150,
          child: Stack(
            children: [
              Positioned(left: 0, right: 0, bottom: 0, height: 60, child: Container(color: AppColors.leafLight)),
              Positioned(
                left: 0,
                right: 0,
                bottom: 30,
                height: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final p in plants)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: PlantView(plant: p),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
            child: Column(
              children: [
                const SizedBox(height: AppSizes.gapXxl),
                Text(AppInfo.name, style: AppText.display.copyWith(color: AppColors.leafDark, fontSize: 46)),
                Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.textMuted)),
                const Spacer(),
                SizedBox(
                  width: 220,
                  height: 280,
                  child: CustomPaint(
                    painter: _LeafPainter(progress),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Text(
                          '${(progress * 100).round()}%',
                          style: AppText.display.copyWith(color: Colors.white, fontSize: 44),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.gapM),
                Text('Growing…', style: AppText.heading.copyWith(color: AppColors.leafDark)),
                const Spacer(),
                const _Credits(),
                const SizedBox(height: 170),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LeafPainter extends CustomPainter {
  const _LeafPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final leaf = Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..cubicTo(w * 1.02, h * 0.22, w * 0.98, h * 0.72, w * 0.5, h * 0.9)
      ..cubicTo(w * 0.02, h * 0.72, w * -0.02, h * 0.22, w * 0.5, h * 0.02)
      ..close();
    canvas.drawPath(leaf, Paint()..color = AppColors.leafTint);
    // The fill, with a gentle wave on top.
    final level = h * 0.9 - (h * 0.88) * progress;
    final water = Path()..moveTo(0, level);
    for (var x = 0.0; x <= w; x += 10) {
      water.lineTo(x, level + math.sin(x / w * math.pi * 3) * 5);
    }
    water
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.save();
    canvas.clipPath(leaf);
    canvas.drawPath(water, Paint()..color = AppColors.leaf);
    canvas.restore();
    // Midrib and veins.
    final vein = Paint()
      ..color = AppColors.leafDark.withValues(alpha: 0.5)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.5, h * 0.12), Offset(w * 0.5, h * 0.98), vein);
    for (final y in [0.3, 0.45, 0.6]) {
      canvas.drawLine(Offset(w * 0.5, h * (y + 0.08)), Offset(w * 0.22, h * y), vein..strokeWidth = 3);
      canvas.drawLine(Offset(w * 0.5, h * (y + 0.08)), Offset(w * 0.78, h * y), vein);
    }
    canvas.drawPath(
      leaf,
      Paint()
        ..color = AppColors.leafDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(_LeafPainter old) => old.progress != progress;
}

Widget _whiteCard(Widget child, {EdgeInsets padding = const EdgeInsets.all(AppSizes.gapL)}) => Container(
  padding: padding,
  decoration: BoxDecoration(
    color: AppColors.card.withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(AppSizes.radiusL),
    border: Border.all(color: AppColors.border, width: AppSizes.borderWidth),
    boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4))],
  ),
  child: child,
);

class _Credits extends StatelessWidget {
  const _Credits({this.small = false, this.onDark = false});
  final bool small;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final ink = onDark ? Colors.white : null;
    return Column(
      children: [
        Text(
          'DEVELOPED BY',
          style: AppText.label.copyWith(letterSpacing: 1.6, fontSize: small ? 11 : null, color: ink),
        ),
        Text(
          AppInfo.developers.join('\n'),
          style: (small ? AppText.bodySmall : AppText.heading.copyWith(fontSize: 17)).copyWith(color: ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Version ${AppInfo.version}',
          style: AppText.bodySmall.copyWith(color: onDark ? Colors.white70 : AppColors.textMuted),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(10);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = AppColors.track;
    canvas.drawOval(rect, track);
    canvas.drawCircle(size.center(Offset.zero), rect.width / 2 - 14, Paint()..color = AppColors.leafTint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      track
        ..color = AppColors.leaf
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
