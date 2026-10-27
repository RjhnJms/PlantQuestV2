import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../art/avatars/avatar_view.dart';
import '../art/binhi/binhi.dart';
import '../art/icons/kid_icon.dart';
import '../art/plants/plant_view.dart';
import '../art/scenes/world_scene.dart';
import '../content/plant_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/stat_pill.dart';

/// Adventure map ideas (preview only; drawn to PNGs by
/// tool/render_map_test.dart). Same progress in each: Sampaguita and
/// Gumamela done, Makahiya next, the rest locked.
enum MapStyle { islands, board, pages, treasure, jeepney, terraces, tree, river }

enum _S { done, current, locked }

_S _stateOf(int i) => i < 2
    ? _S.done
    : i == 2
    ? _S.current
    : _S.locked;

class MapMock extends StatelessWidget {
  const MapMock({super.key, required this.style});

  final MapStyle style;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: switch (style) {
      MapStyle.islands => const Color(0xFF7FD0F5),
      MapStyle.board => const Color(0xFFE9F7DF),
      MapStyle.pages => AppColors.background,
      MapStyle.treasure => const Color(0xFFF4E3B8),
      MapStyle.jeepney => const Color(0xFF9EDB7E),
      MapStyle.terraces => const Color(0xFFBFE6FF),
      MapStyle.tree => const Color(0xFFDFF3FF),
      MapStyle.river => const Color(0xFF9EDB7E),
    },
    body: Stack(
      children: [
        Positioned.fill(
          bottom: 76,
          child: switch (style) {
            MapStyle.islands => const _Islands(),
            MapStyle.board => const _Board(),
            MapStyle.pages => const _Pages(),
            MapStyle.treasure => const _Treasure(),
            MapStyle.jeepney => const _Jeepney(),
            MapStyle.terraces => const _Terraces(),
            MapStyle.tree => const _GiantTree(),
            MapStyle.river => const _River(),
          },
        ),
        const Positioned(left: 20, right: 20, top: 12, child: _Header()),
      ],
    ),
  );
}

/// Home's bar and switch, drawn the same for every idea.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: const [BoxShadow(color: Color(0x22263046), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: const Row(
          children: [
            AvatarView(avatarId: 'boy_cap', size: 44),
            SizedBox(width: 8),
            Expanded(child: Text('Hi, Juan!', style: AppText.heading)),
            StatPill.days(value: 3),
            SizedBox(width: 6),
            StatPill.leaves(value: 25),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFE6D2).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                alignment: Alignment.center,
                child: Text('Adventure', style: AppText.label.copyWith(fontSize: 16, color: AppColors.leafDark)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('My Garden', style: AppText.label.copyWith(fontSize: 16, color: AppColors.textMuted)),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

/// A plant stop: done (with a tick), next (ringed, with START), or locked.
class _Stop extends StatelessWidget {
  const _Stop(this.i, {this.size = 70, this.world = 1, this.label = true, this.square = false});

  final int i;
  final double size;
  final int world;
  final bool label;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final plant = PlantCatalog.inWorld(world)[i];
    final s = world == 1 ? _stateOf(i) : _S.locked;
    final shape = square ? BoxShape.rectangle : BoxShape.circle;
    final radius = square ? BorderRadius.circular(size * 0.24) : null;
    final face = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: radius,
        color: switch (s) {
          _S.done => AppColors.sunshine,
          _S.current => AppColors.card,
          _S.locked => const Color(0xFFE9E1F5),
        },
        border: Border.all(
          color: switch (s) {
            _S.done => AppColors.sunshineDark,
            _S.current => AppColors.grape,
            _S.locked => const Color(0xFFCFC3E8),
          },
          width: s == _S.current ? 5 : 3,
        ),
        boxShadow: [
          BoxShadow(
            color: switch (s) {
              _S.done => AppColors.sunshineDark,
              _S.current => AppColors.grapeDark,
              _S.locked => const Color(0xFFB9ACD6),
            },
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: s == _S.locked ? const KidIconView(KidIcon.lock, muted: true) : PlantView(plant: plant),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (s == _S.current)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(20)),
            child: Text('START', style: AppText.label.copyWith(color: Colors.white, fontSize: 12)),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            face,
            if (s == _S.done) const Positioned(right: -4, top: -4, child: KidIconView(KidIcon.check, size: 24)),
          ],
        ),
        if (label)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              s == _S.locked ? '?' : plant.name,
              style: AppText.label.copyWith(fontSize: 13, color: AppColors.text),
              maxLines: 1,
              softWrap: false,
            ),
          ),
      ],
    );
  }
}

// --------------------------------------------------------------- A: islands

/// The three worlds as islands in a sea, joined by little bridges.
class _Islands extends StatelessWidget {
  const _Islands();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      // Island 1 centre and its five stops around it.
      const top = 150.0;
      final stops = [
        Offset(w * 0.3, top + 70),
        Offset(w * 0.68, top + 60),
        Offset(w * 0.72, top + 200),
        Offset(w * 0.34, top + 250),
        Offset(w * 0.55, top + 330),
      ];
      return Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _SeaPainter())),
          Positioned(
            left: w * 0.05,
            top: top,
            width: w * 0.9,
            height: 420,
            child: const CustomPaint(painter: _IslandPainter(AppColors.leafLight, AppColors.leaf)),
          ),
          Positioned(
            left: w * 0.2,
            top: top + 450,
            width: w * 0.75,
            height: 220,
            child: const CustomPaint(painter: _IslandPainter(Color(0xFFF2D58A), Color(0xFFD8B25E), locked: true)),
          ),
          Positioned.fill(child: CustomPaint(painter: _DashPath(stops, done: 2))),
          for (final (i, o) in stops.indexed)
            Positioned(
              left: o.dx - 45,
              top: o.dy - 45,
              width: 90,
              child: Center(child: _Stop(i, size: 64)),
            ),
          Positioned(left: w * 0.08, top: top + 150, child: _sign('1 · Backyard', '2 of 5')),
          Positioned(left: w * 0.36, top: top + 520, child: _sign('2 · Farm', 'Finish the Backyard', locked: true)),
          Positioned(left: w * 0.62, top: top + 560, child: const KidIconView(KidIcon.lock, size: 40, muted: true)),
          Positioned(
            left: w * 0.08,
            top: top + 320,
            child: const Binhi(stage: BinhiStage.sprout, size: 74, reduceMotion: true),
          ),
        ],
      );
    },
  );
}

Widget _sign(String title, String line, {bool locked = false}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: locked ? const Color(0xFFD9CFC0) : AppColors.bark,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.barkDark, width: 3),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppText.label.copyWith(color: Colors.white, fontSize: 15)),
      Text(line, style: AppText.bodySmall.copyWith(color: Colors.white, fontSize: 12)),
    ],
  ),
);

class _SeaPainter extends CustomPainter {
  const _SeaPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.5);
    final rnd = math.Random(5);
    for (var i = 0; i < 26; i++) {
      final o = Offset(rnd.nextDouble() * s.width, 130 + rnd.nextDouble() * (s.height - 140));
      canvas.drawArc(Rect.fromCenter(center: o, width: 22, height: 10), math.pi, math.pi, false, wave);
      canvas.drawArc(
        Rect.fromCenter(center: o + const Offset(18, 0), width: 22, height: 10),
        math.pi,
        math.pi,
        false,
        wave,
      );
    }
  }

  @override
  bool shouldRepaint(_SeaPainter old) => false;
}

class _IslandPainter extends CustomPainter {
  const _IslandPainter(this.top, this.edge, {this.locked = false});
  final Color top;
  final Color edge;
  final bool locked;

  @override
  void paint(Canvas canvas, Size s) {
    final r = Offset.zero & s;
    final blob = Path()
      ..moveTo(r.width * 0.1, r.height * 0.3)
      ..cubicTo(r.width * 0.05, -r.height * 0.02, r.width * 0.7, -r.height * 0.06, r.width * 0.92, r.height * 0.2)
      ..cubicTo(r.width * 1.06, r.height * 0.45, r.width * 0.98, r.height * 0.95, r.width * 0.6, r.height * 0.97)
      ..cubicTo(r.width * 0.2, r.height * 1.02, -r.width * 0.06, r.height * 0.7, r.width * 0.1, r.height * 0.3)
      ..close();
    // Sand rim, then grass.
    canvas.drawPath(blob.shift(const Offset(0, 10)), Paint()..color = const Color(0xFFE8CF95));
    canvas.drawPath(blob, Paint()..color = locked ? top.withValues(alpha: 0.75) : top);
    canvas.drawPath(
      blob,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = edge,
    );
  }

  @override
  bool shouldRepaint(_IslandPainter old) => false;
}

/// A dashed path through [points]; the first [done] legs are golden.
class _DashPath extends CustomPainter {
  const _DashPath(this.points, {required this.done, this.color = Colors.white, this.doneColor = AppColors.sunshine});
  final List<Offset> points;
  final int done;
  final Color color;
  final Color doneColor;

  @override
  void paint(Canvas canvas, Size s) {
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final d = (b - a).distance;
      final paint = Paint()
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..color = i < done ? doneColor : color.withValues(alpha: 0.85);
      for (var t = 0.0; t < d; t += 16) {
        final p = a + (b - a) * (t / d);
        final q = a + (b - a) * (math.min(t + 7, d) / d);
        canvas.drawLine(p, q, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashPath old) => false;
}

// ----------------------------------------------------------------- B: board

/// A board-game trail of big chunky tiles; Binhi stands on the next one.
class _Board extends StatelessWidget {
  const _Board();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      const top = 175.0;
      // A snake: left to right, down, right to left.
      final tiles = [
        Offset(w * 0.2, top + 40),
        Offset(w * 0.5, top + 40),
        Offset(w * 0.8, top + 40),
        Offset(w * 0.8, top + 175),
        Offset(w * 0.5, top + 175),
      ];
      final world2 = [Offset(w * 0.2, top + 175), Offset(w * 0.2, top + 330), Offset(w * 0.5, top + 330)];
      return Stack(
        children: [
          Positioned(left: 20, top: top - 26, child: _banner('World 1 · Backyard', AppColors.leaf, '2 of 5')),
          Positioned.fill(child: CustomPaint(painter: _BoardLinks([...tiles, ...world2]))),
          for (final (i, o) in tiles.indexed)
            Positioned(
              left: o.dx - 48,
              top: o.dy - 20,
              width: 96,
              child: Center(child: _Stop(i, size: 78, square: true)),
            ),
          Positioned(
            left: tiles[2].dx - 30,
            top: tiles[2].dy - 92,
            child: const Binhi(stage: BinhiStage.sprout, size: 60, reduceMotion: true),
          ),
          Positioned(
            left: 20,
            top: top + 285,
            child: _banner('World 2 · Farm', const Color(0xFFD8B25E), 'Finish World 1', locked: true),
          ),
          for (final (i, o) in world2.skip(1).indexed)
            Positioned(
              left: o.dx - 48,
              top: o.dy + 20,
              width: 96,
              child: Center(child: _Stop(i, size: 78, world: 2, square: true, label: false)),
            ),
          // A dice-like "next" chip.
          Positioned(
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.grape,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: AppColors.grapeDark, offset: Offset(0, 5))],
              ),
              child: Text('GO TO MAKAHIYA', style: AppText.label.copyWith(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      );
    },
  );
}

Widget _banner(String title, Color color, String line, {bool locked = false}) => Container(
  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
  decoration: BoxDecoration(
    color: locked ? color.withValues(alpha: 0.55) : color,
    borderRadius: BorderRadius.circular(14),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(title, style: AppText.label.copyWith(color: Colors.white, fontSize: 16)),
      const SizedBox(width: 10),
      Text(line, style: AppText.bodySmall.copyWith(color: Colors.white, fontSize: 13)),
    ],
  ),
);

class _BoardLinks extends CustomPainter {
  const _BoardLinks(this.points);
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size s) {
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i] + const Offset(0, 24);
      final b = points[i + 1] + const Offset(0, 24);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round
          ..color = i < 2 ? AppColors.sunshineTint : Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_BoardLinks old) => false;
}

// ----------------------------------------------------------------- C: pages

/// One world per page: a big picture of the world with its five plants on
/// a winding trail; swipe for the next world.
class _Pages extends StatelessWidget {
  const _Pages();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth - 32;
      const top = 150.0;
      final h = c.maxHeight - top - 70;
      final stops = [
        Offset(w * 0.24, h * 0.86),
        Offset(w * 0.68, h * 0.74),
        Offset(w * 0.3, h * 0.55),
        Offset(w * 0.72, h * 0.38),
        Offset(w * 0.4, h * 0.2),
      ];
      return Stack(
        children: [
          Positioned(
            left: 16,
            top: top,
            width: w,
            height: h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  const Positioned.fill(child: WorldScene(world: 1, parallax: false, reduceMotion: true)),
                  Positioned.fill(child: CustomPaint(painter: _DashPath(stops, done: 2))),
                  for (final (i, o) in stops.indexed)
                    Positioned(
                      left: o.dx - 45,
                      top: o.dy - 50,
                      width: 90,
                      child: Center(child: _Stop(i, size: 62)),
                    ),
                  Positioned(left: 14, top: 14, child: _banner('World 1 · Backyard', AppColors.bubblegum, '2 of 5')),
                ],
              ),
            ),
          ),
          // Page dots and the next world peeking.
          Positioned(
            left: 0,
            right: 0,
            bottom: 22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, color) in [(0, AppColors.leaf), (1, AppColors.track), (2, AppColors.track)].indexed)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: i == 0 ? 28 : 12,
                    height: 12,
                    decoration: BoxDecoration(color: color.$2, borderRadius: BorderRadius.circular(6)),
                  ),
                const SizedBox(width: 14),
                Text('Swipe for the Farm', style: AppText.label.copyWith(color: AppColors.textMuted)),
                const KidIconView(KidIcon.next, size: 20),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// -------------------------------------------------------------- D: treasure

/// A hand-drawn adventure map on old paper: a dashed trail, little
/// landmarks, X marks for plants still hidden and a compass.
class _Treasure extends StatelessWidget {
  const _Treasure();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      const top = 160.0;
      final stops = [
        Offset(w * 0.22, top + 60),
        Offset(w * 0.62, top + 110),
        Offset(w * 0.32, top + 240),
        Offset(w * 0.72, top + 330),
        Offset(w * 0.38, top + 440),
      ];
      return Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _PaperPainter())),
          Positioned.fill(
            child: CustomPaint(
              painter: _DashPath(stops, done: 2, color: const Color(0xFF8A5A35), doneColor: AppColors.coralDark),
            ),
          ),
          for (final (i, o) in stops.indexed)
            if (_stateOf(i) == _S.locked)
              Positioned(left: o.dx - 26, top: o.dy - 26, child: const _XMark())
            else
              Positioned(
                left: o.dx - 45,
                top: o.dy - 50,
                width: 90,
                child: Center(child: _Stop(i, size: 62)),
              ),
          Positioned(left: w * 0.72, top: top + 10, child: const KidIconView(KidIcon.tree, size: 46)),
          Positioned(left: w * 0.06, top: top + 330, child: const KidIconView(KidIcon.home, size: 48)),
          const Positioned(
            right: 18,
            bottom: 26,
            child: SizedBox.square(dimension: 76, child: CustomPaint(painter: _CompassPainter())),
          ),
          Positioned(
            left: 22,
            bottom: 26,
            child: Text('Backyard · 2 of 5 found', style: AppText.heading.copyWith(color: const Color(0xFF6B4423))),
          ),
        ],
      );
    },
  );
}

class _XMark extends StatelessWidget {
  const _XMark();

  @override
  Widget build(BuildContext context) => const SizedBox.square(dimension: 52, child: CustomPaint(painter: _XPainter()));
}

class _XPainter extends CustomPainter {
  const _XPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = AppColors.coralDark;
    canvas.drawLine(Offset(s.width * 0.2, s.height * 0.2), Offset(s.width * 0.8, s.height * 0.8), p);
    canvas.drawLine(Offset(s.width * 0.8, s.height * 0.2), Offset(s.width * 0.2, s.height * 0.8), p);
  }

  @override
  bool shouldRepaint(_XPainter old) => false;
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final rnd = math.Random(9);
    // Faint stains and a river.
    for (var i = 0; i < 10; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height),
        20 + rnd.nextDouble() * 50,
        Paint()..color = const Color(0xFFE8D29E).withValues(alpha: 0.5),
      );
    }
    final river = Path()
      ..moveTo(s.width, s.height * 0.32)
      ..cubicTo(s.width * 0.6, s.height * 0.42, s.width * 0.9, s.height * 0.62, s.width * 0.55, s.height * 0.75)
      ..cubicTo(s.width * 0.3, s.height * 0.84, s.width * 0.2, s.height * 0.9, 0, s.height * 0.92);
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF9FCFE0),
    );
    // A dark border like an old map.
    canvas.drawRect(
      (Offset.zero & s).deflate(6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = const Color(0xFFC9A66B),
    );
  }

  @override
  bool shouldRepaint(_PaperPainter old) => false;
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFF4D6));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF8A5A35),
    );
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final tip = c + Offset(math.cos(a), math.sin(a)) * (r - 6);
      final side = Offset(math.cos(a + math.pi / 2), math.sin(a + math.pi / 2)) * 7;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(c.dx + side.dx, c.dy + side.dy)
          ..lineTo(c.dx - side.dx, c.dy - side.dy)
          ..close(),
        Paint()..color = i == 0 ? AppColors.coralDark : const Color(0xFF8A5A35),
      );
    }
  }

  @override
  bool shouldRepaint(_CompassPainter old) => false;
}

/// A stop placed with its centre at [o], label underneath.
Widget _at(Offset o, int i, {double size = 62, int world = 1, double width = 390}) => Positioned(
  left: o.dx.clamp(60.0, width - 60) - 60,
  top: o.dy - size / 2 - (i == 2 && world == 1 ? 24 : 0),
  width: 120,
  child: Center(
    child: _Stop(i, size: size, world: world),
  ),
);

// --------------------------------------------------------------- E: jeepney

/// Binhi rides a jeepney along a winding road; each plant is a jeepney stop.
class _Jeepney extends StatelessWidget {
  const _Jeepney();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final road = Path()
        ..moveTo(w * 0.15, h)
        ..cubicTo(w * 0.1, h * 0.7, w * 0.9, h * 0.75, w * 0.85, h * 0.52)
        ..cubicTo(w * 0.8, h * 0.32, w * 0.1, h * 0.42, w * 0.2, h * 0.22);
      final m = road.computeMetrics().first;
      Offset along(double t) => m.getTangentForOffset(m.length * t)!.position;
      Offset beside(double t, double side) {
        final tg = m.getTangentForOffset(m.length * t)!;
        return tg.position + Offset(-tg.vector.dy, tg.vector.dx) * 62 * side;
      }

      final stops = [
        for (final (i, t) in [0.1, 0.3, 0.55, 0.74, 0.94].indexed) beside(t, i.isEven ? 1 : -1),
      ];
      final jeep = along(0.4);
      return Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RoadPainter(road))),
          for (final (i, o) in stops.indexed) _at(o, i, width: w),
          Positioned(
            left: jeep.dx - 50,
            top: jeep.dy - 46,
            child: const SizedBox(width: 100, height: 64, child: CustomPaint(painter: _JeepPainter())),
          ),
          Positioned(left: 20, top: h * 0.16, child: _banner('World 1 · Backyard', AppColors.coral, '2 of 5')),
        ],
      );
    },
  );
}

class _RoadPainter extends CustomPainter {
  const _RoadPainter(this.road);
  final Path road;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawPath(
      road,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 46
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF8E8E9A),
    );
    canvas.drawPath(
      road,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFA9A9B4),
    );
    final m = road.computeMetrics().first;
    final dash = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    for (var d = 0.0; d < m.length; d += 28) {
      canvas.drawPath(m.extractPath(d, d + 12), dash..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) => false;
}

/// A colourful Filipino jeepney with Binhi's sprout poking out the window.
class _JeepPainter extends CustomPainter {
  const _JeepPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.2, w * 0.92, h * 0.55),
      const Radius.circular(10),
    );
    canvas.drawRRect(body, Paint()..color = AppColors.sunshine);
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = AppColors.sunshineDark,
    );
    // Stripes and windows.
    canvas.drawRect(Rect.fromLTWH(w * 0.04, h * 0.58, w * 0.92, h * 0.06), Paint()..color = AppColors.coral);
    canvas.drawRect(Rect.fromLTWH(w * 0.04, h * 0.66, w * 0.92, h * 0.04), Paint()..color = AppColors.sky);
    for (var i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * (0.12 + i * 0.2), h * 0.28, w * 0.14, h * 0.2),
          const Radius.circular(3),
        ),
        Paint()..color = AppColors.skyLight,
      );
    }
    // Roof rack and the silver horse at the front.
    canvas.drawRect(Rect.fromLTWH(w * 0.08, h * 0.12, w * 0.84, h * 0.08), Paint()..color = AppColors.coralDark);
    canvas.drawCircle(Offset(w * 0.95, h * 0.16), w * 0.04, Paint()..color = const Color(0xFFCFD4DC));
    // Sprout in a window.
    canvas.drawLine(
      Offset(w * 0.39, h * 0.42),
      Offset(w * 0.39, h * 0.26),
      Paint()
        ..strokeWidth = 2.4
        ..color = AppColors.foliageDark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.36, h * 0.26), width: 9, height: 6),
      Paint()..color = AppColors.leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.42, h * 0.25), width: 9, height: 6),
      Paint()..color = AppColors.leaf,
    );
    // Wheels.
    for (final x in [0.24, 0.76]) {
      canvas.drawCircle(Offset(w * x, h * 0.8), h * 0.14, Paint()..color = AppColors.text);
      canvas.drawCircle(Offset(w * x, h * 0.8), h * 0.06, Paint()..color = const Color(0xFFCFD4DC));
    }
  }

  @override
  bool shouldRepaint(_JeepPainter old) => false;
}

// -------------------------------------------------------------- F: terraces

/// Climb the rice terraces: each step up the mountain is a plant.
class _Terraces extends StatelessWidget {
  const _Terraces();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final stops = [
        Offset(w * 0.25, h * 0.86),
        Offset(w * 0.72, h * 0.72),
        Offset(w * 0.32, h * 0.57),
        Offset(w * 0.68, h * 0.42),
        Offset(w * 0.45, h * 0.28),
      ];
      return Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _TerracePainter())),
          Positioned.fill(child: CustomPaint(painter: _DashPath(stops, done: 2))),
          for (final (i, o) in stops.indexed) _at(o, i),
          Positioned(
            left: 20,
            top: h * 0.17,
            child: _banner('World 1 · Backyard', AppColors.leafDark, '2 of 5 · climb up!'),
          ),
          Positioned(right: 24, top: h * 0.17, child: const KidIconView(KidIcon.trophy, size: 44, muted: true)),
        ],
      );
    },
  );
}

class _TerracePainter extends CustomPainter {
  const _TerracePainter();

  @override
  void paint(Canvas canvas, Size s) {
    // Bands of green terraces, each a little lighter going up.
    const bands = 7;
    for (var i = 0; i < bands; i++) {
      final y = s.height * (0.25 + i * 0.11);
      final band = Path()..moveTo(0, y + 20);
      for (var x = 0.0; x <= s.width; x += 20) {
        band.lineTo(x, y + math.sin(x / s.width * math.pi * 2 + i) * 14);
      }
      band
        ..lineTo(s.width, s.height)
        ..lineTo(0, s.height)
        ..close();
      final g = Color.lerp(const Color(0xFF8FD16A), const Color(0xFF4CA24F), i / bands)!;
      canvas.drawPath(band, Paint()..color = g);
      canvas.drawPath(
        band,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Color.lerp(g, Colors.black, 0.18)!,
      );
      // Water shine along each terrace edge.
      canvas.drawLine(
        Offset(s.width * 0.1, y + 6),
        Offset(s.width * 0.3, y + 6 + math.sin(0.6 + i) * 6),
        Paint()
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_TerracePainter old) => false;
}

// ------------------------------------------------------------------ G: tree

/// A giant tree to climb: plants sit on its branches from the roots up.
class _GiantTree extends StatelessWidget {
  const _GiantTree();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final stops = [
        Offset(w * 0.24, h * 0.82),
        Offset(w * 0.76, h * 0.7),
        Offset(w * 0.24, h * 0.56),
        Offset(w * 0.76, h * 0.43),
        Offset(w * 0.3, h * 0.3),
      ];
      return Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _TreePainter())),
          for (final (i, o) in stops.indexed) _at(o, i),
          Positioned(
            left: w * 0.5 - 32,
            top: h * 0.57,
            child: const Binhi(stage: BinhiStage.sprout, size: 64, reduceMotion: true),
          ),
          Positioned(left: 20, top: h * 0.17, child: _banner('World 1 · Backyard', AppColors.barkDark, '2 of 5')),
        ],
      );
    },
  );
}

class _TreePainter extends CustomPainter {
  const _TreePainter();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    // Crown at the top.
    for (final (x, y, r) in [(0.3, 0.3, 90.0), (0.7, 0.28, 95.0), (0.5, 0.2, 100.0)]) {
      canvas.drawCircle(Offset(w * x, h * y), r, Paint()..color = AppColors.foliage);
    }
    // Trunk and branches.
    final bark = Paint()..color = AppColors.bark;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.barkDark;
    final trunk = Path()
      ..moveTo(w * 0.42, h)
      ..cubicTo(w * 0.46, h * 0.7, w * 0.4, h * 0.45, w * 0.46, h * 0.25)
      ..lineTo(w * 0.56, h * 0.25)
      ..cubicTo(w * 0.6, h * 0.45, w * 0.54, h * 0.7, w * 0.6, h)
      ..close();
    canvas.drawPath(trunk, bark);
    canvas.drawPath(trunk, edge);
    for (final (y, left) in [(0.84, true), (0.72, false), (0.58, true), (0.45, false), (0.32, true)]) {
      final from = Offset(w * 0.5, h * (y + 0.02));
      final to = Offset(left ? w * 0.2 : w * 0.8, h * y);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..color = AppColors.barkDark,
      );
      canvas.drawLine(
        from,
        to,
        Paint()
          ..strokeWidth = 11
          ..strokeCap = StrokeCap.round
          ..color = AppColors.bark,
      );
      canvas.drawOval(
        Rect.fromCenter(center: to + Offset(left ? -10 : 10, -14), width: 30, height: 14),
        Paint()..color = AppColors.leafLight,
      );
    }
    // Grass at the foot.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.93, w, h * 0.07), Paint()..color = AppColors.leaf);
  }

  @override
  bool shouldRepaint(_TreePainter old) => false;
}

// ----------------------------------------------------------------- H: river

/// Binhi floats down a river in a bangka; plants wait on the banks.
class _River extends StatelessWidget {
  const _River();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      final river = Path()
        ..moveTo(w * 0.55, h * 0.16)
        ..cubicTo(w * 0.15, h * 0.35, w * 0.9, h * 0.55, w * 0.45, h * 0.72)
        ..cubicTo(w * 0.2, h * 0.82, w * 0.4, h * 0.95, w * 0.5, h * 1.05);
      final m = river.computeMetrics().first;
      Offset along(double t) => m.getTangentForOffset(m.length * t)!.position;
      final stops = [
        for (final (i, t) in [0.2, 0.36, 0.52, 0.68, 0.84].indexed) along(t) + Offset(i.isEven ? -95 : 95, 0),
      ];
      final boat = along(0.42);
      return Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RiverPainter(river))),
          for (final (i, o) in stops.indexed) _at(Offset(o.dx.clamp(64, w - 64), o.dy), i),
          Positioned(
            left: boat.dx - 46,
            top: boat.dy - 40,
            child: const SizedBox(width: 92, height: 56, child: CustomPaint(painter: _BangkaPainter())),
          ),
          Positioned(left: 20, top: h * 0.17, child: _banner('World 1 · Backyard', AppColors.skyDark, '2 of 5')),
        ],
      );
    },
  );
}

class _RiverPainter extends CustomPainter {
  const _RiverPainter(this.river);
  final Path river;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 78
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFE8CF95),
    );
    canvas.drawPath(
      river,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 62
        ..strokeCap = StrokeCap.round
        ..color = AppColors.sky,
    );
    final m = river.computeMetrics().first;
    final shine = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.6);
    for (var d = 20.0; d < m.length; d += 70) {
      canvas.drawPath(m.extractPath(d, d + 22).shift(const Offset(-8, 0)), shine);
    }
  }

  @override
  bool shouldRepaint(_RiverPainter old) => false;
}

/// A little outrigger boat (bangka) with Binhi aboard.
class _BangkaPainter extends CustomPainter {
  const _BangkaPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    // Outrigger floats.
    final pole = Paint()
      ..strokeWidth = 3
      ..color = AppColors.barkDark;
    canvas.drawLine(Offset(w * 0.2, h * 0.62), Offset(w * 0.2, h * 0.92), pole);
    canvas.drawLine(Offset(w * 0.8, h * 0.62), Offset(w * 0.8, h * 0.92), pole);
    canvas.drawLine(Offset(w * 0.05, h * 0.92), Offset(w * 0.95, h * 0.92), pole..strokeWidth = 4);
    final hull = Path()
      ..moveTo(0, h * 0.5)
      ..quadraticBezierTo(w * 0.5, h * 0.95, w, h * 0.5)
      ..close();
    canvas.drawPath(hull, Paint()..color = AppColors.coral);
    canvas.drawPath(
      hull,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = AppColors.coralDark,
    );
    canvas.drawLine(
      Offset(w * 0.05, h * 0.55),
      Offset(w * 0.95, h * 0.55),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5,
    );
    // Binhi's pot in the boat.
    final pot = Path()
      ..moveTo(w * 0.4, h * 0.22)
      ..lineTo(w * 0.6, h * 0.22)
      ..lineTo(w * 0.57, h * 0.5)
      ..lineTo(w * 0.43, h * 0.5)
      ..close();
    canvas.drawPath(pot, Paint()..color = AppColors.coralLight);
    canvas.drawLine(
      Offset(w * 0.5, h * 0.22),
      Offset(w * 0.5, h * 0.04),
      Paint()
        ..strokeWidth = 2.4
        ..color = AppColors.foliageDark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.46, h * 0.06), width: 9, height: 6),
      Paint()..color = AppColors.leaf,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.54, h * 0.05), width: 9, height: 6),
      Paint()..color = AppColors.leaf,
    );
  }

  @override
  bool shouldRepaint(_BangkaPainter old) => false;
}
