import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../art/binhi/binhi.dart';
import '../art/icons/kid_icon.dart';
import '../art/plants/plant_view.dart';
import '../content/plant_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/chunky_button.dart';
import '../widgets/stat_pill.dart';

/// Ideas for keeping kids coming back (preview only; drawn to PNGs by
/// tool/render_engage_test.dart): My Garden, Binhi's daily gift and
/// caring for Binhi.
enum EngageIdea { garden, gift, care }

class EngageMock extends StatelessWidget {
  const EngageMock({super.key, required this.idea});

  final EngageIdea idea;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: switch (idea) {
      EngageIdea.garden => const _Garden(),
      EngageIdea.gift => const _Gift(),
      EngageIdea.care => const _Care(),
    },
  );
}

// ---------------------------------------------------------------- My Garden

/// The child's own garden: learned plants plus decorations bought with
/// leaves, placed by dragging.
class _Garden extends StatelessWidget {
  const _Garden();

  @override
  Widget build(BuildContext context) {
    final learned = PlantCatalog.inWorld(1).take(4).toList();
    return SafeArea(
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
                  builder: (context, c) {
                    Widget at(double x, double y, double w, Widget child) => Positioned(
                      left: c.maxWidth * x - w / 2,
                      top: c.maxHeight * y - w,
                      width: w,
                      height: w,
                      child: child,
                    );
                    return Stack(
                      children: [
                        const Positioned.fill(child: CustomPaint(painter: _GardenGround())),
                        // Learned plants (from the Backyard so far).
                        at(0.2, 0.47, 110, PlantView(plant: learned[0])),
                        at(0.8, 0.45, 110, PlantView(plant: learned[1])),
                        at(0.16, 0.86, 120, PlantView(plant: learned[3])),
                        at(0.6, 0.62, 100, PlantView(plant: learned[2])),
                        // Decorations.
                        at(0.5, 0.38, 120, const CustomPaint(painter: _BenchPainter())),
                        at(0.78, 0.9, 130, const CustomPaint(painter: _PondPainter())),
                        at(0.35, 0.2, 40, const CustomPaint(painter: _ButterflyPainter(AppColors.bubblegum))),
                        at(0.7, 0.28, 34, const CustomPaint(painter: _ButterflyPainter(AppColors.sunshine))),
                        // Binhi lives here too.
                        Positioned(
                          left: c.maxWidth * 0.42 - 45,
                          top: c.maxHeight * 0.7,
                          child: const Binhi(stage: BinhiStage.sapling, size: 90, reduceMotion: true),
                        ),
                        // The piece being moved.
                        Positioned(
                          left: c.maxWidth * 0.6 - 60,
                          top: c.maxHeight * 0.62 - 104,
                          child: Container(
                            width: 120,
                            height: 112,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSizes.gapM,
                          top: AppSizes.gapM,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                            ),
                            child: const Row(
                              children: [
                                KidIconView(KidIcon.hand, size: AppSizes.iconSmall),
                                SizedBox(width: 6),
                                Text('Drag to move things', style: AppText.label),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // The decorations tray.
          Container(
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
                Row(
                  children: [
                    const Text('Decorate', style: AppText.heading),
                    const Spacer(),
                    _tab('Plants', false),
                    const SizedBox(width: 6),
                    _tab('Things', true),
                  ],
                ),
                const SizedBox(height: AppSizes.gapS),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TrayItem(painter: _BenchPainter(), label: 'Bench', owned: true),
                    _TrayItem(painter: _PondPainter(), label: 'Pond', owned: true),
                    _TrayItem(painter: _FencePainter(), label: 'Fence', price: 25),
                    _TrayItem(painter: _ButterflyPainter(AppColors.grape), label: 'Butterfly', price: 15),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool on) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: on ? AppColors.leafTint : AppColors.track.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
    ),
    child: Text(label, style: AppText.label.copyWith(color: on ? AppColors.leafDark : AppColors.textMuted)),
  );
}

class _TrayItem extends StatelessWidget {
  const _TrayItem({required this.painter, required this.label, this.owned = false, this.price = 0});

  final CustomPainter painter;
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
        child: CustomPaint(painter: painter),
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

class _GardenGround extends CustomPainter {
  const _GardenGround();

  @override
  void paint(Canvas canvas, Size size) {
    final sky = size.height * 0.16;
    canvas.drawRect(Offset.zero & Size(size.width, sky + 20), Paint()..color = AppColors.skyLight);
    final grass = Path()
      ..moveTo(0, sky)
      ..quadraticBezierTo(size.width * 0.5, sky - 30, size.width, sky)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(grass, Paint()..color = AppColors.leafLight);
    // Soft mowing stripes.
    final stripe = Paint()..color = AppColors.leaf.withValues(alpha: 0.18);
    for (var y = sky + 40; y < size.height; y += 70) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 30), stripe);
    }
    // A dirt path.
    final path = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 34
      ..strokeCap = StrokeCap.round
      ..color = AppColors.sunshineTint;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.45, sky + 10)
        ..cubicTo(
          size.width * 0.2,
          size.height * 0.45,
          size.width * 0.75,
          size.height * 0.6,
          size.width * 0.4,
          size.height,
        ),
      path,
    );
  }

  @override
  bool shouldRepaint(_GardenGround old) => false;
}

class _BenchPainter extends CustomPainter {
  const _BenchPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final wood = Paint()..color = AppColors.bark;
    final dark = Paint()..color = AppColors.barkDark;
    final w = s.width;
    final h = s.height;
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.62, w * 0.07, h * 0.3), dark);
    canvas.drawRect(Rect.fromLTWH(w * 0.73, h * 0.62, w * 0.07, h * 0.3), dark);
    for (final y in [0.3, 0.42]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * y, w * 0.8, h * 0.09), const Radius.circular(4)),
        wood,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.05, h * 0.58, w * 0.9, h * 0.1), const Radius.circular(4)),
      wood,
    );
  }

  @override
  bool shouldRepaint(_BenchPainter old) => false;
}

class _PondPainter extends CustomPainter {
  const _PondPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final r = Rect.fromLTWH(0, s.height * 0.45, s.width, s.height * 0.5);
    canvas.drawOval(r.inflate(5), Paint()..color = AppColors.palmTrunk);
    canvas.drawOval(r, Paint()..color = AppColors.sky);
    canvas.drawOval(r.deflate(s.width * 0.12).shift(const Offset(-6, -4)), Paint()..color = AppColors.skyLight);
    // A lily pad.
    canvas.drawCircle(Offset(s.width * 0.68, s.height * 0.7), s.width * 0.09, Paint()..color = AppColors.leaf);
    canvas.drawCircle(Offset(s.width * 0.7, s.height * 0.66), s.width * 0.035, Paint()..color = AppColors.bubblegum);
  }

  @override
  bool shouldRepaint(_PondPainter old) => false;
}

class _FencePainter extends CustomPainter {
  const _FencePainter();

  @override
  void paint(Canvas canvas, Size s) {
    final wood = Paint()..color = AppColors.bark;
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.45, s.width, s.height * 0.1), wood);
    canvas.drawRect(Rect.fromLTWH(0, s.height * 0.7, s.width, s.height * 0.1), wood);
    for (var i = 0; i < 4; i++) {
      final x = s.width * (0.06 + i * 0.25);
      canvas.drawPath(
        Path()
          ..moveTo(x, s.height * 0.95)
          ..lineTo(x, s.height * 0.3)
          ..lineTo(x + s.width * 0.08, s.height * 0.18)
          ..lineTo(x + s.width * 0.16, s.height * 0.3)
          ..lineTo(x + s.width * 0.16, s.height * 0.95)
          ..close(),
        Paint()..color = AppColors.palmTrunk,
      );
    }
  }

  @override
  bool shouldRepaint(_FencePainter old) => false;
}

class _ButterflyPainter extends CustomPainter {
  const _ButterflyPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final wing = Paint()..color = color;
    final w = s.width;
    canvas.drawOval(Rect.fromCenter(center: c + Offset(-w * 0.2, -w * 0.12), width: w * 0.4, height: w * 0.44), wing);
    canvas.drawOval(Rect.fromCenter(center: c + Offset(w * 0.2, -w * 0.12), width: w * 0.4, height: w * 0.44), wing);
    canvas.drawOval(Rect.fromCenter(center: c + Offset(-w * 0.15, w * 0.18), width: w * 0.28, height: w * 0.3), wing);
    canvas.drawOval(Rect.fromCenter(center: c + Offset(w * 0.15, w * 0.18), width: w * 0.28, height: w * 0.3), wing);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: w * 0.09, height: w * 0.6), Radius.circular(w)),
      Paint()..color = AppColors.text,
    );
  }

  @override
  bool shouldRepaint(_ButterflyPainter old) => old.color != color;
}

// ---------------------------------------------------------------- Daily gift

/// Opening the app once a day: Binhi hands over a gift. Seven days make a
/// week of gifts; a missed day just waits (nothing is lost).
class _Gift extends StatelessWidget {
  const _Gift();

  @override
  Widget build(BuildContext context) {
    const today = 3;
    return Stack(
      children: [
        // Home, dimmed behind the popup.
        Positioned.fill(child: ColoredBox(color: AppColors.leafLight.withValues(alpha: 0.5))),
        Positioned.fill(child: ColoredBox(color: Colors.black.withValues(alpha: 0.4))),
        Center(
          child: Container(
            margin: const EdgeInsets.all(AppSizes.gutter),
            padding: const EdgeInsets.fromLTRB(AppSizes.gapL, AppSizes.gapXl, AppSizes.gapL, AppSizes.gapL),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusL)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('A gift from Binhi!', style: AppText.title.copyWith(color: AppColors.grapeInk)),
                const SizedBox(height: 4),
                Text('Thanks for coming back today.', style: AppText.body.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppSizes.gapL),
                SizedBox(
                  height: 190,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      const Positioned(
                        left: 10,
                        bottom: 0,
                        child: Binhi(
                          stage: BinhiStage.sapling,
                          size: 120,
                          mood: BinhiMood.cheering,
                          reduceMotion: true,
                        ),
                      ),
                      Positioned(
                        right: 24,
                        bottom: 10,
                        child: Transform.rotate(
                          angle: 0.12,
                          child: const SizedBox(
                            width: 130,
                            height: 130,
                            child: CustomPaint(painter: _GiftBoxPainter()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.gapL),
                // The week of gifts.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [for (var d = 1; d <= 7; d++) _DayDot(day: d, today: today)],
                ),
                const SizedBox(height: AppSizes.gapS),
                Text('Day 7 is a big surprise!', style: AppText.label.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: AppSizes.gapL),
                ChunkyButton(label: 'OPEN MY GIFT', onPressed: () {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.day, required this.today});
  final int day;
  final int today;

  @override
  Widget build(BuildContext context) {
    final done = day < today;
    final now = day == today;
    final big = day == 7;
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? AppColors.leafTint
                : now
                ? AppColors.grapeTint
                : AppColors.track.withValues(alpha: 0.5),
            border: Border.all(color: now ? AppColors.grape : Colors.transparent, width: 3),
          ),
          child: Center(
            child: done
                ? const KidIconView(KidIcon.check, size: 20)
                : big
                ? const KidIconView(KidIcon.trophy, size: 22, muted: true)
                : SizedBox(
                    width: 22,
                    height: 22,
                    child: Opacity(
                      opacity: now ? 1 : 0.4,
                      child: const CustomPaint(painter: _GiftBoxPainter()),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 2),
        Text('Day $day', style: AppText.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _GiftBoxPainter extends CustomPainter {
  const _GiftBoxPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final box = Rect.fromLTWH(w * 0.1, h * 0.42, w * 0.8, h * 0.55);
    final lid = Rect.fromLTWH(w * 0.04, h * 0.3, w * 0.92, h * 0.17);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.025)
      ..color = AppColors.coralDark;
    canvas.drawRRect(RRect.fromRectAndRadius(box, Radius.circular(w * 0.06)), Paint()..color = AppColors.coral);
    canvas.drawRRect(RRect.fromRectAndRadius(box, Radius.circular(w * 0.06)), outline);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, Radius.circular(w * 0.05)), Paint()..color = AppColors.coralLight);
    canvas.drawRRect(RRect.fromRectAndRadius(lid, Radius.circular(w * 0.05)), outline);
    final ribbon = Paint()..color = AppColors.sunshine;
    canvas.drawRect(Rect.fromLTWH(w * 0.43, h * 0.3, w * 0.14, h * 0.67), ribbon);
    // Bow.
    canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.3, h * 0.22), ribbon);
    canvas.drawOval(Rect.fromLTWH(w * 0.5, h * 0.1, w * 0.3, h * 0.22), ribbon);
    canvas.drawCircle(Offset(w * 0.5, h * 0.25), w * 0.07, Paint()..color = AppColors.sunshineDark);
  }

  @override
  bool shouldRepaint(_GiftBoxPainter old) => false;
}

// ---------------------------------------------------------------- Care for Binhi

/// Water Binhi once a day. A thirsty Binhi only droops a little and is
/// never hurt; one tap of the watering can makes him happy again.
class _Care extends StatelessWidget {
  const _Care();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(AppSizes.gutter),
      child: Column(
        children: [
          const Text('Take care of Binhi', style: AppText.title),
          Text('Once a day is all Binhi needs.', style: AppText.body.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppSizes.gapL),
          const Expanded(
            child: Row(
              children: [
                Expanded(child: _CareCard(watered: false)),
                SizedBox(width: AppSizes.gapM),
                Expanded(child: _CareCard(watered: true)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gapL),
          // Where it lives: Binhi's corner on Home gets a small can.
          Container(
            padding: const EdgeInsets.all(AppSizes.gapM),
            decoration: BoxDecoration(color: AppColors.skyTint, borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            child: const Row(
              children: [
                SizedBox(width: 44, height: 44, child: CustomPaint(painter: _CanPainter())),
                SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: Text(
                    'On Home, tap the watering can next to Binhi. Water him on any 7 days and a flower grows on his pot!',
                    style: AppText.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _CareCard extends StatelessWidget {
  const _CareCard({required this.watered});
  final bool watered;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.gapM),
    decoration: BoxDecoration(
      color: watered ? AppColors.leafTint : AppColors.sunshineTint,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      border: Border.all(color: watered ? AppColors.leaf : AppColors.sunshine, width: AppSizes.borderWidth),
    ),
    child: Column(
      children: [
        Text(watered ? 'After' : 'Before', style: AppText.label.copyWith(color: AppColors.textMuted)),
        const Spacer(),
        SizedBox(
          height: 170,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Transform.rotate(
                angle: watered ? 0 : -0.12,
                alignment: Alignment.bottomCenter,
                child: Binhi(
                  stage: BinhiStage.sapling,
                  size: 130,
                  mood: watered ? BinhiMood.cheering : BinhiMood.encouraging,
                  reduceMotion: true,
                ),
              ),
              if (watered) ...[
                const Positioned(top: 0, left: 10, child: KidIconView(KidIcon.drop, size: 24)),
                const Positioned(top: 18, right: 8, child: KidIconView(KidIcon.drop, size: 20)),
              ] else
                const Positioned(
                  top: 0,
                  right: 0,
                  child: SizedBox(width: 64, height: 64, child: CustomPaint(painter: _CanPainter(pouring: true))),
                ),
            ],
          ),
        ),
        const Spacer(),
        // How full Binhi is: three drops.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: KidIconView(KidIcon.drop, size: 24, muted: !watered && i > 0),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.gapS),
        Text(
          watered ? 'Ahh, thank you! +2 leaves' : 'Binhi is a little thirsty',
          style: AppText.heading.copyWith(fontSize: 16, color: watered ? AppColors.leafDark : AppColors.sunshineDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.gapS),
        if (!watered)
          ChunkyButton(label: 'WATER', icon: KidIcon.drop, small: true, onPressed: () {})
        else
          const SizedBox(height: 44),
      ],
    ),
  );
}

class _CanPainter extends CustomPainter {
  const _CanPainter({this.pouring = false});
  final bool pouring;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    canvas.save();
    if (pouring) {
      canvas.translate(w / 2, h / 2);
      canvas.rotate(-0.5);
      canvas.translate(-w / 2, -h / 2);
    }
    final body = Paint()..color = AppColors.sky;
    final dark = Paint()
      ..color = AppColors.skyDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round;
    // Spout.
    canvas.drawLine(Offset(w * 0.35, h * 0.6), Offset(w * 0.05, h * 0.3), dark..strokeWidth = w * 0.1);
    // Handle.
    canvas.drawArc(
      Rect.fromLTWH(w * 0.45, h * 0.18, w * 0.45, h * 0.5),
      -math.pi * 0.9,
      math.pi * 1.2,
      false,
      dark..strokeWidth = w * 0.07,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.3, h * 0.4, w * 0.5, h * 0.5), Radius.circular(w * 0.08)),
      body,
    );
    canvas.restore();
    if (pouring) {
      final drop = Paint()..color = AppColors.sky;
      for (final (x, y) in [(0.02, 0.55), (0.1, 0.75), (-0.04, 0.9)]) {
        canvas.drawOval(Rect.fromCenter(center: Offset(w * x, h * y), width: w * 0.08, height: w * 0.13), drop);
      }
    }
  }

  @override
  bool shouldRepaint(_CanPainter old) => old.pouring != pouring;
}
