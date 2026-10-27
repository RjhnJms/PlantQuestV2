import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../theme/world_themes.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/stat_pill.dart';
import '../art/icons/kid_icon.dart';

/// Developer-only screen showing every building block from build step 1.
///
/// It is the app's home screen until the real screens arrive in step 4,
/// then it moves behind a debug-only route.
class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  int _leaves = 0;
  int _days = 1;
  double _progress = 0.3;
  int? _picked;

  void _earn(int amount) => setState(() {
    _leaves += amount;
    _progress = (_leaves % 10) / 10;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            const Text('Building blocks', style: AppText.display),
            const SizedBox(height: AppSizes.gapXs),
            const Text('Step 1 preview. Tap things!', style: AppText.bodySmall),
            const SizedBox(height: AppSizes.gapXl),

            _section('Stat pills'),
            Row(
              children: [
                StatPill.days(value: _days),
                const SizedBox(width: AppSizes.gapS),
                StatPill.leaves(value: _leaves),
              ],
            ),
            const SizedBox(height: AppSizes.gapM),
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(
                    label: '+2 leaves',
                    small: true,
                    tone: ButtonTone.white,
                    onPressed: () => _earn(2),
                  ),
                ),
                const SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: ChunkyButton(
                    label: '+1 day',
                    small: true,
                    tone: ButtonTone.sunshine,
                    onPressed: () => setState(() => _days++),
                  ),
                ),
              ],
            ),

            _section('Progress bars'),
            AppProgressBar(value: _progress, semanticLabel: 'Binhi growth'),
            const SizedBox(height: AppSizes.gapM),
            const AppProgressBar(value: 0.66, color: AppColors.sunshine, height: 12),
            const SizedBox(height: AppSizes.gapM),
            const AppProgressBar(value: 0.02, color: AppColors.grape, height: 12),

            _section('Buttons'),
            ChunkyButton(label: 'GET STARTED', onPressed: () {}),
            const SizedBox(height: AppSizes.gapM),
            ChunkyButton(label: 'NEXT PLANT', icon: KidIcon.arrow, onPressed: () {}),
            const SizedBox(height: AppSizes.gapM),
            const ChunkyButton(label: 'CHECK', onPressed: null),
            const SizedBox(height: AppSizes.gapM),
            ChunkyButton(label: 'CONTINUE', tone: ButtonTone.coral, onPressed: () {}),
            const SizedBox(height: AppSizes.gapM),
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(label: 'PLAY AGAIN', tone: ButtonTone.white, small: true, onPressed: () {}),
                ),
                const SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: ChunkyButton(label: 'DONE', tone: ButtonTone.white, small: true, onPressed: () {}),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.gapM),
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(label: 'Grape', tone: ButtonTone.grape, small: true, onPressed: () {}),
                ),
                const SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: ChunkyButton(label: 'Sky', tone: ButtonTone.sky, small: true, onPressed: () {}),
                ),
              ],
            ),

            _section('Cards'),
            for (final (i, name) in ['Gumamela', 'Makahiya', 'Sampaguita'].indexed) ...[
              ChunkyCard(
                onTap: () => setState(() => _picked = i),
                outlineColor: _picked == i ? AppColors.skyDark : null,
                color: _picked == i ? AppColors.skyTint : AppColors.card,
                ledgeColor: _picked == i ? AppColors.skyDark : AppColors.borderDeep,
                semanticLabel: name,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _picked == i ? AppColors.sky : AppColors.track,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(String.fromCharCode(65 + i), style: AppText.heading),
                    ),
                    const SizedBox(width: AppSizes.gapM),
                    Text(name, style: AppText.heading),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.gapM),
            ],
            for (final world in [1, 2, 3]) ...[_worldBanner(world), const SizedBox(height: AppSizes.gapM)],
          ],
        ),
      ),
    );
  }

  Widget _worldBanner(int world) {
    final theme = WorldTheme.of(world);
    const names = ['Bakuran', 'Bukid', 'Kalikasan'];
    const subtitles = ['BACKYARD', 'FARM', 'NATURE'];
    return ChunkyCard(
      color: theme.accent,
      ledgeColor: theme.accentDark,
      onTap: () {},
      semanticLabel: 'World $world, ${names[world - 1]}',
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Text('$world', style: AppText.title),
          ),
          const SizedBox(width: AppSizes.gapL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WORLD $world · ${subtitles[world - 1]}', style: AppText.label.copyWith(color: AppColors.text)),
                Text(names[world - 1], style: AppText.title),
                const Text('0 of 5 plants done', style: AppText.body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: AppSizes.gapXl, bottom: AppSizes.gapM),
    child: Text(title, style: AppText.heading),
  );
}
