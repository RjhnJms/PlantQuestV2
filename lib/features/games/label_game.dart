import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/plants/plant_drawing.dart';
import '../../art/plants/plant_view.dart';
import '../../art/sticker.dart';
import '../../content/plant_catalog.dart';
import '../../content/plant_content.dart';
import '../../game/rules.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/pressable_3d.dart';
import 'game_pieces.dart';

/// Label it (PLAN.md §6b): drag each part's name onto the right box, like
/// a worksheet. Tapping a word and then a box works too. Each right label
/// makes that part glow and Binhi says what the part does.
class LabelGameScreen extends ConsumerStatefulWidget {
  const LabelGameScreen({super.key, required this.plantId});

  final String plantId;

  @override
  ConsumerState<LabelGameScreen> createState() => _LabelGameScreenState();
}

class _LabelGameScreenState extends ConsumerState<LabelGameScreen> with GameVoice {
  late final plant = PlantCatalog.byId(widget.plantId);
  late final content = PlantContent.of(widget.plantId);
  final _placed = <PlantPart>{};
  PlantPart? _picked;
  PlantPart? _glow;
  final _keys = {for (final p in PlantPart.values) p: GlobalKey()};

  String _word(PlantPart p) => switch (p) {
    PlantPart.root => 'Root',
    PlantPart.stem => 'Stem',
    PlantPart.leaf => 'Leaf',
    PlantPart.special => plant.special.label,
  };

  void _drop(PlantPart word, PlantPart box) {
    if (_placed.contains(box)) return;
    if (word == box) {
      setState(() {
        _placed.add(box);
        _glow = box;
        _picked = null;
      });
      say(content.parts[box]!);
      celebrateCorrect(ref, screenCenterOf(_keys[box]!));
    } else {
      comfortWrong(ref);
      setState(() => _picked = null);
      say('Not that one. Look where the line points!');
    }
  }

  void _restart() => setState(() {
    _placed.clear();
    _picked = null;
    _glow = null;
    hint = null;
  });

  @override
  Widget build(BuildContext context) {
    final done = _placed.length == PlantPart.values.length;
    final left = PlantPart.values.where((p) => !_placed.contains(p)).toList()
      ..sort((a, b) => _word(a).compareTo(_word(b)));
    return GameFrame(
      title: 'Label the ${plant.name}',
      howTo: 'Drag each word to the right box. Or tap a word, then a box.',
      learns: 'the parts of a plant and what each part does.',
      children: [
        ChunkyCard(
          padding: const EdgeInsets.all(AppSizes.gapS),
          child: LayoutBuilder(builder: (context, c) => _diagram(c.maxWidth)),
        ),
        const SizedBox(height: AppSizes.gapS),
        GameHint(hint),
        const SizedBox(height: AppSizes.gapS),
        if (done)
          GameDone(
            text: 'You know all four parts of the ${plant.name}!',
            onWin: () => ref.read(gameActionsProvider).winGame(MiniGame.label, plant.id),
            onPlayAgain: _restart,
          )
        else
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSizes.gapS,
            runSpacing: AppSizes.gapS,
            children: [
              for (final p in left)
                Draggable<PlantPart>(
                  data: p,
                  feedback: Material(color: Colors.transparent, child: _WordChip(_word(p), lifted: true)),
                  childWhenDragging: Opacity(opacity: 0.3, child: _WordChip(_word(p))),
                  child: Semantics(
                    button: true,
                    selected: _picked == p,
                    label: _picked == p ? '${_word(p)}, picked. Now tap a box.' : _word(p),
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () {
                        PressFeedback.onPress?.call();
                        setState(() => _picked = _picked == p ? null : p);
                      },
                      child: _WordChip(_word(p), picked: _picked == p),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _diagram(double w) {
    final pw = w * 0.5;
    final ph = pw * PlantDrawing.designSize.height / PlantDrawing.designSize.width;
    final plantRect = Rect.fromLTWH((w - pw) / 2, 0, pw, ph);
    final scale = pw / PlantDrawing.designSize.width;
    final drawing = PlantArt.of(plant.id);
    Offset at(PlantPart p) => plantRect.topLeft + drawing.regions()[p]!.getBounds().center * scale;

    // Boxes alternate sides from top to bottom so lines never cross, and
    // boxes on the same side never overlap.
    final order = [...PlantPart.values]..sort((a, b) => at(a).dy.compareTo(at(b).dy));
    const boxW = 92.0;
    const boxH = 44.0;
    final boxes = <PlantPart, Rect>{};
    final lastBottom = [-1000.0, -1000.0];
    for (final (i, p) in order.indexed) {
      final side = i % 2;
      final top = (at(p).dy - boxH / 2).clamp(lastBottom[side] + 6, ph - boxH).clamp(0.0, ph - boxH);
      boxes[p] = Rect.fromLTWH(side == 0 ? w - boxW : 0, top, boxW, boxH);
      lastBottom[side] = top + boxH;
    }
    return SizedBox(
      height: ph,
      child: Stack(
        children: [
          Positioned.fromRect(
            rect: plantRect,
            child: Semantics(
              label: 'A ${plant.name} with four empty labels',
              image: true,
              child: CustomPaint(
                painter: PlantPainter(drawing: drawing, mode: PlantMode.detail, highlight: _glow),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _LeaderLines([
                  for (final p in order)
                    (boxes[p]!.left == 0 ? boxes[p]!.centerRight : boxes[p]!.centerLeft, at(p), _placed.contains(p)),
                ]),
              ),
            ),
          ),
          for (final p in order)
            Positioned.fromRect(
              rect: boxes[p]!,
              child: DragTarget<PlantPart>(
                onAcceptWithDetails: (d) => _drop(d.data, p),
                builder: (context, hovering, _) => Semantics(
                  button: !_placed.contains(p),
                  label: _placed.contains(p) ? _word(p) : 'Empty label',
                  excludeSemantics: true,
                  child: GestureDetector(
                    key: _keys[p],
                    onTap: _picked == null ? null : () => _drop(_picked!, p),
                    child: _LabelBox(
                      word: _placed.contains(p) ? _word(p) : null,
                      hovering: hovering.isNotEmpty || (_picked != null && !_placed.contains(p)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LabelBox extends StatelessWidget {
  const _LabelBox({required this.word, required this.hovering});

  final String? word;
  final bool hovering;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: word != null ? AppColors.leafTint : (hovering ? AppColors.skyTint : AppColors.background),
      borderRadius: BorderRadius.circular(AppSizes.radiusS),
      border: Border.all(
        color: word != null ? AppColors.leafDark : (hovering ? AppColors.skyDark : AppColors.borderDeep),
        width: 2.5,
      ),
    ),
    child: word == null
        ? Text('?', style: AppText.heading.copyWith(color: AppColors.textMuted))
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(word!, style: AppText.label.copyWith(color: AppColors.leafDark, fontSize: 15)),
            ),
          ),
  );
}

class _WordChip extends StatelessWidget {
  const _WordChip(this.word, {this.picked = false, this.lifted = false});

  final String word;
  final bool picked;
  final bool lifted;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
    child: Container(
      constraints: const BoxConstraints(minHeight: AppSizes.minTap, minWidth: 92),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapL),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: picked ? AppColors.sky : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: AppColors.skyDark, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyDark.withValues(alpha: lifted ? 0.5 : 1),
            offset: Offset(0, lifted ? 8 : 4),
          ),
        ],
      ),
      child: Text(word, style: AppText.heading.copyWith(fontSize: 18)),
    ),
  );
}

class _LeaderLines extends CustomPainter {
  _LeaderLines(this.lines);

  final List<(Offset, Offset, bool)> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (from, to, done) in lines) {
      final paint = Sticker.stroke(done ? AppColors.leafDark : AppColors.textMuted, 2);
      if (done) {
        canvas.drawLine(from, to, paint);
      } else {
        // Dashed until labelled.
        final d = to - from;
        final n = (d.distance / 8).floor();
        for (var i = 0; i < n; i += 2) {
          canvas.drawLine(from + d * (i / n), from + d * ((i + 1) / n), paint);
        }
      }
      canvas.drawCircle(to, 4, Sticker.solid(done ? AppColors.leafDark : AppColors.textMuted));
    }
  }

  @override
  bool shouldRepaint(_LeaderLines old) => true;
}
