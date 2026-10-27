import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/plants/plant_view.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/content/questions.dart';
import 'package:plantquest/game/quiz_session.dart';
import 'package:plantquest/game/rules.dart';

void main() {
  group('question banks', () {
    final all = [
      for (final p in PlantCatalog.all) ...QuestionBank.plantQuiz(p.id),
      ...QuestionBank.level(QuizLevel.sprout),
      ...QuestionBank.level(QuizLevel.sapling),
    ];

    test('sizes: 3 per plant quiz, at least 15 per level (PLAN.md §6)', () {
      for (final p in PlantCatalog.all) {
        expect(QuestionBank.plantQuiz(p.id), hasLength(3));
      }
      expect(QuestionBank.level(QuizLevel.sprout).length, greaterThanOrEqualTo(15));
      expect(QuestionBank.level(QuizLevel.sapling).length, greaterThanOrEqualTo(15));
    });

    test('ids are unique', () {
      expect(all.map((q) => q.id).toSet(), hasLength(all.length));
    });

    test('every question has a valid right answer and a reason', () {
      for (final q in all) {
        expect(q.reason.trim(), isNotEmpty, reason: q.id);
        expect(q.prompt.trim(), isNotEmpty, reason: q.id);
        if (q.type == QuestionType.tapPart) {
          expect(q.part, isNotNull, reason: q.id);
          expect(q.correctId, q.part!.name, reason: q.id);
          expect(PlantArt.has(q.plantId), isTrue);
        } else {
          expect(q.options, hasLength(4), reason: q.id);
          expect(q.options.map((o) => o.id).toSet(), hasLength(4), reason: '${q.id} option ids');
          expect(q.options.map((o) => o.label).toSet(), hasLength(4), reason: '${q.id} option labels');
          expect(q.options.where((o) => o.id == q.correctId), hasLength(1), reason: q.id);
        }
        if (q.type == QuestionType.pictureChoice) {
          for (final o in q.options) {
            expect(PlantArt.has(o.plantId!), isTrue, reason: q.id);
          }
        }
      }
    });

    test('no emojis in any question text (PLAN.md §2)', () {
      final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);
      for (final q in all) {
        final text = [q.prompt, q.reason, ...q.options.map((o) => o.label)].join(' ');
        expect(emoji.hasMatch(text), isFalse, reason: q.id);
      }
    });

    test('all three question types are used', () {
      expect(all.map((q) => q.type).toSet(), QuestionType.values.toSet());
    });
  });

  group('QuizSession', () {
    test('one tap only: check and continue ignore repeats', () {
      final s = QuizSession.plant('sampaguita', random: math.Random(1));
      expect(s.check(), isNull, reason: 'nothing picked yet');
      s.select(s.current.correctId);
      expect(s.check(), isTrue);
      expect(s.check(), isNull, reason: 'double tap on CHECK');
      expect(s.select('other'), isFalse, reason: 'cannot change after checking');
      expect(s.next(), isTrue);
      expect(s.next(), isFalse, reason: 'double tap on CONTINUE');
      expect(s.index, 1);
    });

    test('a full quiz counts right answers and finishes', () {
      final s = QuizSession.plant('mango', random: math.Random(2));
      for (var i = 0; i < s.total; i++) {
        s.select(i == 0 ? 'wrong' : s.current.correctId);
        s.check();
        s.next();
      }
      expect(s.phase, QuizPhase.finished);
      expect(s.correctCount, 2);
      expect(s.progress, 1);
    });

    test('options are shuffled but the right answer stays right', () {
      final q = QuestionBank.plantQuiz('narra').firstWhere((q) => q.type == QuestionType.multipleChoice);
      final orders = <String>{};
      for (var seed = 0; seed < 12; seed++) {
        final s = QuizSession.plant('narra', random: math.Random(seed));
        final i = s.questions.indexOf(s.questions.firstWhere((x) => x.id == q.id));
        while (s.index < i) {
          s.select(s.current.correctId);
          s.check();
          s.next();
        }
        orders.add(s.options.map((o) => o.id).join());
        expect(s.options.map((o) => o.id).toSet(), q.options.map((o) => o.id).toSet());
      }
      expect(orders.length, greaterThan(1));
    });

    test('level quizzes have the right length and only ask about allowed plants', () {
      final world1 = PlantCatalog.inWorld(1).map((p) => p.id).toSet();
      for (var seed = 0; seed < 20; seed++) {
        final sprout = QuizSession.level(QuizLevel.sprout, {'sampaguita'}, random: math.Random(seed));
        expect(sprout.total, 5);
        expect(sprout.questions.every((q) => world1.contains(q.plantId)), isTrue);
        final sapling = QuizSession.level(QuizLevel.sapling, {'sampaguita'}, random: math.Random(seed));
        expect(sapling.total, 10);
        expect(sapling.questions.map((q) => q.id).toSet(), hasLength(10), reason: 'no repeats');
      }
      final later = PathState.from(PlantCatalog.all.take(8).map((p) => p.id).toSet()).unlockedIds;
      final s = QuizSession.level(QuizLevel.sapling, later, random: math.Random(3));
      expect(s.questions.every((q) => later.contains(q.plantId)), isTrue);
    });
  });
}
