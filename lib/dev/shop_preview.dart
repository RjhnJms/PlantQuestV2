import 'package:flutter/material.dart';

import '../art/binhi/binhi.dart';
import '../game/rewards.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/round_buttons.dart';
import '../widgets/stat_pill.dart';
import '../art/icons/kid_icon.dart';

// Leaf shop idea: a look before building it. Nothing here saves.

/// Suggested prices (they add up to 280, about what the whole game pays).
const shopPrices = {
  OutfitItem.stripes: 20,
  OutfitItem.dots: 30,
  OutfitItem.sunglasses: 40,
  OutfitItem.salakot: 50,
  OutfitItem.garland: 60,
  OutfitItem.banig: 80,
};

BinhiOutfit _only(OutfitItem item) => switch (item) {
  OutfitItem.salakot => const BinhiOutfit(salakot: true),
  OutfitItem.garland => const BinhiOutfit(garland: true),
  OutfitItem.sunglasses => const BinhiOutfit(sunglasses: true),
  _ => BinhiOutfit(pattern: item.pattern),
};

/// The wardrobe turned into a shop.
class ShopMockPage extends StatelessWidget {
  const ShopMockPage({
    super.key,
    required this.wallet,
    required this.earned,
    required this.owned,
    required this.outfit,
  });

  /// Leaves to spend.
  final int wallet;

  /// All leaves ever earned (grows Binhi; spending never lowers it).
  final int earned;
  final Set<OutfitItem> owned;
  final BinhiOutfit outfit;

  @override
  Widget build(BuildContext context) {
    final stage = BinhiStage.forLeaves(earned);
    Widget grid(List<OutfitItem> items) => LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - AppSizes.gapM) / 2;
        return Wrap(
          spacing: AppSizes.gapM,
          runSpacing: AppSizes.gapM,
          children: [
            for (final i in items)
              SizedBox(
                width: w,
                child: _ShopTile(
                  item: i,
                  stage: stage,
                  wallet: wallet,
                  owned: owned.contains(i),
                  worn: switch (i) {
                    OutfitItem.salakot => outfit.salakot,
                    OutfitItem.garland => outfit.garland,
                    OutfitItem.sunglasses => outfit.sunglasses,
                    _ => outfit.pattern == i.pattern,
                  },
                ),
              ),
          ],
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SquareIconButton.back(context),
            const SizedBox(width: AppSizes.gapM),
            const Expanded(child: Text("Binhi's shop", style: AppText.title)),
            StatPill.leaves(value: wallet),
          ],
        ),
        const SizedBox(height: AppSizes.gapL),
        ChunkyCard(
          color: AppColors.grapeTint,
          ledgeColor: AppColors.grape,
          child: Column(
            children: [
              Binhi(stage: stage, size: 140, outfit: outfit, reduceMotion: true, mood: BinhiMood.cheering),
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
        const Text('Things to wear', style: AppText.heading),
        const SizedBox(height: AppSizes.gapM),
        grid([OutfitItem.sunglasses, OutfitItem.salakot, OutfitItem.garland]),
        const SizedBox(height: AppSizes.gapXl),
        const Text('Pot patterns', style: AppText.heading),
        const Text('Binhi can wear one at a time.', style: AppText.bodySmall),
        const SizedBox(height: AppSizes.gapM),
        grid([OutfitItem.stripes, OutfitItem.dots, OutfitItem.banig]),
      ],
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({required this.icon, required this.color, required this.value, required this.label});

  final KidIcon icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
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
  );
}

class _ShopTile extends StatelessWidget {
  const _ShopTile({
    required this.item,
    required this.stage,
    required this.wallet,
    required this.owned,
    required this.worn,
  });

  final OutfitItem item;
  final BinhiStage stage;
  final int wallet;
  final bool owned;
  final bool worn;

  @override
  Widget build(BuildContext context) {
    final price = shopPrices[item]!;
    final canBuy = !owned && wallet >= price;
    final Widget action;
    if (owned) {
      action = Text(worn ? 'Wearing' : 'Tap to wear', style: AppText.label.copyWith(color: AppColors.leafDark));
    } else if (canBuy) {
      action = ChunkyButton(label: 'BUY · $price', icon: KidIcon.leaf, small: true, onPressed: () {});
    } else {
      action = Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco_rounded, size: 18, color: AppColors.textMuted),
              Text(' $price', style: AppText.label.copyWith(color: AppColors.textMuted)),
            ],
          ),
          Text(
            '${price - wallet} more leaves',
            style: AppText.bodySmall.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          AppProgressBar(value: wallet / price, height: 8, semanticLabel: 'Saving up'),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.all(AppSizes.gapS),
      decoration: BoxDecoration(
        color: worn ? AppColors.leafTint : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: worn ? AppColors.leafDark : AppColors.borderDeep, width: worn ? 3 : 2),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: owned || canBuy ? 1 : 0.55,
                child: Binhi(stage: stage, size: 72, outfit: _only(item), reduceMotion: true),
              ),
              if (worn)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.check_circle_rounded, size: 26, color: AppColors.leafDark),
                ),
            ],
          ),
          Text(
            item.label,
            style: AppText.label.copyWith(color: AppColors.text),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          SizedBox(height: 50, child: Center(child: action)),
        ],
      ),
    );
  }
}

/// "Buy it?" sheet: one more tap so a little finger can't buy by accident.
class BuySheetMock extends StatelessWidget {
  const BuySheetMock({super.key, required this.item, required this.wallet, required this.stage});

  final OutfitItem item;
  final int wallet;
  final BinhiStage stage;

  @override
  Widget build(BuildContext context) {
    final price = shopPrices[item]!;
    return _Card(
      color: AppColors.leaf,
      children: [
        Text('Buy the ${item.label}?', style: AppText.title, textAlign: TextAlign.center),
        const SizedBox(height: AppSizes.gapS),
        Binhi(stage: stage, size: 120, outfit: _only(item), reduceMotion: true),
        const SizedBox(height: AppSizes.gapS),
        Text(
          'It costs $price leaves. You will have ${wallet - price} left.\nBinhi stays just as big!',
          style: AppText.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.gapL),
        ChunkyButton(label: 'BUY · $price', icon: KidIcon.leaf, onPressed: () {}),
        const SizedBox(height: AppSizes.gapS),
        ChunkyButton(label: 'Not now', tone: ButtonTone.white, small: true, onPressed: () {}),
      ],
    );
  }
}

/// After buying: Binhi already wearing it.
class ThanksMock extends StatelessWidget {
  const ThanksMock({super.key, required this.item, required this.stage, required this.outfit});

  final OutfitItem item;
  final BinhiStage stage;
  final BinhiOutfit outfit;

  @override
  Widget build(BuildContext context) => _Card(
    color: AppColors.grape,
    children: [
      Text('Salamat!', style: AppText.title.copyWith(color: AppColors.grapeDark)),
      const SizedBox(height: AppSizes.gapS),
      Binhi(stage: stage, size: 140, outfit: outfit, mood: BinhiMood.cheering, reduceMotion: true),
      const SizedBox(height: AppSizes.gapS),
      Text("Binhi loves the ${item.label}! He's wearing it now.", style: AppText.body, textAlign: TextAlign.center),
      const SizedBox(height: AppSizes.gapL),
      ChunkyButton(label: 'YAY!', onPressed: () {}),
    ],
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.color, required this.children});

  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.gapXl),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      border: Border.all(color: color, width: 3),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: children),
  );
}

/// Home's top: the leaf pill shows leaves to spend; Binhi's card shows
/// growth from leaves earned in all, plus a shop button.
class HomeTopMock extends StatelessWidget {
  const HomeTopMock({super.key, required this.wallet, required this.earned, required this.outfit});

  final int wallet;
  final int earned;
  final BinhiOutfit outfit;

  @override
  Widget build(BuildContext context) {
    final stage = BinhiStage.forLeaves(earned);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const StatPill.days(value: 6),
            const SizedBox(width: AppSizes.gapS),
            StatPill.leaves(value: wallet),
          ],
        ),
        const SizedBox(height: AppSizes.gapM),
        ChunkyCard(
          child: Row(
            children: [
              Binhi(stage: stage, size: 78, outfit: outfit, reduceMotion: true),
              const SizedBox(width: AppSizes.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hi! Ready to explore?', style: AppText.heading),
                    Text('Binhi is ${stage.label}', style: AppText.bodySmall),
                    const SizedBox(height: AppSizes.gapS),
                    AppProgressBar(value: BinhiStage.growthProgress(earned), height: 14, semanticLabel: 'Growth'),
                    const SizedBox(height: AppSizes.gapS),
                    ChunkyButton(
                      label: 'SHOP',
                      icon: KidIcon.shop,
                      tone: ButtonTone.grape,
                      small: true,
                      expand: false,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
