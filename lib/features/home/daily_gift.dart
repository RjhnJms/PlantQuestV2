import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/binhi/binhi.dart';
import '../../art/gift_box.dart';
import '../../art/icons/kid_icon.dart';
import '../../game/daily.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/effects/reward_moment.dart';

bool _giftShowing = false;

/// Binhi's gift for coming back (PLAN.md §5e): offered once a day when Home
/// opens. Gifts count up through a week of seven; a missed day just waits.
Future<void> offerDailyGift(BuildContext context, WidgetRef ref) async {
  if (_giftShowing || !ref.read(dailyGiftEnabledProvider)) return;
  _giftShowing = true;
  try {
    final repo = ref.read(repositoryProvider);
    if (await repo.isDoneToday(DailyKind.gift) || !context.mounted) return;
    final n = await repo.getDailyCount(DailyKind.gift) + 1;
    if (!context.mounted) return;
    final still = ref.read(lessMotionProvider);
    final stage = BinhiStage.forLeaves(ref.read(leavesEarnedProvider).value ?? 0);
    final outfit = ref.read(binhiOutfitProvider);
    final open = await showRewardMoment(
      context,
      title: 'A gift from Binhi!',
      art: SizedBox(
        height: 130,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Binhi(stage: stage, outfit: outfit, size: 110, mood: BinhiMood.cheering, reduceMotion: true),
            Transform.rotate(
              angle: 0.12,
              child: const SizedBox.square(dimension: 100, child: CustomPaint(painter: GiftBoxPainter())),
            ),
          ],
        ),
      ),
      message: 'Thanks for coming back today.',
      extra: GiftWeek(today: DailyRules.weekDay(n)),
      color: AppColors.grape,
      titleColor: AppColors.grapeDark,
      buttonLabel: 'OPEN MY GIFT',
      reduceMotion: still,
    );
    if (!open || !context.mounted) return;
    final before = ref.read(leavesEarnedProvider).value ?? 0;
    final gift = await ref.read(gameActionsProvider).openDailyGift();
    if (gift == null || !context.mounted) return;
    final (number, leaves) = gift;
    final big = DailyRules.weekDay(number) == DailyRules.gifts.length;
    await showRewardMoment(
      context,
      title: big ? 'A big surprise!' : 'You got $leaves leaves!',
      art: const SizedBox.square(dimension: 120, child: CustomPaint(painter: GiftBoxPainter(open: true))),
      message: big ? 'You opened all seven gifts. Here are $leaves leaves!' : 'Come back tomorrow for another gift.',
      extra: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KidIconView(KidIcon.leaf),
          const SizedBox(width: 6),
          Text('+$leaves leaves', style: AppText.title.copyWith(color: AppColors.leafDark, fontSize: 22)),
        ],
      ),
      color: AppColors.leaf,
      titleColor: AppColors.leafDark,
      reduceMotion: still,
      onShown: () => cheerReward(context, ref),
    );
    if (!context.mounted) return;
    await celebrateLeaves(context, ref, from: null, earned: leaves, earnedBefore: before);
  } finally {
    _giftShowing = false;
  }
}

/// The week of gifts: opened ones ticked, today's ringed, day 7 a trophy.
class GiftWeek extends StatelessWidget {
  const GiftWeek({super.key, required this.today});

  /// Today's place in the week, 1–7.
  final int today;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Gift $today of 7. Gift 7 is a big surprise.',
    excludeSemantics: true,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var d = 1; d <= DailyRules.gifts.length; d++)
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: d < today
                      ? AppColors.leafTint
                      : d == today
                      ? AppColors.grapeTint
                      : AppColors.track.withValues(alpha: 0.5),
                  border: Border.all(color: d == today ? AppColors.grape : Colors.transparent, width: 3),
                ),
                child: Center(
                  child: d < today
                      ? const KidIconView(KidIcon.check, size: 18)
                      : d == DailyRules.gifts.length
                      ? KidIconView(KidIcon.trophy, size: 20, muted: d != today)
                      : SizedBox.square(
                          dimension: 20,
                          child: Opacity(
                            opacity: d == today ? 1 : 0.4,
                            child: const CustomPaint(painter: GiftBoxPainter()),
                          ),
                        ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          today == DailyRules.gifts.length ? 'Today is the big surprise!' : 'Gift 7 is a big surprise!',
          style: AppText.label.copyWith(color: AppColors.textMuted),
        ),
      ],
    ),
  );
}
