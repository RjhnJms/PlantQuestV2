import 'package:flutter/material.dart';

import '../art/avatars/animal_avatar.dart';
import '../art/avatars/avatar_view.dart';
import '../art/binhi/binhi.dart';
import '../art/icons/kid_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/badge_medal.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/round_buttons.dart';

// Achievements idea, as still mock-ups (nothing saves). Rendered by
// tool/render_badges_test.dart. The sample child has 4 badges.

class _Badge {
  const _Badge(this.title, this.how, this.icon, this.color, {this.leaves, this.animal, this.done = 0, this.goal = 1});

  final String title;
  final String how;
  final KidIcon icon;
  final Color color;
  final int? leaves;
  final AnimalAvatar? animal;
  final int done;
  final int goal;

  BadgeState get state => done >= goal ? BadgeState.earned : (done > 0 ? BadgeState.inProgress : BadgeState.locked);
}

const _badges = [
  _Badge('First Sprout', 'Finish your first plant', KidIcon.grow, AppColors.leaf, leaves: 5, done: 1),
  _Badge('Part Finder', 'Find all parts on 5 plants', KidIcon.tap, AppColors.grape, leaves: 10, done: 5, goal: 5),
  _Badge(
    'Backyard Explorer',
    'Finish World 1',
    KidIcon.home,
    AppColors.bubblegum,
    animal: AnimalAvatar.tarsier,
    done: 5,
    goal: 5,
  ),
  _Badge('Quiz Star', 'Get 4 of 5 on a level quiz', KidIcon.trophy, AppColors.sunshine, leaves: 10, done: 1),
  _Badge(
    'Sharp Eye',
    'Get 5 perfect plant quizzes',
    KidIcon.check,
    AppColors.sky,
    animal: AnimalAvatar.eagle,
    done: 3,
    goal: 5,
  ),
  _Badge(
    'Explorer Week',
    'Visit on 7 days (any days)',
    KidIcon.sun,
    AppColors.coral,
    animal: AnimalAvatar.pawikan,
    done: 3,
    goal: 7,
  ),
  _Badge('Sticker Collector', 'Get 10 stickers', KidIcon.sparkle, AppColors.bubblegum, leaves: 10, done: 6, goal: 10),
  _Badge(
    'Farm Explorer',
    'Finish World 2',
    KidIcon.rice,
    AppColors.sunshine,
    animal: AnimalAvatar.carabao,
    done: 1,
    goal: 5,
  ),
  _Badge(
    'Game Master',
    'Win Label it and Grow it for 5 plants',
    KidIcon.label,
    AppColors.sky,
    leaves: 15,
    done: 2,
    goal: 5,
  ),
  _Badge('Matchmaker', 'Match all 15 plants', KidIcon.match, AppColors.coral, leaves: 15, done: 4, goal: 15),
  _Badge('Nature Explorer', 'Finish World 3', KidIcon.tree, AppColors.teal, animal: AnimalAvatar.pilandok, goal: 5),
  _Badge(
    'Plant Expert',
    'Learn all 15 plants',
    KidIcon.plants,
    AppColors.grape,
    animal: AnimalAvatar.butanding,
    done: 6,
    goal: 15,
  ),
];

Widget _reward(_Badge b, {bool big = false}) {
  if (b.animal != null) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimalAvatarView(b.animal!, size: big ? 40 : 26),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            b.animal!.label,
            style: AppText.label.copyWith(color: AppColors.grapeDark, fontSize: big ? 15 : 12),
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
      KidIconView(KidIcon.leaf, size: big ? AppSizes.iconMedium : 18),
      const SizedBox(width: 2),
      Text(
        '+${b.leaves}',
        style: AppText.label.copyWith(color: AppColors.leafDark, fontSize: big ? 16 : 13),
      ),
    ],
  );
}

// ------------------------------------------------------------- Profile

/// The Badges card on Profile, under the Binhi and Sticker book tiles.
class BadgesProfileMock extends StatelessWidget {
  const BadgesProfileMock({super.key});

  @override
  Widget build(BuildContext context) {
    final earned = _badges.where((b) => b.state == BadgeState.earned).toList();
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSizes.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChunkyCard(
            padding: const EdgeInsets.all(AppSizes.gapM),
            child: Row(
              children: [
                const AvatarView(avatarId: 'girl_sprout', size: 76),
                const SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Maria', style: AppText.title),
                      const Text('Grade 3 · Joined Oct 2026', style: AppText.bodySmall),
                      const SizedBox(height: AppSizes.gapS),
                      ChunkyButton(
                        label: 'EDIT PROFILE',
                        icon: KidIcon.edit,
                        small: true,
                        expand: false,
                        tone: ButtonTone.white,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gapM),
          // The new card.
          ChunkyCard(
            color: AppColors.sunshineTint,
            ledgeColor: AppColors.sunshine,
            padding: const EdgeInsets.all(AppSizes.gapM),
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('BADGES', style: AppText.label.copyWith(color: const Color(0xFF8A5A00))),
                    const Spacer(),
                    Text('${earned.length} of ${_badges.length}', style: AppText.heading),
                    const KidIconView(KidIcon.next, size: AppSizes.iconSmall),
                  ],
                ),
                const SizedBox(height: AppSizes.gapS),
                Row(
                  children: [
                    for (final b in earned) ...[
                      BadgeMedal(icon: b.icon, color: b.color, size: 58),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.gapS),
                Row(
                  children: [
                    const AnimalAvatarView(AnimalAvatar.tarsier, size: 30),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Animal friends: 1 of 6 unlocked',
                        style: AppText.label.copyWith(color: AppColors.text),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gapM),
          Row(
            children: [
              Expanded(
                child: ChunkyCard(
                  color: AppColors.leafTint,
                  ledgeColor: AppColors.leaf,
                  padding: const EdgeInsets.all(AppSizes.gapM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR BINHI', style: AppText.label.copyWith(color: AppColors.leafDark)),
                      const Center(child: Binhi(stage: BinhiStage.sapling, size: 56, reduceMotion: true)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.gapM),
              Expanded(
                child: ChunkyCard(
                  padding: const EdgeInsets.all(AppSizes.gapM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STICKER BOOK', style: AppText.label.copyWith(color: AppColors.coralDark)),
                      const SizedBox(height: AppSizes.gapS),
                      const Text('6 of 15', style: AppText.title),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- Badge page

class BadgesPageMock extends StatelessWidget {
  const BadgesPageMock({super.key});

  @override
  Widget build(BuildContext context) {
    final earned = _badges.where((b) => b.state == BadgeState.earned).toList();
    final rest = _badges.where((b) => b.state != BadgeState.earned).toList()
      ..sort((a, b) => (b.done / b.goal).compareTo(a.done / a.goal));
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSizes.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SquareIconButton.back(context),
              const SizedBox(width: AppSizes.gapM),
              const Expanded(child: Text('Badges', style: AppText.title)),
            ],
          ),
          const SizedBox(height: AppSizes.gapM),
          ChunkyCard(
            padding: const EdgeInsets.all(AppSizes.gapM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${earned.length} of ${_badges.length} badges', style: AppText.heading),
                const SizedBox(height: AppSizes.gapS),
                AppProgressBar(value: earned.length / _badges.length, height: 14, semanticLabel: 'Badges'),
                const SizedBox(height: AppSizes.gapM),
                const Text('Animal friends to unlock', style: AppText.label),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final a in AnimalAvatar.values)
                      Opacity(opacity: a == AnimalAvatar.tarsier ? 1 : 0.35, child: AnimalAvatarView(a, size: 44)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gapXl),
          const Text('Earned', style: AppText.heading),
          const SizedBox(height: AppSizes.gapS),
          _grid(earned),
          const SizedBox(height: AppSizes.gapXl),
          const Text('Keep going!', style: AppText.heading),
          const SizedBox(height: AppSizes.gapS),
          _grid(rest),
        ],
      ),
    );
  }

  Widget _grid(List<_Badge> badges) => LayoutBuilder(
    builder: (context, c) {
      final w = (c.maxWidth - AppSizes.gapM) / 2;
      return Wrap(
        spacing: AppSizes.gapM,
        runSpacing: AppSizes.gapM,
        children: [for (final b in badges) SizedBox(width: w, child: _BadgeTile(b))],
      );
    },
  );
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile(this.b);

  final _Badge b;

  @override
  Widget build(BuildContext context) {
    final earned = b.state == BadgeState.earned;
    return ChunkyCard(
      color: earned ? AppColors.card : AppColors.background,
      padding: const EdgeInsets.all(AppSizes.gapS),
      child: Column(
        children: [
          BadgeMedal(icon: b.icon, color: b.color, state: b.state, size: 72),
          Text(
            b.title,
            style: AppText.label.copyWith(color: earned ? AppColors.text : AppColors.textMuted, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          Text(b.how, style: AppText.bodySmall.copyWith(fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          if (!earned && b.goal > 1) ...[
            AppProgressBar(value: b.done / b.goal, height: 8, semanticLabel: 'Progress'),
            Text('${b.done} of ${b.goal}', style: AppText.label.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: b.animal != null ? AppColors.grapeTint : AppColors.leafTint,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: earned
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const KidIconView(KidIcon.tick, size: 16),
                      const SizedBox(width: 2),
                      Flexible(child: _reward(b)),
                    ],
                  )
                : _reward(b),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- Popup

class BadgePopupMock extends StatelessWidget {
  const BadgePopupMock({super.key});

  @override
  Widget build(BuildContext context) {
    final b = _badges[2]; // Backyard Explorer → Tarsier
    return Container(
      color: const Color(0x99263046),
      padding: const EdgeInsets.all(AppSizes.gutter),
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(AppSizes.gapXl),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: AppColors.sunshineDark, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You got a badge!', style: AppText.title.copyWith(color: const Color(0xFF8A5A00))),
              const SizedBox(height: AppSizes.gapM),
              BadgeMedal(icon: b.icon, color: b.color, size: 120),
              const SizedBox(height: AppSizes.gapS),
              Text(b.title, style: AppText.heading),
              const Text('You finished every plant in the Backyard!', style: AppText.body, textAlign: TextAlign.center),
              const SizedBox(height: AppSizes.gapM),
              Container(
                padding: const EdgeInsets.all(AppSizes.gapM),
                decoration: BoxDecoration(
                  color: AppColors.grapeTint,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Row(
                  children: [
                    const AnimalAvatarView(AnimalAvatar.tarsier, size: 72),
                    const SizedBox(width: AppSizes.gapM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('NEW FRIEND!', style: AppText.label.copyWith(color: AppColors.grapeDark)),
                          Text('Tarsier', style: AppText.title.copyWith(fontSize: 22)),
                          const Text('Now you can pick it as your look.', style: AppText.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.gapL),
              ChunkyButton(label: 'USE IT', icon: KidIcon.profile, onPressed: () {}),
              const SizedBox(height: AppSizes.gapS),
              ChunkyButton(label: 'Later', tone: ButtonTone.white, small: true, onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------- Look picker

class LookPickerMock extends StatelessWidget {
  const LookPickerMock({super.key});

  @override
  Widget build(BuildContext context) {
    const how = {
      AnimalAvatar.carabao: 'Finish World 2',
      AnimalAvatar.eagle: '5 perfect quizzes',
      AnimalAvatar.pawikan: 'Visit on 7 days',
      AnimalAvatar.butanding: 'All 15 plants',
      AnimalAvatar.pilandok: 'Finish World 3',
    };
    Widget tile(Widget art, {String? lock, bool picked = false}) => Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: picked ? AppColors.leafTint : (lock == null ? AppColors.card : AppColors.background),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: picked ? AppColors.leafDark : AppColors.borderDeep, width: picked ? 3 : 2),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: lock == null ? 1 : 0.35, child: art),
              if (lock != null) const KidIconView(KidIcon.lock, size: AppSizes.iconMedium, muted: true),
              if (picked)
                const Positioned(top: 0, right: 0, child: KidIconView(KidIcon.check, size: AppSizes.iconSmall)),
            ],
          ),
          SizedBox(
            height: 30,
            child: Center(
              child: Text(
                lock ?? '',
                style: AppText.label.copyWith(color: AppColors.textMuted, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(AppSizes.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Your look', style: AppText.title),
          const SizedBox(height: AppSizes.gapS),
          const Text('Kids', style: AppText.label),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final (i, id) in ['girl_sprout', 'girl_pigtails', 'boy_spiky'].indexed) ...[
                if (i > 0) const SizedBox(width: AppSizes.gapS),
                Expanded(child: tile(AvatarView(avatarId: id, size: 84))),
              ],
            ],
          ),
          const SizedBox(height: AppSizes.gapL),
          Row(
            children: [
              const Text('Animal friends', style: AppText.label),
              const SizedBox(width: 6),
              Text('· earn badges to unlock', style: AppText.bodySmall.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - 2 * AppSizes.gapS) / 3;
              return Wrap(
                spacing: AppSizes.gapS,
                runSpacing: AppSizes.gapS,
                children: [
                  for (final a in AnimalAvatar.values)
                    SizedBox(
                      width: w,
                      child: tile(AnimalAvatarView(a, size: 84), lock: how[a], picked: a == AnimalAvatar.tarsier),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
