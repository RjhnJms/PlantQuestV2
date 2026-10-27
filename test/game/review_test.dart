import 'dart:math' as math;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/content/questions.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/review.dart';
import 'package:plantquest/game/rules.dart';

void main() {
  final day1 = DateTime(2026, 10, 1, 9);

  test('every question can be found by its id', () {
    for (final q in QuestionBank.plantQuiz('mango')) {
      expect(QuestionBank.byId(q.id)?.prompt, q.prompt);
    }
    expect(QuestionBank.byId('nope'), isNull);
  });

  test('a missed question stays tricky until it is answered right', () {
    final q = QuestionBank.plantQuiz('sampaguita').first.id;
    var plan = ReviewPlan.from(
      answers: [(questionId: q, correct: false, at: day1)],
      quizDone: {'sampaguita': day1},
      now: day1,
    );
    expect(plan.tricky, [q]);
    plan = ReviewPlan.from(
      answers: [
        (questionId: q, correct: false, at: day1),
        (questionId: q, correct: true, at: day1.add(const Duration(hours: 1))),
      ],
      quizDone: {'sampaguita': day1},
      now: day1,
    );
    expect(plan.tricky, isEmpty);
  });

  test('a finished plant asks for a check-in after a week without questions', () {
    final q = QuestionBank.plantQuiz('gumamela').first.id;
    final answers = [(questionId: q, correct: true, at: day1)];
    expect(
      ReviewPlan.from(answers: answers, quizDone: {'gumamela': day1}, now: day1.add(const Duration(days: 6))).rusty,
      isEmpty,
    );
    expect(
      ReviewPlan.from(answers: answers, quizDone: {'gumamela': day1}, now: day1.add(const Duration(days: 8))).rusty,
      ['gumamela'],
    );
  });

  test('a review takes tricky questions first, then one per waiting plant, five at most', () {
    final tricky = [
      for (final id in ['sampaguita', 'gumamela', 'makahiya']) QuestionBank.plantQuiz(id).first.id,
    ];
    final plan = ReviewPlan(tricky: tricky, rusty: const ['kalamansi', 'malunggay', 'palay', 'mango']);
    final qs = plan.questions(math.Random(1));
    expect(qs, hasLength(ReviewRules.size));
    expect(qs.map((q) => q.id), containsAll(tricky));
    expect(qs.where((q) => q.plantId == 'kalamansi'), hasLength(1));
  });

  group('repository', () {
    setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

    late AppDatabase db;
    late ProgressRepository repo;
    var now = day1;

    setUp(() {
      now = day1;
      db = AppDatabase(NativeDatabase.memory());
      repo = ProgressRepository(db, clock: () => now);
    });
    tearDown(() => db.close());

    test('a wrong answer comes back, and a right review answer pays a leaf', () async {
      final quiz = QuestionBank.plantQuiz('sampaguita');
      final a = await repo.startQuiz(QuizKind.plant, plantId: 'sampaguita', total: 3);
      for (final (i, q) in quiz.indexed) {
        await repo.saveAnswer(a, q.id, chosen: 'x', correct: i != 0);
      }
      await repo.finishQuiz(a);
      var plan = await repo.getReviewPlan();
      expect(plan.tricky, [quiz.first.id]);

      now = now.add(const Duration(hours: 1));
      final leavesBefore = await repo.getLeaves();
      final r = await repo.startQuiz(QuizKind.review, total: 1);
      await repo.saveAnswer(r, quiz.first.id, chosen: quiz.first.correctId, correct: true);
      final result = await repo.finishQuiz(r);
      expect(result.leavesEarned, ReviewRules.leavesPerCorrect);
      expect(await repo.getLeaves(), leavesBefore + ReviewRules.leavesPerCorrect);
      plan = await repo.getReviewPlan();
      expect(plan.isEmpty, isTrue);
    });
  });
}
