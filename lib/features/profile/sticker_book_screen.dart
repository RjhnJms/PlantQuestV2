import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../content/plant_catalog.dart';
import '../../content/plant_content.dart';
import '../../state/providers.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/rewards/reward_pieces.dart';
import '../../widgets/round_buttons.dart';

/// All 15 stickers, one per plant quiz finished (PLAN.md §5b).
class StickerBookScreen extends ConsumerWidget {
  const StickerBookScreen({super.key});

  static const _tilts = [-0.06, 0.04, -0.02, 0.07, -0.04];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stickers = ref.watch(stickersProvider);
    final total = PlantCatalog.all.length;
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
                  const Flexible(child: Text('Sticker book', style: AppText.title)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXl),
                children: [
                  ChunkyCard(
                    semanticLabel: '${stickers.length} of $total stickers',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${stickers.length} of $total stickers', style: AppText.heading),
                        const SizedBox(height: AppSizes.gapS),
                        AppProgressBar(value: stickers.length / total, height: 14, semanticLabel: 'Stickers collected'),
                        const SizedBox(height: AppSizes.gapS),
                        Text(
                          stickers.length == total
                              ? 'You collected them all. Amazing!'
                              : "Finish a plant's quiz to get its sticker.",
                          style: AppText.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  for (final world in WorldInfo.all) ...[
                    const SizedBox(height: AppSizes.gapXl),
                    Text('World ${world.number} · ${world.name}', style: AppText.heading),
                    Text(world.subtitle, style: AppText.bodySmall),
                    const SizedBox(height: AppSizes.gapM),
                    LayoutBuilder(
                      builder: (context, c) {
                        final size = ((c.maxWidth - 2 * AppSizes.gapM) / 3 - 8).clamp(64.0, 104.0);
                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppSizes.gapM,
                          runSpacing: AppSizes.gapXs,
                          children: [
                            for (final plant in PlantCatalog.inWorld(world.number))
                              _Sticker(
                                plant: plant,
                                earned: stickers.contains(plant.id),
                                size: size,
                                tilt: _tilts[plant.order % _tilts.length],
                              ),
                          ],
                        );
                      },
                    ),
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

class _Sticker extends StatelessWidget {
  const _Sticker({required this.plant, required this.earned, required this.size, required this.tilt});

  final PlantInfo plant;
  final bool earned;
  final double size;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    final badge = StickerBadge(plant: plant, earned: earned, size: size, tilt: earned ? tilt : 0);
    if (!earned) return badge;
    return Semantics(
      button: true,
      label: '${plant.name} sticker. Open plant.',
      excludeSemantics: true,
      child: GestureDetector(onTap: () => context.push('/plant/${plant.id}'), child: badge),
    );
  }
}
