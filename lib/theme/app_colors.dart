import 'package:flutter/painting.dart';

/// Every color in PlantQuest lives here. Screens and widgets never use
/// `Color(0x...)` directly — they pick a token from this file or from
/// [WorldTheme] in `world_themes.dart`.
///
/// Rule from PLAN.md §10: bright fills carry navy text. White text is only
/// allowed on [grape] (large bold text) and [grapeInk] (any size).
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFFFFF9EC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFF0E6D0);

  /// The darker ledge under white cards and buttons that makes them look 3D.
  static const borderDeep = Color(0xFFE3D6BA);

  /// Empty part of progress bars, disabled buttons, locked tiles.
  static const track = Color(0xFFEFE6D2);

  // Text
  static const text = Color(0xFF263046);
  static const textMuted = Color(0xFF6E7191);
  static const onGrape = Color(0xFFFFFFFF);

  // Leaf green: main buttons, progress, correct
  static const leaf = Color(0xFF4CC35A);
  static const leafDark = Color(0xFF2E9142);
  static const leafLight = Color(0xFFA6E58A);
  static const leafTint = Color(0xFFE6F8DD);

  // Sky blue: skies, selected answer
  static const sky = Color(0xFF6EC6FF);
  static const skyDark = Color(0xFF3BA4E6);
  static const skyLight = Color(0xFFB8E8FF);
  static const skyTint = Color(0xFFE5F5FF);

  // Sunshine: rewards, finished stops, the sun
  static const sunshine = Color(0xFFFFC93C);
  static const sunshineDark = Color(0xFFF2A100);
  static const sunshineTint = Color(0xFFFFF1C7);

  // Coral: Binhi's pot, gentle try again
  static const coral = Color(0xFFFF7F66);
  static const coralDark = Color(0xFFE5604A);
  static const coralLight = Color(0xFFFFB38A);
  static const coralTint = Color(0xFFFFE8E0);

  // Grape: quests and level badges
  static const grape = Color(0xFF8E6CFF);
  static const grapeDark = Color(0xFF6B4FD8);
  static const grapeInk = Color(0xFF7E60E2);
  static const grapeTint = Color(0xFFEFEAFF);

  // Bubblegum: blush, flowers, avatars
  static const bubblegum = Color(0xFFFF8AC4);
  static const bubblegumDark = Color(0xFFE5619F);
  static const bubblegumTint = Color(0xFFFFE6F2);

  // Earth tones for artwork: soil, seeds, bark
  static const soil = Color(0xFF7A4E2D);
  static const soilDark = Color(0xFF5C3A20);
  static const bark = Color(0xFFA8743F);
  static const barkDark = Color(0xFF74502B);

  // Plant artwork
  static const foliage = Color(0xFF3FAE4F);
  static const foliageDark = Color(0xFF2B7F3A);
  static const hibiscusRed = Color(0xFFF0445A);
  static const hibiscusDark = Color(0xFFC22A40);
  static const stemRed = Color(0xFFC0566A);
  static const citrusOrange = Color(0xFFFFA530);
  static const mangoYellow = Color(0xFFFFC23D);
  static const mangoOrange = Color(0xFFFF8F3A);
  static const bananaYellow = Color(0xFFE8E061);
  static const bananaHeart = Color(0xFF9C3D6E);
  static const coconutGreen = Color(0xFF8BBF4A);
  static const coconutBrown = Color(0xFF9A6A3F);
  static const palmTrunk = Color(0xFFB59A7A);
  static const narraYellow = Color(0xFFFFD43B);
  static const bamboo = Color(0xFF8CCB4E);
  static const bambooDark = Color(0xFF5E9A2E);
  static const podGreen = Color(0xFF4E8A35);
  static const riceGold = Color(0xFFF2C14E);
  static const kangkongPink = Color(0xFFE59BD6);
  static const water = Color(0xFF7FD6E8);
  static const waterDark = Color(0xFF3FB0C9);
  static const soilLight = Color(0xFFD9B98C);
  static const soilMid = Color(0xFFC49A68);

  // Avatar skin tones, light to deep
  static const skinLight = Color(0xFFF6D5B8);
  static const skinLightMedium = Color(0xFFEBBF98);
  static const skinMedium = Color(0xFFD9A273);
  static const skinTan = Color(0xFFC48858);
  static const skinBrown = Color(0xFFA36A42);
  static const skinDeep = Color(0xFF7A4B2D);

  // Avatar hair
  static const hairBlack = Color(0xFF2B2532);
  static const hairDarkBrown = Color(0xFF4B3225);
  static const hairBrown = Color(0xFF7A4B2C);
  static const hairAuburn = Color(0xFF94502F);

  // Ocean teal: water topics, Kalikasan accents
  static const teal = Color(0xFF22C1C3);
  static const tealDark = Color(0xFF14989A);
  static const tealTint = Color(0xFFDDF6F6);

  /// Text and fill pairs the UI actually uses. `test/theme/contrast_test.dart`
  /// checks each one against WCAG AA so a palette tweak can't quietly break
  /// readability.
  static const textPairs = <ContrastPair>[
    ContrastPair('text on background', text, background),
    ContrastPair('text on card', text, card),
    ContrastPair('muted on background', textMuted, background),
    ContrastPair('muted on card', textMuted, card),
    ContrastPair('text on leaf', text, leaf),
    ContrastPair('text on leafLight', text, leafLight),
    ContrastPair('text on leafTint', text, leafTint),
    ContrastPair('text on sky', text, sky),
    ContrastPair('text on skyTint', text, skyTint),
    ContrastPair('text on sunshine', text, sunshine),
    ContrastPair('text on sunshineTint', text, sunshineTint),
    ContrastPair('text on coral', text, coral),
    ContrastPair('text on coralLight', text, coralLight),
    ContrastPair('text on coralTint', text, coralTint),
    ContrastPair('text on bubblegum', text, bubblegum),
    ContrastPair('text on bubblegumTint', text, bubblegumTint),
    ContrastPair('text on teal', text, teal),
    ContrastPair('text on tealTint', text, tealTint),
    ContrastPair('text on grapeTint', text, grapeTint),
    ContrastPair('text on track', text, track),
    ContrastPair('white on grapeInk', onGrape, grapeInk),
    ContrastPair('white on grape (large)', onGrape, grape, largeText: true),
  ];
}

/// A foreground/background pair to check for readable contrast.
class ContrastPair {
  const ContrastPair(this.name, this.foreground, this.background, {this.largeText = false});

  final String name;
  final Color foreground;
  final Color background;

  /// Large text (≥ 18.66 px bold or ≥ 24 px) only needs 3:1 instead of 4.5:1.
  final bool largeText;

  double get ratio {
    final a = foreground.computeLuminance();
    final b = background.computeLuminance();
    final hi = a > b ? a : b;
    final lo = a > b ? b : a;
    return (hi + 0.05) / (lo + 0.05);
  }

  double get required => largeText ? 3.0 : 4.5;
}
