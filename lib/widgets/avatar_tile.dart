import 'package:flutter/material.dart';

import '../art/avatars/avatar_view.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import 'chunky_card.dart';
import '../art/icons/kid_icon.dart';

/// A pickable avatar card (About you, Edit profile). The selected one gets
/// a green ring and a check badge; a locked animal friend is faded and says
/// how to unlock it.
class AvatarTile extends StatelessWidget {
  const AvatarTile({
    super.key,
    required this.avatarId,
    required this.label,
    required this.selected,
    required this.onTap,
    this.size = 96,
    this.lockedHint,
  });

  final String avatarId;
  final String label;

  /// Not null while locked: e.g. "Finish World 2".
  final String? lockedHint;
  final bool selected;
  final VoidCallback onTap;

  /// Outer width of the tile.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      child: SizedBox(
        width: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ChunkyCard(
              onTap: lockedHint == null ? onTap : null,
              semanticLabel: lockedHint == null ? label : '$label. Locked. $lockedHint.',
              padding: const EdgeInsets.all(AppSizes.gapS),
              radius: AppSizes.radiusM,
              color: selected ? AppColors.leafTint : (lockedHint == null ? AppColors.card : AppColors.background),
              outlineColor: selected ? AppColors.leaf : null,
              ledgeColor: selected ? AppColors.leafDark : AppColors.borderDeep,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Fills the tile (AvatarView sizes itself only when unconstrained).
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, c) => Opacity(
                              opacity: lockedHint == null ? 1 : 0.35,
                              child: AvatarView(avatarId: avatarId, size: c.maxWidth),
                            ),
                          ),
                        ),
                        if (lockedHint != null) const KidIconView(KidIcon.lock, muted: true),
                      ],
                    ),
                  ),
                  if (lockedHint != null)
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          lockedHint!,
                          style: AppText.label.copyWith(color: AppColors.textMuted, fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.leaf,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.card, width: 2.5),
                  ),
                  child: const KidIconView(KidIcon.tick, size: AppSizes.iconSmall),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
