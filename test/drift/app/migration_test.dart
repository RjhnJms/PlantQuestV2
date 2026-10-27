// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:plantquest/data/database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v10.dart' as v10;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    // The app always upgrades straight to its newest version, so each older
    // version is checked against the latest one.
    const versions = GeneratedHelper.versions;
    final latest = versions.last;
    for (final fromVersion in versions.take(versions.length - 1)) {
      test('from $fromVersion to $latest', () async {
        final schema = await verifier.schemaAt(fromVersion);
        final db = AppDatabase(schema.newConnection());
        await verifier.migrateAndValidate(db, latest);
        await db.close();
      });
    }
  });

  // The following template shows how to write tests ensuring your migrations
  // preserve existing data.
  // Testing this can be useful for migrations that change existing columns
  // (e.g. by alterating their type or constraints). Migrations that only add
  // tables or columns typically don't need these advanced tests. For more
  // information, see https://drift.simonbinder.eu/migrations/tests/#verifying-data-integrity
  // TODO: This generated template shows how these tests could be written. Adopt
  // it to your own needs when testing migrations with data integrity.
  test("migration from v1 to the latest keeps a child's progress", () async {
    // Add data to insert into the old database, and the expected rows after the
    // migration.
    // A child's saved progress must survive the update unchanged; the new
    // wardrobe columns start empty.
    const joined = '2026-06-01T08:00:00.000';
    final oldProfileData = <v1.ProfileData>[
      const v1.ProfileData(
        id: 1,
        name: 'Maya',
        grade: 4,
        avatarId: 'girl_bun',
        joinedAt: joined,
        onboarded: 1,
        soundOn: 1,
        autoRead: 0,
        speechRate: 'slow',
        voiceStyle: 'calm',
        lessMotion: 1,
      ),
    ];
    final expectedNewProfileData = <v10.ProfileData>[
      const v10.ProfileData(
        id: 1,
        name: 'Maya',
        grade: 4,
        avatarId: 'girl_bun',
        joinedAt: joined,
        onboarded: 1,
        soundOn: 1,
        autoRead: 0,
        speechRate: 'slow',
        voiceStyle: 'calm',
        lessMotion: 1,
        wearSalakot: 0,
        wearGarland: 0,
        wearSunglasses: 0,
        potPattern: 'plain',
        musicOn: 1,
      ),
    ];

    final oldLeavesLogData = <v1.LeavesLogData>[
      const v1.LeavesLogData(
        id: 1,
        amount: 5,
        reason: 'explore',
        plantId: 'sampaguita',
        createdAt: joined,
      ),
    ];
    final expectedNewLeavesLogData = <v10.LeavesLogData>[
      const v10.LeavesLogData(
        id: 1,
        amount: 5,
        reason: 'explore',
        plantId: 'sampaguita',
        createdAt: joined,
      ),
    ];

    final oldPlantProgressData = <v1.PlantProgressData>[
      const v1.PlantProgressData(
        plantId: 'sampaguita',
        exploredAt: joined,
        partsFound: 15,
        quizDoneAt: joined,
        bestScore: 3,
      ),
    ];
    final expectedNewPlantProgressData = <v10.PlantProgressData>[
      const v10.PlantProgressData(
        plantId: 'sampaguita',
        exploredAt: joined,
        partsFound: 15,
        quizDoneAt: joined,
        bestScore: 3,
      ),
    ];

    final oldQuizAttemptsData = <v1.QuizAttemptsData>[];
    final expectedNewQuizAttemptsData = <v10.QuizAttemptsData>[];

    final oldQuizAnswersData = <v1.QuizAnswersData>[];
    final expectedNewQuizAnswersData = <v10.QuizAnswersData>[];

    final oldVisitsData = <v1.VisitsData>[];
    final expectedNewVisitsData = <v10.VisitsData>[];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 10,
      createOld: v1.DatabaseAtV1.new,
      createNew: v10.DatabaseAtV10.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.profile, oldProfileData);
        batch.insertAll(oldDb.leavesLog, oldLeavesLogData);
        batch.insertAll(oldDb.plantProgress, oldPlantProgressData);
        batch.insertAll(oldDb.quizAttempts, oldQuizAttemptsData);
        batch.insertAll(oldDb.quizAnswers, oldQuizAnswersData);
        batch.insertAll(oldDb.visits, oldVisitsData);
      },
      validateItems: (newDb) async {
        expect(expectedNewProfileData, await newDb.select(newDb.profile).get());
        expect(
          expectedNewLeavesLogData,
          await newDb.select(newDb.leavesLog).get(),
        );
        expect(
          expectedNewPlantProgressData,
          await newDb.select(newDb.plantProgress).get(),
        );
        expect(
          expectedNewQuizAttemptsData,
          await newDb.select(newDb.quizAttempts).get(),
        );
        expect(
          expectedNewQuizAnswersData,
          await newDb.select(newDb.quizAnswers).get(),
        );
        expect(expectedNewVisitsData, await newDb.select(newDb.visits).get());
      },
    );
  });
}
