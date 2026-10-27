import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import 'ticking_number.dart';
import '../art/icons/kid_icon.dart';

/// Small counter pill: days visited, leaves… (Home header, quiz top bar).
///
/// The number ticks up when [value] grows.
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.icon,
    required this.value,
    required this.iconBackground,
    required this.semanticLabel,
  });

  /// Leaves counter preset.
  const StatPill.leaves({super.key, required this.value})
    : icon = KidIcon.leaf,
      iconBackground = AppColors.leafTint,
      semanticLabel = 'Leaves';

  /// Days-visited counter preset.
  const StatPill.days({super.key, required this.value})
    : icon = KidIcon.sun,
      iconBackground = AppColors.sunshineTint,
      semanticLabel = 'Days visited';

  final KidIcon icon;

  /// Null while still loading: shows a dash instead of a wrong 0.
  final int? value;
  final Color iconBackground;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: value == null ? '$semanticLabel: loading' : '$semanticLabel: $value',
      excludeSemantics: true,
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 5, right: AppSizes.gapM),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          border: Border.all(color: AppColors.border, width: AppSizes.borderWidth),
          boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: KidIconView(icon, size: AppSizes.iconSmall),
            ),
            const SizedBox(width: AppSizes.gapS),
            if (value == null)
              Text('–', style: AppText.number.copyWith(fontSize: 18, color: AppColors.textMuted))
            else
              TickingNumber(value: value!, style: AppText.number.copyWith(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
