import 'package:flutter/material.dart';

import '../art/scenes/world_scene.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../theme/world_themes.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';

/// Developer-only preview of the three world scenes, stacked like the Home
/// adventure path so the parallax can be felt while scrolling.
class SceneGallery extends StatefulWidget {
  const SceneGallery({super.key});

  @override
  State<SceneGallery> createState() => _SceneGalleryState();
}

class _SceneGalleryState extends State<SceneGallery> {
  bool _still = false;

  static const _names = ['Bakuran', 'Bukid', 'Kalikasan'];
  static const _subtitles = ['BACKYARD', 'FARM', 'NATURE'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('World scenes', style: AppText.display),
                  const Text('Scroll slowly: the hills move slower than the path.', style: AppText.bodySmall),
                  const SizedBox(height: AppSizes.gapM),
                  ChunkyButton(
                    label: _still ? 'MOTION ON' : 'LESS MOTION',
                    small: true,
                    tone: ButtonTone.white,
                    onPressed: () => setState(() => _still = !_still),
                  ),
                  const SizedBox(height: AppSizes.gapL),
                  const Text('Header size', style: AppText.heading),
                  const SizedBox(height: AppSizes.gapS),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    child: SizedBox(height: 200, child: WorldScene(world: 1, reduceMotion: _still, parallax: false)),
                  ),
                  const SizedBox(height: AppSizes.gapXl),
                  const Text('Path sections', style: AppText.heading),
                ],
              ),
            ),
            for (final world in [1, 2, 3]) SizedBox(height: 640, child: _section(world)),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }

  Widget _section(int world) {
    final theme = WorldTheme.of(world);
    return Stack(
      children: [
        Positioned.fill(
          child: WorldScene(world: world, reduceMotion: _still),
        ),
        Positioned(
          left: AppSizes.gutter,
          right: AppSizes.gutter,
          bottom: 330,
          child: ChunkyCard(
            color: theme.accent,
            ledgeColor: theme.accentDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WORLD $world · ${_subtitles[world - 1]}', style: AppText.label.copyWith(color: AppColors.text)),
                Text(_names[world - 1], style: AppText.title),
              ],
            ),
          ),
        ),
        // Stand-in path stops, to judge how stops read on the ground.
        for (final (i, x) in [0.3, 0.7, 0.35].indexed)
          Positioned(
            top: 360 + i * 90.0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment(x * 2 - 1, 0),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0 ? AppColors.sunshine : AppColors.card,
                  border: Border.all(color: i == 0 ? AppColors.sunshineDark : AppColors.border, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 5))],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
