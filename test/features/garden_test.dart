import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/art/garden/garden_art.dart';
import 'package:plantquest/art/plants/plant_drawing.dart';
import 'package:plantquest/art/plants/plants_bakuran.dart';
import 'package:plantquest/game/garden.dart';
import 'package:plantquest/game/weather.dart';
import 'package:plantquest/main.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show bringIntoView, endApp, settle;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase db;
  late ProgressRepository repo;

  group('repository', () {
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = ProgressRepository(db);
    });
    tearDown(() => db.close());

    test('buying a decoration spends leaves once', () async {
      for (final id in ['sampaguita', 'gumamela', 'makahiya', 'kalamansi']) {
        await repo.explorePlant(id);
      }
      expect(await repo.getLeaves(), 20);
      expect(await repo.buyDecoration(GardenDeco.fence), isFalse, reason: 'costs 25');
      expect(await repo.buyDecoration(GardenDeco.bench), isTrue);
      expect(await repo.buyDecoration(GardenDeco.bench), isFalse, reason: 'already owned');
      expect(await repo.getLeaves(), 0);
      expect(await repo.getLeavesEarned(), 20, reason: 'Binhi never shrinks');
      expect(await repo.getDecorations(), {GardenDeco.bench});
      expect(await repo.getOwned(), isEmpty, reason: 'not an outfit');
    });

    test('moves are saved and Start over clears them', () async {
      await repo.moveGardenPiece('plant_gumamela', 100, 400);
      await repo.moveGardenPiece('plant_gumamela', 120, 420);
      expect(await repo.getGardenSpots(), {'plant_gumamela': (120.0, 420.0)});
      await repo.startOver();
      expect(await repo.getGardenSpots(), isEmpty);
    });
  });

  Future<void> startApp(WidgetTester tester, List<String> explored, {bool openGarden = true}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    db = AppDatabase(NativeDatabase.memory());
    repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    for (final id in explored) {
      await repo.explorePlant(id);
    }
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()));
    await settle(tester);
    if (!openGarden) return;
    await tester.tap(find.bySemanticsLabel('Profile'));
    await settle(tester);
    final card = find.bySemanticsLabel(RegExp(r'^My Garden\.'));
    await bringIntoView(tester, card);
    await tester.tap(card);
    await settle(tester);
  }

  testWidgets('explored plants grow in their homes; a bench can be bought', (tester) async {
    await startApp(tester, ['sampaguita', 'palay', 'kangkong', 'kalamansi']);
    expect(find.text('4 of 15 plants growing'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Sampaguita\. Hold, then drag')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Garden bed with ${PlantCatalog.byId('palay').name}')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^${PlantCatalog.byId('kangkong').name}, in the pond')), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Bench. 20 leaves. Tap to buy.'));
    await settle(tester);
    expect(find.text('Buy the Bench?'), findsOneWidget);
    await tester.tap(find.text('BUY · 20'));
    await settle(tester);
    expect(await repo.getDecorations(), {GardenDeco.bench});
    // Bought decorations move to the end of the tray.
    final placed = find.bySemanticsLabel('Bench. In your garden.');
    await tester.scrollUntilVisible(placed, 200, scrollable: find.byType(Scrollable).last);
    expect(placed, findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Bench\. Hold, then drag')), findsOneWidget);
    await endApp(tester, db);
  });

  testWidgets('hold and drag moves a plant, and the spot is saved', (tester) async {
    await startApp(tester, ['gumamela']);
    final plant = find.bySemanticsLabel(RegExp(r'^Gumamela\. Hold, then drag'));
    final gesture = await tester.startGesture(tester.getCenter(plant));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(60, 80));
    await tester.pump();
    await gesture.up();
    await settle(tester);
    final spot = (await repo.getGardenSpots())[GardenLayout.plant('gumamela')];
    final start = GardenLayout.startOf(GardenLayout.plant('gumamela'));
    expect(spot, isNotNull);
    expect(spot!.$1, greaterThan(start.x + 20));
    expect(spot.$2, greaterThan(start.y + 30));
    expect(find.text('Gumamela'), findsNothing, reason: 'still in the garden, not the plant page');
    await endApp(tester, db);
  });

  testWidgets('tapping a cloud makes rain; tapping the sun brings a rainbow', (tester) async {
    await startApp(tester, ['sampaguita']);
    expect(find.bySemanticsLabel('Sunny day. Tap a cloud for rain.'), findsOneWidget);
    // Tap where the drawing puts a cloud, then the sun (design units × scale).
    final sky = find.bySemanticsLabel('Sky. Make it rain.');
    final origin = tester.getTopLeft(sky);
    final k = tester.getSize(sky).width / GardenLayout.size.width;
    await tester.tapAt(origin + GardenGroundPainter.cloudsFor(GardenWeather.sunny).first.$1 * k);
    await settle(tester);
    expect(find.bySemanticsLabel('Rainy day. Tap the sun to stop it.'), findsOneWidget);
    expect(find.text('Plants drink rainwater through their roots!'), findsOneWidget);
    await tester.tapAt(origin + GardenGroundPainter.sunCentre * k);
    await settle(tester);
    expect(find.bySemanticsLabel('Rainbow! Tap a cloud for rain.'), findsOneWidget);
    expect(find.textContaining('A rainbow!'), findsOneWidget);
    await endApp(tester, db);
  });

  testWidgets("Home's switch shows My Garden, with decorations in a sheet", (tester) async {
    await startApp(tester, ['sampaguita', 'gumamela', 'makahiya', 'kalamansi'], openGarden: false);
    expect(find.bySemanticsLabel(RegExp(r'^Sampaguita\. Hold, then drag')), findsNothing, reason: 'garden hidden');
    await tester.tap(find.bySemanticsLabel('My Garden'));
    await settle(tester);
    expect(find.bySemanticsLabel(RegExp(r'^Sampaguita\. Hold, then drag')), findsOneWidget);
    expect(find.text('4 of 15 plants growing'), findsOneWidget);
    await tester.tap(find.text('DECORATE'));
    await settle(tester);
    expect(find.bySemanticsLabel('Bench. 20 leaves. Tap to buy.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Bench. 20 leaves. Tap to buy.'));
    await settle(tester);
    await tester.tap(find.text('BUY · 20'));
    await settle(tester);
    expect(await repo.getDecorations(), {GardenDeco.bench});
    await tester.tapAt(const Offset(200, 100)); // close the sheet
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Adventure'));
    await settle(tester);
    expect(find.bySemanticsLabel(RegExp(r'^Sampaguita\. Hold, then drag')), findsNothing);
    await endApp(tester, db);
  });

  testWidgets('tapping a plant wiggles it and shows its name, without leaving the garden', (tester) async {
    await startApp(tester, ['gumamela']);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Gumamela\. Hold, then drag')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Gumamela'), findsOneWidget, reason: 'its name pops up');
    expect(find.text('1 of 15 plants growing'), findsOneWidget, reason: 'still in the garden');
    await settle(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Gumamela'), findsNothing, reason: 'the name goes away');
    await endApp(tester, db);
  });

  testWidgets('big phone text: the plant fact gets its own row, Decorate opens over the tab bar', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.35;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await startApp(tester, ['sampaguita'], openGarden: false);
    await tester.tap(find.bySemanticsLabel('My Garden'));
    await settle(tester);
    final sky = find.bySemanticsLabel('Sky. Make it rain.');
    final origin = tester.getTopLeft(sky);
    final skyWidth = tester.getSize(sky).width;
    final k = skyWidth / GardenLayout.size.width;
    await tester.tapAt(origin + GardenGroundPainter.cloudsFor(GardenWeather.sunny).first.$1 * k);
    await settle(tester);
    final note = find.text('Plants drink rainwater through their roots!');
    expect(note, findsOneWidget);
    // Nearly as wide as the garden, not squeezed beside the button.
    expect(tester.getSize(note).width, greaterThan(skyWidth * 0.5));
    await tester.tap(find.text('DECORATE'));
    await settle(tester);
    final bench = find.bySemanticsLabel(RegExp(r'^Bench\.'));
    expect(bench, findsOneWidget);
    // Nothing (like the bottom tabs) covers it: a tap on it reaches it.
    expect(bench.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await endApp(tester, db);
  });

  testWidgets('dropping a plant on another makes it stand beside it', (tester) async {
    await startApp(tester, ['sampaguita', 'gumamela']);
    final moving = find.bySemanticsLabel(RegExp(r'^Gumamela\. Hold, then drag'));
    final target = find.bySemanticsLabel(RegExp(r'^Sampaguita\. Hold, then drag'));
    final from = tester.getCenter(moving);
    final gesture = await tester.startGesture(from);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveBy(tester.getCenter(target) - from);
    await tester.pump();
    await gesture.up();
    await settle(tester);
    final spots = await repo.getGardenSpots();
    final g = spots[GardenLayout.plant('gumamela')]!;
    final s = GardenLayout.startOf(GardenLayout.plant('sampaguita'));
    final mine = GardenLayout.footprint(
      Offset(g.$1, g.$2),
      GardenLayout.startOf(GardenLayout.plant('gumamela')).box,
      92,
    );
    final theirs = GardenLayout.footprint(Offset(s.x, s.y), s.box, s.box);
    expect((mine.$1 - theirs.$1).distance, greaterThanOrEqualTo(mine.$2 + theirs.$2 - 1));
    await endApp(tester, db);
  });

  testWidgets('tapping Makahiya in the garden folds its leaves', (tester) async {
    await startApp(tester, ['makahiya']);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Makahiya\. Hold, then drag')));
    await tester.pump(); // the reaction's clock starts on this frame
    await tester.pump(const Duration(milliseconds: 600));
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<PlantPainter>()
        .firstWhere((p) => p.drawing is MakahiyaDrawing);
    expect(painter.touch?.fold, 1);
    await tester.pump(const Duration(seconds: 5));
    await endApp(tester, db);
  });

  testWidgets('an empty garden says how to fill it', (tester) async {
    await startApp(tester, []);
    expect(find.text('Explore a plant and it will grow here!'), findsOneWidget);
    await endApp(tester, db);
  });
}
