import 'dart:math' as math;

import '../content/questions.dart';

/// Smart review (PLAN.md §5i): questions a child got wrong come back until
/// they get them right, and plants not seen for a while ask for a quick
/// check-in so they aren't forgotten.
abstract final class ReviewRules {
  /// A finished plant asks for a check-in after this long without a
  /// question about it.
  static const restDays = 7;

  /// Questions in one review.
  static const size = 5;

  /// Leaves for each right answer in a review. Questions leave the review
  /// once answered, so this can't be repeated for more.
  static const leavesPerCorrect = 1;
}

/// One answer, as review needs it.
typedef ReviewAnswer = ({String questionId, bool correct, DateTime at});

/// What is waiting to be reviewed.
class ReviewPlan {
  const ReviewPlan({this.tricky = const [], this.rusty = const []});

  /// Question ids whose latest answer was wrong, newest mistake first.
  final List<String> tricky;

  /// Finished plants not asked about for [ReviewRules.restDays] days,
  /// longest-waiting first.
  final List<String> rusty;

  int get count => tricky.length + rusty.length;
  bool get isEmpty => count == 0;

  /// Works out the plan from every answer given and when each plant's quiz
  /// was finished.
  factory ReviewPlan.from({
    required List<ReviewAnswer> answers,
    required Map<String, DateTime> quizDone,
    required DateTime now,
  }) {
    final latest = <String, ReviewAnswer>{};
    final lastSeen = <String, DateTime>{...quizDone};
    for (final a in answers) {
      final before = latest[a.questionId];
      if (before == null || !a.at.isBefore(before.at)) latest[a.questionId] = a;
      final plant = QuestionBank.byId(a.questionId)?.plantId;
      if (plant != null && (lastSeen[plant] == null || a.at.isAfter(lastSeen[plant]!))) lastSeen[plant] = a.at;
    }
    final tricky = [
      for (final a in latest.values)
        if (!a.correct && QuestionBank.byId(a.questionId) != null) a,
    ]..sort((x, y) => y.at.compareTo(x.at));
    final restSince = now.subtract(const Duration(days: ReviewRules.restDays));
    final rusty = [
      for (final MapEntry(key: plant, value: done) in quizDone.entries)
        if (!lastSeen[plant]!.isAfter(restSince)) (plant, lastSeen[plant] ?? done),
    ]..sort((x, y) => x.$2.compareTo(y.$2));
    return ReviewPlan(tricky: [for (final a in tricky) a.questionId], rusty: [for (final r in rusty) r.$1]);
  }

  /// The questions for one review: tricky ones first, then one question
  /// about each waiting plant (one it hasn't just missed), up to
  /// [ReviewRules.size].
  List<Question> questions(math.Random random) {
    final picked = <Question>[for (final id in tricky.take(ReviewRules.size)) ?QuestionBank.byId(id)];
    for (final plant in rusty) {
      if (picked.length >= ReviewRules.size) break;
      final options = QuestionBank.plantQuiz(plant).where((q) => !tricky.contains(q.id)).toList();
      if (options.isNotEmpty) picked.add(options[random.nextInt(options.length)]);
    }
    return picked..shuffle(random);
  }
}
