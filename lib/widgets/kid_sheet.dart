import 'package:flutter/material.dart';

import '../art/binhi/binhi.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import 'chunky_button.dart';

/// An in-app confirmation (never a system pop-up): Binhi, a question, a big
/// safe choice and a smaller second choice. Returns true when the second
/// (the "do it") choice is picked.
Future<bool> showKidConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String keepLabel,
  required String doLabel,
  BinhiMood mood = BinhiMood.worried,
  BinhiStage stage = BinhiStage.sprout,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.text.withValues(alpha: 0.35),
    builder: (context) => SafeArea(
      child: Container(
        margin: const EdgeInsets.all(AppSizes.gapL),
        padding: const EdgeInsets.fromLTRB(AppSizes.gapXl, AppSizes.gapL, AppSizes.gapXl, AppSizes.gapXl),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Binhi(stage: stage, mood: mood, size: 76, reduceMotion: true),
            const SizedBox(height: AppSizes.gapS),
            Text(title, style: AppText.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.gapS),
            Text(
              message,
              style: AppText.body.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.gapXl),
            ChunkyButton(label: keepLabel, onPressed: () => Navigator.of(context).pop(false)),
            const SizedBox(height: AppSizes.gapM),
            ChunkyButton(
              label: doLabel,
              small: true,
              tone: ButtonTone.coral,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
