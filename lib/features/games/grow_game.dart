import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/plants/plant_view.dart';
import '../../art/sticker.dart';
import '../../content/plant_catalog.dart';
import '../../content/plant_games.dart';
import '../../game/rules.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_card.dart';
import 'game_pieces.dart';
import '../../art/icons/kid_icon.dart';

/// Grow it (PLAN.md §6b): tap four pictures in the order the plant grows.
/// Each right tap says what happens at that stage.
class GrowGameScreen extends ConsumerStatefulWidget {
  const GrowGameScreen({super.key, required this.plantId});

  final String plantId;

  @override
  ConsumerState<GrowGameScreen> createState() => _GrowGameScreenState();
}

class _GrowGameScreenState extends ConsumerState<GrowGameScreen> with GameVoice {
  late final plant = PlantCatalog.byId(widget.plantId);
  late final game = PlantGameContent.of(widget.plantId);
  late final labels = game.start.labels;
  late final facts = game.growFacts(plant.name);

  /// Mixed up, never already in order.
  static const _shuffled = [2, 0, 3, 1];
  final _order = <int>[];
  final _keys = List.generate(4, (_) => GlobalKey());

  void _tap(int stage) {
    if (_order.contains(stage)) return;
    if (stage == _order.length) {
      setState(() => _order.add(stage));
      say(facts[stage]);
      celebrateCorrect(ref, screenCenterOf(_keys[stage]));
    } else {
      comfortWrong(ref);
      say(
        _order.isEmpty
            ? 'Not yet! Every plant starts small. What comes first?'
            : 'Not yet! What comes right after the ${labels[_order.last].toLowerCase()}?',
      );
    }
  }

  void _restart() => setState(() {
    _order.clear();
    hint = null;
  });

  @override
  Widget build(BuildContext context) {
    final done = _order.length == 4;
    return GameFrame(
      title: 'How does ${plant.name} grow?',
      howTo: 'Tap the pictures in order, from first to last.',
      learns: 'how a plant grows, from start to new plants.',
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - 3 * AppSizes.gapS) / 4;
            return Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: AppSizes.gapS),
                  SizedBox(
                    width: w,
                    child: AspectRatio(
                      aspectRatio: 0.8,
                      child: Semantics(
                        label: i < _order.length ? 'Step ${i + 1}: ${labels[_order[i]]}' : 'Step ${i + 1}, empty',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: i < _order.length ? AppColors.leafTint : AppColors.background,
                            borderRadius: BorderRadius.circular(AppSizes.radiusS),
                            border: Border.all(
                              color: i < _order.length ? AppColors.leafDark : AppColors.borderDeep,
                              width: 2.5,
                            ),
                          ),
                          child: i < _order.length
                              ? Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: _StageArt(plant, game.start, _order[i]),
                                )
                              : Center(
                                  child: Text('${i + 1}', style: AppText.title.copyWith(color: AppColors.textMuted)),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.gapXs),
        const Row(
          children: [
            Text('first', style: AppText.bodySmall),
            SizedBox(width: 6),
            Expanded(child: Divider(color: AppColors.borderDeep, thickness: 2)),
            KidIconView(KidIcon.arrow, size: AppSizes.iconSmall, muted: true),
            SizedBox(width: 6),
            Text('last', style: AppText.bodySmall),
          ],
        ),
        const SizedBox(height: AppSizes.gapS),
        GameHint(hint),
        const SizedBox(height: AppSizes.gapS),
        if (done)
          GameDone(
            text: '${labels.join(', ')}. That is how ${plant.name} grows!',
            onWin: () => ref.read(gameActionsProvider).winGame(MiniGame.grow, plant.id),
            onPlayAgain: _restart,
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - AppSizes.gapM) / 2;
              return Wrap(
                spacing: AppSizes.gapM,
                runSpacing: AppSizes.gapM,
                children: [
                  for (final s in _shuffled)
                    SizedBox(
                      key: _keys[s],
                      width: w,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _order.contains(s) ? 0.25 : 1,
                        child: ChunkyCard(
                          onTap: _order.contains(s) ? null : () => _tap(s),
                          semanticLabel: labels[s],
                          padding: const EdgeInsets.all(AppSizes.gapS),
                          child: Column(
                            children: [
                              AspectRatio(aspectRatio: 1.1, child: _StageArt(plant, game.start, s)),
                              Text(
                                labels[s],
                                style: AppText.label.copyWith(color: AppColors.text),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Stage 0–1 are drawn here; stage 2 is the plant's own drawing, small;
/// stage 3 is the full plant.
class _StageArt extends StatelessWidget {
  const _StageArt(this.plant, this.start, this.stage);

  final PlantInfo plant;
  final StartKind start;
  final int stage;

  @override
  Widget build(BuildContext context) => switch (stage) {
    3 => PlantView(plant: plant),
    2 => Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(heightFactor: 0.62, child: PlantView(plant: plant)),
    ),
    _ => CustomPaint(
      painter: _StartPainter(start, sprouted: stage == 1, seedColor: _seedColor),
    ),
  };

  Color get _seedColor => switch (plant.id) {
    'mongo' => AppColors.podGreen,
    'palay' => AppColors.riceGold,
    'kalamansi' || 'gumamela' || 'kangkong' => AppColors.soilLight,
    _ => AppColors.bark,
  };
}

/// The very start of a plant, and just after it starts growing.
class _StartPainter extends CustomPainter {
  _StartPainter(this.start, {required this.sprouted, required this.seedColor});

  final StartKind start;
  final bool sprouted;
  final Color seedColor;

  late Canvas _c;

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    final s = math.min(size.width, size.height) / 100;
    canvas
      ..save()
      ..translate((size.width - 100 * s) / 2, (size.height - 100 * s) / 2)
      ..scale(s);
    final wet = start == StartKind.seedlingPod;
    if (wet) {
      canvas.drawRect(const Rect.fromLTRB(4, 70, 96, 92), Sticker.solid(AppColors.water.withValues(alpha: 0.6)));
    }
    final mound = Path()
      ..moveTo(8, 80)
      ..quadraticBezierTo(50, 62, 92, 80)
      ..lineTo(92, 92)
      ..lineTo(8, 92)
      ..close();
    Sticker.shape(canvas, mound, wet ? AppColors.soil : AppColors.soilMid, AppColors.soilDark, width: 2);

    switch (start) {
      case StartKind.seed:
        _seed(Offset(sprouted ? 43 : 50, sprouted ? 77 : 74), sprouted ? 0.4 : -0.2);
        if (sprouted) _sprout(const Offset(47, 76), const Offset(52, 50));
      case StartKind.coconut:
        final c = Offset(sprouted ? 42 : 50, 64);
        Sticker.shape(
          canvas,
          Path()..addOval(Rect.fromCenter(center: c, width: 34, height: 30)),
          AppColors.coconutBrown,
          AppColors.barkDark,
          width: 2,
        );
        canvas.drawLine(c.translate(-8, -6), c.translate(6, 8), Sticker.stroke(AppColors.barkDark, 1.5));
        if (sprouted) {
          _leaf(c.translate(10, -10), 0.2, 26, 5);
          _leaf(c.translate(10, -10), 0.7, 22, 5);
        }
      case StartKind.cutting:
        canvas.drawLine(const Offset(48, 82), const Offset(54, 40), Sticker.stroke(AppColors.bark, 5));
        _leaf(const Offset(54, 42), -0.7, 13, 7);
        _leaf(const Offset(54, 42), 0.7, 13, 7);
        if (sprouted) {
          for (final dx in [-10.0, -4.0, 4.0, 10.0]) {
            canvas.drawLine(const Offset(48, 82), Offset(48 + dx, 90), Sticker.stroke(AppColors.soilLight, 2));
          }
          _leaf(const Offset(52, 56), -1.2, 12, 6);
          _leaf(const Offset(52, 56), 1.2, 12, 6);
        }
      case StartKind.babyShoot:
        _cone(const Offset(50, 76), sprouted ? 44 : 24, AppColors.foliage);
        if (sprouted) _leaf(const Offset(50, 40), 0.6, 22, 9);
      case StartKind.bambooShoot:
        if (sprouted) {
          for (var y = 76.0; y > 30; y -= 12) {
            canvas.drawLine(Offset(50, y), Offset(50, y - 11), Sticker.stroke(AppColors.bamboo, 8));
            canvas.drawLine(Offset(46, y - 11), Offset(54, y - 11), Sticker.stroke(AppColors.bambooDark, 2));
          }
          _leaf(const Offset(50, 30), 0.5, 14, 5);
        } else {
          _cone(const Offset(50, 76), 26, AppColors.bark);
        }
      case StartKind.spores:
        final rng = math.Random(3);
        for (var i = 0; i < 18; i++) {
          canvas.drawCircle(
            Offset(18 + rng.nextDouble() * 64, 30 + rng.nextDouble() * 42),
            1.6,
            Sticker.solid(AppColors.barkDark),
          );
        }
        if (sprouted) {
          // A tiny new fern with a curled-up leaf.
          canvas.drawLine(const Offset(50, 76), const Offset(50, 50), Sticker.stroke(AppColors.foliageDark, 3));
          canvas.drawArc(
            Rect.fromCenter(center: const Offset(55, 48), width: 12, height: 12),
            math.pi,
            math.pi * 1.6,
            false,
            Sticker.stroke(AppColors.foliageDark, 3),
          );
          _leaf(const Offset(50, 64), -1.2, 12, 6);
        }
      case StartKind.seedlingPod:
        final top = sprouted ? const Offset(50, 36) : const Offset(58, 40);
        canvas.drawLine(const Offset(50, 80), top, Sticker.stroke(AppColors.podGreen, 7));
        if (sprouted) {
          for (final dx in [-12.0, -5.0, 5.0, 12.0]) {
            canvas.drawLine(const Offset(50, 80), Offset(50 + dx, 90), Sticker.stroke(AppColors.barkDark, 2));
          }
          _leaf(top, -0.6, 14, 7);
          _leaf(top, 0.6, 14, 7);
        }
    }
    canvas.restore();
  }

  void _seed(Offset c, double angle) {
    _c
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(angle);
    final r = Rect.fromCenter(center: Offset.zero, width: 18, height: 12);
    Sticker.shape(_c, Path()..addOval(r), seedColor, Sticker.darken(seedColor, 0.35), width: 2);
    _c.restore();
  }

  void _sprout(Offset base, Offset tip) {
    final stem = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx + 3, (base.dy + tip.dy) / 2, tip.dx, tip.dy);
    _c.drawPath(stem, Sticker.stroke(AppColors.foliageDark, 3.5));
    _leaf(tip, -0.9, 16, 9);
    _leaf(tip, 0.9, 16, 9);
  }

  void _cone(Offset base, double height, Color color) {
    final p = Path()
      ..moveTo(base.dx - 9, base.dy)
      ..quadraticBezierTo(base.dx - 6, base.dy - height * 0.6, base.dx, base.dy - height)
      ..quadraticBezierTo(base.dx + 6, base.dy - height * 0.6, base.dx + 9, base.dy)
      ..close();
    Sticker.shape(_c, p, color, Sticker.darken(color, 0.35), width: 2);
  }

  void _leaf(Offset base, double angle, double length, double width) =>
      Sticker.leaf(_c, base, angle, length, width, color: AppColors.foliage, outlineColor: AppColors.foliageDark);

  @override
  bool shouldRepaint(_StartPainter old) => old.start != start || old.sprouted != sprouted;
}
