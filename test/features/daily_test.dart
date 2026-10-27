import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/daily.dart';
import 'package:plantquest/main.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show endApp, settle;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase db;
  late ProgressRepository repo;

  Future<void> startApp(WidgetTester tester, {bool gift = false}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db, dailyGift: gift),
        child: const PlantQuestApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets("Home offers Binhi's gift once a day", (tester) async {
    await startApp(tester, gift: true);
    await settle(tester);
    expect(find.text('A gift from Binhi!'), findsOneWidget);
    expect(find.bySemanticsLabel('Gift 1 of 7. Gift 7 is a big surprise.'), findsOneWidget);
    await tester.tap(find.text('OPEN MY GIFT'));
    await settle(tester);
    expect(find.text('You got 3 leaves!'), findsOneWidget);
    await tester.tap(find.text('YAY!'));
    await settle(tester);
    expect(await repo.getLeaves(), 3);
    expect(await repo.getDailyCount(DailyKind.gift), 1);
    expect(find.text('A gift from Binhi!'), findsNothing);
    await endApp(tester, db);
  });

  testWidgets('watering Binhi pays once a day', (tester) async {
    await startApp(tester);
    final can = find.bySemanticsLabel('Water Binhi');
    expect(can, findsOneWidget, reason: 'he is thirsty at first');
    await tester.tap(can);
    await settle(tester);
    expect(find.text('Ahh, thank you! +2 leaves'), findsOneWidget);
    expect(await repo.getLeaves(), 2);
    final watered = find.bySemanticsLabel('Water Binhi. He had water today.');
    expect(watered, findsOneWidget);
    await tester.tap(watered);
    await settle(tester);
    expect(find.text('Thank you! I had my water today.'), findsOneWidget);
    expect(await repo.getLeaves(), 2);
    await endApp(tester, db);
  });
}
