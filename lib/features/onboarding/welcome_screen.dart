import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/binhi/binhi.dart';
import '../../art/plants/plant_view.dart';
import '../../art/scenes/world_scene.dart';
import '../../content/plant_catalog.dart';
import '../../state/settings.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/sprout_logo.dart';

/// Screen 2: the first thing a new player sees (docs/screens/02-welcome.jpg).
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  static const line = 'Explore the amazing world of plants!';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final still = ref.watch(lessMotionProvider);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Stack(
              children: [
                Positioned.fill(child: WorldScene(world: 1, parallax: false, reduceMotion: still)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(width: 92, child: PlantView(plant: PlantInfo.gumamela)),
                      Binhi(stage: BinhiStage.sprout, size: 96, reduceMotion: still, onTap: () {}),
                      const SizedBox(width: 92, child: PlantView(plant: PlantInfo.kalamansi)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 11,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapL),
                child: Column(
                  children: [
                    const SproutLogo(size: 52),
                    const Text('PlantQuest', style: AppText.display),
                    const SizedBox(height: AppSizes.gapM),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(line, style: AppText.heading, textAlign: TextAlign.center),
                        ),
                        SpeakerButton(text: line),
                      ],
                    ),
                    const Spacer(),
                    ChunkyButton(label: 'GET STARTED', onPressed: () => context.push('/welcome/start')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
