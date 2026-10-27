import 'dart:convert';

import 'package:drift/drift.dart';

import '../art/binhi/binhi_outfit.dart';
import '../art/binhi/binhi_stage.dart';
import '../game/badges.dart';
import '../game/colouring.dart';
import '../game/daily.dart';
import '../game/garden.dart';
import '../game/review.dart';
import '../game/rewards.dart';
import '../game/rules.dart';
import 'database.dart';

/// What finishing a quiz changed, for the Results screen.
class QuizResult {
  const QuizResult({
    required this.score,
    required this.total,
    required this.reward,
    required this.leavesBefore,
    required this.leavesAfter,
    required this.earnedBefore,
    this.newSticker,
  });

  /// The plant whose sticker was earned by this quiz (its first finish).
  final String? newSticker;

  /// Leaves earned in all before this quiz (Binhi's growth; spending in the
  /// shop never lowers it).
  final int earnedBefore;

  final int score;
  final int total;
  final QuizReward reward;
  final int leavesBefore;
  final int leavesAfter;

  int get leavesEarned => leavesAfter - leavesBefore;
  bool get isPerfect => score == total;
  int get earnedAfter => earnedBefore + leavesEarned;
  BinhiStage get stageBefore => BinhiStage.forLeaves(earnedBefore);
  BinhiStage get stageAfter => BinhiStage.forLeaves(earnedAfter);

  /// Binhi reached a new stage: play the full-screen celebration.
  bool get grew => stageAfter.index > stageBefore.index;
}

/// All reads and writes of student progress. Every write is a transaction
/// and safe to repeat, because the save queue may retry it.
class ProgressRepository {
  ProgressRepository(this.db, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final AppDatabase db;
  final DateTime Function() _now;

  // ---------------------------------------------------------------- profile

  Stream<ProfileRow?> watchProfile() => (db.select(db.profile)..where((p) => p.id.equals(1))).watchSingleOrNull();

  Future<ProfileRow?> getProfile() => (db.select(db.profile)..where((p) => p.id.equals(1))).getSingleOrNull();

  /// Saves the About you / Edit profile answers. The first save also sets
  /// the joined date and marks onboarding done.
  Future<void> saveProfile({String? name, required int grade, required String avatarId}) {
    return db.transaction(() async {
      final existing = await getProfile();
      final row = ProfileCompanion(
        id: const Value(1),
        name: Value(ProfileRules.cleanName(name)),
        grade: Value(ProfileRules.cleanGrade(grade)),
        avatarId: Value(avatarId),
        onboarded: const Value(true),
        joinedAt: Value(existing?.joinedAt ?? _now()),
      );
      if (existing == null) {
        await db.into(db.profile).insert(row);
      } else {
        await (db.update(db.profile)..where((p) => p.id.equals(1))).write(row);
      }
    });
  }

  /// Saves what Binhi is wearing.
  Future<void> saveOutfit(BinhiOutfit outfit) async {
    await _ensureProfile();
    await (db.update(db.profile)..where((p) => p.id.equals(1))).write(
      ProfileCompanion(
        wearSalakot: Value(outfit.salakot),
        wearGarland: Value(outfit.garland),
        wearSunglasses: Value(outfit.sunglasses),
        potPattern: Value(outfit.pattern.name),
        hat: Value(outfit.hat?.name),
        glasses: Value(outfit.glasses?.name),
        neck: Value(outfit.neck?.name),
        friend: Value(outfit.friend?.name),
        spot: Value(outfit.spot.name),
      ),
    );
  }

  /// Changes Settings. Only the given values change.
  Future<void> updateSettings({
    bool? soundOn,
    bool? autoRead,
    String? speechRate,
    Value<String?> voiceId = const Value.absent(),
    String? voiceStyle,
    bool? lessMotion,
    bool? musicOn,
  }) async {
    await _ensureProfile();
    await (db.update(db.profile)..where((p) => p.id.equals(1))).write(
      ProfileCompanion(
        soundOn: Value.absentIfNull(soundOn),
        autoRead: Value.absentIfNull(autoRead),
        speechRate: Value.absentIfNull(speechRate),
        voiceId: voiceId,
        voiceStyle: Value.absentIfNull(voiceStyle),
        lessMotion: Value.absentIfNull(lessMotion),
        musicOn: Value.absentIfNull(musicOn),
      ),
    );
  }

  /// Settings can change before onboarding (e.g. sound on the Welcome
  /// screen), so make sure the row exists.
  Future<void> _ensureProfile() async {
    if (await getProfile() == null) {
      await db.into(db.profile).insert(ProfileCompanion.insert(joinedAt: _now()), mode: InsertMode.insertOrIgnore);
    }
  }

  // ----------------------------------------------------------------- visits

  /// Counts today as a visited day (once per day).
  Future<void> recordVisit() =>
      db.into(db.visits).insert(VisitsCompanion.insert(day: dayKey(_now())), mode: InsertMode.insertOrIgnore);

  Stream<int> watchDaysVisited() {
    final count = db.visits.day.count();
    return (db.selectOnly(db.visits)..addColumns([count])).map((r) => r.read(count) ?? 0).watchSingle();
  }

  // ----------------------------------------------------------------- leaves

  Stream<int> watchLeaves() {
    final sum = db.leavesLog.amount.sum();
    return (db.selectOnly(db.leavesLog)..addColumns([sum])).map((r) => r.read(sum) ?? 0).watchSingle();
  }

  Future<int> getLeaves() async {
    final sum = db.leavesLog.amount.sum();
    final row = await (db.selectOnly(db.leavesLog)..addColumns([sum])).getSingle();
    return row.read(sum) ?? 0;
  }

  /// Leaves earned in all (spending not counted). Binhi grows from this.
  Stream<int> watchLeavesEarned() => _earnedQuery().map((r) => r.read(_earnedSum) ?? 0).watchSingle();

  Future<int> getLeavesEarned() async => (await _earnedQuery().getSingle()).read(_earnedSum) ?? 0;

  late final _earnedSum = db.leavesLog.amount.sum(filter: db.leavesLog.amount.isBiggerThanValue(0));

  JoinedSelectStatement<$LeavesLogTable, LeafEntry> _earnedQuery() =>
      db.selectOnly(db.leavesLog)..addColumns([_earnedSum]);

  Future<void> _addLeaves(int amount, String reason, {String? plantId, int? attemptId}) async {
    if (amount <= 0) return;
    await db
        .into(db.leavesLog)
        .insert(
          LeavesLogCompanion.insert(
            amount: amount,
            reason: reason,
            plantId: Value(plantId),
            attemptId: Value(attemptId),
            createdAt: _now(),
          ),
        );
  }

  // --------------------------------------------------------- plant progress

  Stream<Map<String, PlantProgressRow>> watchPlantProgress() =>
      db.select(db.plantProgress).watch().map((rows) => {for (final r in rows) r.plantId: r});

  Future<PlantProgressRow?> _progress(String plantId) =>
      (db.select(db.plantProgress)..where((p) => p.plantId.equals(plantId))).getSingleOrNull();

  Future<void> _ensureProgress(String plantId) => db
      .into(db.plantProgress)
      .insert(PlantProgressCompanion.insert(plantId: plantId), mode: InsertMode.insertOrIgnore);

  /// Opening a plant's details. +5 leaves the first time. Returns leaves earned.
  Future<int> explorePlant(String plantId) => db.transaction(() async {
    await _ensureProgress(plantId);
    final p = await _progress(plantId);
    if (p!.exploredAt != null) return 0;
    await (db.update(
      db.plantProgress,
    )..where((t) => t.plantId.equals(plantId))).write(PlantProgressCompanion(exploredAt: Value(_now())));
    await _addLeaves(LeafRules.explore, 'explore', plantId: plantId);
    return LeafRules.explore;
  });

  /// A part was tapped. +3 leaves once all four are found. Returns leaves earned.
  Future<int> markPartFound(String plantId, int partBit) => db.transaction(() async {
    await _ensureProgress(plantId);
    final p = (await _progress(plantId))!;
    final mask = p.partsFound | partBit;
    final completesNow = mask == PartBits.all && p.allPartsAt == null;
    await (db.update(db.plantProgress)..where((t) => t.plantId.equals(plantId))).write(
      PlantProgressCompanion(partsFound: Value(mask), allPartsAt: completesNow ? Value(_now()) : const Value.absent()),
    );
    if (!completesNow) return 0;
    await _addLeaves(LeafRules.allParts, 'parts', plantId: plantId);
    return LeafRules.allParts;
  });

  // ------------------------------------------------------------------ quiz

  Future<int> startQuiz(QuizKind kind, {String? plantId, required int total}) => db
      .into(db.quizAttempts)
      .insert(QuizAttemptsCompanion.insert(kind: kind.name, plantId: Value(plantId), total: total, startedAt: _now()));

  /// Saves one answer. Repeats of the same question are ignored, so a double
  /// tap or a retried save can't count twice.
  Future<void> saveAnswer(int attemptId, String questionId, {required String chosen, required bool correct}) => db
      .into(db.quizAnswers)
      .insert(
        QuizAnswersCompanion.insert(
          attemptId: attemptId,
          questionId: questionId,
          chosen: chosen,
          correct: correct,
          answeredAt: _now(),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  /// Ends a quiz: scores it from the saved answers, awards leaves by the
  /// new-best rule, and (for plant quizzes) unlocks the next stop.
  /// Safe to call twice: a finished attempt returns its earlier result.
  Future<QuizResult> finishQuiz(int attemptId) => db.transaction(() async {
    final attempt = await (db.select(db.quizAttempts)..where((a) => a.id.equals(attemptId))).getSingle();
    final leavesNow = await getLeaves();
    final earnedNow = await getLeavesEarned();

    if (attempt.finishedAt != null) {
      final earned = await _leavesForAttempt(attemptId);
      final score = attempt.score ?? 0;
      return QuizResult(
        score: score,
        total: attempt.total,
        reward: QuizReward(correctLeaves: earned, perfectBonus: 0, isNewBest: earned > 0),
        leavesBefore: leavesNow - earned,
        leavesAfter: leavesNow,
        earnedBefore: earnedNow - earned,
      );
    }

    final correctCount = db.quizAnswers.id.count(filter: db.quizAnswers.correct.equals(true));
    final scoreRow =
        await (db.selectOnly(db.quizAnswers)
              ..addColumns([correctCount])
              ..where(db.quizAnswers.attemptId.equals(attemptId)))
            .getSingle();
    final score = (scoreRow.read(correctCount) ?? 0).clamp(0, attempt.total);

    final earlier =
        await (db.select(db.quizAttempts)..where(
              (a) =>
                  a.kind.equals(attempt.kind) &
                  (attempt.plantId == null ? a.plantId.isNull() : a.plantId.equals(attempt.plantId!)) &
                  a.finishedAt.isNotNull() &
                  a.id.equals(attemptId).not(),
            ))
            .get();
    final previousBest = earlier.fold<int>(0, (best, a) => (a.score ?? 0) > best ? a.score! : best);
    final hadPerfect = earlier.any((a) => a.score == a.total);

    // A review pays for each right answer (its questions then leave the
    // review, so it can't be farmed); other quizzes pay for new bests.
    final reward = attempt.kind == QuizKind.review.name
        ? QuizReward(correctLeaves: score * ReviewRules.leavesPerCorrect, perfectBonus: 0, isNewBest: score > 0)
        : QuizReward.compute(
            score: score,
            total: attempt.total,
            previousBest: previousBest,
            hadPerfectBefore: hadPerfect,
          );

    await (db.update(db.quizAttempts)..where((a) => a.id.equals(attemptId))).write(
      QuizAttemptsCompanion(finishedAt: Value(_now()), score: Value(score)),
    );
    await _addLeaves(reward.correctLeaves, 'correct', plantId: attempt.plantId, attemptId: attemptId);
    await _addLeaves(reward.perfectBonus, 'perfect', plantId: attempt.plantId, attemptId: attemptId);

    String? newSticker;
    if (attempt.kind == QuizKind.plant.name && attempt.plantId != null) {
      final id = attempt.plantId!;
      await _ensureProgress(id);
      final p = (await _progress(id))!;
      if (p.quizDoneAt == null) newSticker = id;
      await (db.update(db.plantProgress)..where((t) => t.plantId.equals(id))).write(
        PlantProgressCompanion(
          quizDoneAt: Value(p.quizDoneAt ?? _now()),
          bestScore: Value(score > (p.bestScore ?? -1) ? score : p.bestScore),
        ),
      );
    }

    return QuizResult(
      score: score,
      total: attempt.total,
      reward: reward,
      leavesBefore: leavesNow,
      leavesAfter: leavesNow + reward.total,
      earnedBefore: earnedNow,
      newSticker: newSticker,
    );
  });

  /// What smart review has waiting (PLAN.md §5i).
  Future<ReviewPlan> getReviewPlan() async {
    final answers = await db.select(db.quizAnswers).get();
    final progress = await db.select(db.plantProgress).get();
    return ReviewPlan.from(
      answers: [for (final a in answers) (questionId: a.questionId, correct: a.correct, at: a.answeredAt)],
      quizDone: {
        for (final p in progress)
          if (p.quizDoneAt != null) p.plantId: p.quizDoneAt!,
      },
      now: _now(),
    );
  }

  Stream<ReviewPlan> watchReviewPlan() => db
      .customSelect('SELECT 1', readsFrom: {db.quizAnswers, db.plantProgress})
      .watch()
      .asyncMap((_) => getReviewPlan());

  Future<int> _leavesForAttempt(int attemptId) async {
    final sum = db.leavesLog.amount.sum();
    final row =
        await (db.selectOnly(db.leavesLog)
              ..addColumns([sum])
              ..where(db.leavesLog.attemptId.equals(attemptId)))
            .getSingle();
    return row.read(sum) ?? 0;
  }

  // ------------------------------------------------------------- mini-games

  /// (game, plant id) pairs already won.
  Stream<Set<(MiniGame, String)>> watchGameWins() => db.select(db.gameWins).watch().map(_wins);

  Future<Set<(MiniGame, String)>> getGameWins() async => _wins(await db.select(db.gameWins).get());

  static Set<(MiniGame, String)> _wins(List<GameWinRow> rows) => {
    for (final r in rows)
      if (MiniGame.values.asNameMap()[r.game] case final g?) (g, r.plantId),
  };

  /// Records a win. Returns the leaves earned: [leaves] the first time this
  /// game is won for this plant, 0 after that. Safe to repeat.
  Future<int> winGame(MiniGame game, String plantId, int leaves) => db.transaction(() async {
    if ((await getGameWins()).contains((game, plantId))) return 0;
    await db.into(db.gameWins).insert(GameWinsCompanion.insert(game: game.name, plantId: plantId, wonAt: _now()));
    await _addLeaves(leaves, 'game', plantId: plantId);
    return leaves;
  });

  // ------------------------------------------------------------------- shop

  Stream<Set<OutfitItem>> watchOwned() => db.select(db.purchases).watch().map(_owned);

  Future<Set<OutfitItem>> getOwned() async => _owned(await db.select(db.purchases).get());

  static Set<OutfitItem> _owned(List<PurchaseRow> rows) => {for (final r in rows) ?OutfitItem.byName(r.item)};

  /// Buys [item] and puts it on. Returns false (and changes nothing) if it
  /// is already owned or there aren't enough leaves. Safe to repeat.
  Future<bool> buy(OutfitItem item) => db.transaction(() async {
    final owned = await getOwned();
    if (owned.contains(item) || await getLeaves() < item.price) return false;
    await db.into(db.purchases).insert(PurchasesCompanion.insert(item: item.name, price: item.price, boughtAt: _now()));
    await db
        .into(db.leavesLog)
        .insert(LeavesLogCompanion.insert(amount: -item.price, reason: 'buy', createdAt: _now()));
    final p = await getProfile();
    final current = p == null ? BinhiOutfit.none : outfitOf(p);
    await saveOutfit(item.putOn(Shop.wearable(current, owned)));
    return true;
  });

  /// How many days [kind] has happened (gifts opened, days watered).
  Stream<int> watchDailyCount(DailyKind kind) => _daily(kind).watch().map((rows) => rows.length);

  Future<int> getDailyCount(DailyKind kind) async => (await _daily(kind).get()).length;

  /// Whether [kind] already happened today.
  Stream<bool> watchDoneToday(DailyKind kind) =>
      (_daily(kind)..where((d) => d.day.equals(dayKey(_now())))).watch().map((rows) => rows.isNotEmpty);

  SimpleSelectStatement<$DailyCareTable, DailyCareData> _daily(DailyKind kind) =>
      db.select(db.dailyCare)..where((d) => d.kind.equals(kind.name));

  Future<bool> isDoneToday(DailyKind kind) async =>
      (await (_daily(kind)..where((d) => d.day.equals(dayKey(_now())))).get()).isNotEmpty;

  /// Records [kind] for today. False if it already happened today.
  Future<bool> _markToday(DailyKind kind) async {
    if (await isDoneToday(kind)) return false;
    await db.into(db.dailyCare).insert(DailyCareCompanion.insert(kind: kind.name, day: dayKey(_now())));
    return true;
  }

  /// Opens today's gift from Binhi. Returns (gift number, leaves), or null
  /// if today's gift was already opened.
  Future<(int, int)?> openDailyGift() => db.transaction(() async {
    if (!await _markToday(DailyKind.gift)) return null;
    final n = await getDailyCount(DailyKind.gift);
    final leaves = DailyRules.giftLeaves(n);
    await _addLeaves(leaves, 'gift');
    return (n, leaves);
  });

  /// Waters Binhi. Pays once a day; on the 7th day watered (any days) the
  /// flower pot is earned and put on.
  Future<WaterResult> waterBinhi() => db.transaction(() async {
    final fresh = await _markToday(DailyKind.water);
    final days = await getDailyCount(DailyKind.water);
    if (!fresh) return WaterResult(leaves: 0, daysWatered: days, flowerPot: false);
    await _addLeaves(DailyRules.water, 'water');
    var flowerPot = false;
    if (days >= DailyRules.flowerPotDays && !(await getOwned()).contains(OutfitItem.flowers)) {
      await db
          .into(db.purchases)
          .insert(PurchasesCompanion.insert(item: OutfitItem.flowers.name, price: 0, boughtAt: _now()));
      final p = await getProfile();
      final current = p == null ? BinhiOutfit.none : outfitOf(p);
      await saveOutfit(OutfitItem.flowers.putOn(Shop.wearable(current, await getOwned())));
      flowerPot = true;
    }
    return WaterResult(leaves: DailyRules.water, daysWatered: days, flowerPot: flowerPot);
  });

  /// Garden decorations bought (they share the purchases table).
  Stream<Set<GardenDeco>> watchDecorations() => db.select(db.purchases).watch().map(_decos);

  Future<Set<GardenDeco>> getDecorations() async => _decos(await db.select(db.purchases).get());

  static Set<GardenDeco> _decos(List<PurchaseRow> rows) => {for (final r in rows) ?GardenDeco.byItem(r.item)};

  /// Buys a garden decoration. False (and nothing changes) if it is already
  /// owned or there aren't enough leaves. Safe to repeat.
  Future<bool> buyDecoration(GardenDeco deco) => db.transaction(() async {
    if ((await getDecorations()).contains(deco) || await getLeaves() < deco.price) return false;
    await db.into(db.purchases).insert(PurchasesCompanion.insert(item: deco.item, price: deco.price, boughtAt: _now()));
    await db
        .into(db.leavesLog)
        .insert(LeavesLogCompanion.insert(amount: -deco.price, reason: 'buy', createdAt: _now()));
    return true;
  });

  /// Where the child moved garden pieces: piece name → feet (x, y).
  Stream<Map<String, (double, double)>> watchGardenSpots() => db.select(db.gardenSpots).watch().map(_spots);

  Future<Map<String, (double, double)>> getGardenSpots() async => _spots(await db.select(db.gardenSpots).get());

  static Map<String, (double, double)> _spots(List<GardenSpotRow> rows) => {for (final r in rows) r.piece: (r.x, r.y)};

  Future<void> moveGardenPiece(String piece, double x, double y) =>
      db.into(db.gardenSpots).insertOnConflictUpdate(GardenSpotsCompanion.insert(piece: piece, x: x, y: y));

  // ------------------------------------------------------------- colouring

  /// Colouring pages, newest hung first (drafts last).
  Stream<List<SavedColouring>> watchColourings() => db.select(db.colourings).watch().map(_colourings);

  Future<SavedColouring?> getColouring(String plantId) async {
    final row = await (db.select(db.colourings)..where((c) => c.plantId.equals(plantId))).getSingleOrNull();
    return row == null ? null : SavedColouring.of(row);
  }

  static List<SavedColouring> _colourings(List<ColouringRow> rows) =>
      [for (final r in rows) SavedColouring.of(r)]..sort((a, b) {
        final x = a.hungAt, y = b.hungAt;
        if (x == null || y == null) return x == null ? (y == null ? 0 : 1) : -1;
        return y.compareTo(x);
      });

  /// Keeps the picture as it is now (a draft unless it was hung before).
  Future<void> saveColouring(String plantId, Uint8List png) => db.transaction(() async {
    final old = await getColouring(plantId);
    await db
        .into(db.colourings)
        .insertOnConflictUpdate(
          ColouringsCompanion.insert(plantId: plantId, picture: base64Encode(png), hungAt: Value(old?.hungAt)),
        );
  });

  /// Hangs the picture on the bahay kubo wall. Returns the leaves paid:
  /// [ColouringRules.leaves] the first time for this plant, then 0.
  Future<int> hangColouring(String plantId, Uint8List png) => db.transaction(() async {
    final first = (await getColouring(plantId))?.hungAt == null;
    await db
        .into(db.colourings)
        .insertOnConflictUpdate(
          ColouringsCompanion.insert(plantId: plantId, picture: base64Encode(png), hungAt: Value(_now())),
        );
    if (!first) return 0;
    await _addLeaves(ColouringRules.leaves, 'colour', plantId: plantId);
    return ColouringRules.leaves;
  });

  /// The outfit saved on the profile (before checking what is owned).
  /// A profile saved before v10 has only the three flags, so they count
  /// when a slot is empty.
  static BinhiOutfit outfitOf(ProfileRow p) => BinhiOutfit(
    hat: _named(BinhiHat.values, p.hat),
    glasses: _named(BinhiGlasses.values, p.glasses),
    neck: _named(BinhiNeck.values, p.neck),
    friend: _named(BinhiFriend.values, p.friend),
    salakot: p.wearSalakot,
    garland: p.wearGarland,
    sunglasses: p.wearSunglasses,
    pattern: PotPattern.values.asNameMap()[p.potPattern] ?? PotPattern.plain,
    spot: _named(BinhiSpot.values, p.spot) ?? BinhiSpot.meadow,
  );

  static T? _named<T extends Enum>(List<T> values, String? name) => name == null ? null : values.asNameMap()[name];

  /// Best finished Sprout or Sapling result as (score, total), or null.
  Stream<(int, int)?> watchBestLevelScore() => _levelAttempts().watch().map(_best);

  SimpleSelectStatement<$QuizAttemptsTable, QuizAttempt> _levelAttempts() =>
      db.select(db.quizAttempts)
        ..where((a) => a.kind.isIn([QuizKind.sprout.name, QuizKind.sapling.name]) & a.finishedAt.isNotNull());

  static (int, int)? _best(List<QuizAttempt> rows) {
    (int, int)? best;
    for (final a in rows) {
      final s = a.score ?? 0;
      // Compare as fractions: 9/10 beats 4/5.
      if (best == null || s * best.$2 > best.$1 * a.total) best = (s, a.total);
    }
    return best;
  }

  // ----------------------------------------------------------------- badges

  SimpleSelectStatement<$QuizAttemptsTable, QuizAttempt> _perfectPlantQuizzes() => db.select(db.quizAttempts)
    ..where(
      (a) =>
          a.kind.equals(QuizKind.plant.name) &
          a.plantId.isNotNull() &
          a.finishedAt.isNotNull() &
          a.score.equalsExp(a.total),
    );

  /// Plant ids with a perfect plant quiz.
  Stream<Set<String>> watchPerfectPlants() =>
      _perfectPlantQuizzes().watch().map((r) => {for (final a in r) a.plantId!});

  /// What the badges look at, read fresh from progress.
  Future<BadgeFacts> getBadgeFacts() async {
    final progress = await db.select(db.plantProgress).get();
    final perfect = await _perfectPlantQuizzes().get();
    final days = await db.select(db.visits).get();
    return BadgeFacts(
      quizDone: {
        for (final p in progress)
          if (p.quizDoneAt != null) p.plantId,
      },
      allParts: {
        for (final p in progress)
          if (p.partsFound == PartBits.all) p.plantId,
      },
      perfect: {for (final a in perfect) a.plantId!},
      daysVisited: days.length,
      bestLevel: _best(await _levelAttempts().get()),
      gameWins: await getGameWins(),
    );
  }

  Stream<Set<Achievement>> watchBadges() => db.select(db.badgeWins).watch().map(_claimed);

  Future<Set<Achievement>> getBadges() async => _claimed(await db.select(db.badgeWins).get());

  static Set<Achievement> _claimed(List<BadgeWinRow> rows) => {for (final r in rows) ?Achievement.byName(r.badge)};

  /// Claims every badge whose goal is now met and that isn't claimed yet,
  /// paying its leaves. Returns the newly claimed badges, in badge order.
  /// Safe to repeat.
  Future<List<Achievement>> claimNewBadges() => db.transaction(() async {
    final facts = await getBadgeFacts();
    final claimed = await getBadges();
    final fresh = [
      for (final b in Achievement.values)
        if (!claimed.contains(b) && b.earned(facts)) b,
    ];
    for (final b in fresh) {
      await db.into(db.badgeWins).insert(BadgeWinsCompanion.insert(badge: b.name, wonAt: _now()));
      await _addLeaves(b.leaves, 'badge');
    }
    return fresh;
  });

  /// Changes only the avatar (e.g. "USE IT" on a new animal friend).
  Future<void> setAvatar(String avatarId) async {
    await _ensureProfile();
    await (db.update(db.profile)..where((p) => p.id.equals(1))).write(ProfileCompanion(avatarId: Value(avatarId)));
  }

  // ------------------------------------------------------------- start over

  /// Clears leaves, garden (and its pictures), quiz scores and shop purchases. Keeps the name,
  /// settings and days visited (PLAN.md §4 screen 15, §5).
  Future<void> startOver() => db.transaction(() async {
    await db.delete(db.quizAnswers).go();
    await db.delete(db.quizAttempts).go();
    await db.delete(db.plantProgress).go();
    await db.delete(db.leavesLog).go();
    await db.delete(db.purchases).go();
    await db.delete(db.gameWins).go();
    await db.delete(db.badgeWins).go();
    await db.delete(db.gardenSpots).go();
    await db.delete(db.dailyCare).go();
    await db.delete(db.colourings).go();
  });
}

/// A colouring page as saved.
class SavedColouring {
  const SavedColouring({required this.plantId, required this.png, this.hungAt});

  factory SavedColouring.of(ColouringRow r) =>
      SavedColouring(plantId: r.plantId, png: base64Decode(r.picture), hungAt: r.hungAt);

  final String plantId;
  final Uint8List png;
  final DateTime? hungAt;

  bool get hung => hungAt != null;
}
