// DRAFT — for teacher review.
//
// The 15 plants, their worlds and order on the adventure path. Longer text
// (descriptions, part explanations, fun facts, questions) arrives with the
// content step. Ids are stored in the database: never rename one.

import 'dart:ui';

import '../theme/app_colors.dart';

/// The fourth tappable part, named for what kids know the plant for
/// (PLAN.md §14 D3).
enum SpecialPart {
  flower('Flower'),
  fruit('Fruit'),
  grain('Grain'),
  shoot('Shoot'),
  spores('Spores'),
  seedling('Seedling');

  const SpecialPart(this.label);
  final String label;
}

class PlantInfo {
  const PlantInfo({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.world,
    required this.special,
    required this.themeColor,
    required this.tileColor,
  });

  final String id;
  final String name;
  final String scientificName;

  /// 1 Bakuran, 2 Bukid, 3 Kalikasan.
  final int world;
  final SpecialPart special;

  /// The plant's signature color (badges, rings).
  final Color themeColor;

  /// Soft background behind the plant on cards.
  final Color tileColor;

  /// 0–14, the stop number on the path.
  int get order => PlantCatalog.all.indexOf(this);

  static const sampaguita = PlantInfo(
    id: 'sampaguita',
    name: 'Sampaguita',
    scientificName: 'Jasminum sambac',
    world: 1,
    special: SpecialPart.flower,
    themeColor: AppColors.grape,
    tileColor: AppColors.grapeTint,
  );
  static const gumamela = PlantInfo(
    id: 'gumamela',
    name: 'Gumamela',
    scientificName: 'Hibiscus rosa-sinensis',
    world: 1,
    special: SpecialPart.flower,
    themeColor: AppColors.hibiscusRed,
    tileColor: AppColors.coralTint,
  );
  static const makahiya = PlantInfo(
    id: 'makahiya',
    name: 'Makahiya',
    scientificName: 'Mimosa pudica',
    world: 1,
    special: SpecialPart.flower,
    themeColor: AppColors.bubblegum,
    tileColor: AppColors.bubblegumTint,
  );
  static const kalamansi = PlantInfo(
    id: 'kalamansi',
    name: 'Kalamansi',
    scientificName: 'Citrus × microcarpa',
    world: 1,
    special: SpecialPart.fruit,
    themeColor: AppColors.citrusOrange,
    tileColor: AppColors.sunshineTint,
  );
  static const malunggay = PlantInfo(
    id: 'malunggay',
    name: 'Malunggay',
    scientificName: 'Moringa oleifera',
    world: 1,
    special: SpecialPart.fruit,
    themeColor: AppColors.leaf,
    tileColor: AppColors.leafTint,
  );
  static const palay = PlantInfo(
    id: 'palay',
    name: 'Palay',
    scientificName: 'Oryza sativa',
    world: 2,
    special: SpecialPart.grain,
    themeColor: AppColors.riceGold,
    tileColor: AppColors.sunshineTint,
  );
  static const mango = PlantInfo(
    id: 'mango',
    name: 'Mango',
    scientificName: 'Mangifera indica',
    world: 2,
    special: SpecialPart.fruit,
    themeColor: AppColors.mangoOrange,
    tileColor: AppColors.coralTint,
  );
  static const saba = PlantInfo(
    id: 'saba',
    name: 'Saba',
    scientificName: "Musa 'Saba'",
    world: 2,
    special: SpecialPart.fruit,
    themeColor: AppColors.bananaYellow,
    tileColor: AppColors.leafTint,
  );
  static const mongo = PlantInfo(
    id: 'mongo',
    name: 'Mongo',
    scientificName: 'Vigna radiata',
    world: 2,
    special: SpecialPart.fruit,
    themeColor: AppColors.podGreen,
    tileColor: AppColors.leafTint,
  );
  static const niyog = PlantInfo(
    id: 'niyog',
    name: 'Niyog',
    scientificName: 'Cocos nucifera',
    world: 2,
    special: SpecialPart.fruit,
    themeColor: AppColors.coconutBrown,
    tileColor: AppColors.sunshineTint,
  );
  static const narra = PlantInfo(
    id: 'narra',
    name: 'Narra',
    scientificName: 'Pterocarpus indicus',
    world: 3,
    special: SpecialPart.flower,
    themeColor: AppColors.narraYellow,
    tileColor: AppColors.sunshineTint,
  );
  static const kawayan = PlantInfo(
    id: 'kawayan',
    name: 'Kawayan',
    scientificName: 'Bambusa blumeana',
    world: 3,
    special: SpecialPart.shoot,
    themeColor: AppColors.bamboo,
    tileColor: AppColors.leafTint,
  );
  static const pako = PlantInfo(
    id: 'pako',
    name: 'Pako',
    scientificName: 'Diplazium esculentum',
    world: 3,
    special: SpecialPart.spores,
    themeColor: AppColors.teal,
    tileColor: AppColors.tealTint,
  );
  static const bakawan = PlantInfo(
    id: 'bakawan',
    name: 'Bakawan',
    scientificName: 'Rhizophora',
    world: 3,
    special: SpecialPart.seedling,
    themeColor: AppColors.tealDark,
    tileColor: AppColors.tealTint,
  );
  static const kangkong = PlantInfo(
    id: 'kangkong',
    name: 'Kangkong',
    scientificName: 'Ipomoea aquatica',
    world: 3,
    special: SpecialPart.flower,
    themeColor: AppColors.kangkongPink,
    tileColor: AppColors.skyTint,
  );
}

abstract final class PlantCatalog {
  /// In path order.
  static const all = <PlantInfo>[
    PlantInfo.sampaguita,
    PlantInfo.gumamela,
    PlantInfo.makahiya,
    PlantInfo.kalamansi,
    PlantInfo.malunggay,
    PlantInfo.palay,
    PlantInfo.mango,
    PlantInfo.saba,
    PlantInfo.mongo,
    PlantInfo.niyog,
    PlantInfo.narra,
    PlantInfo.kawayan,
    PlantInfo.pako,
    PlantInfo.bakawan,
    PlantInfo.kangkong,
  ];

  static PlantInfo byId(String id) => all.firstWhere((p) => p.id == id);

  static List<PlantInfo> inWorld(int world) => all.where((p) => p.world == world).toList();
}
