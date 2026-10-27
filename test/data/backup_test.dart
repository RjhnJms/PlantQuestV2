import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/data/backup.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/garden.dart';
import 'package:plantquest/game/rewards.dart';
import 'package:plantquest/game/rules.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase a;
  late AppDatabase b;

  setUp(() {
    a = AppDatabase(NativeDatabase.memory());
    b = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async {
    await a.close();
    await b.close();
  });

  /// Some of everything: a profile, plants, a quiz, a purchase, a garden move.
  Future<void> play(ProgressRepository repo) async {
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    await repo.recordVisit();
    for (final id in ['sampaguita', 'gumamela', 'makahiya', 'kalamansi', 'malunggay']) {
      await repo.explorePlant(id);
    }
    final quiz = await repo.startQuiz(QuizKind.plant, plantId: 'sampaguita', total: 3);
    for (var q = 0; q < 3; q++) {
      await repo.saveAnswer(quiz, 'q$q', chosen: 'a', correct: q != 1);
    }
    await repo.finishQuiz(quiz);
    await repo.buy(OutfitItem.stripes);
    await repo.moveGardenPiece(GardenLayout.plant('gumamela'), 120, 400);
    await repo.openDailyGift();
  }

  test('everything saved comes back the same on another phone', () async {
    final from = ProgressRepository(a);
    await play(from);
    final bytes = await Backup(a).export();
    final to = ProgressRepository(b);
    await to.saveProfile(name: 'Someone else', grade: 1, avatarId: 'girl_bun');
    await Backup(b).restore(bytes);

    expect((await to.getProfile())!.name, 'Jamie');
    expect(await to.getLeaves(), await from.getLeaves());
    expect(await to.getLeavesEarned(), await from.getLeavesEarned());
    expect(await to.getOwned(), {OutfitItem.stripes});
    expect(await to.getGardenSpots(), await from.getGardenSpots());
    final aRows = await a.customSelect('SELECT COUNT(*) AS n FROM quiz_answers').getSingle();
    final bRows = await b.customSelect('SELECT COUNT(*) AS n FROM quiz_answers').getSingle();
    expect(bRows.read<int>('n'), aRows.read<int>('n'));
    // And the saved file is readable JSON with a clear label.
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    expect(json['app'], Backup.marker);
  });

  test('a wrong file or one from a newer app changes nothing', () async {
    final repo = ProgressRepository(a);
    await play(repo);
    final before = await repo.getLeaves();
    await expectLater(
      Backup(a).restore(utf8.encode('hello')),
      throwsA(isA<BackupException>().having((e) => e.problem, 'problem', BackupProblem.notABackup)),
    );
    final newer = jsonDecode(utf8.decode(await Backup(a).export())) as Map<String, Object?>;
    newer['schema'] = a.schemaVersion + 1;
    await expectLater(
      Backup(a).restore(utf8.encode(jsonEncode(newer))),
      throwsA(isA<BackupException>().having((e) => e.problem, 'problem', BackupProblem.tooNew)),
    );
    expect(await repo.getLeaves(), before);
  });

  test('an older backup (missing newer tables and columns) still loads', () async {
    await play(ProgressRepository(a));
    final old = jsonDecode(utf8.decode(await Backup(a).export())) as Map<String, Object?>;
    old['schema'] = 5;
    final tables = old['tables']! as Map<String, Object?>;
    tables.remove('garden_spots');
    tables.remove('daily_care');
    for (final row in (tables['profile']! as List).cast<Map<String, Object?>>()) {
      row.remove('music_on');
    }
    await Backup(b).restore(utf8.encode(jsonEncode(old)));
    final to = ProgressRepository(b);
    expect((await to.getProfile())!.name, 'Jamie');
    expect((await to.getProfile())!.musicOn, isTrue, reason: 'the default');
    expect(await to.getGardenSpots(), isEmpty);
  });

  test('file names are tidy', () {
    expect(Backup.fileName('Ma. Cristine', DateTime(2026, 10, 6)), 'PlantQuest-MaCristine-2026-10-06.json');
    expect(Backup.fileName(null, DateTime(2026, 1, 2)), 'PlantQuest-Explorer-2026-01-02.json');
  });
}
