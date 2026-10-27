import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/binhi/binhi.dart';
import '../../content/plant_catalog.dart';
import '../../data/progress_repository.dart';
import '../../game/rules.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/ticking_number.dart';
import '../../app/navigation.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 11: score, leaves earned, Binhi's growth and what to do next.
class ResultsView extends ConsumerWidget {
  const ResultsView({
    super.key,
    required this.result,
    required this.localScore,
    required this.total,
    required this.plantId,
    required this.unlockedNext,
    required this.onPlayAgain,
    this.review = false,
    this.leavesCardKey,
    this.growthKey,
  });

  /// From the database. Null if saving failed: then the score still shows.
  final Future<QuizResult?> result;
  final int localScore;
  final int total;
  final String? plantId;
  final bool unlockedNext;

  /// Null hides PLAY AGAIN (a review can't be replayed).
  final VoidCallback? onPlayAgain;

  /// A smart review, with its own words.
  final bool review;

  /// Where earned leaves fly from and to.
  final GlobalKey? leavesCardKey;
  final GlobalKey? growthKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileProvider).value?.name ?? 'Explorer';
    final earnedNow = ref.watch(leavesEarnedProvider).value ?? 0;
    final still = ref.watch(lessMotionProvider);
    final nextId = plantId == null ? null : PathState.nextAfter(plantId!);

    return Scaffold(
      backgroundColor: AppColors.leafTint,
      body: SafeArea(
        child: FutureBuilder<QuizResult?>(
          future: result,
          builder: (context, snap) {
            final r = snap.data;
            final saving = snap.connectionState != ConnectionState.done;
            final score = r?.score ?? localScore;
            final good = score * 2 >= total;
            final grown = r?.earnedAfter ?? earnedNow;
            final stage = BinhiStage.forLeaves(grown);
            final toGrow = BinhiStage.leavesToGrow(grown);
            final line = review
                ? (score == total
                      ? 'You remembered every one. All caught up!'
                      : 'Great practice! The ones you missed will come back next time.')
                : score == total
                ? 'Perfect score! Every answer was right.'
                : unlockedNext && nextId != null
                ? 'You unlocked the next plant on your adventure!'
                : good
                ? 'You know a lot about plants!'
                : 'Every try helps you learn. Play again!';

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapXl, AppSizes.gutter, AppSizes.gapL),
                    children: [
                      Center(
                        child: Binhi(
                          stage: stage,
                          outfit: ref.watch(binhiOutfitProvider),
                          size: 110,
                          reduceMotion: still,
                          mood: good ? BinhiMood.cheering : BinhiMood.encouraging,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(height: AppSizes.gapM),
                      Text(
                        good ? 'Great job, $name!' : 'Good try, $name!',
                        style: AppText.display.copyWith(fontSize: 30),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.gapS),
                      Text(
                        line,
                        style: AppText.body.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      if (r != null && r.grew) ...[
                        const SizedBox(height: AppSizes.gapL),
                        ChunkyCard(
                          color: AppColors.sunshine,
                          ledgeColor: AppColors.sunshineDark,
                          child: Text(
                            'Binhi grew into ${r.stageAfter.label}!',
                            style: AppText.heading,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSizes.gapXl),
                      Row(
                        children: [
                          Expanded(
                            child: ChunkyCard(
                              semanticLabel: 'Score: $score out of $total',
                              child: Column(
                                children: [
                                  Text('SCORE', style: AppText.label.copyWith(color: AppColors.text)),
                                  const SizedBox(height: 4),
                                  Text('$score/$total', style: AppText.display),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSizes.gapM),
                          Expanded(
                            key: leavesCardKey,
                            child: ChunkyCard(
                              color: AppColors.leaf,
                              ledgeColor: AppColors.leafDark,
                              semanticLabel: saving
                                  ? 'Saving leaves'
                                  : r == null
                                  ? 'Leaves could not be saved this time'
                                  : 'Leaves earned: ${r.leavesEarned}',
                              child: Column(
                                children: [
                                  Text('LEAVES', style: AppText.label.copyWith(color: AppColors.text)),
                                  const SizedBox(height: 4),
                                  if (saving || r == null)
                                    const Text('–', style: AppText.display)
                                  else
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const KidIconView(KidIcon.leaf, size: AppSizes.iconMedium),
                                        TickingNumber(value: r.leavesEarned, prefix: '+', style: AppText.display),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (r != null && r.leavesEarned == 0 && score > 0) ...[
                        const SizedBox(height: AppSizes.gapS),
                        const Text(
                          'Beat your best score to earn more leaves!',
                          style: AppText.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: AppSizes.gapL),
                      Text(
                        toGrow == 0 ? 'Binhi is in full bloom!' : 'Binhi is ${stage.label} · $toGrow leaves to grow',
                        style: AppText.label.copyWith(color: AppColors.text),
                      ),
                      const SizedBox(height: AppSizes.gapS),
                      AppProgressBar(
                        key: growthKey,
                        value: BinhiStage.growthProgress(grown),
                        semanticLabel: 'Binhi growth',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapS, AppSizes.gutter, AppSizes.gapL),
                  child: Column(
                    children: [
                      if (nextId != null)
                        ChunkyButton(
                          label: 'NEXT PLANT: ${PlantCatalog.byId(nextId).name.toUpperCase()}',
                          icon: KidIcon.arrow,
                          onPressed: saving ? null : () => context.pushReplacement('/plant/$nextId'),
                        ),
                      const SizedBox(height: AppSizes.gapM),
                      Row(
                        children: [
                          if (onPlayAgain != null) ...[
                            Expanded(
                              child: ChunkyButton(
                                label: 'PLAY AGAIN',
                                small: true,
                                tone: ButtonTone.white,
                                onPressed: saving ? null : onPlayAgain,
                              ),
                            ),
                            const SizedBox(width: AppSizes.gapM),
                          ],
                          Expanded(
                            child: ChunkyButton(
                              label: 'DONE',
                              small: true,
                              tone: ButtonTone.white,
                              onPressed: () => goBackOrHome(context),
                            ),
                          ),
                        ],
                      ),
                    ],
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
