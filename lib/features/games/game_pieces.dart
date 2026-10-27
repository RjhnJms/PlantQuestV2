import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../art/binhi/binhi.dart';
import '../../game/rules.dart';
import '../../services/read_aloud.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/stat_pill.dart';
import '../../art/icons/kid_icon.dart';

/// The frame every mini-game sits in: Back, title, leaf counter, and the
/// "how to play" + "what you learn" lines.
class GameFrame extends ConsumerWidget {
  const GameFrame({super.key, required this.title, required this.howTo, required this.learns, required this.children});

  final String title;
  final String howTo;
  final String learns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, 0),
              child: Row(
                children: [
                  SquareIconButton.back(context),
                  const SizedBox(width: AppSizes.gapM),
                  Expanded(
                    // Long plant names get a smaller title so it never cuts off.
                    child: Text(title, style: title.length > 18 ? AppText.heading : AppText.title),
                  ),
                  LeafTarget(child: StatPill.leaves(value: ref.watch(leavesProvider).value)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapXl),
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(howTo, style: AppText.body.copyWith(fontSize: 16))),
                      SpeakerButton(text: howTo),
                    ],
                  ),
                  const SizedBox(height: AppSizes.gapXs),
                  Row(
                    children: [
                      const KidIconView(KidIcon.learn, size: AppSizes.iconSmall),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('You learn: $learns', style: AppText.bodySmall.copyWith(color: AppColors.grapeInk)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.gapM),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a hint or fact under the game and reads it aloud when
/// Settings → "Read questions to me" is on, so early readers hear it too.
mixin GameVoice<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String? hint;

  void say(String text) {
    setState(() => hint = text);
    if (ref.read(profileProvider).value?.autoRead ?? true) {
      ref.read(readAloudProvider).speak(text);
    }
  }
}

class GameHint extends StatelessWidget {
  const GameHint(this.text, {super.key});

  final String? text;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    child: text == null
        ? const SizedBox(height: 48)
        : ConstrainedBox(
            key: ValueKey(text),
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              children: [
                const KidIconView(KidIcon.idea, size: AppSizes.iconSmall),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(text!, style: AppText.label.copyWith(color: AppColors.text, fontSize: 15)),
                ),
                SpeakerButton(text: text!),
              ],
            ),
          ),
  );
}

/// "You did it!" Pays leaves the first time ([onWin] returns how many) and
/// sends them flying into the counter.
class GameDone extends ConsumerStatefulWidget {
  const GameDone({super.key, required this.text, required this.onWin, required this.onPlayAgain});

  final String text;

  /// Saves the win; returns the leaves earned (0 when already won before).
  final Future<int> Function() onWin;
  final VoidCallback onPlayAgain;

  @override
  ConsumerState<GameDone> createState() => _GameDoneState();
}

class _GameDoneState extends ConsumerState<GameDone> {
  final _card = GlobalKey();
  int? _earned;

  @override
  void initState() {
    super.initState();
    _win();
  }

  Future<void> _win() async {
    final before = ref.read(leavesEarnedProvider).value ?? 0;
    final got = await widget.onWin();
    if (!mounted) return;
    setState(() => _earned = got);
    final at = screenCenterOf(_card);
    final feel = ref.read(motionFeelProvider);
    if (at != null) ref.read(confettiProvider).burst(at, count: feel.confetti, seconds: feel.burstSeconds);
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (got > 0) await celebrateLeaves(context, ref, from: screenCenterOf(_card), earned: got, earnedBefore: before);
    if (mounted) await celebrateBadges(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final earned = _earned;
    final line = earned == null
        ? ''
        : earned > 0
        ? '+$earned ${earned == 1 ? 'leaf' : 'leaves'}!'
        : 'You already got leaves here. Great practice!';
    return ChunkyCard(
      key: _card,
      color: AppColors.leafTint,
      ledgeColor: AppColors.leaf,
      semanticLabel: 'You did it! ${widget.text} $line',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Binhi(
                stage: ref.watch(binhiStageProvider).value ?? BinhiStage.seed,
                outfit: ref.watch(binhiOutfitProvider),
                mood: BinhiMood.cheering,
                size: 70,
                reduceMotion: ref.watch(lessMotionProvider),
              ),
              const SizedBox(width: AppSizes.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('You did it!', style: AppText.title.copyWith(color: AppColors.leafDark)),
                    Text(widget.text, style: AppText.body.copyWith(fontSize: 16)),
                    if (line.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          line,
                          style: AppText.label.copyWith(
                            color: earned! > 0 ? AppColors.leafDark : AppColors.textMuted,
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.gapM),
          Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  label: 'PLAY AGAIN',
                  small: true,
                  tone: ButtonTone.white,
                  onPressed: widget.onPlayAgain,
                ),
              ),
              const SizedBox(width: AppSizes.gapS),
              Expanded(
                child: ChunkyButton(label: 'DONE', small: true, onPressed: () => goBackOrHome(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Leaves a game still pays for a plant, for the Play cards.
int gameLeavesLeft(Set<(MiniGame, String)> wins, MiniGame game, String plantId) =>
    wins.contains((game, plantId)) ? 0 : (game == MiniGame.match ? LeafRules.matched : LeafRules.miniGame);

/// The one card that opens a mini-game, showing the leaves it still pays
/// or a tick once won. [compact] (Plant page) drops the line under the title.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.title,
    this.line,
    required this.icon,
    required this.leavesLeft,
    required this.onTap,
    this.compact = false,
  });

  final String title;
  final String? line;
  final KidIcon icon;

  /// 0 once won.
  final int leavesLeft;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final reward = leavesLeft > 0 ? '+$leavesLeft ${leavesLeft == 1 ? 'leaf' : 'leaves'}' : 'Done!';
    return ChunkyCard(
      onTap: onTap,
      semanticLabel: [title, ?line, reward].join('. '),
      padding: EdgeInsets.all(compact ? AppSizes.gapS : AppSizes.gapM),
      child: Row(
        children: [
          KidIconView(icon, size: compact ? AppSizes.iconMedium : AppSizes.iconLarge),
          SizedBox(width: compact ? 6 : AppSizes.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: compact ? AppText.label.copyWith(color: AppColors.text, fontSize: 16) : AppText.heading,
                  ),
                ),
                if (line != null && !compact) Text(line!, style: AppText.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.gapS),
          if (leavesLeft > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.leafTint,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(compact ? '+$leavesLeft' : reward, style: AppText.label.copyWith(color: AppColors.leafDark)),
            )
          else
            KidIconView(KidIcon.check, size: compact ? AppSizes.iconSmall : AppSizes.iconMedium),
        ],
      ),
    );
  }
}
