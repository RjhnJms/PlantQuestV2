import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../content/plant_content.dart';
import '../../game/rules.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../theme/world_themes.dart';
import '../../widgets/chunky_card.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 6: every plant, grouped into the three worlds
/// (docs/screens/06-plants.jpg). A world's locked plants share one row of
/// mystery shapes (Oct 2026 layout pass, PLAN.md D13).
class PlantsScreen extends ConsumerWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(pathProvider).value ?? PathState.from({});
    final explored = ref.watch(exploredPlantsProvider).value ?? const <String>{};

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            const Text('Plants', style: AppText.display),
            Text('${explored.length} of 15 explored', style: AppText.label),
            for (final world in WorldInfo.all) ...[
              const SizedBox(height: AppSizes.gapXl),
              _WorldHeader(world: world),
              const SizedBox(height: AppSizes.gapM),
              for (final plant in PlantCatalog.inWorld(world.number).where((p) => path.isUnlocked(p.id))) ...[
                _PlantCard(plant: plant, state: path.of(plant.id)),
                const SizedBox(height: AppSizes.gapM),
              ],
              // Locked plants share one row instead of a card each.
              if (PlantCatalog.inWorld(world.number).any((p) => !path.isUnlocked(p.id))) ...[
                _LockedGroup(plants: [...PlantCatalog.inWorld(world.number).where((p) => !path.isUnlocked(p.id))]),
                const SizedBox(height: AppSizes.gapM),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _WorldHeader extends StatelessWidget {
  const _WorldHeader({required this.world});

  final WorldInfo world;

  @override
  Widget build(BuildContext context) {
    final theme = WorldTheme.of(world.number);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: theme.accent, borderRadius: BorderRadius.circular(10)),
          child: Text('${world.number}', style: AppText.heading),
        ),
        const SizedBox(width: AppSizes.gapS),
        // Wraps instead of running off narrow screens.
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: world.name, style: AppText.heading),
                TextSpan(text: ' · ${world.subtitle}', style: AppText.label),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant, required this.state});

  final PlantInfo plant;
  final StopState state;

  @override
  Widget build(BuildContext context) {
    final locked = state == StopState.locked;
    final current = state == StopState.current;
    return ChunkyCard(
      onTap: locked ? null : () => context.push('/plant/${plant.id}'),
      semanticLabel: locked
          ? 'Mystery plant. Finish the plant before it to unlock.'
          : '${plant.name}. ${PlantContent.of(plant.id).shortLine}',
      padding: const EdgeInsets.all(AppSizes.gapM),
      outlineColor: current ? AppColors.grape : null,
      ledgeColor: current ? AppColors.grape : AppColors.borderDeep,
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: locked ? AppColors.track : plant.tileColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: locked
                ? const KidIconView(KidIcon.lock, size: AppSizes.iconLarge, muted: true)
                : Padding(
                    padding: const EdgeInsets.all(4),
                    child: PlantView(plant: plant),
                  ),
          ),
          const SizedBox(width: AppSizes.gapL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        locked ? '???' : plant.name,
                        style: AppText.heading.copyWith(color: locked ? AppColors.textMuted : AppColors.text),
                      ),
                    ),
                    if (state == StopState.done) ...[
                      const SizedBox(width: AppSizes.gapS),
                      const KidIconView(KidIcon.check, size: AppSizes.iconSmall),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  locked ? 'Finish the plant before it to unlock' : PlantContent.of(plant.id).shortLine,
                  style: AppText.body.copyWith(fontSize: 16, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (!locked) const KidIconView(KidIcon.next, size: AppSizes.iconMedium),
        ],
      ),
    );
  }
}

/// "4 more to discover" with small mystery shapes.
class _LockedGroup extends StatelessWidget {
  const _LockedGroup({required this.plants});

  final List<PlantInfo> plants;

  @override
  Widget build(BuildContext context) {
    final n = plants.length;
    return ChunkyCard(
      color: AppColors.background,
      semanticLabel: '$n mystery ${n == 1 ? 'plant' : 'plants'}. Finish the plants before them to unlock.',
      padding: const EdgeInsets.all(AppSizes.gapM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const KidIconView(KidIcon.lock, size: AppSizes.iconSmall, muted: true),
              const SizedBox(width: 6),
              Expanded(
                child: Text('$n more to discover', style: AppText.heading.copyWith(color: AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.gapS),
          Row(
            children: [
              for (final p in plants)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(width: 48, height: 48, child: PlantView(plant: p, locked: true)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
