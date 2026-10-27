import 'package:drift/drift.dart';

// Database tables (PLAN.md §11). Changing a table means a new schema
// version and a migration step in database.dart. Never edit a released
// version's shape in place.

/// The one student on this phone. Always a single row with id 1.
@DataClassName('ProfileRow')
class Profile extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get name => text().withDefault(const Constant('Explorer'))();
  IntColumn get grade => integer().withDefault(const Constant(3))();
  TextColumn get avatarId => text().withDefault(const Constant('boy_cap'))();
  DateTimeColumn get joinedAt => dateTime()();
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();
  BoolColumn get soundOn => boolean().withDefault(const Constant(true))();
  BoolColumn get autoRead => boolean().withDefault(const Constant(true))();

  /// 'slow' or 'normal'.
  TextColumn get speechRate => text().withDefault(const Constant('normal'))();

  /// An offline voice name, or null for Automatic.
  TextColumn get voiceId => text().nullable()();

  /// 'cheerful', 'normal' or 'calm'.
  TextColumn get voiceStyle => text().withDefault(const Constant('cheerful'))();
  BoolColumn get lessMotion => boolean().withDefault(const Constant(false))();

  /// Background music (v4). Separate from sound effects.
  BoolColumn get musicOn => boolean().withDefault(const Constant(true))();

  // What Binhi is wearing (v2). Only items bought in the shop show; see Shop.wearable.
  BoolColumn get wearSalakot => boolean().withDefault(const Constant(false))();
  BoolColumn get wearGarland => boolean().withDefault(const Constant(false))();
  BoolColumn get wearSunglasses => boolean().withDefault(const Constant(false))();

  /// A PotPattern name, e.g. 'plain', 'stripes' or 'jeepney'.
  TextColumn get potPattern => text().withDefault(const Constant('plain'))();

  // More slots (v10, PLAN.md §5m): BinhiHat, BinhiGlasses, BinhiNeck,
  // BinhiFriend and BinhiSpot names, or null. The three flags above still
  // mirror the first items, so older backups load the same.
  TextColumn get hat => text().nullable()();
  TextColumn get glasses => text().nullable()();
  TextColumn get neck => text().nullable()();
  TextColumn get friend => text().nullable()();
  TextColumn get spot => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every leaf earned (positive) and spent in the shop (negative, reason
/// 'buy'). Leaves to spend = the sum. Leaves earned (grows Binhi) = the sum
/// of the positive rows, so buying never shrinks Binhi.
@DataClassName('LeafEntry')
class LeavesLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amount => integer()();

  /// 'explore', 'parts', 'correct', 'perfect', 'game', 'badge', 'gift',
  /// 'water' or 'buy'.
  TextColumn get reason => text()();
  TextColumn get plantId => text().nullable()();
  IntColumn get attemptId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('PlantProgressRow')
class PlantProgress extends Table {
  TextColumn get plantId => text()();
  DateTimeColumn get exploredAt => dateTime().nullable()();

  /// Bitmask of parts tapped (see PartBits).
  IntColumn get partsFound => integer().withDefault(const Constant(0))();
  DateTimeColumn get allPartsAt => dateTime().nullable()();

  /// Set the first time this plant's quiz is finished: unlocks the next stop.
  DateTimeColumn get quizDoneAt => dateTime().nullable()();
  IntColumn get bestScore => integer().nullable()();

  @override
  Set<Column> get primaryKey => {plantId};
}

@DataClassName('QuizAttempt')
class QuizAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'plant', 'sprout', 'sapling' or 'review'.
  TextColumn get kind => text()();
  TextColumn get plantId => text().nullable()();
  IntColumn get total => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()();
}

@DataClassName('QuizAnswer')
class QuizAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get attemptId => integer().references(QuizAttempts, #id, onDelete: KeyAction.cascade)();
  TextColumn get questionId => text()();
  TextColumn get chosen => text()();
  BoolColumn get correct => boolean()();
  DateTimeColumn get answeredAt => dateTime()();

  /// One answer per question per attempt, so a fast double tap can never
  /// count twice.
  @override
  List<Set<Column>> get uniqueKeys => [
    {attemptId, questionId},
  ];
}

/// Things bought in Binhi's shop (v3). One row per item, never twice.
@DataClassName('PurchaseRow')
class Purchases extends Table {
  /// An OutfitItem name, e.g. 'salakot'.
  TextColumn get item => text()();
  IntColumn get price => integer()();
  DateTimeColumn get boughtAt => dateTime()();

  @override
  Set<Column> get primaryKey => {item};
}

/// Mini-game wins (v5): one row per game per plant, the first time only,
/// so leaves can't be farmed by replaying.
@DataClassName('GameWinRow')
class GameWins extends Table {
  /// A MiniGame name: 'label', 'grow' or 'match'.
  TextColumn get game => text()();
  TextColumn get plantId => text()();
  DateTimeColumn get wonAt => dateTime()();

  @override
  Set<Column> get primaryKey => {game, plantId};
}

/// Badges already claimed (v6). A badge's reward is paid when its row is
/// added, so it is never paid twice.
@DataClassName('BadgeWinRow')
class BadgeWins extends Table {
  /// A Badge name, e.g. 'backyard'.
  TextColumn get badge => text()();
  DateTimeColumn get wonAt => dateTime()();

  @override
  Set<Column> get primaryKey => {badge};
}

/// Where the child moved things in My Garden (PLAN.md §5d). Pieces not
/// listed stand at their starting spot.
@DataClassName('GardenSpotRow')
class GardenSpots extends Table {
  /// A GardenLayout piece name, e.g. 'plant_gumamela', 'bed', 'deco_bench'.
  TextColumn get piece => text()();
  RealColumn get x => real()();
  RealColumn get y => real()();

  @override
  Set<Column> get primaryKey => {piece};
}

/// Binhi's daily gift and watering (PLAN.md §5e): one row per kind per
/// day it happened.
class DailyCare extends Table {
  /// A DailyKind name: 'gift' or 'water'.
  TextColumn get kind => text()();

  /// "YYYY-MM-DD", local time.
  TextColumn get day => text()();

  @override
  Set<Column> get primaryKey => {kind, day};
}

/// The child's colouring pages (PLAN.md §5l), one per plant.
@DataClassName('ColouringRow')
class Colourings extends Table {
  TextColumn get plantId => text()();

  /// The colours as a base64 PNG (text, so backups stay plain JSON).
  TextColumn get picture => text()();

  /// When it was last hung on the bahay kubo wall; null while it is only a
  /// draft. The leaves are paid the first time it is set.
  DateTimeColumn get hungAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {plantId};
}

/// One row per calendar day the app was opened. Never cleared.
class Visits extends Table {
  /// "YYYY-MM-DD", local time.
  TextColumn get day => text()();

  @override
  Set<Column> get primaryKey => {day};
}
