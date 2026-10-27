import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/game/rules.dart';

void main() {
  group('QuizReward (only new bests earn leaves)', () {
    QuizReward r(int score, int total, int best, {bool perfectBefore = false}) =>
        QuizReward.compute(score: score, total: total, previousBest: best, hadPerfectBefore: perfectBefore);

    test('PLAN.md example: 2/3, then 2/3 again, then 3/3', () {
      expect(r(2, 3, 0).total, 4);
      expect(r(2, 3, 2).total, 0);
      expect(r(3, 3, 2).total, 7);
    });

    test('perfect first try earns all correct leaves plus the bonus', () {
      final reward = r(5, 5, 0);
      expect(reward.correctLeaves, 10);
      expect(reward.perfectBonus, 5);
      expect(reward.isNewBest, isTrue);
    });

    test('a second perfect earns nothing', () {
      expect(r(3, 3, 3, perfectBefore: true).total, 0);
    });

    test('a worse score earns nothing and is not a new best', () {
      final reward = r(1, 3, 2);
      expect(reward.total, 0);
      expect(reward.isNewBest, isFalse);
    });

    test('zero right on a first try earns nothing', () {
      expect(r(0, 3, 0).total, 0);
    });
  });

  group('PathState', () {
    final ids = PlantCatalog.all.map((p) => p.id).toList();

    test('new player: stop 1 current, everything else locked', () {
      final path = PathState.from({});
      expect(path.of(ids[0]), StopState.current);
      for (final id in ids.skip(1)) {
        expect(path.of(id), StopState.locked, reason: id);
      }
      expect(path.currentId, 'sampaguita');
      expect(path.doneCount, 0);
      expect(path.isWorldOpen(1), isTrue);
      expect(path.isWorldOpen(2), isFalse);
    });

    test('finishing a quiz unlocks the next stop', () {
      final path = PathState.from({'sampaguita'});
      expect(path.of('sampaguita'), StopState.done);
      expect(path.of('gumamela'), StopState.current);
      expect(path.of('makahiya'), StopState.locked);
    });

    test('finishing World 1 opens World 2', () {
      final path = PathState.from(ids.take(5).toSet());
      expect(path.isWorldOpen(2), isTrue);
      expect(path.currentId, 'palay');
      expect(path.doneInWorld(1), 5);
      expect(path.isWorldOpen(3), isFalse);
    });

    test('all done: no current stop', () {
      final path = PathState.from(ids.toSet());
      expect(path.currentId, isNull);
      expect(path.doneCount, 15);
    });

    test('next plant crosses worlds and ends at the last plant', () {
      expect(PathState.nextAfter('malunggay'), 'palay');
      expect(PathState.nextAfter('niyog'), 'narra');
      expect(PathState.nextAfter('kangkong'), isNull);
    });
  });

  group('QuizLevel', () {
    test('grade picks the level', () {
      for (final g in [1, 2, 3, 4]) {
        expect(QuizLevel.forGrade(g), QuizLevel.sprout);
      }
      expect(QuizLevel.forGrade(5), QuizLevel.sapling);
      expect(QuizLevel.forGrade(6), QuizLevel.sapling);
    });

    test('question pool is never smaller than World 1', () {
      final world1 = PlantCatalog.inWorld(1).map((p) => p.id).toSet();
      expect(QuizLevel.questionPool({'sampaguita'}), world1);
      final more = PathState.from(PlantCatalog.all.take(7).map((p) => p.id).toSet()).unlockedIds;
      expect(QuizLevel.questionPool(more), containsAll([...world1, 'palay', 'mango', 'saba']));
      expect(QuizLevel.questionPool(more), isNot(contains('mongo')));
    });
  });

  group('Profile rules', () {
    test('names are trimmed, shortened to 20, and default to Explorer', () {
      expect(ProfileRules.cleanName('  Jamie  '), 'Jamie');
      expect(ProfileRules.cleanName(''), 'Explorer');
      expect(ProfileRules.cleanName(null), 'Explorer');
      expect(ProfileRules.cleanName('   '), 'Explorer');
      expect(ProfileRules.cleanName('Maria  Clara'), 'Maria Clara');
      expect(ProfileRules.cleanName('A' * 30).length, 20);
    });

    test('grade is kept between 1 and 6', () {
      expect(ProfileRules.cleanGrade(0), 1);
      expect(ProfileRules.cleanGrade(9), 6);
      expect(ProfileRules.cleanGrade(4), 4);
    });
  });

  test('part bits', () {
    expect(PartBits.count(0), 0);
    expect(PartBits.count(PartBits.root | PartBits.leaf), 2);
    expect(PartBits.count(PartBits.all), 4);
  });

  test('day key uses local calendar days', () {
    expect(dayKey(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
    expect(dayKey(DateTime(2026, 3, 8, 0, 1)), '2026-03-08');
  });
}
