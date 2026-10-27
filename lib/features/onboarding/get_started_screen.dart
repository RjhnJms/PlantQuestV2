import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/binhi/binhi.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/sprout_logo.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 3: "Learn. Discover. Grow." (docs/screens/03-get-started.jpg).
class GetStartedScreen extends ConsumerWidget {
  const GetStartedScreen({super.key});

  static const title = 'Learn. Discover. Grow.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapL),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: SquareIconButton.back(context)),
              // Scrolls on small phones (e.g. 360 × 640) so nothing is cut off.
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: AppSizes.gapM),
                  children: [
                    const Center(child: SproutLogo(size: 34, withName: true, nameSize: 26)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(title, style: AppText.title.copyWith(color: AppColors.leafDark)),
                        ),
                        const SpeakerButton(text: title),
                      ],
                    ),
                    const SizedBox(height: AppSizes.gapL),
                    const _Feature(
                      icon: KidIcon.book,
                      color: AppColors.teal,
                      title: 'Learn',
                      line: 'Meet amazing plants.',
                    ),
                    const SizedBox(height: AppSizes.gapM),
                    const _Feature(
                      icon: KidIcon.quiz,
                      color: AppColors.grape,
                      title: 'Discover',
                      line: 'Answer fun questions.',
                    ),
                    const SizedBox(height: AppSizes.gapM),
                    const _Feature(
                      icon: KidIcon.grow,
                      color: AppColors.leaf,
                      title: 'Grow',
                      line: 'Earn leaves to help Binhi grow!',
                    ),
                    const SizedBox(height: AppSizes.gapXl),
                    Center(
                      child: Binhi(
                        stage: BinhiStage.sprout,
                        size: 74,
                        reduceMotion: ref.watch(lessMotionProvider),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              ChunkyButton(label: 'GET STARTED', onPressed: () => context.push('/welcome/start/about')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.color, required this.title, required this.line});

  final KidIcon icon;
  final Color color;
  final String title;
  final String line;

  @override
  Widget build(BuildContext context) {
    return ChunkyCard(
      child: Row(
        children: [
          KidIconView(icon, size: AppSizes.iconLarge),
          const SizedBox(width: AppSizes.gapL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.heading),
                Text(line, style: AppText.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
