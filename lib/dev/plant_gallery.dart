import 'package:flutter/material.dart';

import '../art/plants/plant_view.dart';
import '../content/plant_catalog.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';

/// Developer-only preview of the 15 plants: tap a card to see it big, then
/// tap the plant's parts like on Plant details.
class PlantGallery extends StatefulWidget {
  const PlantGallery({super.key});

  @override
  State<PlantGallery> createState() => _PlantGalleryState();
}

class _PlantGalleryState extends State<PlantGallery> {
  PlantInfo _plant = PlantCatalog.all.first;
  PlantPart? _part;
  final Set<PlantPart> _found = {};
  bool _locked = false;

  static const _worlds = ['Bakuran', 'Bukid', 'Kalikasan'];

  void _pick(PlantInfo p) => setState(() {
    _plant = p;
    _part = null;
    _found.clear();
  });

  String _partLabel(PlantPart p) => switch (p) {
    PlantPart.root => 'Root',
    PlantPart.stem => 'Stem',
    PlantPart.leaf => 'Leaf',
    PlantPart.special => _plant.special.label,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            const Text('Plants', style: AppText.display),
            Text('${_plant.name} · ${_plant.scientificName}', style: AppText.bodySmall),
            const SizedBox(height: AppSizes.gapM),
            ChunkyCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
                child: Column(
                  children: [
                    const SizedBox(height: AppSizes.gapS),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapM, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.grapeTint,
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      ),
                      child: Text(
                        'Tap the parts! ${_found.length}/4 found',
                        style: AppText.label.copyWith(color: AppColors.grapeInk),
                      ),
                    ),
                    PlantView(
                      plant: _plant,
                      mode: PlantMode.detail,
                      highlight: _part,
                      onPartTap: (p) => setState(() {
                        _part = p;
                        _found.add(p);
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.gapM),
            Wrap(
              spacing: AppSizes.gapS,
              runSpacing: AppSizes.gapS,
              children: [
                for (final p in PlantPart.values)
                  ChunkyButton(
                    label: _partLabel(p),
                    small: true,
                    expand: false,
                    tone: p == _part ? ButtonTone.grape : ButtonTone.white,
                    onPressed: () => setState(() {
                      _part = p;
                      _found.add(p);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.gapL),
            ChunkyButton(
              label: _locked ? 'SHOW PLANTS' : 'SHOW LOCKED LOOK',
              small: true,
              tone: ButtonTone.white,
              onPressed: () => setState(() => _locked = !_locked),
            ),
            for (final world in [1, 2, 3]) ...[
              const SizedBox(height: AppSizes.gapXl),
              Text('$world · ${_worlds[world - 1]}', style: AppText.heading),
              const SizedBox(height: AppSizes.gapM),
              LayoutBuilder(
                builder: (context, c) {
                  final w = (c.maxWidth - 2 * AppSizes.gapM) / 3;
                  return Wrap(
                    spacing: AppSizes.gapM,
                    runSpacing: AppSizes.gapM,
                    children: [for (final p in PlantCatalog.inWorld(world)) SizedBox(width: w, child: _tile(p))],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tile(PlantInfo p) {
    final selected = p == _plant;
    return ChunkyCard(
      onTap: () => _pick(p),
      semanticLabel: _locked ? 'Mystery plant' : p.name,
      padding: const EdgeInsets.all(AppSizes.gapS),
      radius: AppSizes.radiusM,
      outlineColor: selected ? p.themeColor : null,
      ledgeColor: selected ? p.themeColor : AppColors.borderDeep,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _locked ? AppColors.track : p.tileColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: PlantView(plant: p, locked: _locked),
          ),
          const SizedBox(height: 4),
          Text(
            _locked ? '???' : p.name,
            style: AppText.label.copyWith(color: AppColors.text, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
