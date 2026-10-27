import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// PlantQuest's local SQLite database (drift).
///
/// Updates must never wipe a child's progress, so the schema is versioned:
///
/// 1. Change the tables in `tables.dart`.
/// 2. Bump [schemaVersion].
/// 3. Run `dart run drift_dev make-migrations`. It saves the new schema in
///    `drift_schemas/` and writes migration helpers and tests.
/// 4. Add the step in [migration] (`onUpgrade`) and run the tests.
///
/// Version history:
/// - v1: profile, leaves_log, plant_progress, quiz_attempts, quiz_answers,
///   visits.
/// - v2: profile gets wear_salakot, wear_garland, wear_sunglasses and
///   pot_pattern (Binhi's wardrobe).
/// - v3: purchases (Binhi's shop); leaves_log may hold negative 'buy' rows.
/// - v4: profile gets music_on.
/// - v5: game_wins (mini-games).
/// - v6: badge_wins (achievements).
/// - v7: garden_spots (My Garden).
/// - v8: daily_care (daily gift, watering Binhi).
/// - v9: colourings (colouring pages).
/// - v10: profile gets hat, glasses, neck, friend and spot (more shop items).
@DriftDatabase(
  tables: [
    Profile,
    LeavesLog,
    PlantProgress,
    QuizAttempts,
    QuizAnswers,
    Purchases,
    GameWins,
    BadgeWins,
    GardenSpots,
    DailyCare,
    Colourings,
    Visits,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Each released version gets one step here, run in order.
      if (from < 2) {
        await m.addColumn(profile, profile.wearSalakot);
        await m.addColumn(profile, profile.wearGarland);
        await m.addColumn(profile, profile.wearSunglasses);
        await m.addColumn(profile, profile.potPattern);
      }
      if (from < 3) {
        await m.createTable(purchases);
      }
      if (from < 4) {
        await m.addColumn(profile, profile.musicOn);
      }
      if (from < 5) {
        await m.createTable(gameWins);
      }
      if (from < 6) {
        await m.createTable(badgeWins);
      }
      if (from < 7) {
        await m.createTable(gardenSpots);
      }
      if (from < 8) {
        await m.createTable(dailyCare);
      }
      if (from < 9) {
        await m.createTable(colourings);
      }
      if (from < 10) {
        await m.addColumn(profile, profile.hat);
        await m.addColumn(profile, profile.glasses);
        await m.addColumn(profile, profile.neck);
        await m.addColumn(profile, profile.friend);
        await m.addColumn(profile, profile.spot);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
