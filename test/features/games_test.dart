import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/plants/plant_drawing.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/content/plant_games.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/rules.dart';
import 'package:plantquest/art/icons/kid_icon.dart';
import 'package:plantquest/main.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show bringIntoView, endApp, kidIcon, settle;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase db;
  late ProgressRepository repo;

  Future<void> startApp(WidgetTester tester, {Size size = const Size(1080, 2400), double ratio = 2.625}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = ratio;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()));
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await bringIntoView(tester, f);
    await tester.tap(f);
    await settle(tester);
  }

  Future<void> openPlantGame(WidgetTester tester, String title) async {
    await tester.tap(find.bySemanticsLabel('Plants'));
    await settle(tester);
    await tester.tap(find.text('Sampaguita'));
    await settle(tester);
    await tap(tester, find.text(title));
  }

  /// Plays Label it the way a child might: tries each box until the word fits.
  Future<void> playLabel(WidgetTester tester) async {
    for (final word in ['Flower', 'Leaf', 'Root', 'Stem']) {
      final chip = find.descendant(of: find.byType(Draggable<PlantPart>), matching: find.text(word));
      for (var i = 0; i < 4 && chip.evaluate().isNotEmpty; i++) {
        final box = find.byType(DragTarget<PlantPart>).at(i);
        if (find.descendant(of: box, matching: find.text('?')).evaluate().isEmpty) continue; // filled
        await tap(tester, chip);
        await tap(tester, box);
      }
      expect(chip, findsNothing, reason: '$word placed');
    }
  }

  testWidgets('Label it: pays +3 once, then it is practice', (tester) async {
    await startApp(tester);
    await openPlantGame(tester, 'Label it');
    expect(find.text('Label the Sampaguita'), findsOneWidget);
    final before = await repo.getLeaves();
    await playLabel(tester);
    expect(find.text('You did it!'), findsOneWidget);
    expect(find.text('+3 leaves!'), findsOneWidget);
    expect(await repo.getLeaves(), before + LeafRules.miniGame);

    await tap(tester, find.text('PLAY AGAIN'));
    await playLabel(tester);
    expect(find.text('You already got leaves here. Great practice!'), findsOneWidget);
    expect(await repo.getLeaves(), before + LeafRules.miniGame);

    await tap(tester, find.text('DONE'));
    await bringIntoView(tester, find.text('Label it'));
    expect(find.bySemanticsLabel(RegExp('^Label it.*Done!')), findsOneWidget, reason: 'card shows a tick');
    await endApp(tester, db);
  });

  testWidgets('Grow it: a wrong tap is a gentle hint; the right order pays +3', (tester) async {
    await startApp(tester);
    await openPlantGame(tester, 'Grow it');
    final labels = PlantGameContent.of('sampaguita').start.labels;
    expect(labels.first, 'Cutting', reason: 'sampaguita starts from a cutting');
    final before = await repo.getLeaves();
    await tap(tester, find.text(labels[2]));
    expect(find.textContaining('Not yet!'), findsOneWidget);
    for (final l in labels) {
      await tap(tester, find.text(l).last);
    }
    expect(find.text('You did it!'), findsOneWidget);
    expect(await repo.getLeaves(), before + LeafRules.miniGame);
    await endApp(tester, db);
  });

  testWidgets('Match it: +1 for each plant matched the first time', (tester) async {
    await startApp(tester);
    await tester.tap(find.bySemanticsLabel('Quiz'));
    await settle(tester);
    await tap(tester, find.text('Match it'));
    final onScreen = [
      for (final p in PlantCatalog.all)
        if (find.text(p.name).evaluate().isNotEmpty) p,
    ];
    expect(onScreen, hasLength(4));
    expect(onScreen.every((p) => p.world == 1), isTrue, reason: 'new players match World 1 plants');
    // A wrong match first.
    await tap(tester, find.text(onScreen[0].name));
    await tap(tester, find.text(PlantGameContent.of(onScreen[1].id).use.label));
    expect(find.textContaining('not quite'), findsOneWidget);
    for (final p in onScreen) {
      await tap(tester, find.text(p.name));
      await tap(tester, find.text(PlantGameContent.of(p.id).use.label));
    }
    expect(find.text('You did it!'), findsOneWidget);
    expect(find.text('+4 leaves!'), findsOneWidget);
    expect((await repo.getGameWins()).where((w) => w.$1 == MiniGame.match), hasLength(4));
    await endApp(tester, db);
  });

  testWidgets('mini-games fit a 360 × 640 phone', (tester) async {
    await startApp(tester, size: const Size(720, 1280), ratio: 2);
    await openPlantGame(tester, 'Label it');
    expect(tester.takeException(), isNull, reason: 'Label it');
    await tester.tap(kidIcon(KidIcon.back));
    await settle(tester);
    await tap(tester, find.text('Grow it'));
    expect(tester.takeException(), isNull, reason: 'Grow it');
    await endApp(tester, db);
  });
}
