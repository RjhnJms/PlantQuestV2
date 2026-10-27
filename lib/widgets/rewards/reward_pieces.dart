import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../art/avatars/avatar_view.dart';
import '../../art/binhi/binhi.dart';
import '../../art/plants/plant_view.dart';
import '../../art/sticker.dart';
import '../../content/plant_catalog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';

// Reward pieces. StickerBadge is used by the sticker book; the rest are
// still ideas shown only in the Rewards preview (#/rewards-preview).

const _gold = Color(0xFFFFC93C);
const _goldDark = Color(0xFFD99A00);
const _goldLight = Color(0xFFFFF0B3);

/// A die-cut sticker: a plant on a white bubble with a name ribbon.
/// Not yet earned shows a dashed spot with the plant's mystery shape.
class StickerBadge extends StatelessWidget {
  const StickerBadge({
    super.key,
    required this.plant,
    this.earned = true,
    this.size = 96,
    this.tilt = 0,
    this.showName = true,
  });

  /// The name ribbon under the bubble (off for tiny stickers).
  final bool showName;

  final PlantInfo plant;
  final bool earned;
  final double size;

  /// A small turn so a page of stickers looks hand-placed.
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earned ? AppColors.card : AppColors.track,
        border: Border.all(
          color: earned ? plant.themeColor : AppColors.borderDeep,
          width: earned ? (size < 60 ? 2.5 : 4) : 2,
        ),
        boxShadow: earned ? [const BoxShadow(color: Color(0x33263046), blurRadius: 6, offset: Offset(0, 3))] : null,
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: ClipOval(
        child: ColoredBox(
          color: earned ? plant.tileColor : AppColors.track,
          child: Padding(
            padding: EdgeInsets.all(size * 0.04),
            child: PlantView(plant: plant, locked: !earned),
          ),
        ),
      ),
    );
    return Semantics(
      label: earned ? '${plant.name} sticker' : 'Sticker not earned yet',
      child: Transform.rotate(
        angle: tilt,
        child: !showName
            ? bubble
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bubble,
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: earned ? plant.themeColor : AppColors.border,
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                        border: Border.all(color: AppColors.card, width: 2),
                      ),
                      child: Text(
                        earned ? plant.name : '???',
                        style: AppText.label.copyWith(
                          color: earned ? AppColors.text : AppColors.textMuted,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A plant card. [gold] (a perfect quiz) adds a gold frame, stars and a
/// shine that sweeps across every few seconds.
class GoldPlantCard extends StatefulWidget {
  const GoldPlantCard({super.key, required this.plant, this.gold = true, this.width = 150, this.reduceMotion = false});

  final PlantInfo plant;
  final bool gold;
  final double width;
  final bool reduceMotion;

  @override
  State<GoldPlantCard> createState() => _GoldPlantCardState();
}

class _GoldPlantCardState extends State<GoldPlantCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.gold && !widget.reduceMotion) _shine.repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plant;
    final gold = widget.gold;
    final card = Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        gradient: gold
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_goldLight, _gold, _goldDark, _gold],
              )
            : null,
        color: gold ? null : AppColors.borderDeep,
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusM - 4)),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: gold ? const Color(0xFFFFF7D6) : p.tileColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: PlantView(plant: p),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(p.name, style: AppText.heading.copyWith(fontSize: 17), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  Icon(Icons.star_rounded, size: 20, color: gold || i < 2 ? _gold : AppColors.track),
              ],
            ),
            if (gold)
              Text('PERFECT!', style: AppText.label.copyWith(color: const Color(0xFF8A5A00), fontSize: 11))
            else
              Text('2 of 3 right', style: AppText.label.copyWith(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
    if (!gold || widget.reduceMotion) return card;
    return AnimatedBuilder(
      animation: _shine,
      child: card,
      builder: (context, child) {
        // The shine crosses in the first 40 % of each loop, then rests.
        final t = (_shine.value / 0.4).clamp(0.0, 1.0);
        if (t <= 0 || t >= 1) return child!;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (r) => LinearGradient(
            begin: Alignment(-1 + t * 4 - 1.5, -1),
            end: Alignment(-1 + t * 4 - 0.5, 1),
            colors: const [Color(0x00FFFFFF), Color(0x88FFFFFF), Color(0x00FFFFFF)],
          ).createShader(r),
          child: child,
        );
      },
    );
  }
}

/// Things kids can place in Binhi's garden.
enum GardenItem {
  fence('Bamboo fence', Icons.fence_rounded),
  pond('Little pond', Icons.water_rounded),
  butterfly('Butterflies', Icons.flutter_dash_rounded),
  parol('Parol lantern', Icons.star_rounded),
  wateringCan('Watering can', Icons.local_drink_rounded),
  bench('Bench', Icons.chair_rounded);

  const GardenItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Binhi's garden patch with the decorations kids have placed.
class GardenPatch extends StatelessWidget {
  const GardenPatch({
    super.key,
    required this.items,
    this.outfit = BinhiOutfit.none,
    this.stage = BinhiStage.blooming,
    this.reduceMotion = false,
  });

  final Set<GardenItem> items;
  final BinhiOutfit outfit;
  final BinhiStage stage;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;
            return Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _GardenPainter(items))),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: h * 0.1,
                  child: Center(
                    child: Binhi(stage: stage, size: h * 0.62, outfit: outfit, reduceMotion: reduceMotion),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GardenPainter extends CustomPainter {
  _GardenPainter(this.items);

  final Set<GardenItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final all = Offset.zero & size;
    canvas.drawRect(
      all,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.skyLight, AppColors.skyTint],
        ).createShader(all),
    );
    // Sun and a hill.
    canvas.drawCircle(Offset(w * 0.86, h * 0.18), h * 0.09, Sticker.solid(AppColors.sunshine));
    final hill = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.5, h * 0.48, w, h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill, Sticker.fill(Rect.fromLTWH(0, h * 0.5, w, h * 0.5), AppColors.leafLight, lift: 0.1));
    final grass = Rect.fromLTWH(0, h * 0.74, w, h * 0.26);
    canvas.drawRect(grass, Sticker.solid(AppColors.leaf));

    if (items.contains(GardenItem.fence)) _fence(canvas, size);
    if (items.contains(GardenItem.pond)) _pond(canvas, size);
    if (items.contains(GardenItem.bench)) _bench(canvas, size);
    if (items.contains(GardenItem.wateringCan)) _can(canvas, size);
    if (items.contains(GardenItem.parol)) _parol(canvas, size);
    if (items.contains(GardenItem.butterfly)) _butterflies(canvas, size);
  }

  void _fence(Canvas canvas, Size s) {
    final y = s.height * 0.6;
    final post = s.height * 0.2;
    final rail = Sticker.stroke(AppColors.bambooDark, 4);
    canvas
      ..drawLine(Offset(0, y + post * 0.35), Offset(s.width, y + post * 0.35), rail)
      ..drawLine(Offset(0, y + post * 0.7), Offset(s.width, y + post * 0.7), rail);
    for (var x = 8.0; x < s.width; x += s.width / 14) {
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 9, post), const Radius.circular(4));
      canvas
        ..drawRRect(r, Sticker.solid(AppColors.bamboo))
        ..drawRRect(r, Sticker.stroke(AppColors.bambooDark, 2))
        ..drawLine(Offset(x, y + post * 0.5), Offset(x + 9, y + post * 0.5), Sticker.stroke(AppColors.bambooDark, 1.5));
    }
  }

  void _pond(Canvas canvas, Size s) {
    final r = Rect.fromCenter(
      center: Offset(s.width * 0.2, s.height * 0.86),
      width: s.width * 0.28,
      height: s.height * 0.14,
    );
    canvas
      ..drawOval(r, Sticker.solid(AppColors.water))
      ..drawOval(r, Sticker.stroke(AppColors.waterDark, 3))
      ..drawOval(
        Rect.fromCenter(
          center: r.center.translate(-r.width * 0.15, -r.height * 0.15),
          width: r.width * 0.3,
          height: r.height * 0.22,
        ),
        Sticker.solid(AppColors.card.withValues(alpha: 0.6)),
      );
    // A lily pad with a pink flower.
    final pad = r.center.translate(r.width * 0.22, 0);
    canvas.drawCircle(pad, r.height * 0.24, Sticker.solid(AppColors.foliage));
    Sticker.flower(
      canvas,
      pad.translate(0, -2),
      r.height * 0.22,
      petal: AppColors.bubblegum,
      petalOutline: AppColors.bubblegumDark,
    );
  }

  void _bench(Canvas canvas, Size s) {
    final x = s.width * 0.7;
    final y = s.height * 0.8;
    final wood = Sticker.solid(AppColors.bark);
    final edge = Sticker.stroke(AppColors.barkDark, 2);
    final seat = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, s.width * 0.18, 8), const Radius.circular(3));
    final back = RRect.fromRectAndRadius(Rect.fromLTWH(x, y - 18, s.width * 0.18, 7), const Radius.circular(3));
    for (final leg in [x + 6, x + s.width * 0.18 - 12]) {
      final l = Rect.fromLTWH(leg, y - 18, 6, 34);
      canvas
        ..drawRect(l, wood)
        ..drawRect(l, edge);
    }
    canvas
      ..drawRRect(back, wood)
      ..drawRRect(back, edge)
      ..drawRRect(seat, wood)
      ..drawRRect(seat, edge);
  }

  void _can(Canvas canvas, Size s) {
    final o = Offset(s.width * 0.62, s.height * 0.86);
    final body = RRect.fromRectAndRadius(Rect.fromCenter(center: o, width: 30, height: 24), const Radius.circular(6));
    final spout = Path()
      ..moveTo(o.dx + 12, o.dy + 4)
      ..lineTo(o.dx + 30, o.dy - 12)
      ..lineTo(o.dx + 33, o.dy - 9)
      ..lineTo(o.dx + 14, o.dy + 9)
      ..close();
    Sticker.shape(canvas, spout, AppColors.sky, AppColors.skyDark, width: 2);
    Sticker.shape(canvas, Path()..addRRect(body), AppColors.sky, AppColors.skyDark, width: 2);
    canvas.drawArc(
      Rect.fromCenter(center: o.translate(-4, -12), width: 18, height: 14),
      math.pi,
      math.pi,
      false,
      Sticker.stroke(AppColors.skyDark, 3),
    );
  }

  void _parol(Canvas canvas, Size s) {
    final c = Offset(s.width * 0.16, s.height * 0.26);
    canvas.drawLine(Offset(c.dx, 0), c.translate(0, -18), Sticker.stroke(AppColors.barkDark, 1.5));
    final star = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? 18.0 : 8.0;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    Sticker.shape(canvas, star, AppColors.coral, AppColors.coralDark, width: 2);
    canvas.drawCircle(c, 4, Sticker.solid(AppColors.sunshine));
    for (final dx in [-5.0, 0.0, 5.0]) {
      canvas.drawLine(c.translate(dx, 14), c.translate(dx * 1.6, 30), Sticker.stroke(AppColors.sunshineDark, 2));
    }
  }

  void _butterflies(Canvas canvas, Size s) {
    for (final (o, color) in [
      (Offset(s.width * 0.3, s.height * 0.3), AppColors.grape),
      (Offset(s.width * 0.66, s.height * 0.22), AppColors.sunshine),
      (Offset(s.width * 0.76, s.height * 0.42), AppColors.bubblegum),
    ]) {
      for (final side in [-1.0, 1.0]) {
        canvas
          ..drawOval(Rect.fromCenter(center: o.translate(side * 6, -3), width: 11, height: 13), Sticker.solid(color))
          ..drawOval(
            Rect.fromCenter(center: o.translate(side * 5, 5), width: 8, height: 9),
            Sticker.solid(Color.lerp(color, AppColors.card, 0.35)!),
          );
      }
      canvas.drawLine(o.translate(0, -6), o.translate(0, 8), Sticker.stroke(AppColors.text, 2.4));
    }
  }

  @override
  bool shouldRepaint(_GardenPainter old) => !_sameSet(old.items, items);

  static bool _sameSet(Set<GardenItem> a, Set<GardenItem> b) => a.length == b.length && a.containsAll(b);
}

/// An extra fun fact that opens after a perfect quiz.
class BonusFactCard extends StatelessWidget {
  const BonusFactCard({super.key, required this.plant, required this.fact, this.unlocked = true});

  final PlantInfo plant;
  final String fact;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? AppColors.grapeTint : AppColors.track,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: unlocked ? AppColors.grape : AppColors.borderDeep, width: 2.5),
      ),
      padding: const EdgeInsets.all(AppSizes.gapL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: plant.tileColor, borderRadius: BorderRadius.circular(AppSizes.radiusS)),
            padding: const EdgeInsets.all(6),
            child: PlantView(plant: plant, locked: !unlocked),
          ),
          const SizedBox(width: AppSizes.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      unlocked ? Icons.lightbulb_rounded : Icons.lock_rounded,
                      size: 20,
                      color: unlocked ? AppColors.grapeDark : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        unlocked ? 'BONUS FACT' : 'GET 3 OF 3 TO OPEN',
                        style: AppText.label.copyWith(color: unlocked ? AppColors.grapeDark : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked ? fact : 'A secret ${plant.name} fact is waiting for you!',
                  style: AppText.body.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The certificate for learning all 15 plants.
class PlantExpertCertificate extends StatelessWidget {
  const PlantExpertCertificate({super.key, required this.name, required this.avatarId, this.date = 'October 22, 2026'});

  final String name;
  final String? avatarId;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEF),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: _goldDark, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x33263046), blurRadius: 10, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusM - 5),
          border: Border.all(color: AppColors.leaf, width: 2),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('CERTIFICATE', style: AppText.label.copyWith(color: AppColors.leafDark, letterSpacing: 3)),
            Text('Plant Expert', style: AppText.display.copyWith(fontSize: 32, color: AppColors.text)),
            const SizedBox(height: AppSizes.gapS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarView(avatarId: avatarId, size: 64),
                const SizedBox(width: AppSizes.gapM),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This is to say that', style: AppText.bodySmall),
                      Text(name, style: AppText.title.copyWith(color: AppColors.grapeDark)),
                      const Text('learned all 15 plants!', style: AppText.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.gapM),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final p in PlantCatalog.all)
                  Container(
                    width: 34,
                    height: 34,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: p.tileColor, shape: BoxShape.circle),
                    child: PlantView(plant: p),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.gapM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date, style: AppText.label.copyWith(color: AppColors.text)),
                      Container(height: 2, width: 110, color: AppColors.borderDeep),
                      Text('Date', style: AppText.bodySmall.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                const Binhi(
                  stage: BinhiStage.blooming,
                  size: 56,
                  outfit: BinhiOutfit(garland: true),
                  reduceMotion: true,
                ),
                const SizedBox(width: 6),
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [_goldLight, _gold, _goldDark]),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Color(0xFF7A4E00), size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
