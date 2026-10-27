import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../art/binhi/binhi.dart';
import '../art/plants/plant_drawing.dart';
import '../content/plant_catalog.dart';
import '../data/progress_repository.dart';
import '../game/rules.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/stat_pill.dart';

/// Developer-only page to try the saved game rules before the real
/// screens exist. Everything here is really saved on the device (or in the
/// browser for the preview) and survives a refresh.
class ProgressLab extends ConsumerStatefulWidget {
  const ProgressLab({super.key});

  @override
  ConsumerState<ProgressLab> createState() => _ProgressLabState();
}

class _ProgressLabState extends ConsumerState<ProgressLab> {
  String _last = 'Tap a button to play.';
  final _binhi = BinhiController();

  @override
  void dispose() {
    _binhi.dispose();
    super.dispose();
  }

  Future<void> _quiz(QuizKind kind, int correct, int total, {String? plantId}) async {
    final actions = ref.read(gameActionsProvider);
    final id = await actions.startQuiz(kind, plantId: plantId, total: total);
    for (var i = 0; i < total; i++) {
      actions.saveAnswer(id, 'q$i', chosen: 'a', correct: i < correct);
    }
    final QuizResult? r = await actions.finishQuiz(id);
    if (r == null) {
      setState(() => _last = 'Could not save this quiz (it would not count).');
      return;
    }
    if (r.leavesEarned > 0) _binhi.cheer();
    final name = plantId == null ? kind.name : PlantCatalog.byId(plantId).name;
    setState(
      () => _last =
          '$name quiz ${r.score}/${r.total}: +${r.leavesEarned} leaves'
          '${r.reward.isNewBest ? ' (new best!)' : ' (not a new best)'}'
          '${r.grew ? '. Binhi grew into ${r.stageAfter.label}!' : ''}',
    );
  }

  Future<void> _earn(String what, Future<int> Function() action) async {
    final got = await action();
    if (got > 0) _binhi.hop();
    setState(() => _last = '$what: +$got leaves');
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(gameActionsProvider);
    final profile = ref.watch(profileProvider).value;
    final leaves = ref.watch(leavesProvider).value ?? 0;
    final days = ref.watch(daysVisitedProvider).value ?? 0;
    final path = ref.watch(pathProvider).value ?? PathState.from({});
    final best = ref.watch(bestLevelScoreProvider).value;
    final current = path.currentId;
    final earned = ref.watch(leavesEarnedProvider).value ?? 0;
    final stage = BinhiStage.forLeaves(earned);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            const Text('Progress lab', style: AppText.display),
            const Text('Saved for real. Refresh the page: it stays.', style: AppText.bodySmall),
            const SizedBox(height: AppSizes.gapM),
            Row(
              children: [
                StatPill.days(value: days),
                const SizedBox(width: AppSizes.gapS),
                StatPill.leaves(value: leaves),
                const Spacer(),
                Text(best == null ? 'Best: –' : 'Best: ${best.$1}/${best.$2}', style: AppText.label),
              ],
            ),
            const SizedBox(height: AppSizes.gapM),
            ChunkyCard(
              child: Row(
                children: [
                  Binhi(stage: stage, size: 70, controller: _binhi, onTap: () {}),
                  const SizedBox(width: AppSizes.gapM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile == null || !profile.onboarded
                              ? 'No profile yet'
                              : '${profile.name} · Grade ${profile.grade}',
                          style: AppText.heading,
                        ),
                        Text(
                          stage.next == null
                              ? 'Binhi is ${stage.label}'
                              : 'Binhi is ${stage.label} · ${BinhiStage.leavesToGrow(earned)} leaves to grow',
                          style: AppText.bodySmall,
                        ),
                        const SizedBox(height: AppSizes.gapS),
                        AppProgressBar(value: BinhiStage.growthProgress(earned), height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.gapM),
            Container(
              padding: const EdgeInsets.all(AppSizes.gapM),
              decoration: BoxDecoration(
                color: AppColors.skyTint,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Text(_last, style: AppText.body),
            ),
            const SizedBox(height: AppSizes.gapL),
            ChunkyButton(
              label: 'SAVE PROFILE: JAMIE, GRADE 4',
              small: true,
              tone: ButtonTone.white,
              onPressed: () async {
                await actions.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_spiky');
                setState(() => _last = 'Profile saved.');
              },
            ),
            const SizedBox(height: AppSizes.gapS),
            if (current != null) ...[
              Text('Current stop: ${PlantCatalog.byId(current).name}', style: AppText.heading),
              const SizedBox(height: AppSizes.gapS),
              ChunkyButton(
                label: 'EXPLORE IT',
                small: true,
                tone: ButtonTone.sky,
                onPressed: () => _earn('Explore', () => actions.explorePlant(current)),
              ),
              const SizedBox(height: AppSizes.gapS),
              ChunkyButton(
                label: 'TAP ALL 4 PARTS',
                small: true,
                tone: ButtonTone.sky,
                onPressed: () => _earn('All parts', () async {
                  var got = 0;
                  for (final p in PlantPart.values) {
                    got += await actions.partFound(current, p);
                  }
                  return got;
                }),
              ),
              const SizedBox(height: AppSizes.gapS),
              Row(
                children: [
                  for (final score in [1, 2, 3]) ...[
                    Expanded(
                      child: ChunkyButton(
                        label: 'QUIZ $score/3',
                        small: true,
                        onPressed: () => _quiz(QuizKind.plant, score, 3, plantId: current),
                      ),
                    ),
                    if (score < 3) const SizedBox(width: AppSizes.gapS),
                  ],
                ],
              ),
            ] else
              const Text('All 15 plants done!', style: AppText.heading),
            const SizedBox(height: AppSizes.gapS),
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(
                    label: 'SPROUT 4/5',
                    small: true,
                    tone: ButtonTone.grape,
                    onPressed: () => _quiz(QuizKind.sprout, 4, 5),
                  ),
                ),
                const SizedBox(width: AppSizes.gapS),
                Expanded(
                  child: ChunkyButton(
                    label: 'SAPLING 10/10',
                    small: true,
                    tone: ButtonTone.grape,
                    onPressed: () => _quiz(QuizKind.sapling, 10, 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.gapS),
            ChunkyButton(
              label: 'START OVER',
              small: true,
              tone: ButtonTone.coral,
              onPressed: () async {
                await actions.startOver();
                setState(() => _last = 'Started over. Name and days visited were kept.');
              },
            ),
            const SizedBox(height: AppSizes.gapXl),
            const Text('Adventure path', style: AppText.heading),
            const SizedBox(height: AppSizes.gapS),
            for (final plant in PlantCatalog.all)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('${plant.order + 1}', style: AppText.label)),
                    Expanded(child: Text(plant.name, style: AppText.body)),
                    _stateChip(path.of(plant.id)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stateChip(StopState s) {
    final (label, color) = switch (s) {
      StopState.done => ('done', AppColors.sunshine),
      StopState.current => ('current', AppColors.leafLight),
      StopState.locked => ('locked', AppColors.track),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSizes.radiusPill)),
      child: Text(label, style: AppText.label.copyWith(color: AppColors.text)),
    );
  }
}
