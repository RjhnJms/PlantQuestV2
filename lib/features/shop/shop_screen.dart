import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/binhi/binhi.dart';
import '../../art/binhi/binhi_spot.dart';
import '../../game/colouring.dart';
import '../../game/daily.dart';
import '../../game/rewards.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/effects/reward_moment.dart';
import '../../widgets/pressable_3d.dart';
import '../../widgets/stat_pill.dart';
import '../../art/icons/kid_icon.dart';

/// The Shop tab: spend leaves on things for Binhi, then tap to wear them
/// (PLAN.md §5b). Spending never shrinks Binhi; he grows from leaves earned.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _binhi = BinhiController();

  /// One purchase at a time (a double tap can't start two).
  bool _buying = false;

  @override
  void dispose() {
    _binhi.dispose();
    super.dispose();
  }

  void _toggle(OutfitItem item, BinhiOutfit outfit) {
    if (!item.wearable) return;
    PressFeedback.onPress?.call();
    ref.read(gameActionsProvider).saveOutfit(item.wornIn(outfit) ? item.takeOff(outfit) : item.putOn(outfit));
    _binhi.hop();
  }

  Future<void> _buy(OutfitItem item, int wallet, BinhiStage stage) async {
    if (_buying) return;
    _buying = true;
    try {
      await _buyFlow(item, wallet, stage);
    } finally {
      _buying = false;
    }
  }

  Future<void> _buyFlow(OutfitItem item, int wallet, BinhiStage stage) async {
    final still = ref.read(lessMotionProvider);
    final sure = await showRewardMoment(
      context,
      title: 'Buy the ${item.label}?',
      art: ItemArt(item: item, stage: stage, size: 120),
      message: 'It costs ${item.price} leaves. You will have ${wallet - item.price} left.\nBinhi stays just as big!',
      color: AppColors.leaf,
      titleColor: AppColors.text,
      buttonLabel: 'BUY · ${item.price}',
      secondLabel: 'Not now',
      reduceMotion: still,
    );
    if (!sure || !mounted) return;
    final bought = await ref.read(gameActionsProvider).buy(item);
    if (!bought || !mounted) return;
    ref.read(shopSeenWalletProvider.notifier).seen(wallet - item.price);
    _binhi.cheer();
    final outfit = item.putOn(ref.read(binhiOutfitProvider));
    await showRewardMoment(
      context,
      title: 'Salamat!',
      art: item.wearable
          ? _InSpot(
              spot: outfit.spot,
              size: 150,
              child: Binhi(stage: stage, size: 140, outfit: outfit, mood: BinhiMood.cheering, reduceMotion: true),
            )
          : ItemArt(item: item, stage: stage, size: 120),
      message: switch (item.slot) {
        OutfitSlot.pack => 'New colours for your colouring pages!',
        OutfitSlot.spot => 'Binhi loves his new spot!',
        _ => "Binhi loves the ${item.label}! He's wearing it now.",
      },
      color: AppColors.grape,
      titleColor: AppColors.grapeDark,
      reduceMotion: still,
      onShown: () => cheerReward(context, ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletLoaded = ref.watch(leavesProvider).value;
    final wallet = walletLoaded ?? 0;
    final earned = ref.watch(leavesEarnedProvider).value ?? 0;
    final owned = ref.watch(ownedProvider).value ?? const <OutfitItem>{};
    final outfit = ref.watch(binhiOutfitProvider);
    final stage = BinhiStage.forLeaves(earned);
    final still = ref.watch(lessMotionProvider);
    final watered = ref.watch(daysWateredProvider).value ?? 0;

    // Each group is one row that slides sideways, so the shop stays short.
    final rowHeight = 250 + (MediaQuery.textScalerOf(context).scale(16) - 16) * 5;
    Widget row(List<OutfitItem> items) => SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(bottom: 6),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.gapM),
        itemBuilder: (context, k) {
          final i = items[k];
          return SizedBox(
            width: 150,
            child: _ItemTile(
              item: i,
              stage: stage,
              wallet: wallet,
              owned: owned.contains(i),
              worn: owned.contains(i) && i.wornIn(outfit),
              daysWatered: watered,
              onWear: () => _toggle(i, outfit),
              onBuy: () => _buy(i, wallet, stage),
            ),
          );
        },
      ),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            Row(
              children: [
                const Expanded(child: Text('Shop', style: AppText.display)),
                LeafTarget(child: StatPill.leaves(value: walletLoaded)),
              ],
            ),
            const SizedBox(height: AppSizes.gapL),
            ChunkyCard(
              color: AppColors.grapeTint,
              ledgeColor: AppColors.grape,
              child: Column(
                children: [
                  _InSpot(
                    spot: outfit.spot,
                    size: 170,
                    child: Binhi(
                      stage: stage,
                      size: 140,
                      outfit: outfit,
                      controller: _binhi,
                      reduceMotion: still,
                      mood: BinhiMood.cheering,
                      semanticLabel: 'Binhi in his outfit',
                    ),
                  ),
                  const SizedBox(height: AppSizes.gapS),
                  Row(
                    children: [
                      Expanded(
                        child: _Number(
                          icon: KidIcon.leaf,
                          color: AppColors.leafDark,
                          value: '$wallet',
                          label: 'leaves to spend',
                        ),
                      ),
                      const SizedBox(width: AppSizes.gapS),
                      Expanded(
                        child: _Number(
                          icon: KidIcon.earned,
                          color: AppColors.grapeDark,
                          value: '$earned',
                          label: 'earned in all\n(Binhi keeps growing)',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.gapXl),
            for (final (slot, title, line) in _sections) ...[
              Text(title, style: AppText.heading),
              Text(line, style: AppText.bodySmall),
              const SizedBox(height: AppSizes.gapM),
              row(OutfitItem.inSlot(slot)),
              const SizedBox(height: AppSizes.gapXl),
            ],
          ],
        ),
      ),
    );
  }
}

/// The shop's groups, in order.
const _sections = [
  (OutfitSlot.hat, 'Hats', 'Binhi wears one hat at a time.'),
  (OutfitSlot.glasses, 'Glasses', 'One pair at a time.'),
  (OutfitSlot.neck, 'Around the rim', 'One at a time.'),
  (OutfitSlot.friend, 'Little friends', 'A friend who stays near Binhi.'),
  (OutfitSlot.pattern, 'Pot patterns', 'One pattern at a time.'),
  (OutfitSlot.spot, "Binhi's spot", 'The scene behind Binhi on Home.'),
  (OutfitSlot.pack, 'Colouring packs', 'Six more colours each, for colouring pages.'),
];

/// Binhi standing in his spot's scene (just Binhi in the meadow).
class _InSpot extends StatelessWidget {
  const _InSpot({required this.spot, required this.size, required this.child});

  final BinhiSpot spot;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (spot == BinhiSpot.meadow) return child;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      child: SizedBox(
        width: size * 1.3,
        height: size,
        child: CustomPaint(
          painter: BinhiSpotPainter(spot),
          child: Align(alignment: Alignment.bottomCenter, child: child),
        ),
      ),
    );
  }
}

/// How a shop item looks: Binhi wearing it, his spot, or a pack's colours.
class ItemArt extends StatelessWidget {
  const ItemArt({super.key, required this.item, required this.stage, required this.size});

  final OutfitItem item;
  final BinhiStage stage;
  final double size;

  @override
  Widget build(BuildContext context) => switch (item.slot) {
    OutfitSlot.spot => _InSpot(
      spot: item.alone.spot,
      size: size,
      child: Binhi(stage: stage, size: size * 0.62, reduceMotion: true),
    ),
    OutfitSlot.pack => SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Wrap(
          spacing: size * 0.06,
          runSpacing: size * 0.06,
          alignment: WrapAlignment.center,
          children: [
            for (final (rgb, _) in ColouringRules.packs[item]!)
              Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: Color(0xFF000000 | rgb),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.card, width: 2),
                  boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 2))],
                ),
              ),
          ],
        ),
      ),
    ),
    _ => Binhi(stage: stage, size: size, outfit: item.alone, reduceMotion: true),
  };
}

class _Number extends StatelessWidget {
  const _Number({required this.icon, required this.color, required this.value, required this.label});

  final KidIcon icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$value $label',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(AppSizes.gapS),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusS)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KidIconView(icon, size: AppSizes.iconSmall),
              const SizedBox(width: 4),
              Text(value, style: AppText.title.copyWith(color: color)),
            ],
          ),
          Text(label, style: AppText.bodySmall.copyWith(fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.stage,
    required this.wallet,
    required this.owned,
    required this.worn,
    required this.onWear,
    required this.onBuy,
    this.daysWatered = 0,
  });

  final OutfitItem item;
  final BinhiStage stage;
  final int wallet;
  final bool owned;
  final bool worn;
  final VoidCallback onWear;
  final VoidCallback onBuy;

  /// For the flower pot, which is earned by watering Binhi.
  final int daysWatered;

  @override
  Widget build(BuildContext context) {
    final canBuy = !owned && item.forSale && wallet >= item.price;
    final short = item.price - wallet;
    final Widget action;
    final String label;
    if (owned && !item.wearable) {
      label = '${item.label}. Yours! The colours are in your colouring pages.';
      action = Text('In your colours', style: AppText.label.copyWith(color: AppColors.leafDark));
    } else if (owned) {
      final verb = item.slot == OutfitSlot.spot ? 'use' : 'wear';
      label = '${item.label}. ${worn ? 'Wearing. Tap to take off.' : 'Yours. Tap to $verb.'}';
      action = Text(
        worn ? (item.slot == OutfitSlot.spot ? 'Using' : 'Wearing') : 'Tap to $verb',
        style: AppText.label.copyWith(color: AppColors.leafDark),
      );
    } else if (!item.forSale) {
      const goal = DailyRules.flowerPotDays;
      label = '${item.label}. Water Binhi on $goal days to get it. $daysWatered of $goal.';
      action = Column(
        children: [
          const KidIconView(KidIcon.drop, size: AppSizes.iconSmall),
          Text(
            'Water Binhi on $goal days',
            style: AppText.bodySmall.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          AppProgressBar(value: daysWatered / goal, height: 8, color: AppColors.sky, semanticLabel: 'Days watered'),
        ],
      );
    } else if (canBuy) {
      label = '${item.label}. ${item.price} leaves.';
      action = ChunkyButton(label: 'BUY · ${item.price}', icon: KidIcon.leaf, small: true, onPressed: onBuy);
    } else {
      label = '${item.label}. ${item.price} leaves. You need $short more.';
      action = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const KidIconView(KidIcon.leaf, size: AppSizes.iconSmall, muted: true),
              Text(' ${item.price}', style: AppText.label.copyWith(color: AppColors.textMuted)),
            ],
          ),
          Text('$short more leaves', style: AppText.bodySmall.copyWith(fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          AppProgressBar(value: wallet / item.price, height: 8, semanticLabel: 'Saving up'),
        ],
      );
    }
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(AppSizes.gapS),
      decoration: BoxDecoration(
        color: worn ? AppColors.leafTint : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: worn ? AppColors.leafDark : AppColors.borderDeep,
          width: worn ? 3 : AppSizes.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: owned || canBuy ? 1 : 0.55,
                child: ItemArt(item: item, stage: stage, size: 72),
              ),
              if (worn)
                const Positioned(top: 0, right: 0, child: KidIconView(KidIcon.check, size: AppSizes.iconMedium)),
            ],
          ),
          Text(
            item.label,
            style: AppText.label.copyWith(color: AppColors.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          SizedBox(height: 72, child: Center(child: action)),
        ],
      ),
    );
    if (canBuy) return Semantics(label: label, child: tile);
    return Semantics(
      button: owned,
      toggled: owned ? worn : null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(onTap: owned ? onWear : null, child: tile),
    );
  }
}
