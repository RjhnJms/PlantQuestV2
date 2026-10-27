import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import 'pressable_3d.dart';
import '../art/icons/kid_icon.dart';

/// Color sets for [ChunkyButton]. Bright fills use navy text (PLAN.md §10).
enum ButtonTone {
  leaf(AppColors.leaf, AppColors.leafDark, AppColors.text),
  white(AppColors.card, AppColors.borderDeep, AppColors.text, AppColors.border),
  coral(AppColors.coral, AppColors.coralDark, AppColors.text),
  grape(AppColors.grape, AppColors.grapeDark, AppColors.onGrape),
  sky(AppColors.sky, AppColors.skyDark, AppColors.text),
  sunshine(AppColors.sunshine, AppColors.sunshineDark, AppColors.text);

  const ButtonTone(this.face, this.ledge, this.foreground, [this.border]);

  final Color face;
  final Color ledge;
  final Color foreground;
  final Color? border;
}

/// The big, pressable game button: GET STARTED, CHECK, CONTINUE, SAVE…
///
/// Pass `onPressed: null` to show the calm disabled state (e.g. CHECK before
/// an answer is picked).
class ChunkyButton extends StatelessWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone = ButtonTone.leaf,
    this.icon,
    this.expand = true,
    this.small = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonTone tone;
  final KidIcon? icon;

  /// Fill the available width (most buttons in PlantQuest do).
  final bool expand;

  /// Smaller text and padding for secondary buttons like "Start over".
  /// Still at least [AppSizes.minTap] tall.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final face = enabled ? tone.face : AppColors.track;
    final ledge = enabled ? tone.ledge : AppColors.borderDeep;
    final foreground = enabled ? tone.foreground : AppColors.textMuted;
    final textStyle = (small ? AppText.button.copyWith(fontSize: 17) : AppText.button).copyWith(color: foreground);

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          KidIconView(icon!, size: small ? AppSizes.iconSmall : AppSizes.iconMedium, muted: !enabled),
          const SizedBox(width: AppSizes.gapS),
        ],
        Flexible(
          // One word ("Cheerful", "Flower") shrinks to fit instead of
          // breaking in the middle; longer labels wrap onto two lines.
          child: label.contains(' ')
              ? Text(label, style: textStyle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, style: textStyle, maxLines: 1),
                ),
        ),
      ],
    );

    return Pressable3D(
      onTap: onPressed,
      faceColor: face,
      ledgeColor: ledge,
      borderColor: enabled ? tone.border : null,
      radius: AppSizes.radiusM,
      minHeight: small ? AppSizes.minTap : AppSizes.minTap + 4,
      highlight: enabled,
      glow: enabled,
      semanticLabel: label,
      padding: EdgeInsets.symmetric(horizontal: small ? AppSizes.gapL : AppSizes.gapXl, vertical: AppSizes.gapM),
      child: Center(widthFactor: 1, child: content),
    );
  }
}
