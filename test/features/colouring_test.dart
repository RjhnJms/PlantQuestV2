import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/app/router.dart';
import 'package:plantquest/art/colouring/colouring_art.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/data/backup.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/features/colouring/colouring_screen.dart';
import 'package:plantquest/game/colouring.dart';
import 'package:plantquest/main.dart';
import 'package:plantquest/widgets/chunky_button.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show endApp, settle;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('repository', () {
    late AppDatabase db;
    late ProgressRepository repo;
    var now = DateTime(2026, 10, 27, 9);
    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = ProgressRepository(db, clock: () => now);
    });
    tearDown(() => db.close());

    final png = Uint8List.fromList([1, 2, 3]);

    test('a draft is kept; hanging pays leaves the first time only', () async {
      await repo.saveColouring('gumamela', png);
      expect((await repo.getColouring('gumamela'))!.hung, isFalse);
      expect(await repo.getLeaves(), 0);

      expect(await repo.hangColouring('gumamela', png), ColouringRules.leaves);
      expect(await repo.getLeaves(), 2);
      now = now.add(const Duration(hours: 1));
      expect(await repo.hangColouring('gumamela', Uint8List.fromList([4])), 0, reason: 'no farming');
      expect(await repo.getLeaves(), 2);

      // Colouring more keeps it on the wall.
      await repo.saveColouring('gumamela', Uint8List.fromList([5]));
      final saved = await repo.getColouring('gumamela');
      expect(saved!.hung, isTrue);
      expect(saved.png, [5]);
    });

    test('newest hung picture comes first; drafts last', () async {
      await repo.hangColouring('gumamela', png);
      now = now.add(const Duration(minutes: 5));
      await repo.hangColouring('makahiya', png);
      await repo.saveColouring('sampaguita', png);
      final list = await repo.watchColourings().first;
      expect([for (final c in list) c.plantId], ['makahiya', 'gumamela', 'sampaguita']);
    });

    test('pictures go into backups and Start over clears them', () async {
      await repo.hangColouring('gumamela', png);
      final file = await Backup(db).export();
      await repo.startOver();
      expect(await repo.getColouring('gumamela'), isNull);
      await Backup(db).restore(file);
      expect((await repo.getColouring('gumamela'))!.png, png);
    });
  });

  testWidgets('every plant has a colouring page with its own parts', (tester) async {
    await tester.runAsync(() async {
      for (final p in PlantCatalog.all) {
        final regions = await ColouringArt.regions(ColouringArt.of(p.id));
        expect(regions.count, greaterThan(5), reason: p.id);
        final sky = regions.at(2, 2);
        final sun = regions.at((30 * ColouringRules.pixelScale).round(), (32 * ColouringRules.pixelScale).round());
        final plant = regions.at(ColouringRules.pixelWidth ~/ 2, (150 * ColouringRules.pixelScale).round());
        expect(sun, isNot(sky), reason: '${p.id}: the sun is its own part');
        expect(regions.isSmall(sky), isFalse, reason: p.id);
        expect(plant, isNot(-1), reason: p.id);
      }
    });
  });

  testWidgets('colour a plant, hang it, and see it on the bahay kubo', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    await repo.explorePlant('gumamela');
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()));
    await settle(tester);
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(routerProvider)
        .push('/plant/gumamela/colour');
    await settle(tester);

    // The page works out its parts (real async work), then is ready.
    Future<void> work() async {
      for (var i = 0; i < 20; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
        await tester.pump();
      }
    }

    await work();
    expect(find.text('Colour Gumamela'), findsOneWidget);
    bool hangReady() => tester.widget<ChunkyButton>(find.widgetWithText(ChunkyButton, 'HANG IT')).onPressed != null;
    expect(hangReady(), isFalse, reason: 'nothing coloured yet');

    // Fill the sky in the top left corner of the page.
    await tester.tap(find.bySemanticsLabel('Fill'));
    await tester.pump();
    final paper = find.bySemanticsLabel('Colouring page. Colour with your finger.');
    final box = tester.getRect(paper);
    final page = ColouringPainter.pageRect(box.size).shift(box.topLeft);
    await tester.tapAt(page.topLeft + const Offset(8, 8));
    await work();
    expect(hangReady(), isTrue);

    await tester.tap(find.text('HANG IT'));
    await work();
    await settle(tester);
    expect(find.textContaining('Ang ganda!'), findsOneWidget);
    expect(find.text('+2 leaves'), findsOneWidget);
    expect(await repo.getLeaves(), 5 + 2, reason: 'explored + first picture');

    await tester.tap(find.text('SEE IT IN MY GARDEN'));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('YAY!').evaluate().isNotEmpty) {
        await tester.tap(find.text('YAY!'));
        await settle(tester);
      }
    }
    await work();
    expect(find.byType(PictureFrame), findsOneWidget, reason: 'hanging on the bahay kubo');

    // Inside the kubo: the wall of pictures.
    await tester.tap(find.bySemanticsLabel('Bahay kubo. See your pictures.'));
    await settle(tester);
    expect(find.bySemanticsLabel(RegExp(r'^Gumamela picture')), findsOneWidget);
    await endApp(tester, db);
  });
}
