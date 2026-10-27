import 'package:drift/drift.dart' show Value;

import '../art/binhi/binhi_outfit.dart';
import '../art/plants/plant_drawing.dart';
import '../data/progress_repository.dart';
import '../data/save_queue.dart';
import '../game/badges.dart';
import '../game/daily.dart';
import '../game/garden.dart';
import '../game/rewards.dart';
import '../game/rules.dart';

/// Everything a screen can do to progress. Each call goes through the save
/// queue: saves run one at a time, failures are retried, and nothing here
/// ever throws into a screen.
class GameActions {
  GameActions(this._repo, this._queue);

  final ProgressRepository _repo;
  final SaveQueue _queue;

  /// Call once at startup: counts today as a visited day.
  Future<void> appOpened() => _queue.run(_repo.recordVisit, label: 'visit');

  Future<void> saveProfile({String? name, required int grade, required String avatarId}) => _queue.run(
    () => _repo.saveProfile(name: name, grade: grade, avatarId: avatarId),
    label: 'profile',
  );

  /// A mini-game was won for [plantId]. Returns leaves earned (only the
  /// first time).
  Future<int> winGame(MiniGame game, String plantId) async =>
      await _queue.run(
        () => _repo.winGame(game, plantId, game == MiniGame.match ? LeafRules.matched : LeafRules.miniGame),
        label: 'game',
      ) ??
      0;

  /// Claims any badges just earned (paying their leaves). Returns them.
  Future<List<Achievement>> claimNewBadges() async =>
      await _queue.run(_repo.claimNewBadges, label: 'badges') ?? const [];

  Future<void> setAvatar(String avatarId) => _queue.run(() => _repo.setAvatar(avatarId), label: 'avatar');

  /// Buys and puts on [item]. False if it couldn't (not enough leaves).
  Future<bool> buy(OutfitItem item) async => await _queue.run(() => _repo.buy(item), label: 'buy') ?? false;

  /// Opens today's gift: (gift number, leaves), or null if already opened.
  Future<(int, int)?> openDailyGift() => _queue.run<(int, int)?>(_repo.openDailyGift, label: 'gift');

  /// Waters Binhi (pays once a day).
  Future<WaterResult?> waterBinhi() => _queue.run(_repo.waterBinhi, label: 'water');

  /// Buys a garden decoration. False if it couldn't (not enough leaves).
  Future<bool> buyDecoration(GardenDeco deco) async =>
      await _queue.run(() => _repo.buyDecoration(deco), label: 'buy') ?? false;

  Future<void> moveGardenPiece(String piece, double x, double y) =>
      _queue.run(() => _repo.moveGardenPiece(piece, x, y), label: 'garden');

  Future<void> saveOutfit(BinhiOutfit outfit) => _queue.run(() => _repo.saveOutfit(outfit), label: 'outfit');

  Future<void> updateSettings({
    bool? soundOn,
    bool? autoRead,
    String? speechRate,
    Value<String?> voiceId = const Value.absent(),
    String? voiceStyle,
    bool? lessMotion,
    bool? musicOn,
  }) => _queue.run(
    () => _repo.updateSettings(
      soundOn: soundOn,
      autoRead: autoRead,
      speechRate: speechRate,
      voiceId: voiceId,
      voiceStyle: voiceStyle,
      lessMotion: lessMotion,
      musicOn: musicOn,
    ),
    label: 'settings',
  );

  /// Opening Plant details. Returns leaves earned (5 the first time, else 0).
  Future<int> explorePlant(String plantId) async =>
      await _queue.run(() => _repo.explorePlant(plantId), label: 'explore') ?? 0;

  /// A part was tapped. Returns leaves earned (3 when the last part is found).
  Future<int> partFound(String plantId, PlantPart part) async =>
      await _queue.run(() => _repo.markPartFound(plantId, _bit(part)), label: 'part') ?? 0;

  /// Starts a quiz. Returns null if it couldn't be saved; the quiz still runs
  /// and simply won't count (it never gets stuck).
  Future<int?> startQuiz(QuizKind kind, {String? plantId, required int total}) => _queue.run(
    () => _repo.startQuiz(kind, plantId: plantId, total: total),
    label: 'quiz start',
  );

  /// Fire-and-forget: the quiz moves on right away while the answer saves.
  void saveAnswer(int? attemptId, String questionId, {required String chosen, required bool correct}) {
    if (attemptId == null) return;
    _queue.run(
      () => _repo.saveAnswer(attemptId, questionId, chosen: chosen, correct: correct),
      label: 'answer',
    );
  }

  /// Ends a quiz after all its answers are saved (the queue keeps order).
  /// Returns null if it couldn't be saved, so Results can show the score
  /// it counted itself.
  Future<QuizResult?> finishQuiz(int? attemptId) async =>
      attemptId == null ? null : _queue.run(() => _repo.finishQuiz(attemptId), label: 'quiz finish');

  Future<void> startOver() => _queue.run(_repo.startOver, label: 'start over');

  static int _bit(PlantPart part) => switch (part) {
    PlantPart.root => PartBits.root,
    PlantPart.stem => PartBits.stem,
    PlantPart.leaf => PartBits.leaf,
    PlantPart.special => PartBits.special,
  };
}
