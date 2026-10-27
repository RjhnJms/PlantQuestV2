import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../chunky_button.dart';
import 'pop_in.dart';

/// A card that pops up over the screen for a new sticker or outfit
/// (PLAN.md §5b). Returns true if the main button was pressed, false for
/// [secondLabel] or a tap outside.
Future<bool> showRewardMoment(
  BuildContext context, {
  required String title,
  required Widget art,
  required String message,

  /// Shown under the message, e.g. what a badge unlocked.
  Widget? extra,
  Color color = AppColors.coral,
  Color titleColor = AppColors.coralDark,
  String buttonLabel = 'YAY!',
  String? secondLabel,
  bool reduceMotion = false,
  VoidCallback? onShown,
}) async {
  onShown?.call();
  final picked = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0x99263046),
    transitionDuration: Duration(milliseconds: reduceMotion ? 150 : 320),
    // While the card is appearing, the whole screen ignores taps, so the
    // second tap of a quick double tap can't press BUY (or close the card).
    transitionBuilder: (context, a, b, child) => AnimatedBuilder(
      animation: a,
      builder: (context, shown) => AbsorbPointer(absorbing: a.status != AnimationStatus.completed, child: shown),
      child: reduceMotion
          ? FadeTransition(opacity: a, child: child)
          : ScaleTransition(
              scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
              child: FadeTransition(opacity: a, child: child),
            ),
    ),
    pageBuilder: (context, a, b) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.gutter),
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.gapXl),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  border: Border.all(color: color, width: 3),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppText.title.copyWith(color: titleColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSizes.gapM),
                      PopIn(trigger: title, scale: reduceMotion ? 1 : 1.08, child: art),
                      const SizedBox(height: AppSizes.gapS),
                      Text(message, style: AppText.body, textAlign: TextAlign.center),
                      if (extra != null) ...[const SizedBox(height: AppSizes.gapM), extra],
                      const SizedBox(height: AppSizes.gapL),
                      ChunkyButton(label: buttonLabel, onPressed: () => Navigator.of(context).pop(true)),
                      if (secondLabel != null) ...[
                        const SizedBox(height: AppSizes.gapS),
                        ChunkyButton(
                          label: secondLabel,
                          tone: ButtonTone.white,
                          small: true,
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  return picked ?? false;
}
