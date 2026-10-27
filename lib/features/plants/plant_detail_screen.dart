import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../content/plant_content.dart';
import '../games/game_pieces.dart';
import '../../game/colouring.dart';
import '../../game/rules.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/speakable_text.dart';
import '../../widgets/stat_pill.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 7 (docs/screens/07-plant-details.jpg), tidied in the Oct 2026
/// layout pass (PLAN.md D13): one card to learn (plant, parts, what each
/// part does), one "Did you know?" line, and everything to do (the two
/// games and START QUIZ) together at the bottom.
class PlantDetailScreen extends ConsumerStatefulWidget {
  const PlantDetailScreen({super.key, required this.plantId});

  final String plantId;

  @override
  ConsumerState<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends ConsumerState<PlantDetailScreen> {
  PlantPart? _part;

  /// Part picks (from the plant or the part buttons); each makes the plant react.
  int _touches = 0;
  String? _reward;
  Timer? _rewardTimer;
  bool _explored = false;
  final _plantKey = GlobalKey();

  PlantInfo get plant => PlantCatalog.byId(widget.plantId);
  PlantContent get content => PlantContent.of(widget.plantId);

  @override
  void dispose() {
    _rewardTimer?.cancel();
    super.dispose();
  }

  /// First visit to an unlocked plant: +5 leaves.
  Future<void> _explore() async {
    _explored = true;
    final before = ref.read(leavesEarnedProvider).value ?? 0;
    final got = await ref.read(gameActionsProvider).explorePlant(widget.plantId);
    if (got > 0) _giveLeaves(got, before, '+$got leaves for exploring!');
  }

  Future<void> _tapPart(PlantPart part) async {
    setState(() {
      _part = part;
      _touches++;
    });
    final before = ref.read(leavesEarnedProvider).value ?? 0;
    final got = await ref.read(gameActionsProvider).partFound(widget.plantId, part);
    if (got > 0) {
      final feel = ref.read(motionFeelProvider);
      final at = screenCenterOf(_plantKey);
      if (at != null) ref.read(confettiProvider).burst(at, count: feel.confetti ~/ 2, seconds: feel.burstSeconds);
      _giveLeaves(got, before, '+$got leaves! You found every part!');
    }
  }

  /// Shows the message and sends the leaves flying from the plant into the
  /// leaf counter (and on to Binhi's celebration if he grows).
  Future<void> _giveLeaves(int got, int before, String text) async {
    _celebrate(text);
    if (!mounted) return;
    await celebrateLeaves(context, ref, from: screenCenterOf(_plantKey), earned: got, earnedBefore: before);
    // Finding every part can complete Part Finder or Plant Expert.
    if (mounted) await celebrateBadges(context, ref);
  }

  void _celebrate(String text) {
    if (!mounted) return;
    _rewardTimer?.cancel();
    setState(() => _reward = text);
    _rewardTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _reward = null);
    });
  }

  String _partLabel(PlantPart p) => switch (p) {
    PlantPart.root => 'Root',
    PlantPart.stem => 'Stem',
    PlantPart.leaf => 'Leaf',
    PlantPart.special => plant.special.label,
  };

  static int _bit(PlantPart p) => switch (p) {
    PlantPart.root => PartBits.root,
    PlantPart.stem => PartBits.stem,
    PlantPart.leaf => PartBits.leaf,
    PlantPart.special => PartBits.special,
  };

  @override
  Widget build(BuildContext context) {
    final pathAsync = ref.watch(pathProvider);
    final path = pathAsync.value;
    if (path == null) return const Scaffold(body: SizedBox.shrink());

    if (!path.isUnlocked(widget.plantId)) return _LockedPlant(plant: plant);
    if (!_explored) WidgetsBinding.instance.addPostFrameCallback((_) => _explore());

    final row = ref.watch(plantProgressProvider).value?[widget.plantId];
    final wins = ref.watch(gameWinsProvider).value ?? const <(MiniGame, String)>{};
    final hungPicture = (ref.watch(colouringsProvider).value ?? const []).any(
      (c) => c.plantId == widget.plantId && c.hung,
    );
    final found = row?.partsFound ?? 0;

    return Scaffold(
      backgroundColor: plant.tileColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapL),
                children: [
                  Row(
                    children: [
                      SquareIconButton.back(context),
                      const SizedBox(width: AppSizes.gapM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plant.name, style: AppText.title),
                            Text(
                              plant.scientificName,
                              style: AppText.bodySmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.text),
                            ),
                          ],
                        ),
                      ),
                      LeafTarget(child: StatPill.leaves(value: ref.watch(leavesProvider).value)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.gapM),
                  // Learn: the plant, its parts and what they do, in one card.
                  ChunkyCard(
                    padding: const EdgeInsets.all(AppSizes.gapM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SpeakableText(content.description, style: AppText.body.copyWith(fontSize: 17)),
                            ),
                            SpeakerButton(text: content.description),
                          ],
                        ),
                        const SizedBox(height: AppSizes.gapS),
                        Align(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapM, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.grapeTint,
                              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                            ),
                            child: Text(
                              found == PartBits.all
                                  ? 'You found all 4 parts!'
                                  : 'Tap the parts! ${PartBits.count(found)}/4 found',
                              style: AppText.label.copyWith(color: AppColors.grapeInk),
                            ),
                          ),
                        ),
                        // Capped so the part buttons and what they do stay
                        // in view on a phone.
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.36),
                            child: KeyedSubtree(
                              key: _plantKey,
                              child: PlantView(
                                plant: plant,
                                mode: PlantMode.detail,
                                highlight: _part,
                                onPartTap: _tapPart,
                                // Touching the plant makes it react (a
                                // makahiya folds its leaves).
                                react: true,
                                touches: _touches,
                                reduceMotion: ref.watch(lessMotionProvider),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.gapS),
                        Row(
                          children: [
                            for (final (i, p) in PlantPart.values.indexed) ...[
                              if (i > 0) const SizedBox(width: 6),
                              Expanded(
                                child: _PartButton(
                                  label: _partLabel(p),
                                  found: found & _bit(p) != 0,
                                  picked: p == _part,
                                  onTap: () => _tapPart(p),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSizes.gapM),
                        _PartInfo(part: _part, label: _part == null ? null : _partLabel(_part!), content: content),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.gapM),
                  _DidYouKnow(text: content.funFact),
                ],
              ),
            ),
            // Do: everything to play sits together at the bottom. The
            // "+5 leaves" message gets its own slot here too, so it never
            // covers the plant.
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(a), child: child),
                ),
                child: _reward == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        key: ValueKey(_reward),
                        padding: const EdgeInsets.only(top: AppSizes.gapS),
                        child: _RewardChip(text: _reward!),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapS, AppSizes.gutter, AppSizes.gapL),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GameCard(
                          compact: true,
                          title: 'Label it',
                          icon: KidIcon.label,
                          leavesLeft: gameLeavesLeft(wins, MiniGame.label, plant.id),
                          onTap: () => context.push('/plant/${plant.id}/label'),
                        ),
                      ),
                      const SizedBox(width: AppSizes.gapS),
                      Expanded(
                        child: GameCard(
                          compact: true,
                          title: 'Grow it',
                          icon: KidIcon.grow,
                          leavesLeft: gameLeavesLeft(wins, MiniGame.grow, plant.id),
                          onTap: () => context.push('/plant/${plant.id}/grow'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.gapS),
                  GameCard(
                    compact: true,
                    title: 'Colour it',
                    icon: KidIcon.crayon,
                    leavesLeft: hungPicture ? 0 : ColouringRules.leaves,
                    onTap: () => context.push('/plant/${plant.id}/colour'),
                  ),
                  const SizedBox(height: AppSizes.gapS),
                  ChunkyButton(
                    label: 'START QUIZ',
                    icon: KidIcon.quiz,
                    onPressed: () => context.push('/quiz/plant/${widget.plantId}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the four part buttons under the plant (a tick once found).
class _PartButton extends StatelessWidget {
  const _PartButton({required this.label, required this.found, required this.picked, required this.onTap});

  final String label;
  final bool found;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChunkyButton(
    label: label,
    icon: found ? KidIcon.tick : null,
    small: true,
    tone: picked ? ButtonTone.grape : ButtonTone.white,
    onPressed: onTap,
  );
}

/// What the picked part does, inside the plant card.
class _PartInfo extends StatelessWidget {
  const _PartInfo({required this.part, required this.label, required this.content});

  final PlantPart? part;
  final String? label;
  final PlantContent content;

  @override
  Widget build(BuildContext context) {
    if (part == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KidIconView(KidIcon.tap, size: AppSizes.iconSmall),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Tap a part of the plant to learn about it.',
              style: AppText.label.copyWith(color: AppColors.grapeInk, fontSize: 15),
            ),
          ),
        ],
      );
    }
    final text = content.parts[part]!;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.gapM, AppSizes.gapS, 4, AppSizes.gapS),
      decoration: BoxDecoration(color: AppColors.grapeTint, borderRadius: BorderRadius.circular(AppSizes.radiusS)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label!, style: AppText.heading.copyWith(color: AppColors.grapeDark, fontSize: 18)),
                SpeakableText(text, style: AppText.body.copyWith(fontSize: 16)),
              ],
            ),
          ),
          SpeakerButton(text: '$label. $text'),
        ],
      ),
    );
  }
}

/// The fun fact as one quiet line under the card.
class _DidYouKnow extends StatelessWidget {
  const _DidYouKnow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const KidIconView(KidIcon.idea, size: AppSizes.iconMedium),
      const SizedBox(width: AppSizes.gapS),
      Expanded(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Did you know? ',
                style: AppText.label.copyWith(color: AppColors.text, fontSize: 16),
              ),
              TextSpan(text: text),
            ],
          ),
          style: AppText.body.copyWith(fontSize: 16),
        ),
      ),
      SpeakerButton(text: 'Did you know? $text'),
    ],
  );
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapL, vertical: AppSizes.gapS),
        decoration: BoxDecoration(
          color: AppColors.sunshine,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          boxShadow: const [BoxShadow(color: AppColors.sunshineDark, offset: Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KidIconView(KidIcon.leaf, size: AppSizes.iconMedium),
            const SizedBox(width: AppSizes.gapS),
            Flexible(child: Text(text, style: AppText.heading.copyWith(fontSize: 17))),
          ],
        ),
      ),
    );
  }
}

class _LockedPlant extends StatelessWidget {
  const _LockedPlant({required this.plant});

  final PlantInfo plant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SquareIconButton.back(context),
              const Spacer(),
              Center(
                child: SizedBox(width: 200, child: PlantView(plant: plant, locked: true)),
              ),
              const SizedBox(height: AppSizes.gapL),
              const Center(child: Text('This plant is still a mystery!', style: AppText.title)),
              const SizedBox(height: AppSizes.gapS),
              const Center(child: Text('Finish the plant before it to unlock.', style: AppText.body)),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
