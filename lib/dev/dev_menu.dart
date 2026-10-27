import 'package:flutter/material.dart';

import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/chunky_button.dart';
import 'avatar_gallery.dart';
import 'binhi_gallery.dart';
import 'component_gallery.dart';
import 'plant_gallery.dart';
import 'progress_lab.dart';
import 'rewards_preview.dart';
import 'scene_gallery.dart';

/// Temporary start screen while the real screens are being built.
/// Removed from the app in build step 4.
class DevMenu extends StatelessWidget {
  const DevMenu({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('PlantQuest preview', style: AppText.display),
              const SizedBox(height: AppSizes.gapXs),
              const Text('Work in progress. Pick something to look at.', style: AppText.bodySmall),
              const SizedBox(height: AppSizes.gapXl),
              ChunkyButton(label: 'BINHI', onPressed: () => open(const BinhiGallery())),
              const SizedBox(height: AppSizes.gapM),
              ChunkyButton(label: 'AVATARS', tone: ButtonTone.sky, onPressed: () => open(const AvatarGallery())),
              const SizedBox(height: AppSizes.gapM),
              ChunkyButton(
                label: 'WORLD SCENES',
                tone: ButtonTone.sunshine,
                onPressed: () => open(const SceneGallery()),
              ),
              const SizedBox(height: AppSizes.gapM),
              ChunkyButton(label: 'PLANTS', tone: ButtonTone.grape, onPressed: () => open(const PlantGallery())),
              const SizedBox(height: AppSizes.gapM),
              ChunkyButton(label: 'PROGRESS LAB', tone: ButtonTone.coral, onPressed: () => open(const ProgressLab())),
              const SizedBox(height: AppSizes.gapM),
              ChunkyButton(label: 'REWARD IDEAS', tone: ButtonTone.sky, onPressed: () => open(const RewardsPreview())),
              const SizedBox(height: AppSizes.gapM),
              ChunkyButton(
                label: 'BUILDING BLOCKS',
                tone: ButtonTone.white,
                onPressed: () => open(const ComponentGallery()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
