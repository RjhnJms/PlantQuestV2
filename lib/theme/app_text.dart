import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Text styles. Fredoka is bundled in `assets/fonts/`, so it works offline.
///
/// Sizes are a little larger than a typical app because the readers are
/// 6–12 years old.
abstract final class AppText {
  static const family = 'Fredoka';

  static const display = TextStyle(
    fontFamily: family,
    fontSize: 34,
    height: 1.1,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const title = TextStyle(
    fontFamily: family,
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const heading = TextStyle(
    fontFamily: family,
    fontSize: 21,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const body = TextStyle(
    fontFamily: family,
    fontSize: 18,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const bodySmall = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const label = TextStyle(
    fontFamily: family,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  static const button = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 1,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.text,
  );

  static const number = TextStyle(
    fontFamily: family,
    fontSize: 20,
    height: 1,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
