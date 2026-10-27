import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../art/binhi/binhi_outfit.dart';
import '../art/binhi/binhi_stage.dart';
import '../data/connection.dart';
import '../data/database.dart';
import '../data/progress_repository.dart';
import '../data/save_queue.dart';
import '../art/avatars/animal_avatar.dart';
import '../game/badges.dart';
import '../game/daily.dart';
import '../game/garden.dart';
import '../game/review.dart';
import '../game/rewards.dart';
import '../game/rules.dart';
import '../game/weather.dart';
import 'game_actions.dart';

// App state (Riverpod). Screens watch these; they never touch the database
// directly. Tests override [databaseProvider] with an in-memory database.

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(openPlantQuestDatabase());
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = Provider<ProgressRepository>((ref) => ProgressRepository(ref.watch(databaseProvider)));

final saveQueueProvider = Provider<SaveQueue>((ref) {
  final queue = SaveQueue();
  ref.onDispose(queue.dispose);
  return queue;
});

/// Every action that changes progress goes through here.
final gameActionsProvider = Provider<GameActions>(
  (ref) => GameActions(ref.watch(repositoryProvider), ref.watch(saveQueueProvider)),
);

/// The student, or null before onboarding.
final profileProvider = StreamProvider<ProfileRow?>((ref) => ref.watch(repositoryProvider).watchProfile());

/// Leaves to spend: the sum of leaves_log (earned minus spent in the shop).
final leavesProvider = StreamProvider<int>((ref) => ref.watch(repositoryProvider).watchLeaves());

final daysVisitedProvider = StreamProvider<int>((ref) => ref.watch(repositoryProvider).watchDaysVisited());

final plantProgressProvider = StreamProvider<Map<String, PlantProgressRow>>(
  (ref) => ref.watch(repositoryProvider).watchPlantProgress(),
);

/// Best Sprout or Sapling score as (score, total).
final bestLevelScoreProvider = StreamProvider<(int, int)?>(
  (ref) => ref.watch(repositoryProvider).watchBestLevelScore(),
);

/// The adventure path: which stops are done, current or locked.
final pathProvider = Provider<AsyncValue<PathState>>(
  (ref) => ref
      .watch(plantProgressProvider)
      .whenData(
        (rows) => PathState.from({
          for (final r in rows.values)
            if (r.quizDoneAt != null) r.plantId,
        }),
      ),
);

/// Plants opened at least once (the Profile garden and "x of 15 explored").
final exploredPlantsProvider = Provider<AsyncValue<Set<String>>>(
  (ref) => ref
      .watch(plantProgressProvider)
      .whenData(
        (rows) => {
          for (final r in rows.values)
            if (r.exploredAt != null) r.plantId,
        },
      ),
);

final binhiStageProvider = Provider<AsyncValue<BinhiStage>>(
  (ref) => ref.watch(leavesEarnedProvider).whenData(BinhiStage.forLeaves),
);

/// Leaves earned in all. Binhi grows from this; shopping never lowers it.
final leavesEarnedProvider = StreamProvider<int>((ref) => ref.watch(repositoryProvider).watchLeavesEarned());

/// Shop items bought.
final ownedProvider = StreamProvider<Set<OutfitItem>>((ref) => ref.watch(repositoryProvider).watchOwned());

/// Days Binhi was watered, and whether he has had water today.
final daysWateredProvider = StreamProvider<int>(
  (ref) => ref.watch(repositoryProvider).watchDailyCount(DailyKind.water),
);
final wateredTodayProvider = StreamProvider<bool>(
  (ref) => ref.watch(repositoryProvider).watchDoneToday(DailyKind.water),
);

/// The daily gift popup (tests switch it off; see test_overrides.dart).
final dailyGiftEnabledProvider = Provider<bool>((ref) => true);

/// Picks the weather My Garden opens on (PLAN.md §5f). Tests and previews
/// override it to get a set weather.
final gardenWeatherPickProvider = Provider<GardenWeather Function()>((ref) {
  final rnd = math.Random();
  return () => WeatherRules.pick(rnd);
});

/// What smart review has waiting: tricky questions and plants to check in
/// on (PLAN.md §5i).
final reviewPlanProvider = StreamProvider<ReviewPlan>((ref) => ref.watch(repositoryProvider).watchReviewPlan());

/// Garden decorations bought (PLAN.md §5d).
final decorationsProvider = StreamProvider<Set<GardenDeco>>((ref) => ref.watch(repositoryProvider).watchDecorations());

/// Where garden pieces were moved: piece name → feet (x, y).
final gardenSpotsProvider = StreamProvider<Map<String, (double, double)>>(
  (ref) => ref.watch(repositoryProvider).watchGardenSpots(),
);

/// Colouring pages, newest hung first (PLAN.md §5l).
final colouringsProvider = StreamProvider<List<SavedColouring>>(
  (ref) => ref.watch(repositoryProvider).watchColourings(),
);

/// The plant whose picture was just hung, so My Garden can show it going
/// up on the bahay kubo wall. The garden clears it once shown.
final justHungProvider = NotifierProvider<JustHung, String?>(JustHung.new);

class JustHung extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? plantId) => state = plantId;
}

/// Plant ids whose quiz is finished: one sticker each.
final stickersProvider = Provider<Set<String>>((ref) {
  final progress = ref.watch(plantProgressProvider).value ?? const {};
  return {
    for (final r in progress.values)
      if (r.quizDoneAt != null) r.plantId,
  };
});

/// What Binhi wears everywhere: the saved choice, minus anything not owned.
final binhiOutfitProvider = Provider<BinhiOutfit>((ref) {
  final p = ref.watch(profileProvider).value;
  if (p == null) return BinhiOutfit.none;
  return Shop.wearable(ProgressRepository.outfitOf(p), ref.watch(ownedProvider).value ?? const {});
});

/// Leaves to spend when the Shop tab was last opened (this session).
/// The tab shows a dot when something new becomes affordable after that.
final shopSeenWalletProvider = NotifierProvider<ShopSeenWallet, int?>(ShopSeenWallet.new);

class ShopSeenWallet extends Notifier<int?> {
  @override
  int? build() => null;

  void seen(int wallet) => state = wallet;
}

/// Opening the shop clears the tab's dot.
void markShopSeen(WidgetRef ref) {
  final wallet = ref.read(leavesProvider).value;
  if (wallet != null) ref.read(shopSeenWalletProvider.notifier).seen(wallet);
}

final shopDotProvider = Provider<bool>((ref) {
  final wallet = ref.watch(leavesProvider).value;
  final owned = ref.watch(ownedProvider).value;
  if (wallet == null || owned == null) return false;
  final seen = ref.watch(shopSeenWalletProvider);
  return Shop.affordable(wallet, owned).any((i) => seen == null || i.price > seen);
});

/// Mini-game wins as (game, plant id).
final gameWinsProvider = StreamProvider<Set<(MiniGame, String)>>(
  (ref) => ref.watch(repositoryProvider).watchGameWins(),
);

/// Badges claimed so far.
final badgesProvider = StreamProvider<Set<Achievement>>((ref) => ref.watch(repositoryProvider).watchBadges());

/// Animal friends unlocked by badges.
final animalsUnlockedProvider = Provider<Set<AnimalAvatar>>(
  (ref) => {for (final b in ref.watch(badgesProvider).value ?? const <Achievement>{}) ?b.animal},
);

/// Achievement popups and rewards. Tests about other things switch this off so
/// seeded progress doesn't pop up badges (test/test_overrides.dart).
final badgesEnabledProvider = Provider<bool>((ref) => true);

final perfectPlantsProvider = StreamProvider<Set<String>>((ref) => ref.watch(repositoryProvider).watchPerfectPlants());

/// Live badge progress for the Badges card and page.
final badgeFactsProvider = Provider<BadgeFacts>((ref) {
  final progress = ref.watch(plantProgressProvider).value ?? const {};
  return BadgeFacts(
    quizDone: {
      for (final r in progress.values)
        if (r.quizDoneAt != null) r.plantId,
    },
    allParts: {
      for (final r in progress.values)
        if (r.partsFound == PartBits.all) r.plantId,
    },
    perfect: ref.watch(perfectPlantsProvider).value ?? const {},
    daysVisited: ref.watch(daysVisitedProvider).value ?? 0,
    bestLevel: ref.watch(bestLevelScoreProvider).value,
    gameWins: ref.watch(gameWinsProvider).value ?? const {},
  );
});
