import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/avatars/animal_avatar.dart';
import '../../art/icons/kid_icon.dart';
import '../../game/badges.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/badge_medal.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/round_buttons.dart';

/// All 12 badges (PLAN.md §5c): earned ones first, then the closest to done.
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = ref.watch(badgeFactsProvider);
    final claimed = ref.watch(badgesProvider).value ?? const <Achievement>{};
    final animals = ref.watch(animalsUnlockedProvider);
    double share(Achievement b) {
      final (d, g) = b.progress(facts);
      return d / g;
    }

    final earned = Achievement.values.where(claimed.contains).toList();
    final rest = Achievement.values.where((b) => !claimed.contains(b)).toList()
      ..sort((a, b) => share(b).compareTo(share(a)));

    Widget grid(List<Achievement> badges) => LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - AppSizes.gapM) / 2;
        return Wrap(
          spacing: AppSizes.gapM,
          runSpacing: AppSizes.gapM,
          children: [
            for (final b in badges)
              SizedBox(
                width: w,
                child: _BadgeTile(badge: b, progress: b.progress(facts), earned: claimed.contains(b)),
              ),
          ],
        );
      },
    );

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
                  const Flexible(child: Text('Badges', style: AppText.title)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXl),
                children: [
                  ChunkyCard(
                    padding: const EdgeInsets.all(AppSizes.gapM),
                    semanticLabel:
                        '${earned.length} of ${Achievement.values.length} badges. ${animals.length} of 6 animal friends.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${earned.length} of ${Achievement.values.length} badges', style: AppText.heading),
                        const SizedBox(height: AppSizes.gapS),
                        AppProgressBar(
                          value: earned.length / Achievement.values.length,
                          height: 14,
                          semanticLabel: 'Badges',
                        ),
                        const SizedBox(height: AppSizes.gapM),
                        const Text('Animal friends to unlock', style: AppText.label),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final a in AnimalAvatar.values)
                              Opacity(opacity: animals.contains(a) ? 1 : 0.35, child: AnimalAvatarView(a, size: 44)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (earned.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.gapXl),
                    const Text('Earned', style: AppText.heading),
                    const SizedBox(height: AppSizes.gapS),
                    grid(earned),
                  ],
                  if (rest.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.gapXl),
                    const Text('Keep going!', style: AppText.heading),
                    const SizedBox(height: AppSizes.gapS),
                    grid(rest),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What a badge gives: an animal friend or some leaves.
class BadgeReward extends StatelessWidget {
  const BadgeReward(this.badge, {super.key});

  final Achievement badge;

  @override
  Widget build(BuildContext context) {
    final animal = badge.animal;
    if (animal != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimalAvatarView(animal, size: 26),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              animal.label,
              style: AppText.label.copyWith(color: AppColors.grapeDark, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const KidIconView(KidIcon.leaf, size: 18),
        const SizedBox(width: 2),
        Text('+${badge.leaves}', style: AppText.label.copyWith(color: AppColors.leafDark, fontSize: 13)),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.progress, required this.earned});

  final Achievement badge;
  final (int, int) progress;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final (done, goal) = progress;
    final state = earned ? BadgeState.earned : (done > 0 ? BadgeState.inProgress : BadgeState.locked);
    final reward = badge.animal?.label ?? '${badge.leaves} leaves';
    return ChunkyCard(
      color: earned ? AppColors.card : AppColors.background,
      padding: const EdgeInsets.all(AppSizes.gapS),
      semanticLabel: earned
          ? '${badge.title}. Earned. $reward.'
          : '${badge.title}. ${badge.how}. $done of $goal. Reward: $reward.',
      child: Column(
        children: [
          BadgeMedal(icon: badge.icon, color: badge.color, state: state, size: 72),
          Text(
            badge.title,
            style: AppText.label.copyWith(color: earned ? AppColors.text : AppColors.textMuted, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          Text(badge.how, style: AppText.bodySmall.copyWith(fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          if (!earned && goal > 1) ...[
            AppProgressBar(value: done / goal, height: 8, semanticLabel: 'Progress'),
            Text('$done of $goal', style: AppText.label.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badge.animal != null ? AppColors.grapeTint : AppColors.leafTint,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (earned) ...[const KidIconView(KidIcon.tick, size: 16), const SizedBox(width: 2)],
                Flexible(child: BadgeReward(badge)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The Badges card on Profile.
class BadgesCard extends ConsumerWidget {
  const BadgesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimed = ref.watch(badgesProvider).value ?? const <Achievement>{};
    final animals = ref.watch(animalsUnlockedProvider);
    final shown = Achievement.values.where(claimed.contains).toList().reversed.take(4).toList();
    return ChunkyCard(
      color: AppColors.sunshineTint,
      ledgeColor: AppColors.sunshine,
      padding: const EdgeInsets.all(AppSizes.gapM),
      onTap: () => context.push('/profile/badges'),
      semanticLabel: 'Badges. ${claimed.length} of ${Achievement.values.length}. Open.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('BADGES', style: AppText.label.copyWith(color: const Color(0xFF8A5A00))),
              const Spacer(),
              Text('${claimed.length} of ${Achievement.values.length}', style: AppText.heading),
              const KidIconView(KidIcon.next, size: AppSizes.iconSmall),
            ],
          ),
          const SizedBox(height: AppSizes.gapS),
          if (shown.isEmpty)
            const Text('Finish your first plant to get a badge!', style: AppText.bodySmall)
          else
            Row(
              children: [
                for (final b in shown) ...[
                  BadgeMedal(icon: b.icon, color: b.color, size: 58),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          const SizedBox(height: AppSizes.gapS),
          Row(
            children: [
              for (final a in animals.take(3)) ...[AnimalAvatarView(a, size: 30), const SizedBox(width: 4)],
              if (animals.isEmpty) const KidIconView(KidIcon.lock, size: AppSizes.iconSmall, muted: true),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Animal friends: ${animals.length} of ${AnimalAvatar.values.length} unlocked',
                  style: AppText.label.copyWith(color: AppColors.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
