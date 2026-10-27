/// Spacing, radii and tap sizes shared across the app.
abstract final class AppSizes {
  /// Smallest tap target anywhere in the app (PLAN.md §2).
  static const double minTap = 56;

  /// Side padding for screens.
  static const double gutter = 20;

  static const double gapXs = 4;
  static const double gapS = 8;
  static const double gapM = 12;
  static const double gapL = 16;
  static const double gapXl = 24;
  static const double gapXxl = 32;

  static const double radiusS = 14;
  static const double radiusM = 20;
  static const double radiusL = 26;
  static const double radiusPill = 999;

  /// Height of the colored ledge under chunky buttons and cards.
  static const double depth = 5;

  /// Ledge height while pressed. The face sinks by `depth - depthPressed`.
  static const double depthPressed = 1;

  static const double borderWidth = 2;

  // The three icon sizes (PLAN.md design rules). Nothing in between.
  /// Inside pills, ticks, small labels.
  static const double iconSmall = 22;

  /// Buttons, the tab bar, list rows.
  static const double iconMedium = 30;

  /// Game cards, headers, big moments.
  static const double iconLarge = 44;
}
