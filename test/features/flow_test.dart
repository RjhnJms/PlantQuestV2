import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/art/icons/kid_icon.dart';
import 'package:plantquest/main.dart';

import '../test_overrides.dart';

import 'package:plantquest/widgets/stat_pill.dart';

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  late AppDatabase db;

  /// Starts the real app on a phone-sized screen with a fresh in-memory
  /// database and animations calmed, like the "less motion" setting.
  Future<void> startApp(WidgetTester tester, {Future<void> Function(ProgressRepository repo)? seed}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    db = AppDatabase(NativeDatabase.memory());
    if (seed != null) await seed(ProgressRepository(db));
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()));
    await settle(tester);
  }

  testWidgets('first launch: Welcome → Get Started → About you → Home', (tester) async {
    await startApp(tester);
    expect(find.text('Explore the amazing world of plants!'), findsOneWidget);

    await tester.tap(find.text('GET STARTED'));
    await settle(tester);
    expect(find.text('Learn. Discover. Grow.'), findsOneWidget);

    await tester.tap(find.text('GET STARTED'));
    await settle(tester);
    expect(find.text('Hi! I am Binhi. What should I call you?'), findsOneWidget);

    // LET'S GO stays off until a name and grade are chosen.
    await tester.tap(find.text("LET'S GO!"));
    await settle(tester);
    expect(find.text('Your name'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Jamie');
    await tester.tap(find.bySemanticsLabel('Grade 4'));
    await settle(tester);
    await tester.tap(find.text("LET'S GO!"));
    await settle(tester);

    expect(find.text('Hi, Jamie!'), findsOneWidget);
    expect(find.text('0 of 5 done'), findsOneWidget, reason: 'World 1 label on the path');
    expect(find.text('Tap Sampaguita to explore!'), findsOneWidget, reason: 'Binhi points to the first plant');
    // Opening the app counted today, even on the very first launch.
    final days = tester
        .widgetList<StatPill>(find.byType(StatPill))
        .firstWhere((p) => p.semanticLabel == 'Days visited');
    expect(days.value, 1);
    final profile = await ProgressRepository(db).getProfile();
    expect(profile!.grade, 4);
    expect(profile.onboarded, isTrue);
    await endApp(tester, db);
  });

  testWidgets('Skip names the player Explorer', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('GET STARTED'));
    await settle(tester);
    await tester.tap(find.text('GET STARTED'));
    await settle(tester);
    await tester.tap(find.text('Skip'));
    await settle(tester);
    expect(find.text('Hi, Explorer!'), findsOneWidget);
    await endApp(tester, db);
  });

  group('after onboarding', () {
    Future<void> onboarded(ProgressRepository repo) =>
        repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'girl_sprout');

    testWidgets('returning players go straight to Home', (tester) async {
      await startApp(tester, seed: onboarded);
      expect(find.text('Hi, Jamie!'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('^Binhi is ')), findsOneWidget, reason: 'Binhi in his growth ring');
      await endApp(tester, db);
    });

    testWidgets('a locked stop explains what to finish first', (tester) async {
      await startApp(tester, seed: onboarded);
      await bringIntoView(tester, find.bySemanticsLabel('Gumamela, locked'));
      await tester.tap(find.bySemanticsLabel('Gumamela, locked'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Finish Sampaguita first!', skipOffstage: false), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 400)); // let the fade-out finish
      expect(find.text('Finish Sampaguita first!', skipOffstage: false), findsNothing);
      await endApp(tester, db);
    });

    testWidgets('opening a plant earns 5 leaves once; parts explain themselves', (tester) async {
      await startApp(tester, seed: onboarded);
      await bringIntoView(tester, find.bySemanticsLabel('Sampaguita, start here'));
      await tester.tap(find.bySemanticsLabel('Sampaguita, start here'));
      await settle(tester);

      expect(find.text('Jasminum sambac'), findsOneWidget);
      expect(find.text('+5 leaves for exploring!'), findsOneWidget);
      expect(await ProgressRepository(db).getLeaves(), 5);

      await bringIntoView(tester, find.bySemanticsLabel('Flower'));
      await tester.tap(find.bySemanticsLabel('Root'));
      await settle(tester);
      expect(find.text('Roots hold the plant in the soil and drink water.', skipOffstage: false), findsOneWidget);
      expect(find.text('Tap the parts! 1/4 found'), findsOneWidget);

      for (final part in ['Stem', 'Leaf', 'Flower']) {
        await tester.tap(find.bySemanticsLabel(part));
        await settle(tester);
      }
      expect(find.text('You found all 4 parts!'), findsOneWidget);
      expect(await ProgressRepository(db).getLeaves(), 8);
      await endApp(tester, db);
    });

    testWidgets('Plants tab: unlocked cards show names, locked ones are mysteries', (tester) async {
      await startApp(tester, seed: onboarded);
      await tester.tap(find.bySemanticsLabel('Plants'));
      await settle(tester);
      expect(find.text('0 of 15 explored'), findsOneWidget);
      expect(find.text('Sampaguita'), findsOneWidget);
      expect(find.text('4 more to discover'), findsOneWidget, reason: 'World 1 locked plants share a row');
      expect(find.text('Gumamela'), findsNothing);
      await endApp(tester, db);
    });
  });
}

/// Lets streams, saves and page transitions finish. Doesn't wait for
/// endless animations (there are none with animations calmed).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Closes the app and its database inside the test, so drift's clean-up
/// timers finish before the test checks for leftovers.
Future<void> endApp(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  // Let short-lived effect timers (e.g. waiting for flying leaves) finish.
  await tester.pump(const Duration(seconds: 4));
  final closing = db.close();
  await tester.pump(Duration.zero);
  await closing;
}

/// Scrolls until [finder] is on screen, then centers it a little above the
/// middle (taps at the very edge can miss).
Future<void> bringIntoView(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.4);
  await settle(tester);
}

/// Finds one of PlantQuest's own icons (they are drawn, not font icons).
Finder kidIcon(KidIcon icon) => find.byWidgetPredicate((w) => w is KidIconView && w.icon == icon);
