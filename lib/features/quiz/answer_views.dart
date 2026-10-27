import 'package:flutter/material.dart';

import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../content/questions.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/effects/pop_in.dart';
import '../../art/icons/kid_icon.dart';

/// How an answer looks right now.
enum AnswerLook { normal, selected, correct, wrong, faded }

AnswerLook answerLook({
  required String id,
  required String? selected,
  required bool checked,
  required String correctId,
}) {
  if (!checked) return id == selected ? AnswerLook.selected : AnswerLook.normal;
  if (id == correctId) return AnswerLook.correct;
  if (id == selected) return AnswerLook.wrong;
  return AnswerLook.faded;
}

(Color face, Color ledge, Color? ring) _colors(AnswerLook look) => switch (look) {
  AnswerLook.normal || AnswerLook.faded => (AppColors.card, AppColors.borderDeep, null),
  AnswerLook.selected => (AppColors.skyTint, AppColors.skyDark, AppColors.sky),
  AnswerLook.correct => (AppColors.leafTint, AppColors.leafDark, AppColors.leaf),
  AnswerLook.wrong => (AppColors.coralTint, AppColors.coralDark, AppColors.coral),
};

String _stateWord(AnswerLook look) => switch (look) {
  AnswerLook.selected => ', picked',
  AnswerLook.correct => ', right answer',
  AnswerLook.wrong => ', your answer',
  _ => '',
};

/// A–D list (multiple choice).
class ChoiceList extends StatelessWidget {
  const ChoiceList({
    super.key,
    required this.options,
    required this.selected,
    required this.checked,
    required this.correctId,
    required this.onPick,
  });

  final List<QuizOption> options;
  final String? selected;
  final bool checked;
  final String correctId;
  final ValueChanged<String> onPick;

  static const _letters = ['A', 'B', 'C', 'D'];
  static const _badges = [AppColors.sky, AppColors.coral, AppColors.grapeInk, AppColors.teal];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, o) in options.indexed) ...[
          Builder(
            builder: (context) {
              final look = answerLook(id: o.id, selected: selected, checked: checked, correctId: correctId);
              final (face, ledge, ring) = _colors(look);
              return PopIn(
                trigger: look == AnswerLook.correct,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: look == AnswerLook.faded ? 0.5 : 1,
                  child: ChunkyCard(
                    onTap: checked ? null : () => onPick(o.id),
                    semanticLabel: '${_letters[i]}. ${o.label}${_stateWord(look)}',
                    color: face,
                    ledgeColor: ledge,
                    outlineColor: ring,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapM, vertical: AppSizes.gapM),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _badges[i],
                            borderRadius: BorderRadius.circular(AppSizes.radiusS - 4),
                          ),
                          child: Text(
                            _letters[i],
                            style: AppText.heading.copyWith(
                              color: _badges[i] == AppColors.grapeInk ? AppColors.onGrape : AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.gapM),
                        Expanded(
                          child: Text(o.label, style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        if (look == AnswerLook.correct) const KidIconView(KidIcon.check, size: AppSizes.iconMedium),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.gapM),
        ],
      ],
    );
  }
}

/// 2 × 2 plant pictures (picture choice).
class PictureGrid extends StatelessWidget {
  const PictureGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.checked,
    required this.correctId,
    required this.onPick,
  });

  final List<QuizOption> options;
  final String? selected;
  final bool checked;
  final String correctId;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - AppSizes.gapM) / 2;
        return Wrap(
          spacing: AppSizes.gapM,
          runSpacing: AppSizes.gapM,
          children: [
            for (final o in options)
              SizedBox(
                width: w,
                child: Builder(
                  builder: (context) {
                    final look = answerLook(id: o.id, selected: selected, checked: checked, correctId: correctId);
                    final (face, ledge, ring) = _colors(look);
                    return PopIn(
                      trigger: look == AnswerLook.correct,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: look == AnswerLook.faded ? 0.5 : 1,
                        child: ChunkyCard(
                          onTap: checked ? null : () => onPick(o.id),
                          semanticLabel: '${o.label}${_stateWord(look)}',
                          color: face,
                          ledgeColor: ledge,
                          outlineColor: ring,
                          padding: const EdgeInsets.all(AppSizes.gapS),
                          child: Column(
                            children: [
                              SizedBox(
                                height: w * 0.62,
                                child: PlantView(plant: PlantCatalog.byId(o.plantId!)),
                              ),
                              const SizedBox(height: 4),
                              Text(o.label, style: AppText.heading.copyWith(fontSize: 18)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Tap the part on the big drawing (with part buttons too, for screen
/// readers and small fingers).
class TapPartAnswer extends StatelessWidget {
  const TapPartAnswer({
    super.key,
    required this.question,
    required this.selected,
    required this.checked,
    required this.onPick,
  });

  final Question question;
  final String? selected;
  final bool checked;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final plant = PlantCatalog.byId(question.plantId);
    PlantPart? picked;
    for (final p in PlantPart.values) {
      if (p.name == selected) picked = p;
    }
    final glow = checked ? question.part : picked;
    return Column(
      children: [
        PopIn(
          trigger: checked && selected == question.correctId,
          child: ChunkyCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
              child: SizedBox(
                height: 300,
                child: PlantView(
                  plant: plant,
                  mode: PlantMode.detail,
                  highlight: glow,
                  onPartTap: checked ? null : (p) => onPick(p.name),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.gapM),
        Wrap(
          spacing: AppSizes.gapS,
          runSpacing: AppSizes.gapS,
          alignment: WrapAlignment.center,
          children: [
            for (final p in PlantPart.values)
              ChunkyButton(
                label: Question.partLabel(p, plant.id),
                small: true,
                expand: false,
                tone: switch (answerLook(
                  id: p.name,
                  selected: selected,
                  checked: checked,
                  correctId: question.correctId,
                )) {
                  AnswerLook.selected => ButtonTone.sky,
                  AnswerLook.correct => ButtonTone.leaf,
                  AnswerLook.wrong => ButtonTone.coral,
                  _ => ButtonTone.white,
                },
                // Stays "enabled" after checking so it keeps its green/coral
                // color; taps are simply ignored then.
                onPressed: () {
                  if (!checked) onPick(p.name);
                },
              ),
          ],
        ),
      ],
    );
  }
}
