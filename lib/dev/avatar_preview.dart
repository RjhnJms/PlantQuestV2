import 'package:flutter/material.dart';

import '../art/avatars/animal_avatar.dart';
import '../art/avatars/avatar_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/chunky_card.dart';
import '../widgets/stat_pill.dart';

// Avatar style ideas, as still sheets. Rendered by tool/render_avatars_test.dart.

/// One option on a sheet. [look] null means option C (animal friends).
class AvatarSheet extends StatelessWidget {
  const AvatarSheet({super.key, this.look});

  final AvatarLook? look;

  Widget _avatar(int i, double size) {
    final l = look;
    if (l == null) {
      return i < AnimalAvatar.values.length
          ? AnimalAvatarView(AnimalAvatar.values[i], size: size)
          : AvatarView(avatarId: AvatarSpec.all[i].id, size: size, look: AvatarLook.polished);
    }
    return AvatarView(avatarId: AvatarSpec.all[i].id, size: size, look: l);
  }

  String get _title => look?.title ?? 'C · Animal friends';
  String get _line => look?.line ?? 'Philippine animals to pick from, next to the polished kids';

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.background,
    padding: const EdgeInsets.all(AppSizes.gutter),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_title, style: AppText.title),
        Text(_line, style: AppText.bodySmall),
        const SizedBox(height: AppSizes.gapL),
        ChunkyCard(
          padding: const EdgeInsets.all(AppSizes.gapM),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: AppSizes.gapS,
            runSpacing: AppSizes.gapM,
            children: [
              for (var i = 0; i < 12; i++)
                Column(
                  children: [
                    _avatar(i, 96),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 100,
                      child: Text(
                        look == null && i < AnimalAvatar.values.length
                            ? AnimalAvatar.values[i].label
                            : AvatarSpec.all[i].label.replaceFirst(RegExp('^(Boy|Girl) with '), ''),
                        style: AppText.label.copyWith(color: AppColors.text, fontSize: 12),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.gapL),
        const Text('On Profile', style: AppText.heading),
        const SizedBox(height: AppSizes.gapS),
        ChunkyCard(
          padding: const EdgeInsets.all(AppSizes.gapM),
          child: Row(
            children: [
              _avatar(look == null ? 0 : 6, 76),
              const SizedBox(width: AppSizes.gapM),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Maria', style: AppText.title),
                  Text('Grade 3 · Joined Oct 2026', style: AppText.bodySmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.gapM),
        const Text('On Home', style: AppText.heading),
        const SizedBox(height: AppSizes.gapS),
        Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
          decoration: BoxDecoration(color: AppColors.skyTint, borderRadius: BorderRadius.circular(AppSizes.radiusL)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusL)),
            child: Row(
              children: [
                _avatar(1, 44),
                const SizedBox(width: AppSizes.gapS),
                const Expanded(child: Text('Hi, Juan!', style: AppText.heading)),
                const StatPill.days(value: 3),
                const SizedBox(width: 6),
                const StatPill.leaves(value: 49),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
