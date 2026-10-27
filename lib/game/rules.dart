import '../content/plant_catalog.dart';

/// Game rules from PLAN.md §5–6. Pure functions only: no database, no
/// widgets, so every rule is easy to test.
abstract final class LeafRules {
  /// Opening a plant's details for the first time.
  static const explore = 5;

  /// Tapping all four parts of a plant (once per plant).
  static const allParts = 3;

  /// Each correct answer above your best score for that quiz.
  static const perCorrect = 2;

  /// The first time a quiz is perfect.
  static const perfect = 5;

  /// Winning Label it or Grow it for a plant (once per plant per game).
  static const miniGame = 3;

  /// Each plant matched right in Match it for the first time.
  static const matched = 1;
}

/// The mini-games, as stored in `game_wins` (PLAN.md §6b).
enum MiniGame { label, grow, match }

/// Leaves earned when a quiz ends.
class QuizReward {
  const QuizReward({required this.correctLeaves, required this.perfectBonus, required this.isNewBest});

  /// 2 × (score − previous best), or 0 if the best wasn't beaten.
  final int correctLeaves;

  /// [LeafRules.perfect] the first time this quiz is perfect, else 0.
  final int perfectBonus;

  final bool isNewBest;

  int get total => correctLeaves + perfectBonus;

  /// "Replays earn leaves only for new bests" (PLAN.md §5, Q3).
  ///
  /// [previousBest] is 0 when the quiz was never finished before.
  /// Example: first try 2/3 → +4. Replay 2/3 → +0. Replay 3/3 → +2 +5.
  factory QuizReward.compute({
    required int score,
    required int total,
    required int previousBest,
    required bool hadPerfectBefore,
  }) {
    final gain = score > previousBest ? score - previousBest : 0;
    final perfectNow = total > 0 && score == total;
    return QuizReward(
      correctLeaves: gain * LeafRules.perCorrect,
      perfectBonus: perfectNow && !hadPerfectBefore ? LeafRules.perfect : 0,
      isNewBest: gain > 0,
    );
  }
}

/// How a stop on the adventure path looks.
enum StopState { done, current, locked }

/// The adventure path for a set of finished plant quizzes (PLAN.md §5).
///
/// Stops open in order: stop 1 is always open, and finishing a plant's quiz
/// (any score) opens the next one, crossing into the next world.
class PathState {
  PathState._(this.stops);

  factory PathState.from(Set<String> quizDone) {
    final stops = <String, StopState>{};
    var previousDone = true; // stop 1 behaves as if "before it" is done
    for (final plant in PlantCatalog.all) {
      final done = quizDone.contains(plant.id);
      stops[plant.id] = done
          ? StopState.done
          : previousDone
          ? StopState.current
          : StopState.locked;
      previousDone = done;
    }
    return PathState._(stops);
  }

  /// Plant id → state, in path order.
  final Map<String, StopState> stops;

  StopState of(String plantId) => stops[plantId] ?? StopState.locked;

  bool isUnlocked(String plantId) => of(plantId) != StopState.locked;

  int get doneCount => stops.values.where((s) => s == StopState.done).length;

  int doneInWorld(int world) => PlantCatalog.inWorld(world).where((p) => of(p.id) == StopState.done).length;

  /// The next plant to play, or null when all 15 are done.
  String? get currentId {
    for (final e in stops.entries) {
      if (e.value == StopState.current) return e.key;
    }
    return null;
  }

  /// A world is open once its first plant is unlocked.
  bool isWorldOpen(int world) => isUnlocked(PlantCatalog.inWorld(world).first.id);

  Set<String> get unlockedIds => {
    for (final e in stops.entries)
      if (e.value != StopState.locked) e.key,
  };

  /// The plant after [plantId] on the path (for NEXT PLANT), or null after
  /// the last one.
  static String? nextAfter(String plantId) {
    final i = PlantCatalog.all.indexWhere((p) => p.id == plantId);
    return i < 0 || i + 1 >= PlantCatalog.all.length ? null : PlantCatalog.all[i + 1].id;
  }
}

/// The two level quizzes.
enum QuizLevel {
  sprout(5, 'Sprout Quiz', 'Grades 1–4'),
  sapling(10, 'Sapling Quiz', 'Grades 5–6');

  const QuizLevel(this.questionCount, this.title, this.grades);

  final int questionCount;
  final String title;
  final String grades;

  /// Which level says YOUR LEVEL for a grade (the other is CHALLENGE).
  static QuizLevel forGrade(int grade) => grade >= 5 ? sapling : sprout;

  /// Plants a level quiz may ask about (PLAN.md §6, Q4): only unlocked
  /// plants, but never fewer than all of World 1.
  static Set<String> questionPool(Set<String> unlockedIds) {
    final world1 = {for (final p in PlantCatalog.inWorld(1)) p.id};
    return unlockedIds.length < world1.length ? world1 : {...unlockedIds, ...world1};
  }
}

/// Kinds of quiz, as stored in the database.
/// What a quiz attempt was, as stored in `quiz_attempts.kind`.
enum QuizKind { plant, sprout, sapling, review }

/// The four tappable parts as bits in `plant_progress.parts_found`.
abstract final class PartBits {
  static const root = 1;
  static const stem = 2;
  static const leaf = 4;
  static const special = 8;
  static const all = root | stem | leaf | special;

  static int count(int mask) =>
      (mask & root != 0 ? 1 : 0) +
      (mask & stem != 0 ? 1 : 0) +
      (mask & leaf != 0 ? 1 : 0) +
      (mask & special != 0 ? 1 : 0);
}

/// Profile rules.
abstract final class ProfileRules {
  static const maxNameLength = 20;
  static const defaultName = 'Explorer';

  /// Trims and shortens a typed name; an empty name becomes "Explorer"
  /// (the About you Skip rule).
  static String cleanName(String? raw) {
    final name = (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return defaultName;
    return name.length <= maxNameLength ? name : name.substring(0, maxNameLength).trimRight();
  }

  static int cleanGrade(int grade) => grade.clamp(1, 6);
}

/// A calendar day key like "2026-10-15", in the phone's local time.
/// Days visited counts distinct keys and never resets.
String dayKey(DateTime time) {
  final t = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)}';
}
