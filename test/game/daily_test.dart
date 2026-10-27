import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi_outfit.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/daily.dart';
import 'package:plantquest/game/rewards.dart';

void main() {
  test('gifts count through a week of seven, then start again', () {
    expect([for (var n = 1; n <= 8; n++) DailyRules.giftLeaves(n)], [3, 3, 4, 4, 5, 5, 15, 3]);
    expect(DailyRules.weekDay(7), 7);
    expect(DailyRules.weekDay(8), 1);
  });

  test('the flower pot is earned, never for sale', () {
    expect(OutfitItem.flowers.forSale, isFalse);
    expect(OutfitItem.flowers.pattern, PotPattern.flowers);
    expect(Shop.affordable(999, const {}), isNot(contains(OutfitItem.flowers)));
  });

  group('repository', () {
    setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

    late AppDatabase db;
    late ProgressRepository repo;
    var now = DateTime(2026, 10, 20, 8);

    setUp(() {
      now = DateTime(2026, 10, 20, 8);
      db = AppDatabase(NativeDatabase.memory());
      repo = ProgressRepository(db, clock: () => now);
    });
    tearDown(() => db.close());

    test('one gift a day; a missed day just waits', () async {
      expect(await repo.openDailyGift(), (1, 3));
      expect(await repo.openDailyGift(), isNull, reason: 'already opened today');
      now = now.add(const Duration(days: 3));
      expect(await repo.openDailyGift(), (2, 3), reason: 'missed days do not reset');
      now = now.add(const Duration(days: 1));
      expect(await repo.openDailyGift(), (3, 4));
      expect(await repo.getLeaves(), 10);
      expect(await repo.getDailyCount(DailyKind.gift), 3);
    });

    test('watering pays once a day and the 7th day earns the flower pot', () async {
      final first = await repo.waterBinhi();
      expect((first.leaves, first.daysWatered, first.flowerPot), (2, 1, false));
      final again = await repo.waterBinhi();
      expect((again.leaves, again.daysWatered), (0, 1));
      WaterResult last = first;
      for (var d = 2; d <= 7; d++) {
        now = now.add(const Duration(days: 2));
        last = await repo.waterBinhi();
      }
      expect(last.daysWatered, 7);
      expect(last.flowerPot, isTrue);
      expect(await repo.getOwned(), contains(OutfitItem.flowers));
      expect(ProgressRepository.outfitOf((await repo.getProfile())!).pattern, PotPattern.flowers);
      expect(await repo.getLeaves(), 14);
      now = now.add(const Duration(days: 1));
      expect((await repo.waterBinhi()).flowerPot, isFalse, reason: 'earned once');
    });

    test('Start over clears gifts and watering', () async {
      await repo.openDailyGift();
      await repo.waterBinhi();
      await repo.startOver();
      expect(await repo.getDailyCount(DailyKind.gift), 0);
      expect(await repo.getDailyCount(DailyKind.water), 0);
      expect(await repo.openDailyGift(), (1, 3));
    });
  });
}
