import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/rules.dart';
import 'package:plantquest/main.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show endApp, settle;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase db;

  Future<void> startApp(WidgetTester tester, {List<String> quizzesDone = const [], double textScale = 1}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    db = AppDatabase(NativeDatabase.memory());
    final repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    for (final id in quizzesDone) {
      await repo.explorePlant(id);
      final a = await repo.startQuiz(QuizKind.plant, plantId: id, total: 3);
      for (var q = 0; q < 3; q++) {
        await repo.saveAnswer(a, 'q$q', chosen: 'a', correct: true);
      }
      await repo.finishQuiz(a);
    }
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()));
    await settle(tester);
  }

  testWidgets('a new explorer starts on World 1; dots and swipes turn the page', (tester) async {
    await startApp(tester);
    expect(find.text('World 1 · Bakuran'), findsOneWidget);
    expect(find.text('Swipe for Bukid'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('World 2, Bukid'));
    await settle(tester);
    expect(find.text('World 2 · Bukid'), findsOneWidget);
    expect(find.text('Finish Bakuran to open'), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await settle(tester);
    expect(find.text('World 3 · Kalikasan'), findsOneWidget);
    expect(find.text('Back to Bakuran'), findsOneWidget);
    await endApp(tester, db);
  });

  testWidgets('Home opens on the world with the next plant', (tester) async {
    await startApp(tester, quizzesDone: [for (final p in PlantCatalog.inWorld(1)) p.id]);
    expect(find.text('World 2 · Bukid'), findsOneWidget);
    expect(find.text('Tap ${PlantCatalog.inWorld(2).first.name} to explore!'), findsOneWidget);
    await endApp(tester, db);
  });

  testWidgets('big phone text fits the world pages', (tester) async {
    await startApp(tester, textScale: 1.35);
    expect(find.text('World 1 · Bakuran'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await endApp(tester, db);
  });
}
