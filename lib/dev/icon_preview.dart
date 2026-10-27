import 'package:flutter/material.dart';

import '../art/icons/kid_icon.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/chunky_card.dart';

// Icon style ideas, as still sheets (nothing works). Browser: #/icon-preview

const _names = {
  KidIcon.home: 'Home',
  KidIcon.plants: 'Plants',
  KidIcon.quiz: 'Quiz',
  KidIcon.shop: 'Shop',
  KidIcon.profile: 'Profile',
  KidIcon.leaf: 'Leaves',
  KidIcon.sun: 'Days',
  KidIcon.trophy: 'Best',
  KidIcon.lock: 'Locked',
  KidIcon.speaker: 'Listen',
  KidIcon.settings: 'Settings',
  KidIcon.check: 'Done',
  KidIcon.idea: 'Did you know',
  KidIcon.label: 'Label it',
  KidIcon.grow: 'Grow it',
  KidIcon.match: 'Match it',
};

/// Today's Material icons, for comparing.
const _material = {
  KidIcon.home: Icons.home_rounded,
  KidIcon.plants: Icons.local_florist_rounded,
  KidIcon.quiz: Icons.extension_rounded,
  KidIcon.shop: Icons.storefront_rounded,
  KidIcon.profile: Icons.person_rounded,
  KidIcon.leaf: Icons.eco_rounded,
  KidIcon.sun: Icons.wb_sunny_rounded,
  KidIcon.trophy: Icons.emoji_events_rounded,
  KidIcon.lock: Icons.lock_rounded,
  KidIcon.speaker: Icons.volume_up_rounded,
  KidIcon.settings: Icons.settings_rounded,
  KidIcon.check: Icons.check_circle_rounded,
  KidIcon.idea: Icons.lightbulb_rounded,
  KidIcon.label: Icons.label_rounded,
  KidIcon.grow: Icons.spa_rounded,
  KidIcon.match: Icons.join_inner_rounded,
};

class IconPreview extends StatefulWidget {
  const IconPreview({super.key});

  @override
  State<IconPreview> createState() => _IconPreviewState();
}

class _IconPreviewState extends State<IconPreview> {
  KidIconStyle? _style = KidIconStyle.sticker;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Wrap(
            spacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Now'),
                selected: _style == null,
                onSelected: (_) => setState(() => _style = null),
              ),
              for (final s in KidIconStyle.values)
                ChoiceChip(label: Text(s.title), selected: _style == s, onSelected: (_) => setState(() => _style = s)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(child: IconSheet(style: _style)),
          ),
        ],
      ),
    ),
  );
}

/// One style on a sheet: the whole set, then the icons in place.
class IconSheet extends StatelessWidget {
  const IconSheet({super.key, required this.style});

  /// Null shows today's Material icons.
  final KidIconStyle? style;

  Widget _icon(KidIcon i, double size, {bool muted = false}) {
    final s = style;
    if (s != null) return KidIconView(i, size: size, style: s, muted: muted);
    return Icon(_material[i] ?? Icons.circle, size: size * 0.8, color: muted ? AppColors.textMuted : AppColors.text);
  }

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    padding: const EdgeInsets.all(AppSizes.gutter),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(style == null ? 'Now · Material icons' : '${style!.title} icons', style: AppText.title),
        Text(style?.line ?? 'Standard icons, one color', style: AppText.bodySmall),
        const SizedBox(height: AppSizes.gapL),
        ChunkyCard(
          padding: const EdgeInsets.all(AppSizes.gapM),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            runSpacing: AppSizes.gapM,
            children: [
              for (final i in KidIcon.values.where((i) => style != null || _material.containsKey(i)))
                SizedBox(
                  width: 82,
                  child: Column(
                    children: [
                      _icon(i, 48),
                      const SizedBox(height: 4),
                      Text(_names[i] ?? i.name, style: AppText.label.copyWith(color: AppColors.text, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.gapL),
        const Text('In the bottom bar', style: AppText.heading),
        const SizedBox(height: AppSizes.gapS),
        Container(
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: AppColors.border, width: 2),
          ),
          child: Row(
            children: [
              for (final (n, i) in [
                (0, KidIcon.home),
                (1, KidIcon.plants),
                (2, KidIcon.quiz),
                (3, KidIcon.shop),
                (4, KidIcon.profile),
              ])
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: n == 0 ? AppColors.leafTint : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSizes.radiusS),
                        ),
                        child: _icon(i, 32, muted: n != 0),
                      ),
                      Text(
                        _names[i]!,
                        style: AppText.label.copyWith(
                          fontSize: 12,
                          color: n == 0 ? AppColors.text : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.gapL),
        const Text('Counters and buttons', style: AppText.heading),
        const SizedBox(height: AppSizes.gapS),
        Row(
          children: [
            _pill(_icon(KidIcon.sun, 28), '3'),
            const SizedBox(width: 6),
            _pill(_icon(KidIcon.leaf, 28), '49'),
            const SizedBox(width: 6),
            _pill(_icon(KidIcon.trophy, 28), '4/5'),
            const Spacer(),
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.skyTint, shape: BoxShape.circle),
              child: _icon(KidIcon.speaker, 32),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.gapM),
        Row(
          children: [
            for (final (i, label, left) in [
              (KidIcon.label, 'Label it', false),
              (KidIcon.grow, 'Grow it', true),
              (KidIcon.match, 'Match it', true),
            ]) ...[
              Expanded(
                child: ChunkyCard(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppSizes.gapS),
                  child: Column(
                    children: [
                      _icon(i, 40),
                      Text(label, style: AppText.label.copyWith(color: AppColors.text)),
                      if (left)
                        Text('+3', style: AppText.label.copyWith(color: AppColors.leafDark))
                      else
                        _icon(KidIcon.check, 20),
                    ],
                  ),
                ),
              ),
              if (i != KidIcon.match) const SizedBox(width: AppSizes.gapS),
            ],
          ],
        ),
        const SizedBox(height: AppSizes.gapM),
        ChunkyCard(
          color: AppColors.background,
          padding: const EdgeInsets.all(AppSizes.gapM),
          child: Row(
            children: [
              _icon(KidIcon.lock, 30, muted: style == null),
              const SizedBox(width: AppSizes.gapS),
              Expanded(
                child: Text('3 more to discover', style: AppText.heading.copyWith(color: AppColors.textMuted)),
              ),
              _icon(KidIcon.idea, 30),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _pill(Widget icon, String value) => Container(
    padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 3))],
    ),
    child: Row(
      children: [
        icon,
        const SizedBox(width: 6),
        Text(value, style: AppText.heading),
      ],
    ),
  );
}
