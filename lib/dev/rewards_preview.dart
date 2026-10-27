import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../art/binhi/binhi.dart';
import '../content/plant_catalog.dart';
import '../services/sound_service.dart';
import '../state/effects.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/chunky_button.dart';
import '../widgets/effects/pop_in.dart';
import '../widgets/rewards/reward_pieces.dart';
import '../widgets/round_buttons.dart';
import '../art/icons/kid_icon.dart';

/// Rewards ideas to look at before choosing which ones go in the game.
/// Nothing here is saved. Browser preview: #/rewards-preview
class RewardsPreview extends ConsumerStatefulWidget {
  const RewardsPreview({super.key});

  @override
  ConsumerState<RewardsPreview> createState() => _RewardsPreviewState();
}

class _RewardsPreviewState extends ConsumerState<RewardsPreview> {
  var _outfit = const BinhiOutfit(salakot: true, pattern: PotPattern.banig);
  final _garden = <GardenItem>{GardenItem.fence, GardenItem.butterfly, GardenItem.pond};

  @override
  Widget build(BuildContext context) {
    final still = ref.watch(lessMotionProvider);
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            Row(
              children: [
                SquareIconButton.back(context),
                const SizedBox(width: AppSizes.gapM),
                const Expanded(child: Text('Reward ideas', style: AppText.title)),
              ],
            ),
            const SizedBox(height: AppSizes.gapS),
            const Text('A look at each idea. Nothing is saved yet. Pick the ones you like.', style: AppText.bodySmall),
            _Section(
              letter: 'A',
              title: 'Sticker book',
              how: 'Finish a plant quiz to earn its sticker. 15 to collect.',
              color: AppColors.coral,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    for (final (i, p) in PlantCatalog.all.indexed)
                      StickerBadge(plant: p, earned: i < 6, size: 84, tilt: [-0.06, 0.04, -0.02, 0.07][i % 4]),
                  ],
                ),
                const SizedBox(height: AppSizes.gapM),
                ChunkyButton(
                  label: 'SHOW "YOU GOT A STICKER!"',
                  tone: ButtonTone.coral,
                  icon: KidIcon.sparkle,
                  onPressed: () => _showStickerMoment(PlantCatalog.byId('saba')),
                ),
              ],
            ),
            _Section(
              letter: 'B',
              title: "Binhi's wardrobe",
              how: 'Unlocked by milestones, not bought with leaves. Tap to try them on.',
              color: AppColors.grape,
              children: [
                Center(
                  child: Binhi(stage: BinhiStage.blooming, size: 170, outfit: _outfit, reduceMotion: still),
                ),
                const SizedBox(height: AppSizes.gapS),
                Wrap(
                  spacing: AppSizes.gapS,
                  runSpacing: AppSizes.gapS,
                  children: [
                    _Toggle(
                      label: 'Salakot',
                      unlock: 'Finish World 1',
                      on: _outfit.salakot,
                      onTap: () => setState(() => _outfit = _outfit.copyWith(salakot: !_outfit.salakot)),
                    ),
                    _Toggle(
                      label: 'Sampaguita garland',
                      unlock: '5 perfect quizzes',
                      on: _outfit.garland,
                      onTap: () => setState(() => _outfit = _outfit.copyWith(garland: !_outfit.garland)),
                    ),
                    _Toggle(
                      label: 'Sunglasses',
                      unlock: 'Visit 7 days',
                      on: _outfit.sunglasses,
                      onTap: () => setState(() => _outfit = _outfit.copyWith(sunglasses: !_outfit.sunglasses)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.gapM),
                const Text('POT PATTERN', style: AppText.label),
                const SizedBox(height: AppSizes.gapXs),
                Wrap(
                  spacing: AppSizes.gapS,
                  runSpacing: AppSizes.gapS,
                  children: [
                    for (final p in PotPattern.values)
                      _Toggle(
                        label: p.label,
                        on: _outfit.pattern == p,
                        onTap: () => setState(() => _outfit = _outfit.copyWith(pattern: p)),
                      ),
                  ],
                ),
              ],
            ),
            _Section(
              letter: 'C',
              title: 'Gold plant cards',
              how: 'Get every question right and the plant card turns gold and shines.',
              color: AppColors.sunshineDark,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        children: [
                          GoldPlantCard(plant: PlantCatalog.byId('gumamela'), gold: false, reduceMotion: still),
                          const SizedBox(height: 4),
                          const Text('Normal', style: AppText.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.gapM),
                    Flexible(
                      child: Column(
                        children: [
                          GoldPlantCard(plant: PlantCatalog.byId('mango'), reduceMotion: still),
                          const SizedBox(height: 4),
                          const Text('Gold (perfect)', style: AppText.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _Section(
              letter: 'D',
              title: 'Garden decorations',
              how: 'Each world you finish gives new things to place around Binhi.',
              color: AppColors.leafDark,
              children: [
                GardenPatch(items: _garden, outfit: _outfit, reduceMotion: still),
                const SizedBox(height: AppSizes.gapM),
                Wrap(
                  spacing: AppSizes.gapS,
                  runSpacing: AppSizes.gapS,
                  children: [
                    for (final item in GardenItem.values)
                      _Toggle(
                        label: item.label,
                        icon: item.icon,
                        on: _garden.contains(item),
                        onTap: () => setState(() => _garden.contains(item) ? _garden.remove(item) : _garden.add(item)),
                      ),
                  ],
                ),
              ],
            ),
            _Section(
              letter: 'E',
              title: 'Bonus fun facts',
              how: 'A perfect quiz opens one extra fact on that plant\'s page.',
              color: AppColors.grapeDark,
              children: [
                BonusFactCard(
                  plant: PlantCatalog.byId('makahiya'),
                  fact: 'Makahiya can fold its leaves in about one second, and opens them again after a few minutes.',
                ),
                const SizedBox(height: AppSizes.gapM),
                BonusFactCard(plant: PlantCatalog.byId('narra'), fact: '', unlocked: false),
              ],
            ),
            _Section(
              letter: 'F',
              title: 'Plant Expert certificate',
              how: 'Learn all 15 plants to get a certificate with your name. Show it to your teacher!',
              color: AppColors.skyDark,
              children: [PlantExpertCertificate(name: profile?.name ?? 'Juan', avatarId: profile?.avatarId)],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStickerMoment(PlantInfo plant) async {
    final feel = ref.read(motionFeelProvider);
    final sound = ref.read(soundServiceProvider)..play(Sfx.levelUp);
    final size = MediaQuery.sizeOf(context);
    ref.read(confettiProvider).burst(Offset(size.width / 2, size.height * 0.4), count: feel.confetti);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: const Color(0x99263046),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, a, b, child) => ScaleTransition(
        scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: a, child: child),
      ),
      pageBuilder: (context, a, b) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(AppSizes.gapXl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(color: AppColors.coral, width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You got a sticker!', style: AppText.title.copyWith(color: AppColors.coralDark)),
                const SizedBox(height: AppSizes.gapM),
                PopIn(
                  trigger: plant.id,
                  child: StickerBadge(plant: plant, size: 150, tilt: -0.05),
                ),
                const SizedBox(height: AppSizes.gapS),
                const Text('It went into your sticker book.', style: AppText.body, textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.gapL),
                ChunkyButton(
                  label: 'YAY!',
                  onPressed: () {
                    sound.play(Sfx.tap);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.letter,
    required this.title,
    required this.how,
    required this.color,
    required this.children,
  });

  final String letter;
  final String title;
  final String how;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.gapXl),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        padding: const EdgeInsets.all(AppSizes.gapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color,
                  child: Text(letter, style: AppText.heading.copyWith(color: AppColors.card, fontSize: 17)),
                ),
                const SizedBox(width: AppSizes.gapS),
                Expanded(child: Text(title, style: AppText.title.copyWith(fontSize: 22))),
              ],
            ),
            const SizedBox(height: AppSizes.gapXs),
            Text(how, style: AppText.bodySmall),
            const SizedBox(height: AppSizes.gapL),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A small on/off pill with an optional "how to unlock" line.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, required this.on, required this.onTap, this.unlock, this.icon});

  final String label;
  final String? unlock;
  final IconData? icon;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: on,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: on ? AppColors.leafTint : AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(color: on ? AppColors.leafDark : AppColors.borderDeep, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? (on ? Icons.check_circle_rounded : Icons.circle_outlined),
                size: 20,
                color: on ? AppColors.leafDark : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppText.label.copyWith(color: AppColors.text)),
                  if (unlock != null) Text(unlock!, style: AppText.bodySmall.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
