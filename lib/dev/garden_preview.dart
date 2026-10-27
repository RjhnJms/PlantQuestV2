import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../art/binhi/binhi.dart';
import '../art/icons/kid_icon.dart';
import '../art/plants/plant_view.dart';
import '../content/plant_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/stat_pill.dart';

/// Four looks for My Garden (preview only; drawn to PNGs by
/// tool/render_garden_test.dart). Every look uses the same header, tray and
/// pieces so only the garden itself changes. [GardenLook.mixed] is the
/// owner's pick: Storybook with a bahay kubo, flowers in pots, crops in a
/// raised bed, trees in the ground and water plants in the pond.
enum GardenLook { storybook, beds, kubo, island, mixed }

class GardenMock extends StatelessWidget {
  const GardenMock({super.key, required this.look});

  final GardenLook look;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapS),
            child: Row(
              children: [
                Expanded(child: Text('My Garden', style: AppText.title)),
                StatPill.leaves(value: 64),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapM),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
                child: LayoutBuilder(
                  builder: (context, c) => _Scene(look: look, size: c.biggest),
                ),
              ),
            ),
          ),
          _Tray(look: look),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------------------ scenes

class _Scene extends StatelessWidget {
  const _Scene({required this.look, required this.size});

  final GardenLook look;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final plants = PlantCatalog.inWorld(1);
    final w = size.width;
    final h = size.height;

    /// A piece standing with its feet at (x, y) as shares of the scene.
    Widget at(double x, double y, double box, Widget child, {bool shadow = false}) => Positioned(
      left: w * x - box / 2,
      top: h * y - box,
      width: box,
      height: box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (shadow)
            Positioned(
              left: box * 0.18,
              right: box * 0.18,
              bottom: -box * 0.04,
              height: box * 0.12,
              child: const _Shadow(),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );

    Widget plant(int i) => PlantView(plant: plants[i]);
    const binhi = Binhi(stage: BinhiStage.sapling, size: 90, reduceMotion: true);

    final pieces = switch (look) {
      GardenLook.storybook => [
        at(0.5, 0.36, 120, const CustomPaint(painter: _Deco(_Kind.bench)), shadow: true),
        at(0.2, 0.47, 110, plant(0)),
        at(0.82, 0.47, 110, plant(1)),
        at(0.72, 0.66, 104, plant(2)),
        at(0.18, 0.88, 120, plant(3)),
        at(0.8, 0.96, 140, const CustomPaint(painter: _Deco(_Kind.pond)), shadow: false),
        at(0.47, 0.82, 90, binhi),
        at(0.36, 0.42, 36, const CustomPaint(painter: _Deco(_Kind.butterfly, AppColors.bubblegum)), shadow: false),
        at(0.72, 0.3, 30, const CustomPaint(painter: _Deco(_Kind.butterfly, AppColors.sunshine)), shadow: false),
      ],
      GardenLook.beds => [
        // Four raised beds in a 2 x 2 grid, a plant in each; the empty one
        // shows where a new plant can go.
        at(0.28, 0.4, 112, plant(0)),
        at(0.72, 0.4, 112, plant(1)),
        at(0.28, 0.66, 112, plant(2)),
        at(0.72, 0.6, 50, const CustomPaint(painter: _Deco(_Kind.plus)), shadow: false),
        at(0.3, 0.95, 110, const CustomPaint(painter: _Deco(_Kind.bench)), shadow: true),
        at(0.78, 0.95, 120, plant(3)),
        at(0.52, 0.96, 80, binhi),
        at(0.9, 0.15, 34, const CustomPaint(painter: _Deco(_Kind.butterfly, AppColors.bubblegum)), shadow: false),
      ],
      GardenLook.kubo => [
        at(0.22, 0.52, 100, plant(0)),
        at(0.84, 0.55, 104, plant(1)),
        at(0.56, 0.7, 96, plant(2)),
        at(0.2, 0.9, 116, plant(3)),
        at(0.74, 0.92, 130, const CustomPaint(painter: _Deco(_Kind.banig)), shadow: false),
        at(0.74, 0.86, 64, const CustomPaint(painter: _Deco(_Kind.palayok)), shadow: true),
        at(0.45, 0.88, 90, binhi),
        at(0.38, 0.6, 30, const CustomPaint(painter: _Deco(_Kind.butterfly, AppColors.sunshine)), shadow: false),
      ],
      GardenLook.island => [
        at(0.24, 0.56, 104, plant(0)),
        at(0.72, 0.48, 104, plant(1)),
        at(0.58, 0.64, 96, plant(2)),
        at(0.2, 0.74, 100, plant(3)),
        at(0.5, 0.43, 96, const CustomPaint(painter: _Deco(_Kind.bench)), shadow: true),
        at(0.44, 0.78, 84, binhi),
        at(0.78, 0.76, 96, const CustomPaint(painter: _Deco(_Kind.pond)), shadow: false),
        at(0.2, 0.28, 34, const CustomPaint(painter: _Deco(_Kind.butterfly, AppColors.bubblegum)), shadow: false),
        at(0.85, 0.3, 30, const CustomPaint(painter: _Deco(_Kind.butterfly, AppColors.grape)), shadow: false),
      ],
      GardenLook.mixed => [
        at(0.8, 0.37, 104, const CustomPaint(painter: _Deco(_Kind.bench)), shadow: true),
        // Flowers in pots by the kubo.
        at(0.12, 0.52, 92, _Potted(PlantCatalog.byId('gumamela')), shadow: true),
        at(0.6, 0.47, 84, _Potted(PlantCatalog.byId('sampaguita')), shadow: true),
        // Crops in a raised bed.
        Positioned(
          left: w * 0.52,
          top: h * 0.66 - 104,
          width: w * 0.46,
          height: 104,
          child: _RaisedBed([PlantCatalog.byId('palay'), PlantCatalog.byId('mongo')]),
        ),
        // Wild plants and trees in the ground.
        at(0.2, 0.74, 96, PlantView(plant: PlantCatalog.byId('makahiya'))),
        at(0.16, 0.97, 126, PlantView(plant: PlantCatalog.byId('kalamansi'))),
        // Water plants in the pond.
        at(0.78, 0.99, 150, const CustomPaint(painter: _Deco(_Kind.pond))),
        at(0.72, 0.93, 62, PlantView(plant: PlantCatalog.byId('kangkong'), mode: PlantMode.planted)),
        at(0.48, 0.84, 88, binhi),
        at(0.4, 0.56, 32, const CustomPaint(painter: _Deco(_Kind.butterfly, AppColors.bubblegum))),
      ],
    };

    return Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _Ground(look))),
        ...pieces,
        if (look != GardenLook.kubo)
          Positioned(
            left: AppSizes.gapM,
            top: AppSizes.gapM,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Row(
                children: [
                  const KidIconView(KidIcon.hand, size: AppSizes.iconSmall),
                  const SizedBox(width: 6),
                  Text(look == GardenLook.beds ? 'Tap a bed to plant' : 'Drag to move things', style: AppText.label),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Shadow extends StatelessWidget {
  const _Shadow();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.elliptical(100, 40)),
      color: Colors.black.withValues(alpha: 0.12),
    ),
  );
}

/// The ground for each look.
class _Ground extends CustomPainter {
  const _Ground(this.look);
  final GardenLook look;

  @override
  void paint(Canvas canvas, Size s) {
    switch (look) {
      case GardenLook.storybook:
        _storybook(canvas, s);
      case GardenLook.beds:
        _beds(canvas, s);
      case GardenLook.kubo:
        _kubo(canvas, s);
      case GardenLook.island:
        _island(canvas, s);
      case GardenLook.mixed:
        _mixed(canvas, s);
    }
  }

  // A: soft painted garden: hedge and trees at the back, tufts and flowers,
  // stepping stones.
  void _storybook(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    _sky(canvas, s, h * 0.24, const [AppColors.sky, AppColors.skyTint]);
    _cloud(canvas, Offset(w * 0.75, h * 0.07), 90);
    _cloud(canvas, Offset(w * 0.22, h * 0.12), 60);
    // Trees and a hedge at the back.
    for (final (x, r) in [(0.08, 46.0), (0.3, 36.0), (0.92, 50.0), (0.68, 34.0)]) {
      canvas.drawRect(Rect.fromLTWH(w * x - 5, h * 0.17, 10, 40), Paint()..color = AppColors.bark);
      _blob(canvas, Offset(w * x, h * 0.16), r, AppColors.foliage, AppColors.foliageDark);
    }
    final hedge = Path()..moveTo(0, h * 0.25);
    for (var x = 0.0; x <= w; x += 28) {
      hedge.quadraticBezierTo(x + 14, h * 0.21, x + 28, h * 0.25);
    }
    hedge
      ..lineTo(w, h * 0.3)
      ..lineTo(0, h * 0.3)
      ..close();
    _outlined(canvas, hedge, AppColors.foliage, AppColors.foliageDark);
    // Grass with a soft light from the top.
    final grass = Rect.fromLTWH(0, h * 0.28, w, h);
    canvas.drawRect(
      grass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.leafLight, AppColors.leaf],
        ).createShader(grass),
    );
    // A sandy path from the bench to the front, with a darker edge.
    final walk = Path()
      ..moveTo(w * 0.5, h * 0.33)
      ..cubicTo(w * 0.3, h * 0.55, w * 0.62, h * 0.7, w * 0.46, h * 1.04);
    canvas.drawPath(
      walk,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 50
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFD8C8A2),
    );
    canvas.drawPath(
      walk,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 42
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFF1E6CB),
    );
    // Pebbles along the path.
    for (final metric in walk.computeMetrics()) {
      for (var d = 30.0; d < metric.length; d += 46) {
        final t = metric.getTangentForOffset(d)!;
        final side = (d ~/ 46).isEven ? 1.0 : -1.0;
        final o = t.position + Offset(-t.vector.dy, t.vector.dx) * 12 * side;
        canvas.drawOval(Rect.fromCenter(center: o, width: 7, height: 4.5), Paint()..color = const Color(0xFFCDBB93));
      }
    }
    // A flower border along the hedge.
    const border = [Colors.white, AppColors.bubblegum, AppColors.sunshine];
    for (var i = 0; i < 16; i++) {
      final x = w * (i + 0.5) / 16;
      _flowerAt(canvas, Offset(x, h * (i.isEven ? 0.305 : 0.315)), border[i % 3]);
    }
    _tufts(canvas, s, h * 0.36, 14, 7);
  }

  // E: Storybook with the family's bahay kubo at the back.
  void _mixed(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    _sky(canvas, s, h * 0.26, const [AppColors.sky, AppColors.skyTint]);
    _cloud(canvas, Offset(w * 0.7, h * 0.06), 84);
    _cloud(canvas, Offset(w * 0.3, h * 0.05), 54);
    for (final (x, r) in [(0.62, 34.0), (0.94, 48.0), (0.76, 40.0)]) {
      canvas.drawRect(Rect.fromLTWH(w * x - 5, h * 0.17, 10, 40), Paint()..color = AppColors.bark);
      _blob(canvas, Offset(w * x, h * 0.16), r, AppColors.foliage, AppColors.foliageDark);
    }
    final hedge = Path()..moveTo(0, h * 0.25);
    for (var x = 0.0; x <= w; x += 28) {
      hedge.quadraticBezierTo(x + 14, h * 0.21, x + 28, h * 0.25);
    }
    hedge
      ..lineTo(w, h * 0.3)
      ..lineTo(0, h * 0.3)
      ..close();
    _outlined(canvas, hedge, AppColors.foliage, AppColors.foliageDark);
    final grass = Rect.fromLTWH(0, h * 0.28, w, h);
    canvas.drawRect(
      grass,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.leafLight, AppColors.leaf],
        ).createShader(grass),
    );
    // The path starts at the kubo's steps.
    final walk = Path()
      ..moveTo(w * 0.32, h * 0.39)
      ..cubicTo(w * 0.4, h * 0.58, w * 0.56, h * 0.72, w * 0.46, h * 1.04);
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
    for (final metric in walk.computeMetrics()) {
      for (var d = 40.0; d < metric.length; d += 46) {
        final t = metric.getTangentForOffset(d)!;
        final side = (d ~/ 46).isEven ? 1.0 : -1.0;
        final o = t.position + Offset(-t.vector.dy, t.vector.dx) * 11 * side;
        canvas.drawOval(Rect.fromCenter(center: o, width: 7, height: 4.5), Paint()..color = const Color(0xFFCDBB93));
      }
    }
    // Flower border along the hedge, on the open side.
    const border = [Colors.white, AppColors.bubblegum, AppColors.sunshine];
    for (var i = 9; i < 16; i++) {
      _flowerAt(canvas, Offset(w * (i + 0.5) / 16, h * (i.isEven ? 0.305 : 0.315)), border[i % 3]);
    }
    // Bahay kubo, on stilts, with bamboo steps down to the path.
    final hut = Rect.fromLTWH(w * 0.04, h * 0.1, w * 0.52, h * 0.29);
    canvas.drawOval(
      Rect.fromLTWH(hut.left + 4, hut.bottom - 10, hut.width - 8, 18),
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
    _hut(canvas, hut);
    final step = Paint()
      ..color = AppColors.bambooDark
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final top = Offset(w * 0.3, hut.top + hut.height * 0.68);
    final foot = Offset(w * 0.32, hut.bottom + 4);
    canvas.drawLine(top + const Offset(-10, 0), foot + const Offset(-12, 0), step);
    canvas.drawLine(top + const Offset(10, 0), foot + const Offset(12, 0), step);
    for (var i = 1; i < 4; i++) {
      final o = Offset.lerp(top, foot, i / 4)!;
      canvas.drawLine(o + const Offset(-11, 0), o + const Offset(11, 0), step..color = AppColors.bamboo);
      step.color = AppColors.bambooDark;
    }
    _tufts(canvas, s, h * 0.42, 12, 7);
  }

  // B: tidy raised beds with wooden frames on a lawn.
  void _beds(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    _sky(canvas, s, h * 0.14, const [AppColors.skyLight, AppColors.skyTint]);
    // Lawn with mowing stripes.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.12, w, h), Paint()..color = AppColors.leafLight);
    for (var x = 0.0; x < w; x += 56) {
      canvas.drawRect(Rect.fromLTWH(x, h * 0.12, 28, h), Paint()..color = AppColors.leaf.withValues(alpha: 0.14));
    }
    // Picket fence along the top.
    for (var x = 6.0; x < w; x += 22) {
      final p = Path()
        ..moveTo(x, h * 0.16)
        ..lineTo(x + 7, h * 0.12)
        ..lineTo(x + 14, h * 0.16)
        ..lineTo(x + 14, h * 0.22)
        ..lineTo(x, h * 0.22)
        ..close();
      _outlined(canvas, p, Colors.white, AppColors.borderDeep);
    }
    // Gravel path in the middle.
    final path = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.47, h * 0.2, w * 0.06, h * 0.62),
      const Radius.circular(8),
    );
    canvas.drawRRect(path, Paint()..color = const Color(0xFFF1E6CB));
    // Four beds.
    for (final (x, y) in [(0.28, 0.4), (0.72, 0.4), (0.28, 0.66), (0.72, 0.66)]) {
      final r = Rect.fromCenter(center: Offset(w * x, h * y - 8), width: w * 0.36, height: 54);
      _bed(canvas, r);
    }
    _tufts(canvas, s, h * 0.8, 10, 2);
    _flowers(canvas, s, h * 0.84, 8, 5);
  }

  void _bed(Canvas canvas, Rect r) {
    final frame = RRect.fromRectAndRadius(r, const Radius.circular(10));
    _outlinedRRect(canvas, frame.shift(const Offset(0, 8)), AppColors.barkDark, AppColors.barkDark);
    _outlinedRRect(canvas, frame, AppColors.bark, AppColors.barkDark);
    final soil = RRect.fromRectAndRadius(r.deflate(9), const Radius.circular(6));
    canvas.drawRRect(soil, Paint()..color = AppColors.soil);
    // Soil crumbs.
    final dot = Paint()..color = AppColors.soilDark;
    for (var i = 0; i < 10; i++) {
      canvas.drawCircle(Offset(r.left + 16 + i * (r.width - 32) / 9, r.center.dy + (i.isEven ? -4 : 5)), 2.2, dot);
    }
  }

  // C: a Filipino backyard: bahay kubo, bamboo fence, coconut trees and
  // warm afternoon light.
  void _kubo(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    _sky(canvas, s, h * 0.4, const [Color(0xFFFFD9A8), Color(0xFFFFF1D6)]);
    // Low sun.
    canvas.drawCircle(
      Offset(w * 0.2, h * 0.12),
      44,
      Paint()
        ..color = AppColors.sunshine.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
    canvas.drawCircle(Offset(w * 0.2, h * 0.12), 28, Paint()..color = AppColors.sunshine);
    // Far hills.
    final hills = Path()
      ..moveTo(0, h * 0.3)
      ..quadraticBezierTo(w * 0.3, h * 0.2, w * 0.6, h * 0.29)
      ..quadraticBezierTo(w * 0.85, h * 0.36, w, h * 0.26)
      ..lineTo(w, h * 0.4)
      ..lineTo(0, h * 0.4)
      ..close();
    canvas.drawPath(hills, Paint()..color = const Color(0xFF9BCB78));
    // Coconut trees.
    for (final x in [0.08, 0.94]) {
      _palm(canvas, Offset(w * x, h * 0.4), h * 0.3);
    }
    // Bahay kubo.
    _hut(canvas, Rect.fromLTWH(w * 0.52, h * 0.15, w * 0.34, h * 0.25));
    // Ground: warm grass and a packed-earth yard.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.38, w, h), Paint()..color = const Color(0xFF8FD16A));
    final yard = Path()
      ..moveTo(w * 0.3, h * 0.42)
      ..quadraticBezierTo(w * 0.05, h * 0.75, w * 0.35, h)
      ..lineTo(w * 0.95, h)
      ..quadraticBezierTo(w * 1.05, h * 0.65, w * 0.7, h * 0.42)
      ..close();
    canvas.drawPath(yard, Paint()..color = const Color(0xFFF1D9A6));
    // Bamboo fence across.
    final y = h * 0.4;
    for (var x = 0.0; x < w; x += 14) {
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y - 30, 11, 34), const Radius.circular(4));
      _outlinedRRect(canvas, r, AppColors.bamboo, AppColors.bambooDark);
      canvas.drawLine(Offset(x + 1, y - 18), Offset(x + 10, y - 18), Paint()..color = AppColors.bambooDark);
    }
    canvas.drawRect(Rect.fromLTWH(0, y - 22, w, 5), Paint()..color = AppColors.bambooDark);
    _flowers(canvas, s, h * 0.44, 12, 9, colors: const [AppColors.hibiscusRed, AppColors.coral, AppColors.sunshine]);
    _tufts(canvas, s, h * 0.45, 12, 11);
  }

  void _hut(Canvas canvas, Rect r) {
    final stilt = Paint()..color = AppColors.barkDark;
    for (final x in [0.12, 0.45, 0.82]) {
      canvas.drawRect(Rect.fromLTWH(r.left + r.width * x, r.top + r.height * 0.6, 6, r.height * 0.4), stilt);
    }
    final wall = Rect.fromLTWH(r.left + r.width * 0.06, r.top + r.height * 0.38, r.width * 0.88, r.height * 0.3);
    _outlinedRRect(
      canvas,
      RRect.fromRectAndRadius(wall, const Radius.circular(3)),
      const Color(0xFFE8C98A),
      AppColors.barkDark,
    );
    // Woven wall lines.
    final weave = Paint()
      ..color = const Color(0xFFC9A464)
      ..strokeWidth = 1.5;
    for (var x = wall.left + 6; x < wall.right; x += 7) {
      canvas.drawLine(Offset(x, wall.top + 3), Offset(x, wall.bottom - 3), weave);
    }
    // Window.
    canvas.drawRect(
      Rect.fromLTWH(wall.left + wall.width * 0.6, wall.top + 6, wall.width * 0.22, wall.height * 0.5),
      Paint()..color = AppColors.barkDark,
    );
    // Nipa roof.
    final roof = Path()
      ..moveTo(r.left - 6, r.top + r.height * 0.42)
      ..lineTo(r.left + r.width * 0.5, r.top)
      ..lineTo(r.right + 6, r.top + r.height * 0.42)
      ..close();
    _outlined(canvas, roof, const Color(0xFFD9A441), AppColors.barkDark);
    final thatch = Paint()
      ..color = const Color(0xFFB98328)
      ..strokeWidth = 1.5;
    for (var i = 1; i < 4; i++) {
      final t = i / 4;
      canvas.drawLine(
        Offset(r.left + r.width * 0.5 * (1 - t), r.top + r.height * 0.42 * t),
        Offset(r.right - r.width * 0.5 * (1 - t), r.top + r.height * 0.42 * t),
        thatch,
      );
    }
  }

  void _palm(Canvas canvas, Offset foot, double height) {
    final trunk = Path()
      ..moveTo(foot.dx - 6, foot.dy)
      ..quadraticBezierTo(foot.dx + 10, foot.dy - height * 0.5, foot.dx + 4, foot.dy - height)
      ..lineTo(foot.dx + 12, foot.dy - height)
      ..quadraticBezierTo(foot.dx + 18, foot.dy - height * 0.5, foot.dx + 6, foot.dy)
      ..close();
    _outlined(canvas, trunk, AppColors.palmTrunk, AppColors.barkDark);
    final top = Offset(foot.dx + 8, foot.dy - height);
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + (i - 2.5) * 0.55;
      final tip = top + Offset(math.cos(a), math.sin(a) + 0.9) * 46;
      final leaf = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(top.dx + math.cos(a) * 30, top.dy - 18, tip.dx, tip.dy)
        ..quadraticBezierTo(top.dx + math.cos(a) * 16, top.dy - 4, top.dx, top.dy)
        ..close();
      _outlined(canvas, leaf, AppColors.coconutGreen, AppColors.foliageDark);
    }
  }

  // D: a little floating island in the sky, like a game world.
  void _island(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    _sky(canvas, s, h, const [Color(0xFF8FD3FF), Color(0xFFE5F5FF)]);
    _cloud(canvas, Offset(w * 0.18, h * 0.12), 80);
    _cloud(canvas, Offset(w * 0.82, h * 0.2), 60);
    _cloud(canvas, Offset(w * 0.85, h * 0.92), 90);
    _cloud(canvas, Offset(w * 0.12, h * 0.9), 70);
    final top = Rect.fromCenter(center: Offset(w / 2, h * 0.56), width: w * 0.96, height: h * 0.5);
    // Cliff (soil) under the island.
    final cliff = Path()
      ..moveTo(top.left + 4, top.center.dy)
      ..quadraticBezierTo(w * 0.2, h * 0.92, w * 0.5, h * 0.97)
      ..quadraticBezierTo(w * 0.8, h * 0.92, top.right - 4, top.center.dy)
      ..close();
    _outlined(canvas, cliff, AppColors.bark, AppColors.barkDark);
    // Rock layers.
    final layer = Paint()
      ..color = AppColors.barkDark.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w / 2, h * 0.78), width: w * 0.6, height: 40),
      0.2,
      2.6,
      false,
      layer,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w / 2, h * 0.88), width: w * 0.3, height: 26),
      0.3,
      2.4,
      false,
      layer,
    );
    // Grass top.
    _outlinedOval(canvas, top.shift(const Offset(0, 8)), AppColors.foliage, AppColors.foliageDark);
    _outlinedOval(canvas, top, AppColors.leafLight, AppColors.foliageDark);
    canvas.drawOval(
      top.deflate(26).shift(const Offset(-10, -8)),
      Paint()..color = Colors.white.withValues(alpha: 0.16),
    );
    _tufts(canvas, s, h * 0.38, 10, 21, inside: top);
    _flowers(canvas, s, h * 0.4, 10, 22, inside: top);
    // A tiny waterfall from the pond.
    final fall = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.78 - 8, h * 0.755, 16, h * 0.15),
      const Radius.circular(7),
    );
    canvas.drawRRect(fall, Paint()..color = AppColors.skyLight);
    canvas.drawRRect(fall.deflate(5), Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  // ---------------------------------------------------------------- helpers

  void _sky(Canvas canvas, Size s, double bottom, List<Color> colors) {
    final r = Rect.fromLTWH(0, 0, s.width, bottom);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(r),
    );
  }

  void _cloud(Canvas canvas, Offset o, double w) {
    final p = Paint()..color = Colors.white;
    final h = w * 0.3;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w / 2, o.dy, w, h), Radius.circular(h / 2)), p);
    canvas.drawCircle(Offset(o.dx - w * 0.14, o.dy + 2), h * 0.6, p);
    canvas.drawCircle(Offset(o.dx + w * 0.12, o.dy - 2), h * 0.8, p);
  }

  void _blob(Canvas canvas, Offset c, double r, Color fill, Color line) {
    final p = Path()
      ..addOval(Rect.fromCircle(center: c, radius: r))
      ..addOval(Rect.fromCircle(center: c + Offset(-r * 0.6, r * 0.25), radius: r * 0.65))
      ..addOval(Rect.fromCircle(center: c + Offset(r * 0.6, r * 0.25), radius: r * 0.65));
    canvas.drawPath(p, Paint()..color = fill);
    canvas.save();
    canvas.clipPath(p);
    canvas.drawCircle(
      c + Offset(-r * 0.4, -r * 0.45),
      r * 0.85,
      Paint()..color = Color.lerp(fill, Colors.white, 0.16)!,
    );
    canvas.drawCircle(c + Offset(r * 0.5, r * 0.7), r * 0.8, Paint()..color = Color.lerp(fill, Colors.black, 0.12)!);
    canvas.restore();
    _outlined(canvas, p, Colors.transparent, line);
  }

  void _tufts(Canvas canvas, Size s, double top, int count, int seed, {Rect? inside}) {
    final rnd = math.Random(seed);
    final p = Paint()
      ..color = AppColors.foliageDark.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final o = _spot(rnd, s, top, inside);
      for (final dx in [-5.0, 0.0, 5.0]) {
        canvas.drawLine(o, o + Offset(dx * 1.3, -10 - dx.abs() * 0.4), p);
      }
    }
  }

  void _flowers(Canvas canvas, Size s, double top, int count, int seed, {Rect? inside, List<Color>? colors}) {
    final rnd = math.Random(seed);
    final palette = colors ?? const [Colors.white, AppColors.bubblegum, AppColors.sunshine, AppColors.grape];
    for (var i = 0; i < count; i++) {
      final o = _spot(rnd, s, top, inside);
      _flowerAt(canvas, o, palette[i % palette.length]);
    }
  }

  void _flowerAt(Canvas canvas, Offset o, Color color) {
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

  Offset _spot(math.Random rnd, Size s, double top, Rect? inside) {
    if (inside == null) return Offset(rnd.nextDouble() * s.width, top + rnd.nextDouble() * (s.height - top));
    while (true) {
      final o = Offset(inside.left + rnd.nextDouble() * inside.width, inside.top + rnd.nextDouble() * inside.height);
      final d = Offset((o.dx - inside.center.dx) / (inside.width / 2), (o.dy - inside.center.dy) / (inside.height / 2));
      if (d.distance < 0.82) return o;
    }
  }

  @override
  bool shouldRepaint(_Ground old) => old.look != look;
}

// ------------------------------------------------------------- decorations

enum _Kind { bench, pond, fence, butterfly, plus, banig, palayok, pot, bed, potOnly, bedOnly }

/// Garden decorations, drawn in the app's sticker style (dark outline,
/// light shine).
class _Deco extends CustomPainter {
  const _Deco(this.kind, [this.color = AppColors.grape]);
  final _Kind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    switch (kind) {
      case _Kind.potOnly:
        _potShape(canvas, Offset.zero & s);
      case _Kind.bedOnly:
        _bedFront(canvas, Offset.zero & s);
      case _Kind.pot:
        _potShape(canvas, Rect.fromLTWH(w * 0.18, h * 0.3, w * 0.64, h * 0.66));
      case _Kind.bed:
        _bedFront(canvas, Rect.fromLTWH(w * 0.02, h * 0.36, w * 0.96, h * 0.56));
      case _Kind.bench:
        for (final x in [0.2, 0.72]) {
          _outlinedRRect(
            canvas,
            RRect.fromRectAndRadius(Rect.fromLTWH(w * x, h * 0.6, w * 0.08, h * 0.32), const Radius.circular(3)),
            AppColors.barkDark,
            AppColors.soilDark,
          );
        }
        for (final y in [0.28, 0.41]) {
          _outlinedRRect(
            canvas,
            RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * y, w * 0.8, h * 0.1), const Radius.circular(5)),
            AppColors.bark,
            AppColors.barkDark,
          );
        }
        _outlinedRRect(
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
      case _Kind.pond:
        final r = Rect.fromLTWH(w * 0.04, h * 0.48, w * 0.92, h * 0.46);
        // Stone rim.
        final rnd = math.Random(2);
        for (var i = 0; i < 16; i++) {
          final a = i * 2 * math.pi / 16;
          final o = r.center + Offset(math.cos(a) * r.width / 2, math.sin(a) * r.height / 2);
          _outlinedOval(
            canvas,
            Rect.fromCenter(center: o, width: w * (0.12 + rnd.nextDouble() * 0.05), height: h * 0.08),
            const Color(0xFFDCD3C0),
            const Color(0xFFADA28A),
          );
        }
        _outlinedOval(canvas, r.deflate(4), AppColors.sky, AppColors.skyDark);
        canvas.drawOval(
          Rect.fromLTWH(r.left + r.width * 0.15, r.top + r.height * 0.18, r.width * 0.4, r.height * 0.22),
          Paint()..color = Colors.white.withValues(alpha: 0.45),
        );
        // Lily pad and flower, reeds.
        _outlinedOval(
          canvas,
          Rect.fromCenter(center: Offset(w * 0.65, h * 0.73), width: w * 0.2, height: h * 0.1),
          AppColors.leaf,
          AppColors.leafDark,
        );
        canvas.drawCircle(Offset(w * 0.67, h * 0.7), w * 0.035, Paint()..color = AppColors.bubblegum);
        final reed = Paint()
          ..color = AppColors.foliageDark
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
        for (final (x, top) in [(0.86, 0.3), (0.9, 0.36), (0.82, 0.38)]) {
          canvas.drawLine(Offset(w * x, h * 0.62), Offset(w * x, h * top), reed);
        }
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.845, h * 0.3, w * 0.03, h * 0.1), const Radius.circular(4)),
          Paint()..color = AppColors.barkDark,
        );
      case _Kind.fence:
        _outlinedRRect(
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
          _outlined(canvas, p, Colors.white, AppColors.borderDeep);
        }
      case _Kind.butterfly:
        final c = s.center(Offset.zero);
        final dark = Color.lerp(color, Colors.black, 0.3)!;
        for (final sx in [-1.0, 1.0]) {
          _outlinedOval(
            canvas,
            Rect.fromCenter(center: c + Offset(sx * w * 0.2, -w * 0.12), width: w * 0.42, height: w * 0.46),
            color,
            dark,
          );
          _outlinedOval(
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
      case _Kind.plus:
        final c = s.center(Offset.zero);
        canvas.drawCircle(c, w * 0.45, Paint()..color = Colors.white.withValues(alpha: 0.85));
        final p = Paint()
          ..color = AppColors.leafDark
          ..strokeWidth = w * 0.1
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(c - Offset(w * 0.2, 0), c + Offset(w * 0.2, 0), p);
        canvas.drawLine(c - Offset(0, w * 0.2), c + Offset(0, w * 0.2), p);
      case _Kind.banig:
        // A woven mat seen at an angle.
        final mat = Path()
          ..moveTo(w * 0.15, h * 0.6)
          ..lineTo(w * 0.85, h * 0.6)
          ..lineTo(w * 0.98, h * 0.95)
          ..lineTo(w * 0.02, h * 0.95)
          ..close();
        _outlined(canvas, mat, const Color(0xFFF2C46B), AppColors.barkDark);
        canvas.save();
        canvas.clipPath(mat);
        for (var i = 0; i < 6; i++) {
          canvas.drawRect(
            Rect.fromLTWH(0, h * (0.6 + i * 0.06), w, h * 0.03),
            Paint()..color = [AppColors.hibiscusRed, AppColors.grape, AppColors.leaf][i % 3].withValues(alpha: 0.55),
          );
        }
        canvas.restore();
      case _Kind.palayok:
        // A clay pot.
        final pot = Path()
          ..moveTo(w * 0.3, h * 0.35)
          ..quadraticBezierTo(w * 0.02, h * 0.62, w * 0.3, h * 0.95)
          ..lineTo(w * 0.7, h * 0.95)
          ..quadraticBezierTo(w * 0.98, h * 0.62, w * 0.7, h * 0.35)
          ..close();
        _outlined(canvas, pot, const Color(0xFFC8713F), AppColors.soilDark);
        _outlinedRRect(
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
    }
  }

  @override
  bool shouldRepaint(_Deco old) => old.kind != kind || old.color != color;
}

void _outlined(Canvas canvas, Path p, Color fill, Color line) {
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

void _outlinedOval(Canvas canvas, Rect r, Color fill, Color line) => _outlined(canvas, Path()..addOval(r), fill, line);

void _outlinedRRect(Canvas canvas, RRect r, Color fill, Color line) =>
    _outlined(canvas, Path()..addRRect(r), fill, line);

/// A terracotta pot: rim, tapered body, a darker band and a soft shine.
void _potShape(Canvas canvas, Rect r) {
  const clay = Color(0xFFE07A4F);
  const clayDark = Color(0xFFA9492A);
  final rimH = r.height * 0.24;
  final body = Path()
    ..moveTo(r.left + r.width * 0.06, r.top + rimH)
    ..lineTo(r.right - r.width * 0.06, r.top + rimH)
    ..lineTo(r.right - r.width * 0.18, r.bottom)
    ..lineTo(r.left + r.width * 0.18, r.bottom)
    ..close();
  _outlined(canvas, body, clay, clayDark);
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
  _outlinedRRect(
    canvas,
    RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, r.width, rimH), Radius.circular(rimH * 0.35)),
    const Color(0xFFEB8C60),
    clayDark,
  );
}

/// The front of a wooden raised bed with soil showing on top.
void _bedFront(Canvas canvas, Rect r) {
  final soilH = r.height * 0.4;
  _outlinedRRect(
    canvas,
    RRect.fromRectAndRadius(Rect.fromLTWH(r.left, r.top, r.width, soilH * 1.6), Radius.circular(soilH * 0.5)),
    AppColors.soil,
    AppColors.soilDark,
  );
  // Soil crumbs on top.
  final crumb = Paint()..color = AppColors.soilDark;
  for (var i = 0; i < 14; i++) {
    canvas.drawCircle(Offset(r.left + 14 + i * (r.width - 28) / 13, r.top + soilH * (i.isEven ? 0.45 : 0.7)), 2, crumb);
  }
  final front = RRect.fromRectAndRadius(
    Rect.fromLTWH(r.left, r.top + soilH, r.width, r.height - soilH),
    const Radius.circular(8),
  );
  _outlinedRRect(canvas, front, AppColors.bark, AppColors.barkDark);
  // Plank lines and corner posts.
  final plank = Paint()
    ..color = AppColors.barkDark.withValues(alpha: 0.5)
    ..strokeWidth = 2;
  final mid = r.top + soilH + (r.height - soilH) / 2;
  canvas.drawLine(Offset(r.left + 10, mid), Offset(r.right - 10, mid), plank);
  for (final x in [r.left + 4, r.right - 14]) {
    _outlinedRRect(
      canvas,
      RRect.fromRectAndRadius(Rect.fromLTWH(x, r.top + soilH - 4, 10, r.height - soilH + 4), const Radius.circular(3)),
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

/// A flowering plant growing in a pot.
class _Potted extends StatelessWidget {
  const _Potted(this.plant);
  final PlantInfo plant;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final b = c.maxHeight;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -b * 0.1,
            right: -b * 0.1,
            top: -b * 0.2,
            bottom: b * 0.26,
            child: PlantView(plant: plant, mode: PlantMode.planted),
          ),
          Positioned(
            left: b * 0.2,
            right: b * 0.2,
            bottom: 0,
            height: b * 0.4,
            child: const CustomPaint(painter: _Deco(_Kind.potOnly)),
          ),
        ],
      );
    },
  );
}

/// Crops side by side in one raised bed.
class _RaisedBed extends StatelessWidget {
  const _RaisedBed(this.plants);
  final List<PlantInfo> plants;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final b = c.maxHeight;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, right: 0, bottom: -b * 0.04, height: b * 0.12, child: const _Shadow()),
          Positioned(
            left: c.maxWidth * 0.04,
            right: c.maxWidth * 0.04,
            top: -b * 0.14,
            bottom: b * 0.3,
            child: Row(
              children: [
                for (final p in plants)
                  Expanded(
                    child: PlantView(plant: p, mode: PlantMode.planted),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: b * 0.42,
            child: const CustomPaint(painter: _Deco(_Kind.bedOnly)),
          ),
        ],
      );
    },
  );
}

// --------------------------------------------------------------------- tray

class _Tray extends StatelessWidget {
  const _Tray({required this.look});
  final GardenLook look;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(AppSizes.gapM),
    padding: const EdgeInsets.all(AppSizes.gapM),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      border: Border.all(color: AppColors.border, width: AppSizes.borderWidth),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Decorate', style: AppText.heading),
        const SizedBox(height: AppSizes.gapS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: look == GardenLook.mixed
              ? const [
                  _TrayItem(kind: _Kind.pot, label: 'Flower pot', price: 10),
                  _TrayItem(kind: _Kind.bed, label: 'Garden bed', price: 30),
                  _TrayItem(kind: _Kind.bench, label: 'Bench', owned: true),
                  _TrayItem(kind: _Kind.fence, label: 'Fence', price: 25),
                ]
              : const [
                  _TrayItem(kind: _Kind.bench, label: 'Bench', owned: true),
                  _TrayItem(kind: _Kind.pond, label: 'Pond', owned: true),
                  _TrayItem(kind: _Kind.fence, label: 'Fence', price: 25),
                  _TrayItem(kind: _Kind.butterfly, label: 'Butterfly', price: 15),
                ],
        ),
      ],
    ),
  );
}

class _TrayItem extends StatelessWidget {
  const _TrayItem({required this.kind, required this.label, this.owned = false, this.price = 0});

  final _Kind kind;
  final String label;
  final bool owned;
  final int price;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 72,
        height: 64,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: owned ? AppColors.leafTint : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(color: owned ? AppColors.leaf : AppColors.border, width: AppSizes.borderWidth),
        ),
        child: CustomPaint(painter: _Deco(kind)),
      ),
      const SizedBox(height: 4),
      Text(label, style: AppText.bodySmall),
      if (owned)
        Text('Placed', style: AppText.label.copyWith(color: AppColors.leafDark, fontSize: 12))
      else
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KidIconView(KidIcon.leaf, size: 16),
            Text(' $price', style: AppText.label.copyWith(fontSize: 13)),
          ],
        ),
    ],
  );
}
