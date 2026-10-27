import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Accent and scene colors for each world (PLAN.md §10).
///
/// Bakuran = warm sunny yellows and pinks, Bukid = golden rice and fresh
/// greens, Kalikasan = deep forest greens and teals.
class WorldTheme {
  const WorldTheme({
    required this.accent,
    required this.accentDark,
    required this.tint,
    required this.skyTop,
    required this.skyBottom,
    required this.far,
    required this.mid,
    required this.near,
    required this.nearLight,
    required this.detail,
    required this.detailAlt,
  });

  /// Banner and badge fill. Carries navy text.
  final Color accent;

  /// 3D ledge under [accent] fills.
  final Color accentDark;

  /// Soft background wash for cards in this world.
  final Color tint;

  // Scene layers, back to front.
  final Color skyTop;
  final Color skyBottom;

  /// Distant hills, mountains or forest.
  final Color far;

  /// Middle land: hills, rice terraces, mangroves.
  final Color mid;

  /// The ground the path sits on.
  final Color near;

  /// Light stripes and highlights on [near].
  final Color nearLight;

  /// Small details: flowers, grains, ripples.
  final Color detail;
  final Color detailAlt;

  static const bakuran = WorldTheme(
    accent: AppColors.bubblegum,
    accentDark: AppColors.bubblegumDark,
    tint: AppColors.bubblegumTint,
    skyTop: AppColors.sky,
    skyBottom: AppColors.skyLight,
    far: AppColors.leafLight,
    mid: Color(0xFF7FD36B),
    near: Color(0xFF6CCB5F),
    nearLight: Color(0xFF8EDB78),
    detail: AppColors.bubblegum,
    detailAlt: AppColors.sunshine,
  );

  static const bukid = WorldTheme(
    accent: AppColors.sunshine,
    accentDark: AppColors.sunshineDark,
    tint: AppColors.sunshineTint,
    skyTop: AppColors.sky,
    skyBottom: Color(0xFFFFE9B0),
    far: Color(0xFF94CDB4),
    mid: Color(0xFF8FCB3F),
    near: Color(0xFFF2C94C),
    nearLight: Color(0xFFF8DE84),
    detail: Color(0xFFE0A526),
    detailAlt: AppColors.leaf,
  );

  static const kalikasan = WorldTheme(
    accent: AppColors.teal,
    accentDark: AppColors.tealDark,
    tint: AppColors.tealTint,
    skyTop: Color(0xFF4FB6E8),
    skyBottom: Color(0xFFBDEBE6),
    far: Color(0xFF2E7D5B),
    mid: Color(0xFF3FA45B),
    near: Color(0xFF3B9E55),
    nearLight: Color(0xFF55B86C),
    detail: AppColors.teal,
    detailAlt: Color(0xFF8BE3E0),
  );

  /// World number 1–3 to its theme.
  static WorldTheme of(int world) => switch (world) {
    1 => bakuran,
    2 => bukid,
    _ => kalikasan,
  };
}
