import 'package:flutter/painting.dart';

import '../art/avatars/animal_avatar.dart';
import '../art/icons/kid_icon.dart';
import '../content/plant_catalog.dart';
import '../theme/app_colors.dart';
import 'rules.dart';

/// Everything the badges look at, read from progress (PLAN.md §5c).
class BadgeFacts {
  const BadgeFacts({
    this.quizDone = const {},
    this.allParts = const {},
    this.perfect = const {},
    this.daysVisited = 0,
    this.bestLevel,
    this.gameWins = const {},
  });

  /// Plant ids whose quiz is finished (one sticker each).
  final Set<String> quizDone;

  /// Plant ids with all four parts found.
  final Set<String> allParts;

  /// Plant ids with a perfect plant quiz.
  final Set<String> perfect;
  final int daysVisited;

  /// Best Sprout or Sapling result as (score, total).
  final (int, int)? bestLevel;
  final Set<(MiniGame, String)> gameWins;

  int _doneIn(int world) => PlantCatalog.inWorld(world).where((p) => quizDone.contains(p.id)).length;
}

/// The 12 badges. Each is earned once; its reward (leaves, or an animal
/// friend to use as an avatar) is paid when it is first claimed.
/// [name]s are stored in the database: never rename one once released.
enum Achievement {
  firstSprout('First Sprout', 'Finish your first plant', KidIcon.grow, AppColors.leaf, leaves: 5),
  partFinder('Part Finder', 'Find all parts on 5 plants', KidIcon.tap, AppColors.grape, leaves: 10),
  backyard('Backyard Explorer', 'Finish World 1', KidIcon.home, AppColors.bubblegum, animal: AnimalAvatar.tarsier),
  quizStar('Quiz Star', 'Get 4 of 5 on a level quiz', KidIcon.trophy, AppColors.sunshine, leaves: 10),
  sharpEye('Sharp Eye', 'Get 5 perfect plant quizzes', KidIcon.check, AppColors.sky, animal: AnimalAvatar.eagle),
  explorerWeek(
    'Explorer Week',
    'Visit on 7 days (any days)',
    KidIcon.sun,
    AppColors.coral,
    animal: AnimalAvatar.pawikan,
  ),
  stickers('Sticker Collector', 'Get 10 stickers', KidIcon.sparkle, AppColors.bubblegum, leaves: 10),
  farm('Farm Explorer', 'Finish World 2', KidIcon.rice, AppColors.sunshine, animal: AnimalAvatar.carabao),
  gameMaster('Game Master', 'Win Label it and Grow it for 5 plants', KidIcon.label, AppColors.sky, leaves: 15),
  matchmaker('Matchmaker', 'Match all 15 plants', KidIcon.match, AppColors.coral, leaves: 15),
  nature('Nature Explorer', 'Finish World 3', KidIcon.tree, AppColors.teal, animal: AnimalAvatar.pilandok),
  plantExpert(
    'Plant Expert',
    'Find every part and finish the quiz of all 15 plants',
    KidIcon.plants,
    AppColors.grape,
    animal: AnimalAvatar.butanding,
  );

  const Achievement(this.title, this.how, this.icon, this.color, {this.leaves = 0, this.animal});

  final String title;
  final String how;
  final KidIcon icon;

  /// Ribbon color.
  final Color color;

  /// Leaves paid when earned (0 for animal badges).
  final int leaves;

  /// The animal friend this badge unlocks, if any.
  final AnimalAvatar? animal;

  /// How far the child is, as (done, goal).
  (int, int) progress(BadgeFacts f) {
    final all = PlantCatalog.all.length;
    return switch (this) {
      firstSprout => (f.quizDone.length.clamp(0, 1), 1),
      partFinder => (f.allParts.length.clamp(0, 5), 5),
      backyard => (f._doneIn(1), 5),
      farm => (f._doneIn(2), 5),
      nature => (f._doneIn(3), 5),
      quizStar => (f.bestLevel != null && f.bestLevel!.$1 * 5 >= f.bestLevel!.$2 * 4 ? 1 : 0, 1),
      sharpEye => (f.perfect.length.clamp(0, 5), 5),
      explorerWeek => (f.daysVisited.clamp(0, 7), 7),
      stickers => (f.quizDone.length.clamp(0, 10), 10),
      gameMaster => (
        PlantCatalog.all
            .where((p) => f.gameWins.contains((MiniGame.label, p.id)) && f.gameWins.contains((MiniGame.grow, p.id)))
            .length
            .clamp(0, 5),
        5,
      ),
      matchmaker => (f.gameWins.where((w) => w.$1 == MiniGame.match).length.clamp(0, all), all),
      plantExpert => (f.quizDone.intersection(f.allParts).length, all),
    };
  }

  bool earned(BadgeFacts f) {
    final (done, goal) = progress(f);
    return done >= goal;
  }

  /// A short goal for small labels (e.g. under a locked animal friend).
  String get shortHow => switch (this) {
    sharpEye => '5 perfect quizzes',
    explorerWeek => 'Visit on 7 days',
    plantExpert => 'Learn all 15 plants',
    gameMaster => 'Both games, 5 plants',
    _ => how,
  };

  /// A cheerful line for the popup.
  String get cheer => switch (this) {
    firstSprout => 'You finished your very first plant!',
    partFinder => 'You found every part on 5 plants!',
    backyard => 'You finished every plant in the Backyard!',
    farm => 'You finished every plant on the Farm!',
    nature => 'You finished every plant in Nature!',
    quizStar => 'You got 4 of 5 or better on a level quiz!',
    sharpEye => 'Five perfect plant quizzes. What sharp eyes!',
    explorerWeek => 'You came back to explore on 7 days!',
    stickers => 'You collected 10 stickers!',
    gameMaster => 'You won both games for 5 plants!',
    matchmaker => 'You matched all 15 plants!',
    plantExpert => 'You know all 15 plants. You are a Plant Expert!',
  };

  static Achievement? byName(String name) => values.asNameMap()[name];
}
