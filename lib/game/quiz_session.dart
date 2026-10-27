import 'dart:math' as math;

import '../content/questions.dart';
import 'rules.dart';

enum QuizPhase {
  /// Picking an answer (CHECK is enabled once one is picked).
  answering,

  /// Showing "Correct!" or "Good try!" (CONTINUE).
  checked,

  /// All questions answered: show Results.
  finished,
}

/// One play of a quiz. Pure logic: the screen shows it, the save queue
/// stores it.
///
/// Every step accepts one tap only: [check] and [next] ignore repeats, so
/// fast double taps can never count twice.
class QuizSession {
  QuizSession._(this.kind, this.plantId, this.questions, math.Random random)
    : _orders = [
        for (final q in questions) ([...q.options]..shuffle(random)),
      ];

  /// The 3-question quiz for one plant. Answer order is shuffled.
  factory QuizSession.plant(String plantId, {math.Random? random}) {
    final r = random ?? math.Random();
    final questions = QuestionBank.plantQuiz(plantId)..shuffle(r);
    return QuizSession._(QuizKind.plant, plantId, questions, r);
  }

  /// A Sprout or Sapling quiz drawn from plants the player has unlocked
  /// (never fewer than all of World 1).
  factory QuizSession.level(QuizLevel level, Set<String> unlockedIds, {math.Random? random}) {
    final r = random ?? math.Random();
    final pool = QuizLevel.questionPool(unlockedIds);
    final bank = QuestionBank.level(level).where((q) => pool.contains(q.plantId)).toList()..shuffle(r);
    return QuizSession._(
      level == QuizLevel.sprout ? QuizKind.sprout : QuizKind.sapling,
      null,
      bank.take(level.questionCount).toList(),
      r,
    );
  }

  /// A smart review: the questions it was given, answers shuffled.
  factory QuizSession.review(List<Question> questions, {math.Random? random}) =>
      QuizSession._(QuizKind.review, null, questions, random ?? math.Random());

  final QuizKind kind;
  final String? plantId;
  final List<Question> questions;
  final List<List<QuizOption>> _orders;

  int _index = 0;
  String? _selected;
  QuizPhase _phase = QuizPhase.answering;
  final List<bool> _results = [];

  int get index => _index;
  int get total => questions.length;
  Question get current => questions[_index];

  /// The current question's options, in this play's shuffled order.
  List<QuizOption> get options => _orders[_index];

  String? get selected => _selected;
  QuizPhase get phase => _phase;
  bool get isLast => _index == questions.length - 1;
  int get correctCount => _results.where((r) => r).length;

  /// Right or wrong for the last checked question.
  bool? get lastCorrect => _results.length > _index ? _results[_index] : null;

  /// 0–1 for the progress bar: answered questions out of all.
  double get progress => _results.length / total;

  /// Pick (or change) an answer. Ignored once checked.
  bool select(String answerId) {
    if (_phase != QuizPhase.answering) return false;
    _selected = answerId;
    return true;
  }

  /// CHECK. Returns whether the answer was right, or null if this tap must
  /// be ignored (nothing picked, or already checked).
  bool? check() {
    if (_phase != QuizPhase.answering || _selected == null) return null;
    final right = current.isCorrect(_selected!);
    _results.add(right);
    _phase = QuizPhase.checked;
    return right;
  }

  /// CONTINUE. Returns false if this tap must be ignored.
  bool next() {
    if (_phase != QuizPhase.checked) return false;
    if (isLast) {
      _phase = QuizPhase.finished;
    } else {
      _index++;
      _selected = null;
      _phase = QuizPhase.answering;
    }
    return true;
  }
}
