import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/content/questions.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/badges.dart';
import 'package:plantquest/game/rules.dart';
import 'package:plantquest/art/icons/kid_icon.dart';
import 'package:plantquest/main.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show bringIntoView, endApp, kidIcon, settle;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase db;
  late ProgressRepository repo;

  Future<void> startApp(WidgetTester tester, {Future<void> Function()? seed, bool badges = false}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    if (seed != null) await seed();
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db, badges: badges),
        child: const PlantQuestApp(),
      ),
    );
    await settle(tester);
  }

  /// The question on screen, found by its prompt.
  Question onScreen(WidgetTester tester, List<Question> bank) =>
      bank.firstWhere((q) => find.text(q.prompt).evaluate().isNotEmpty);

  /// Picks the right (or a wrong) answer for the question on screen.
  Future<void> answer(WidgetTester tester, Question q, {required bool right}) async {
    if (q.type == QuestionType.tapPart) {
      final label = right ? q.correctLabel : (q.correctLabel == 'Leaf' ? 'Root' : 'Leaf');
      await bringIntoView(tester, find.bySemanticsLabel(label));
      await tester.tap(find.bySemanticsLabel(label));
    } else {
      final label = right ? q.correctLabel : q.options.firstWhere((o) => o.id != q.correctId).label;
      await bringIntoView(tester, find.text(label));
      await tester.tap(find.text(label));
    }
    await settle(tester);
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await settle(tester);
  }

  testWidgets('perfect plant quiz: +11 leaves, next plant unlocked, NEXT PLANT offered', (tester) async {
    await startApp(tester);
    await tester.tap(find.bySemanticsLabel('Plants'));
    await settle(tester);
    await tester.tap(find.text('Sampaguita'));
    await settle(tester);
    await tapButton(tester, 'START QUIZ');

    final bank = QuestionBank.plantQuiz('sampaguita');
    for (var i = 1; i <= 3; i++) {
      expect(find.text('Question $i of 3'), findsOneWidget);
      final q = onScreen(tester, bank);
      await answer(tester, q, right: true);
      // A fast double tap on CHECK must not count twice.
      await tester.tap(find.text('CHECK'));
      await tester.tap(find.text('CHECK'), warnIfMissed: false);
      await settle(tester);
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text(q.reason), findsOneWidget);
      await tapButton(tester, i == 3 ? 'SEE RESULTS' : 'CONTINUE');
    }

    // 16 leaves: Binhi grows into a sprout, so the celebration shows first.
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    expect(find.text('YAY!'), findsOneWidget);
    await tapButton(tester, 'YAY!');

    // First finish of this plant: its sticker pops up next.
    await settle(tester);
    expect(find.text('You got a sticker!'), findsOneWidget);
    expect(find.text('The Sampaguita sticker went into your sticker book.'), findsOneWidget);
    await tapButton(tester, 'YAY!');
    await settle(tester);
    expect(find.text('You got a sticker!'), findsNothing);

    expect(find.text('Great job, Jamie!'), findsOneWidget);
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('Perfect score! Every answer was right.'), findsOneWidget);
    expect(find.text('NEXT PLANT: GUMAMELA'), findsOneWidget);
    // 5 for exploring + 3 × 2 correct + 5 perfect.
    expect(await repo.getLeaves(), 16);
    final row = await (db.select(db.plantProgress)..where((t) => t.plantId.equals('sampaguita'))).getSingle();
    expect(row.quizDoneAt, isNotNull);
    await tapButton(tester, 'NEXT PLANT: GUMAMELA');
    expect(find.text('Hibiscus rosa-sinensis'), findsOneWidget);
    await endApp(tester, db);
  });

  testWidgets('Shop tab: buy with leaves to spend; Binhi keeps his size and wears it', (tester) async {
    Future<void> perfect(String id) async {
      await repo.explorePlant(id);
      final a = await repo.startQuiz(QuizKind.plant, plantId: id, total: 3);
      for (var q = 0; q < 3; q++) {
        await repo.saveAnswer(a, 'q$q', chosen: 'a', correct: true);
      }
      await repo.finishQuiz(a);
    }

    await startApp(
      tester,
      seed: () async {
        await perfect('sampaguita');
        await perfect('gumamela');
      },
    );
    // 32 leaves: something is affordable, so the Shop tab has a dot.
    expect(find.bySemanticsLabel('Shop, something new'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Shop, something new'));
    await settle(tester);
    expect(find.bySemanticsLabel('Shop'), findsOneWidget, reason: 'dot gone once opened');
    expect(find.text('8 more leaves'), findsOneWidget, reason: 'Sunglasses cost 40');

    await bringIntoView(tester, find.text('BUY · 20'));
    await tapButton(tester, 'BUY · 20');
    expect(find.text('Buy the Stripes pot?'), findsOneWidget);
    expect(find.text('It costs 20 leaves. You will have 12 left.\nBinhi stays just as big!'), findsOneWidget);
    await tester.tap(find.text('BUY · 20').last);
    await settle(tester);
    expect(find.text('Salamat!'), findsOneWidget);
    await tapButton(tester, 'YAY!');

    expect(await repo.getLeaves(), 12);
    expect(await repo.getLeavesEarned(), 32);
    expect(find.text('Wearing'), findsOneWidget);
    expect((await repo.getProfile())!.potPattern, 'stripes');
    await endApp(tester, db);
  });

  testWidgets('a fast double tap on BUY only opens the question card', (tester) async {
    await startApp(
      tester,
      seed: () async {
        await repo.explorePlant('sampaguita');
        await repo.explorePlant('gumamela');
        await repo.explorePlant('makahiya');
        await repo.explorePlant('kalamansi');
      },
    );
    await tester.tap(find.bySemanticsLabel(RegExp('^Shop')));
    await settle(tester);
    await bringIntoView(tester, find.text('BUY · 20'));
    await tester.tap(find.text('BUY · 20'));
    await tester.pump(const Duration(milliseconds: 60));
    // Second tap lands on the card's BUY while it is still appearing.
    await tester.tap(find.text('BUY · 20').last, warnIfMissed: false);
    await settle(tester);
    expect(find.text('Buy the Stripes pot?'), findsOneWidget);
    expect(await repo.getOwned(), isEmpty);
    expect(await repo.getLeaves(), 20);
    await tapButton(tester, 'Not now');
    await endApp(tester, db);
  });

  testWidgets('Not now buys nothing', (tester) async {
    await startApp(
      tester,
      seed: () async {
        await repo.explorePlant('sampaguita');
        final a = await repo.startQuiz(QuizKind.plant, plantId: 'sampaguita', total: 3);
        for (var q = 0; q < 3; q++) {
          await repo.saveAnswer(a, 'q$q', chosen: 'a', correct: true);
        }
        await repo.finishQuiz(a);
        await repo.explorePlant('gumamela');
      },
    );
    await tester.tap(find.bySemanticsLabel(RegExp('^Shop')));
    await settle(tester);
    await bringIntoView(tester, find.text('BUY · 20'));
    await tapButton(tester, 'BUY · 20');
    await tapButton(tester, 'Not now');
    expect(find.text('Buy the Stripes pot?'), findsNothing);
    expect(await repo.getLeaves(), 21);
    expect(await repo.getOwned(), isEmpty);
    await endApp(tester, db);
  });

  testWidgets('badges: Home claims earned ones; finishing World 1 gives the tarsier to wear', (tester) async {
    await startApp(
      tester,
      badges: true,
      seed: () async {
        for (final id in ['sampaguita', 'gumamela', 'makahiya', 'kalamansi']) {
          final a = await repo.startQuiz(QuizKind.plant, plantId: id, total: 3);
          await repo.finishQuiz(a);
        }
      },
    );
    // First Sprout was earned before: Home shows it once it opens.
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.text('You got a badge!'), findsOneWidget);
    expect(find.text('+5 leaves'), findsOneWidget);
    await tapButton(tester, 'YAY!');
    expect(find.text('You got a badge!'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Plants'));
    await settle(tester);
    await bringIntoView(tester, find.text('Malunggay'));
    await tester.tap(find.text('Malunggay'));
    await settle(tester);
    // Exploring Malunggay (+5) on top of the badge's leaves makes Binhi grow.
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    expect(find.text('Thank you for the leaves!'), findsOneWidget);
    await tapButton(tester, 'YAY!');
    await tapButton(tester, 'START QUIZ');
    final bank = QuestionBank.plantQuiz('malunggay');
    for (var i = 1; i <= 3; i++) {
      await answer(tester, onScreen(tester, bank), right: true);
      await tapButton(tester, 'CHECK');
      await tapButton(tester, i == 3 ? 'SEE RESULTS' : 'CONTINUE');
    }
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    if (find.text('Thank you for the leaves!').evaluate().isNotEmpty) await tapButton(tester, 'YAY!');
    expect(find.text('You got a sticker!'), findsOneWidget);
    await tapButton(tester, 'YAY!');

    expect(find.text('You got a badge!'), findsOneWidget);
    expect(find.text('Tarsier'), findsOneWidget);
    await tapButton(tester, 'USE IT');
    await settle(tester);
    expect((await repo.getProfile())!.avatarId, 'animal_tarsier');
    expect(await repo.getBadges(), {Achievement.firstSprout, Achievement.backyard});
    await endApp(tester, db);
  });

  testWidgets('a wrong answer is a gentle "Good try!" with the right answer', (tester) async {
    await startApp(tester);
    await tester.tap(find.bySemanticsLabel('Plants'));
    await settle(tester);
    await tester.tap(find.text('Sampaguita'));
    await settle(tester);
    await tapButton(tester, 'START QUIZ');
    final q = onScreen(tester, QuestionBank.plantQuiz('sampaguita'));
    await answer(tester, q, right: false);
    await tapButton(tester, 'CHECK');
    expect(find.text('Good try!'), findsOneWidget);
    expect(find.text('Answer: ${q.correctLabel}'), findsOneWidget);
    expect(find.textContaining('WRONG'), findsNothing);
    await endApp(tester, db);
  });

  testWidgets('stopping a quiz asks first, and KEEP PLAYING stays', (tester) async {
    await startApp(tester);
    await tester.tap(find.bySemanticsLabel('Quiz'));
    await settle(tester);
    await tester.tap(find.text('Sprout Quiz'));
    await settle(tester);
    expect(find.text('Question 1 of 5'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Stop quiz'));
    await settle(tester);
    expect(find.text('Stop this quiz?'), findsOneWidget);
    await tapButton(tester, 'KEEP PLAYING');
    expect(find.text('Question 1 of 5'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Stop quiz'));
    await settle(tester);
    await tapButton(tester, 'Stop');
    expect(find.text('Sprout Quiz'), findsOneWidget, reason: 'back on the Quiz tab');
    await endApp(tester, db);
  });

  testWidgets('Quiz tab: grade 4 is a Sprout; locked plant quizzes are mysteries', (tester) async {
    await startApp(tester);
    await tester.tap(find.bySemanticsLabel('Quiz'));
    await settle(tester);
    expect(find.text('YOUR LEVEL'), findsOneWidget);
    expect(find.text('CHALLENGE'), findsOneWidget);
    expect(find.bySemanticsLabel('Sampaguita quiz'), findsOneWidget);
    expect(find.text('14 more plant quizzes unlock as you explore.', skipOffstage: false), findsOneWidget);
    await endApp(tester, db);
  });

  testWidgets('Edit profile saves name, grade and look', (tester) async {
    await startApp(tester);
    await tester.tap(find.bySemanticsLabel('Profile'));
    await settle(tester);
    expect(find.text('Jamie'), findsOneWidget);
    await tapButton(tester, 'EDIT PROFILE');
    await tester.enterText(find.byType(TextField), 'Maria');
    await tester.tap(find.bySemanticsLabel('Grade 6'));
    // Close the keyboard first, or the list keeps the name box in view.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await scrollToBottom(tester);
    await tester.tap(find.bySemanticsLabel('Girl with a braid and a flower'));
    await settle(tester);
    await tapButton(tester, 'SAVE');
    final p = (await repo.getProfile())!;
    expect(p.name, 'Maria');
    expect(p.grade, 6);
    expect(p.avatarId, 'girl_braid');
    expect(find.text('Maria'), findsOneWidget);
    await endApp(tester, db);
  });

  testWidgets('Settings: switches save; Start over needs a second, smaller tap', (tester) async {
    await startApp(
      tester,
      seed: () async {
        await repo.explorePlant('sampaguita');
      },
    );
    await tester.tap(find.bySemanticsLabel('Profile'));
    await settle(tester);
    await tester.tap(kidIcon(KidIcon.settings));
    await settle(tester);

    await tester.tap(find.text('Music'));
    await settle(tester);
    expect((await repo.getProfile())!.musicOn, isFalse);
    expect((await repo.getProfile())!.soundOn, isTrue, reason: 'music and sounds are separate');

    await bringIntoView(tester, find.text('Slow'));
    await tester.tap(find.text('Slow'));
    await settle(tester);
    expect((await repo.getProfile())!.speechRate, 'slow');

    await scrollToBottom(tester);
    await tester.tap(find.text('Less motion'));
    await settle(tester);
    expect((await repo.getProfile())!.lessMotion, isTrue);

    await scrollToBottom(tester);
    await tester.tap(find.text('Start over').last);
    await settle(tester);
    expect(find.text('Start over?'), findsOneWidget);
    await tapButton(tester, 'KEEP MY PROGRESS');
    expect(await repo.getLeaves(), 5);

    await tester.tap(find.text('Start over').last);
    await settle(tester);
    // In the sheet, "Start over" is the smaller second button.
    await tester.tap(find.descendant(of: find.byType(BottomSheet), matching: find.text('Start over')));
    await settle(tester);
    expect(await repo.getLeaves(), 0);
    expect((await repo.getProfile())!.name, 'Jamie', reason: 'name stays');
    await endApp(tester, db);
  });

  testWidgets('smart review: a missed question waits on the Quiz tab and pays a leaf when fixed', (tester) async {
    final missed = QuestionBank.plantQuiz('sampaguita')[1];
    await startApp(
      tester,
      seed: () async {
        await repo.explorePlant('sampaguita');
        final a = await repo.startQuiz(QuizKind.plant, plantId: 'sampaguita', total: 3);
        for (final q in QuestionBank.plantQuiz('sampaguita')) {
          await repo.saveAnswer(a, q.id, chosen: 'x', correct: q.id != missed.id);
        }
        await repo.finishQuiz(a);
      },
    );
    await tester.tap(find.bySemanticsLabel('Quiz'));
    await settle(tester);
    expect(find.text('BONUS ROUND'), findsOneWidget);
    expect(find.text('1 tricky question'), findsOneWidget);
    final before = await repo.getLeaves();
    await tester.tap(find.text('BONUS ROUND'));
    await settle(tester);
    expect(find.text('Question 1 of 1'), findsOneWidget);
    await answer(tester, missed, right: true);
    await tapButton(tester, 'CHECK');
    expect(find.text('Correct!'), findsOneWidget);
    await tapButton(tester, 'SEE RESULTS');
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);
    expect(find.text('You remembered every one. All caught up!'), findsOneWidget);
    expect(find.text('PLAY AGAIN'), findsNothing);
    expect(await repo.getLeaves(), before + 1);
    // That leaf grows Binhi into a sprout, so his celebration comes first.
    if (find.text('YAY!').evaluate().isNotEmpty) await tapButton(tester, 'YAY!');
    await tapButton(tester, 'DONE');
    expect(find.text('BONUS ROUND'), findsNothing);
    expect(find.text('All caught up! Questions you miss will come back here.'), findsOneWidget);
    await endApp(tester, db);
  });

  test('perfect plant quiz pays 11 (rules check)', () {
    final r = QuizReward.compute(score: 3, total: 3, previousBest: 0, hadPerfectBefore: false);
    expect(r.total, 11);
  });
}

/// Flings the open screen's list to its end.
Future<void> scrollToBottom(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).last, const Offset(0, -3000));
  await settle(tester);
}
