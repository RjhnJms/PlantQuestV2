import 'package:flutter/material.dart';

import '../art/binhi/binhi.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';

/// Developer-only preview of Binhi in every stage and mood.
class BinhiGallery extends StatefulWidget {
  const BinhiGallery({super.key});

  @override
  State<BinhiGallery> createState() => _BinhiGalleryState();
}

class _BinhiGalleryState extends State<BinhiGallery> {
  final _controller = BinhiController();
  var _stage = BinhiStage.sprout;
  var _mood = BinhiMood.happy;
  var _still = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            const Text('Binhi', style: AppText.display),
            const Text('Tap Binhi to make him hop.', style: AppText.bodySmall),
            const SizedBox(height: AppSizes.gapL),
            ChunkyCard(
              color: AppColors.skyTint,
              ledgeColor: AppColors.skyLight,
              outlineColor: AppColors.skyLight,
              child: Center(
                child: Binhi(
                  stage: _stage,
                  mood: _mood,
                  size: 180,
                  controller: _controller,
                  reduceMotion: _still,
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: AppSizes.gapL),
            _chips<BinhiStage>(BinhiStage.values, _stage, (s) => setState(() => _stage = s)),
            const SizedBox(height: AppSizes.gapS),
            _chips<BinhiMood>(BinhiMood.values, _mood, (m) => setState(() => _mood = m)),
            const SizedBox(height: AppSizes.gapM),
            Row(
              children: [
                Expanded(
                  child: ChunkyButton(label: 'CHEER', small: true, onPressed: _controller.cheer),
                ),
                const SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: ChunkyButton(
                    label: _still ? 'MOTION ON' : 'LESS MOTION',
                    small: true,
                    tone: ButtonTone.white,
                    onPressed: () => setState(() => _still = !_still),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.gapXl),
            const Text('Every stage and mood', style: AppText.heading),
            const SizedBox(height: AppSizes.gapM),
            for (final stage in BinhiStage.values) ...[
              Text('${stage.name} (${stage.minLeaves}+ leaves)', style: AppText.label),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final mood in BinhiMood.values) Binhi(stage: stage, mood: mood, size: 70, reduceMotion: true),
                ],
              ),
              const SizedBox(height: AppSizes.gapM),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chips<T extends Enum>(List<T> values, T selected, ValueChanged<T> onPick) {
    return Wrap(
      spacing: AppSizes.gapS,
      runSpacing: AppSizes.gapS,
      children: [
        for (final v in values)
          ChunkyButton(
            label: v.name,
            small: true,
            expand: false,
            tone: v == selected ? ButtonTone.sky : ButtonTone.white,
            onPressed: () => onPick(v),
          ),
      ],
    );
  }
}
