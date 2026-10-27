import 'dart:ui';

import '../../theme/app_colors.dart';

enum HairStyle { cap, spiky, afro, sidePart, curlyTop, bowl, longBangs, pigtails, puffs, ponytail, bob, braid }

enum Accessory { sprout, glasses, hairTies, flowerClip, headband }

/// One of the 12 avatars kids pick from (6 boys, 6 girls).
///
/// [id] is what the database stores, so never rename an id once released.
class AvatarSpec {
  const AvatarSpec({
    required this.id,
    required this.isGirl,
    required this.label,
    required this.skin,
    required this.hair,
    required this.hairStyle,
    required this.shirt,
    required this.background,
    this.accessories = const {},
    this.accent = AppColors.bubblegum,
  });

  final String id;
  final bool isGirl;

  /// Short description for screen readers, e.g. "Boy with a red cap".
  final String label;

  final Color skin;
  final Color hair;
  final HairStyle hairStyle;
  final Color shirt;
  final Color background;
  final Set<Accessory> accessories;

  /// Color for caps, ties, headbands.
  final Color accent;

  static const all = <AvatarSpec>[
    // Boys
    AvatarSpec(
      id: 'boy_cap',
      isGirl: false,
      label: 'Boy with a cap',
      skin: AppColors.skinTan,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.cap,
      shirt: AppColors.sky,
      background: AppColors.skyTint,
      accent: AppColors.coral,
    ),
    AvatarSpec(
      id: 'boy_spiky',
      isGirl: false,
      label: 'Boy with spiky hair',
      skin: AppColors.skinLightMedium,
      hair: AppColors.hairDarkBrown,
      hairStyle: HairStyle.spiky,
      shirt: AppColors.leaf,
      background: AppColors.leafTint,
    ),
    AvatarSpec(
      id: 'boy_curly',
      isGirl: false,
      label: 'Boy with curly hair and glasses',
      skin: AppColors.skinDeep,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.afro,
      shirt: AppColors.sunshine,
      background: AppColors.sunshineTint,
      accessories: {Accessory.glasses},
    ),
    AvatarSpec(
      id: 'boy_sidepart',
      isGirl: false,
      label: 'Boy with neat hair',
      skin: AppColors.skinMedium,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.sidePart,
      shirt: AppColors.grape,
      background: AppColors.grapeTint,
    ),
    AvatarSpec(
      id: 'boy_curltop',
      isGirl: false,
      label: 'Boy with short curls',
      skin: AppColors.skinBrown,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.curlyTop,
      shirt: AppColors.teal,
      background: AppColors.tealTint,
    ),
    AvatarSpec(
      id: 'boy_bowl',
      isGirl: false,
      label: 'Boy with a bowl cut',
      skin: AppColors.skinLight,
      hair: AppColors.hairBrown,
      hairStyle: HairStyle.bowl,
      shirt: AppColors.coral,
      background: AppColors.coralTint,
    ),
    // Girls
    AvatarSpec(
      id: 'girl_sprout',
      isGirl: true,
      label: 'Girl with a little sprout',
      skin: AppColors.skinLightMedium,
      hair: AppColors.hairDarkBrown,
      hairStyle: HairStyle.longBangs,
      shirt: AppColors.grape,
      background: AppColors.grapeTint,
      accessories: {Accessory.sprout},
    ),
    AvatarSpec(
      id: 'girl_pigtails',
      isGirl: true,
      label: 'Girl with pigtails',
      skin: AppColors.skinTan,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.pigtails,
      shirt: AppColors.bubblegum,
      background: AppColors.bubblegumTint,
      accessories: {Accessory.hairTies},
      accent: AppColors.sunshine,
    ),
    AvatarSpec(
      id: 'girl_puffs',
      isGirl: true,
      label: 'Girl with puffy hair',
      skin: AppColors.skinDeep,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.puffs,
      shirt: AppColors.sunshine,
      background: AppColors.sunshineTint,
      accessories: {Accessory.hairTies},
      accent: AppColors.bubblegum,
    ),
    AvatarSpec(
      id: 'girl_ponytail',
      isGirl: true,
      label: 'Girl with a ponytail',
      skin: AppColors.skinMedium,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.ponytail,
      shirt: AppColors.teal,
      background: AppColors.tealTint,
      accessories: {Accessory.hairTies},
      accent: AppColors.sunshine,
    ),
    AvatarSpec(
      id: 'girl_bob',
      isGirl: true,
      label: 'Girl with short hair and glasses',
      skin: AppColors.skinLight,
      hair: AppColors.hairAuburn,
      hairStyle: HairStyle.bob,
      shirt: AppColors.leaf,
      background: AppColors.leafTint,
      accessories: {Accessory.headband, Accessory.glasses},
      accent: AppColors.bubblegum,
    ),
    AvatarSpec(
      id: 'girl_braid',
      isGirl: true,
      label: 'Girl with a braid and a flower',
      skin: AppColors.skinBrown,
      hair: AppColors.hairBlack,
      hairStyle: HairStyle.braid,
      shirt: AppColors.coral,
      background: AppColors.coralTint,
      accessories: {Accessory.flowerClip, Accessory.hairTies},
      accent: AppColors.sunshine,
    ),
  ];

  static List<AvatarSpec> get boys => all.where((a) => !a.isGirl).toList();
  static List<AvatarSpec> get girls => all.where((a) => a.isGirl).toList();

  /// Looks up an avatar by id. Unknown ids (e.g. from an older version)
  /// fall back to the first avatar instead of crashing.
  static AvatarSpec byId(String? id) => all.firstWhere((a) => a.id == id, orElse: () => all.first);
}
