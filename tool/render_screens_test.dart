// Pictures of every main screen with some progress, for UI reviews.
// Saves to docs/previews/ui/<set>/. Not part of the normal test run.
//
// Run:  flutter test tool/render_screens_test.dart --dart-define=SET=now

import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/app/router.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/content/questions.dart';
import 'package:plantquest/game/garden.dart';
import 'package:plantquest/game/rewards.dart';
import 'package:plantquest/game/weather.dart';
import 'package:plantquest/game/rules.dart';
import 'package:plantquest/main.dart';

import '../test/features/flow_test.dart' show endApp, settle;
import '../test/test_overrides.dart';

const _set = String.fromEnvironment('SET', defaultValue: 'now');
const _out = 'docs/previews/ui/$_set';

Future<void> _loadFonts() async {
  final fredoka = FontLoader('Fredoka');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    fredoka.addFont(Future.value(ByteData.sublistView(File('assets/fonts/Fredoka-$w.ttf').readAsBytesSync())));
  }
  await fredoka.load();
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
}

Future<void> _seed(ProgressRepository repo) async {
  await repo.saveProfile(name: 'Juan', grade: 4, avatarId: 'boy_cap');
  await repo.recordVisit();
  for (final id in ['sampaguita', 'gumamela', 'makahiya', 'kalamansi', 'malunggay', 'palay']) {
    await repo.explorePlant(id);
    final a = await repo.startQuiz(QuizKind.plant, plantId: id, total: 3);
    for (final (q, question) in QuestionBank.plantQuiz(id).indexed) {
      await repo.saveAnswer(a, question.id, chosen: 'a', correct: q < 2 || id == 'sampaguita');
    }
    await repo.finishQuiz(a);
  }
  await repo.explorePlant('mango');
  await repo.buy(OutfitItem.stripes);
  await repo.winGame(MiniGame.label, 'sampaguita', 3);
  await repo.claimNewBadges();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await settle(tester);
  await tester.pump(const Duration(seconds: 2));
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

const _root = ValueKey('root');

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  for (final (tall, suffix) in [(false, ''), (true, '-full')]) {
    testWidgets('screens$suffix', (tester) async {
      await _loadFonts();
      // A common phone: 390 x 844. "full" is extra tall to see whole pages.
      tester.view.physicalSize = Size(780, tall ? 4000 : 1688);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final db = AppDatabase(NativeDatabase.memory());
      await _seed(ProgressRepository(db));
      await tester.pumpWidget(
        RepaintBoundary(
          key: _root,
          child: ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()),
        ),
      );
      await settle(tester);
      final router = ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(routerProvider);
      for (final (path, name) in [
        ('/home', '1-home'),
        ('/plants', '2-plants'),
        ('/plant/sampaguita', '3-plant-details'),
        ('/quiz', '4-quiz'),
        ('/shop', '5-shop'),
        ('/profile', '6-profile'),
        ('/settings', '7-settings'),
        ('/profile/edit', '8-edit-profile'),
        ('/profile/badges', '9-badges'),
        ('/profile/garden', '10-garden'),
      ]) {
        router.go(path);
        await _shot(tester, '$name$suffix');
      }
      await endApp(tester, db);
    });
  }

  // My Garden with every plant and three decorations, tall enough to see
  // the whole garden at once.
  testWidgets('garden full', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(780, 2600);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Juan', grade: 4, avatarId: 'boy_cap');
    for (final p in PlantCatalog.all) {
      await repo.explorePlant(p.id);
    }
    // Every decoration, as if bought.
    for (final d in GardenDeco.values) {
      await db.into(db.purchases).insert(PurchasesCompanion.insert(item: d.item, price: 0, boughtAt: DateTime(2026)));
    }
    await tester.pumpWidget(
      RepaintBoundary(
        key: _root,
        child: ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()),
      ),
    );
    await settle(tester);
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(routerProvider).go('/profile/garden');
    await _shot(tester, '10-garden-all');
    await endApp(tester, db);
  });

  // The garden in each weather (PLAN.md §5f).
  for (final (name, weather, watered) in [
    ('sunny', GardenWeather.sunny, false),
    ('cloudy', GardenWeather.cloudy, false),
    ('rainy', GardenWeather.rainy, false),
    ('rainbow', GardenWeather.rainy, true),
  ]) {
    testWidgets('garden $name', (tester) async {
      await _loadFonts();
      tester.view.physicalSize = const Size(780, 1688);
      tester.view.devicePixelRatio = 2;
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
        disableAnimations: true,
      );
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      final db = AppDatabase(NativeDatabase.memory());
      final repo = ProgressRepository(db);
      await repo.saveProfile(name: 'Juan', grade: 4, avatarId: 'boy_cap');
      for (final id in ['sampaguita', 'gumamela', 'makahiya', 'kalamansi', 'palay', 'mongo', 'kangkong']) {
        await repo.explorePlant(id);
      }
      await repo.buyDecoration(GardenDeco.bench);
      if (watered) await repo.waterBinhi();
      await tester.pumpWidget(
        RepaintBoundary(
          key: _root,
          child: ProviderScope(
            overrides: testOverrides(db, weather: weather),
            child: const PlantQuestApp(),
          ),
        ),
      );
      await settle(tester);
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(routerProvider).go('/profile/garden');
      await _shot(tester, '11-weather-$name');
      await endApp(tester, db);
    });
  }
}
