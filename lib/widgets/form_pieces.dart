import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../art/avatars/avatar_view.dart';
import '../game/rules.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import 'avatar_tile.dart';
import 'chunky_card.dart';

/// Shared by About you and Edit profile.

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSizes.gapXl, bottom: AppSizes.gapS),
    child: Text(text, style: AppText.heading),
  );
}

/// Name box: first name or nickname, up to 20 letters.
class NameField extends StatelessWidget {
  const NameField({super.key, required this.controller, this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      borderSide: BorderSide(color: c, width: AppSizes.borderWidth),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 4))],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLength: ProfileRules.maxNameLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            style: AppText.heading,
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: AppText.heading.copyWith(color: AppColors.textMuted),
              counterText: '',
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.gapXl, vertical: 18),
              enabledBorder: border(AppColors.border),
              focusedBorder: border(AppColors.sky),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.gapS),
        const Text('Just your first name or a nickname.', style: AppText.bodySmall),
      ],
    );
  }
}

/// Grades 1–6 in two rows of three.
class GradePicker extends StatelessWidget {
  const GradePicker({super.key, required this.selected, required this.onChanged});

  final int? selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 2 * AppSizes.gapM) / 3;
        return Wrap(
          spacing: AppSizes.gapM,
          runSpacing: AppSizes.gapM,
          children: [
            for (var g = 1; g <= 6; g++)
              SizedBox(
                width: w,
                child: Semantics(
                  selected: g == selected,
                  child: ChunkyCard(
                    onTap: () => onChanged(g),
                    semanticLabel: 'Grade $g',
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.gapS),
                    radius: AppSizes.radiusM,
                    color: g == selected ? AppColors.teal : AppColors.card,
                    ledgeColor: g == selected ? AppColors.tealDark : AppColors.borderDeep,
                    child: Column(
                      children: [
                        Text('Grade', style: AppText.label.copyWith(color: AppColors.text)),
                        Text('$g', style: AppText.title),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// One swipeable row of all 12 avatars (About you).
class AvatarCarousel extends StatelessWidget {
  const AvatarCarousel({super.key, required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 8, right: 8),
        itemCount: AvatarSpec.all.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.gapM),
        itemBuilder: (context, i) {
          final spec = AvatarSpec.all[i];
          return AvatarTile(
            avatarId: spec.id,
            label: spec.label,
            size: 92,
            selected: spec.id == selected,
            onTap: () => onChanged(spec.id),
          );
        },
      ),
    );
  }
}

/// Boys and girls in two grids of three, then animal friends (Edit
/// profile). [animalHints] says how to unlock each animal; animals in
/// [animalsUnlocked] can be picked.
class AvatarGrid extends StatelessWidget {
  const AvatarGrid({
    super.key,
    required this.selected,
    required this.onChanged,
    this.animalsUnlocked = const {},
    this.animalHints = const {},
  });

  final String? selected;
  final ValueChanged<String> onChanged;
  final Set<AnimalAvatar> animalsUnlocked;
  final Map<AnimalAvatar, String> animalHints;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 2 * AppSizes.gapM) / 3;
        Widget group(String title, List<AvatarSpec> specs) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.gapM, bottom: AppSizes.gapS),
              child: Text(title, style: AppText.label),
            ),
            Wrap(
              spacing: AppSizes.gapM,
              runSpacing: AppSizes.gapM,
              children: [
                for (final s in specs)
                  AvatarTile(
                    avatarId: s.id,
                    label: s.label,
                    size: w,
                    selected: s.id == selected,
                    onTap: () => onChanged(s.id),
                  ),
              ],
            ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            group('Boys', AvatarSpec.boys),
            group('Girls', AvatarSpec.girls),
            Padding(
              padding: const EdgeInsets.only(top: AppSizes.gapM, bottom: AppSizes.gapS),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Animal friends', style: AppText.label),
                    TextSpan(text: '  · earn badges to unlock', style: AppText.bodySmall.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ),
            Wrap(
              spacing: AppSizes.gapM,
              runSpacing: AppSizes.gapM,
              children: [
                for (final a in AnimalAvatar.values)
                  AvatarTile(
                    avatarId: AnimalIds.of(a),
                    label: a.label,
                    size: w,
                    selected: AnimalIds.of(a) == selected,
                    lockedHint: animalsUnlocked.contains(a) ? null : animalHints[a],
                    onTap: () => onChanged(AnimalIds.of(a)),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
