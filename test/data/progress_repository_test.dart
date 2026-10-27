import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi_outfit.dart';
import 'package:plantquest/art/binhi/binhi_stage.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/art/avatars/animal_avatar.dart';
import 'package:plantquest/game/badges.dart';
import 'package:plantquest/game/rewards.dart';
import 'package:plantquest/game/rules.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase db;
  late ProgressRepository repo;
  var now = DateTime(2026, 10, 15, 9);

  setUp(() {
    now = DateTime(2026, 10, 15, 9);
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressRepository(db, clock: () => now);
  });

  tearDown(() => db.close());

  /// Plays a quiz: [correct] right answers out of [total].
  Future<QuizResult> play(QuizKind kind, int correct, int total, {String? plantId}) async {
    final id = await repo.startQuiz(kind, plantId: plantId, total: total);
    for (var i = 0; i < total; i++) {
      await repo.saveAnswer(id, 'q$i', chosen: 'a', correct: i < correct);
    }
    return repo.finishQuiz(id);
  }

  group('profile', () {
    test('first save marks onboarded and sets joined date; edits keep it', () async {
      expect(await repo.getProfile(), isNull);
      await repo.saveProfile(name: '  Jamie ', grade: 4, avatarId: 'boy_spiky');
      var p = (await repo.getProfile())!;
      expect(p.name, 'Jamie');
      expect(p.onboarded, isTrue);
      expect(p.joinedAt, now);

      now = DateTime(2026, 11, 2);
      await repo.saveProfile(name: 'Jay', grade: 5, avatarId: 'girl_bob');
      p = (await repo.getProfile())!;
      expect(p.name, 'Jay');
      expect(p.grade, 5);
      expect(p.joinedAt, DateTime(2026, 10, 15, 9), reason: 'joined date never changes');
    });

    test('Skip (no name) becomes Explorer', () async {
      await repo.saveProfile(name: null, grade: 2, avatarId: 'girl_puffs');
      expect((await repo.getProfile())!.name, 'Explorer');
    });

    test('settings change only what is given, even before onboarding', () async {
      await repo.updateSettings(soundOn: false);
      var p = (await repo.getProfile())!;
      expect(p.soundOn, isFalse);
      expect(p.onboarded, isFalse);
      await repo.updateSettings(speechRate: 'slow', voiceId: const Value('en-us-x-voice'), lessMotion: true);
      p = (await repo.getProfile())!;
      expect(p.soundOn, isFalse);
      expect(p.speechRate, 'slow');
      expect(p.voiceId, 'en-us-x-voice');
      expect(p.lessMotion, isTrue);
      await repo.updateSettings(voiceId: const Value(null));
      expect((await repo.getProfile())!.voiceId, isNull, reason: 'back to Automatic');
    });
  });

  group('leaves for exploring', () {
    test('+5 the first time a plant is opened, never again', () async {
      expect(await repo.explorePlant('sampaguita'), 5);
      expect(await repo.explorePlant('sampaguita'), 0);
      expect(await repo.getLeaves(), 5);
    });

    test('+3 only when the fourth part is found, once', () async {
      expect(await repo.markPartFound('gumamela', PartBits.root), 0);
      expect(await repo.markPartFound('gumamela', PartBits.root), 0);
      expect(await repo.markPartFound('gumamela', PartBits.stem), 0);
      expect(await repo.markPartFound('gumamela', PartBits.leaf), 0);
      expect(await repo.markPartFound('gumamela', PartBits.special), 3);
      expect(await repo.markPartFound('gumamela', PartBits.leaf), 0);
      expect(await repo.getLeaves(), 3);
    });
  });

  group('quizzes', () {
    test('PLAN.md example: 2/3 → +4, 2/3 → +0, 3/3 → +7', () async {
      expect((await play(QuizKind.plant, 2, 3, plantId: 'sampaguita')).leavesEarned, 4);
      expect((await play(QuizKind.plant, 2, 3, plantId: 'sampaguita')).leavesEarned, 0);
      expect((await play(QuizKind.plant, 3, 3, plantId: 'sampaguita')).leavesEarned, 7);
      expect((await play(QuizKind.plant, 3, 3, plantId: 'sampaguita')).leavesEarned, 0);
      expect(await repo.getLeaves(), 11);
    });

    test('bests are kept per quiz: a new plant starts from zero', () async {
      await play(QuizKind.plant, 3, 3, plantId: 'sampaguita');
      expect((await play(QuizKind.plant, 2, 3, plantId: 'gumamela')).leavesEarned, 4);
      expect((await play(QuizKind.sprout, 4, 5)).leavesEarned, 8);
      expect((await play(QuizKind.sapling, 4, 10)).leavesEarned, 8, reason: 'Sapling has its own best');
    });

    test('a double-tapped answer counts once', () async {
      final id = await repo.startQuiz(QuizKind.plant, plantId: 'makahiya', total: 3);
      await repo.saveAnswer(id, 'q1', chosen: 'a', correct: true);
      await repo.saveAnswer(id, 'q1', chosen: 'a', correct: true);
      await repo.saveAnswer(id, 'q2', chosen: 'b', correct: false);
      final result = await repo.finishQuiz(id);
      expect(result.score, 1);
      expect(result.leavesEarned, 2);
    });

    test('finishing twice (a retried save) does not pay twice', () async {
      final id = await repo.startQuiz(QuizKind.plant, plantId: 'kalamansi', total: 3);
      for (var i = 0; i < 3; i++) {
        await repo.saveAnswer(id, 'q$i', chosen: 'a', correct: true);
      }
      final first = await repo.finishQuiz(id);
      final again = await repo.finishQuiz(id);
      expect(first.leavesEarned, 11);
      expect(again.leavesEarned, 11);
      expect(await repo.getLeaves(), 11);
    });

    test('finishing a plant quiz unlocks the next stop, whatever the score', () async {
      await play(QuizKind.plant, 0, 3, plantId: 'sampaguita');
      final rows = await repo.watchPlantProgress().first;
      final path = PathState.from({
        for (final r in rows.values)
          if (r.quizDoneAt != null) r.plantId,
      });
      expect(path.of('sampaguita'), StopState.done);
      expect(path.of('gumamela'), StopState.current);
      expect(rows['sampaguita']!.bestScore, 0);
    });

    test('Results knows when Binhi grows', () async {
      await repo.explorePlant('sampaguita'); // 5 leaves, still a seed
      final result = await play(QuizKind.plant, 3, 3, plantId: 'sampaguita'); // +11 → 16
      expect(result.stageBefore, BinhiStage.seed);
      expect(result.stageAfter, BinhiStage.sprout);
      expect(result.grew, isTrue);
    });

    test('best level score compares fractions', () async {
      expect(await repo.watchBestLevelScore().first, isNull);
      await play(QuizKind.sprout, 4, 5);
      await play(QuizKind.sapling, 9, 10);
      expect(await repo.watchBestLevelScore().first, (9, 10));
    });
  });

  group('days visited', () {
    test('counts each calendar day once', () async {
      await repo.recordVisit();
      await repo.recordVisit();
      expect(await repo.watchDaysVisited().first, 1);
      now = DateTime(2026, 10, 16, 7);
      await repo.recordVisit();
      expect(await repo.watchDaysVisited().first, 2);
    });
  });

  test('mini-game wins pay once per game per plant; Start over clears them', () async {
    expect(await repo.winGame(MiniGame.label, 'sampaguita', 3), 3);
    expect(await repo.winGame(MiniGame.label, 'sampaguita', 3), 0);
    expect(await repo.winGame(MiniGame.grow, 'sampaguita', 3), 3);
    expect(await repo.winGame(MiniGame.label, 'gumamela', 3), 3);
    expect(await repo.getLeaves(), 9);
    expect(await repo.getGameWins(), {
      (MiniGame.label, 'sampaguita'),
      (MiniGame.grow, 'sampaguita'),
      (MiniGame.label, 'gumamela'),
    });
    await repo.startOver();
    expect(await repo.getGameWins(), isEmpty);
    expect(await repo.winGame(MiniGame.label, 'sampaguita', 3), 3);
  });

  test('badges: claimed once, leaves paid once, Start over clears them', () async {
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    expect(await repo.claimNewBadges(), isEmpty);
    for (final id in ['sampaguita', 'gumamela', 'makahiya', 'kalamansi', 'malunggay']) {
      await play(QuizKind.plant, 1, 3, plantId: id);
    }
    final before = await repo.getLeaves();
    final fresh = await repo.claimNewBadges();
    expect(fresh, [Achievement.firstSprout, Achievement.backyard]);
    expect(await repo.getLeaves(), before + Achievement.firstSprout.leaves, reason: 'tarsier badge pays no leaves');
    expect(await repo.claimNewBadges(), isEmpty, reason: 'never twice');
    expect(await repo.getLeaves(), before + Achievement.firstSprout.leaves);

    await repo.setAvatar(AnimalIds.of(AnimalAvatar.tarsier));
    expect((await repo.getProfile())!.avatarId, 'animal_tarsier');
    expect((await repo.getProfile())!.name, 'Jamie', reason: 'only the avatar changes');

    await repo.startOver();
    expect(await repo.getBadges(), isEmpty);
  });

  group('rewards and shop', () {
    test("a plant quiz's first finish gives its sticker; replays don't", () async {
      final first = await play(QuizKind.plant, 1, 3, plantId: 'sampaguita');
      expect(first.newSticker, 'sampaguita');
      final again = await play(QuizKind.plant, 3, 3, plantId: 'sampaguita');
      expect(again.newSticker, isNull);
      expect((await play(QuizKind.sprout, 5, 5)).newSticker, isNull);
    });

    test('buying spends leaves to spend but never leaves earned (Binhi keeps his size)', () async {
      await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
      await repo.explorePlant('sampaguita'); // 5
      await play(QuizKind.plant, 3, 3, plantId: 'sampaguita'); // 11
      await repo.explorePlant('gumamela'); // 5
      await play(QuizKind.plant, 3, 3, plantId: 'gumamela'); // 11
      expect(await repo.getLeaves(), 32);

      expect(await repo.buy(OutfitItem.sunglasses), isFalse, reason: '40 > 32');
      expect(await repo.buy(OutfitItem.stripes), isTrue);
      expect(await repo.getLeaves(), 12);
      expect(await repo.getLeavesEarned(), 32);
      expect(await repo.watchLeavesEarned().first, 32);
      expect(await repo.getOwned(), {OutfitItem.stripes});
      expect(await repo.buy(OutfitItem.stripes), isFalse, reason: 'never twice');
      expect(await repo.getLeaves(), 12);

      // Bought items go on right away.
      final p = (await repo.getProfile())!;
      expect(ProgressRepository.outfitOf(p), const BinhiOutfit(pattern: PotPattern.stripes));

      // A quiz after shopping: growth counts from leaves earned.
      final r = await play(QuizKind.plant, 2, 3, plantId: 'makahiya');
      expect(r.leavesBefore, 12);
      expect(r.earnedBefore, 32);
      expect(r.stageAfter, BinhiStage.sapling);
    });

    test('every outfit slot is saved; older saves (flags only) still load', () async {
      await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
      const look = BinhiOutfit(
        hat: BinhiHat.crown,
        glasses: BinhiGlasses.hearts,
        neck: BinhiNeck.scarf,
        friend: BinhiFriend.bird,
        pattern: PotPattern.jeepney,
        spot: BinhiSpot.night,
      );
      await repo.saveOutfit(look);
      expect(ProgressRepository.outfitOf((await repo.getProfile())!), look);

      // A profile from before v10: only the three flags were saved.
      final old = (await repo.getProfile())!.copyWith(
        wearSalakot: true,
        wearGarland: true,
        hat: const Value(null),
        glasses: const Value(null),
        neck: const Value(null),
        friend: const Value(null),
        spot: const Value(null),
      );
      expect(
        ProgressRepository.outfitOf(old),
        const BinhiOutfit(salakot: true, garland: true, pattern: PotPattern.jeepney),
      );
    });

    test('Start over empties the shop; the saved outfit no longer shows', () async {
      await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
      await repo.explorePlant('sampaguita');
      await play(QuizKind.plant, 3, 3, plantId: 'sampaguita');
      await repo.explorePlant('gumamela');
      await repo.buy(OutfitItem.stripes);
      await repo.startOver();
      expect(await repo.getOwned(), isEmpty);
      final p = (await repo.getProfile())!;
      expect(Shop.wearable(ProgressRepository.outfitOf(p), await repo.getOwned()), BinhiOutfit.none);
    });
  });

  test('Start over clears progress but keeps name, settings and days', () async {
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    await repo.updateSettings(soundOn: false);
    await repo.recordVisit();
    await repo.explorePlant('sampaguita');
    await play(QuizKind.plant, 3, 3, plantId: 'sampaguita');
    await play(QuizKind.sprout, 5, 5);
    expect(await repo.getLeaves(), greaterThan(0));

    await repo.startOver();

    expect(await repo.getLeaves(), 0);
    expect(await repo.watchPlantProgress().first, isEmpty);
    expect(await repo.watchBestLevelScore().first, isNull);
    final p = (await repo.getProfile())!;
    expect(p.name, 'Jamie');
    expect(p.soundOn, isFalse);
    expect(await repo.watchDaysVisited().first, 1);
    // And the rules start fresh: the same quiz pays again.
    expect((await play(QuizKind.plant, 2, 3, plantId: 'sampaguita')).leavesEarned, 4);
  });

  test('leaves total always equals the sum of the leaves log', () async {
    await repo.explorePlant('sampaguita');
    await play(QuizKind.plant, 2, 3, plantId: 'sampaguita');
    for (final bit in [PartBits.root, PartBits.stem, PartBits.leaf, PartBits.special]) {
      await repo.markPartFound('sampaguita', bit);
    }
    final rows = await db.select(db.leavesLog).get();
    expect(await repo.getLeaves(), rows.fold<int>(0, (s, r) => s + r.amount));
    expect(await repo.getLeaves(), 12);
  });

  group('schema safety', () {
    test('tables match the saved v1 schema (bump the version when they change)', () {
      final snapshot = jsonDecode(
        File('drift_schemas/app/drift_schema_v${db.schemaVersion}.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final saved = {
        for (final e in snapshot['entities'] as List<dynamic>)
          ((e as Map<String, dynamic>)['data'] as Map<String, dynamic>)['name'] as String: {
            for (final c in (e['data'] as Map<String, dynamic>)['columns'] as List<dynamic>)
              (c as Map<String, dynamic>)['name'] as String,
          },
      };
      final current = {
        for (final t in db.allTables) t.actualTableName: {for (final c in t.$columns) c.name},
      };
      expect(current, saved);
    });

    test('progress survives closing and reopening the database file', () async {
      final dir = await Directory.systemTemp.createTemp('plantquest_db');
      final file = File('${dir.path}/plantquest.sqlite');
      try {
        final first = AppDatabase(NativeDatabase(file));
        await ProgressRepository(first).explorePlant('mango');
        await first.close();

        final reopened = AppDatabase(NativeDatabase(file));
        expect(await ProgressRepository(reopened).getLeaves(), 5);
        await reopened.close();
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });
}
