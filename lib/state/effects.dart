import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../art/avatars/animal_avatar.dart';
import '../art/binhi/binhi_stage.dart';
import '../art/icons/kid_icon.dart';
import '../content/plant_catalog.dart';
import '../services/sound_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/effects/confetti.dart';
import '../widgets/effects/flying_leaves.dart';
import '../widgets/effects/grow_celebration.dart';
import '../widgets/badge_medal.dart';
import '../widgets/effects/motion_feel.dart';
import '../widgets/effects/reward_moment.dart';
import '../widgets/rewards/reward_pieces.dart';
import 'providers.dart';
import 'settings.dart';

// App-wide reward effects (PLAN.md §9). The confetti and flying-leaf layers
// sit above every screen (see main.dart), so positions are screen
// coordinates.

final confettiProvider = Provider<ConfettiController>((ref) {
  final c = ConfettiController();
  ref.onDispose(c.dispose);
  return c;
});

final flyingLeavesProvider = Provider<FlyingLeavesController>((ref) {
  final c = FlyingLeavesController();
  ref.onDispose(c.dispose);
  return c;
});

/// Bouncy (PLAN.md D10), or Gentle with the "less motion" setting.
final motionFeelProvider = Provider<MotionFeel>(
  (ref) => ref.watch(lessMotionProvider) ? MotionFeel.gentle : MotionFeel.bouncy,
);

/// Marks the leaf counter that flying leaves should land in. The most
/// recently shown one wins (e.g. Plant details over Home).
class LeafTarget extends StatefulWidget {
  const LeafTarget({super.key, required this.child});

  final Widget child;

  static final _mounted = <_LeafTargetState>[];

  /// Screen position of the current leaf counter, if any is showing.
  static Offset? position() {
    for (final t in _mounted.reversed) {
      final box = t.context.findRenderObject();
      if (box is RenderBox && box.hasSize && box.attached && TickerMode.valuesOf(t.context).enabled) {
        return box.localToGlobal(box.size.center(Offset.zero));
      }
    }
    return null;
  }

  @override
  State<LeafTarget> createState() => _LeafTargetState();
}

class _LeafTargetState extends State<LeafTarget> {
  @override
  void initState() {
    super.initState();
    LeafTarget._mounted.add(this);
  }

  @override
  void dispose() {
    LeafTarget._mounted.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Centre of a widget on screen (for effect start and end points).
Offset? screenCenterOf(GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.hasSize || !box.attached) return null;
  return box.localToGlobal(box.size.center(Offset.zero));
}

/// The full "you earned leaves" moment: leaves fly from [from] into the
/// leaf counter (or [to]) with a soft leaf sound as they land; if those
/// leaves made Binhi grow, the full-screen celebration follows.
Future<void> celebrateLeaves(
  BuildContext context,
  WidgetRef ref, {
  required Offset? from,
  required int earned,
  required int earnedBefore,
  Offset? to,
}) async {
  if (earned <= 0) return;
  final feel = ref.read(motionFeelProvider);
  final sound = ref.read(soundServiceProvider);
  final target = to ?? LeafTarget.position();
  final size = MediaQuery.sizeOf(context);
  final start = from ?? Offset(size.width / 2, size.height / 2);
  final end = target ?? Offset(size.width - 48, 64);

  final landed = Completer<void>();
  var count = 0;
  ref
      .read(flyingLeavesProvider)
      .fly(
        from: start,
        to: end,
        count: feel.leaves,
        onEachArrive: () {
          count++;
          if (count.isOdd) sound.play(Sfx.leaf);
          HapticFeedback.selectionClick();
          if (count == feel.leaves && !landed.isCompleted) landed.complete();
        },
      );
  await landed.future.timeout(const Duration(seconds: 3), onTimeout: () {});

  final before = BinhiStage.forLeaves(earnedBefore);
  final after = BinhiStage.forLeaves(earnedBefore + earned);
  if (after.index > before.index && context.mounted) {
    await showGrowCelebration(
      context,
      stage: after,
      outfit: ref.read(binhiOutfitProvider),
      feel: feel,
      reduceMotion: ref.read(lessMotionProvider),
      onShown: () {
        sound.play(Sfx.levelUp);
        HapticFeedback.heavyImpact();
      },
    );
  }
}

/// After a plant quiz's first finish: "You got a sticker!"
Future<void> celebrateSticker(BuildContext context, WidgetRef ref, String plantId) async {
  if (!context.mounted) return;
  final plant = PlantCatalog.byId(plantId);
  await showRewardMoment(
    context,
    title: 'You got a sticker!',
    art: StickerBadge(plant: plant, size: 140, tilt: -0.05),
    message: 'The ${plant.name} sticker went into your sticker book.',
    reduceMotion: ref.read(lessMotionProvider),
    onShown: () => cheerReward(context, ref),
  );
}

bool _badgesShowing = false;

/// Claims badges the child has just earned and shows "You got a badge!"
/// for each (PLAN.md §5c). Called at the end of other celebrations, so it
/// never interrupts them. An animal friend can be put on right away.
Future<void> celebrateBadges(BuildContext context, WidgetRef ref) async {
  if (_badgesShowing || !ref.read(badgesEnabledProvider)) return;
  _badgesShowing = true;
  try {
    final fresh = await ref.read(gameActionsProvider).claimNewBadges();
    for (final b in fresh) {
      if (!context.mounted) return;
      final animal = b.animal;
      final use = await showRewardMoment(
        context,
        title: 'You got a badge!',
        art: BadgeMedal(icon: b.icon, color: b.color, size: 120),
        message: '${b.title}\n${b.cheer}',
        color: AppColors.sunshineDark,
        titleColor: const Color(0xFF8A5A00),
        buttonLabel: animal == null ? 'YAY!' : 'USE IT',
        secondLabel: animal == null ? null : 'Later',
        reduceMotion: ref.read(lessMotionProvider),
        onShown: () => cheerReward(context, ref),
        extra: Container(
          padding: const EdgeInsets.all(AppSizes.gapM),
          decoration: BoxDecoration(
            color: animal == null ? AppColors.leafTint : AppColors.grapeTint,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: animal == null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const KidIconView(KidIcon.leaf),
                    const SizedBox(width: 6),
                    Text('+${b.leaves} leaves', style: AppText.title.copyWith(color: AppColors.leafDark, fontSize: 22)),
                  ],
                )
              : Row(
                  children: [
                    AnimalAvatarView(animal, size: 72),
                    const SizedBox(width: AppSizes.gapM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NEW FRIEND!', style: AppText.label.copyWith(color: AppColors.grapeDark)),
                          Text(animal.label, style: AppText.title.copyWith(fontSize: 22)),
                          const Text('Now you can pick it as your look.', style: AppText.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      );
      if (use && animal != null) await ref.read(gameActionsProvider).setAvatar(AnimalIds.of(animal));
    }
  } finally {
    _badgesShowing = false;
  }
}

/// Sound, buzz and confetti for a reward card.
void cheerReward(BuildContext context, WidgetRef ref) {
  final feel = ref.read(motionFeelProvider);
  ref.read(soundServiceProvider).play(Sfx.levelUp);
  HapticFeedback.mediumImpact();
  final size = MediaQuery.sizeOf(context);
  ref.read(confettiProvider).burst(Offset(size.width / 2, size.height * 0.35), count: feel.confetti);
}

/// A right answer: wooden "correct" sound, a firm buzz and a confetti burst
/// (sparkles with less motion).
void celebrateCorrect(WidgetRef ref, Offset? at) {
  final feel = ref.read(motionFeelProvider);
  ref.read(soundServiceProvider).play(Sfx.correct);
  HapticFeedback.mediumImpact();
  if (at != null) ref.read(confettiProvider).burst(at, count: feel.confetti, seconds: feel.burstSeconds);
}

/// A gentle "try again": soft sound, light buzz, no confetti.
void comfortWrong(WidgetRef ref) {
  ref.read(soundServiceProvider).play(Sfx.tryAgain);
  HapticFeedback.lightImpact();
}
