import 'package:flutter/material.dart';

import '../art/avatars/avatar_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/avatar_tile.dart';

/// Developer-only preview of the 12 avatars, laid out like Edit profile.
class AvatarGallery extends StatefulWidget {
  const AvatarGallery({super.key});

  @override
  State<AvatarGallery> createState() => _AvatarGalleryState();
}

class _AvatarGalleryState extends State<AvatarGallery> {
  String _selected = AvatarSpec.all[1].id;

  @override
  Widget build(BuildContext context) {
    final spec = AvatarSpec.byId(_selected);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            const Text('Avatars', style: AppText.display),
            const SizedBox(height: AppSizes.gapL),
            Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
                child: AvatarView(avatarId: _selected, size: 132),
              ),
            ),
            const SizedBox(height: AppSizes.gapS),
            Center(child: Text(spec.label, style: AppText.bodySmall)),
            _group('Boys', AvatarSpec.boys),
            _group('Girls', AvatarSpec.girls),
          ],
        ),
      ),
    );
  }

  Widget _group(String title, List<AvatarSpec> specs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.gapXl),
        Text(title, style: AppText.heading.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: AppSizes.gapM),
        LayoutBuilder(
          builder: (context, c) {
            final tile = (c.maxWidth - 2 * AppSizes.gapM) / 3;
            return Wrap(
              spacing: AppSizes.gapM,
              runSpacing: AppSizes.gapM,
              children: [
                for (final s in specs)
                  AvatarTile(
                    avatarId: s.id,
                    label: s.label,
                    size: tile,
                    selected: s.id == _selected,
                    onTap: () => setState(() => _selected = s.id),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
