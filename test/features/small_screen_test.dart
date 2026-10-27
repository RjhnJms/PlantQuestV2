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

import 'flow_test.dart' show bringIntoView, endApp, kidIcon, settle;

/// Budget phones are often 360 × 640 dp (the Budget_Phone emulator too).
/// Every screen must fit without the "overflowed" error.
void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  Future<AppDatabase> start(WidgetTester tester, {bool onboarded = false}) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final db = AppDatabase(NativeDatabase.memory());
    if (onboarded) await ProgressRepository(db).saveProfile(name: 'Maria Clara', grade: 5, avatarId: 'girl_braid');
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()));
    await settle(tester);
    return db;
  }

  testWidgets('onboarding screens fit a 360 × 640 phone', (tester) async {
    final db = await start(tester);
    expect(tester.takeException(), isNull, reason: 'Welcome');
    await tester.tap(find.text('GET STARTED'));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'Get Started');
    await tester.tap(find.text('GET STARTED'));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'About you');
    await endApp(tester, db);
  });

  testWidgets('tab screens and plant details fit a 360 × 640 phone', (tester) async {
    final db = await start(tester, onboarded: true);
    expect(tester.takeException(), isNull, reason: 'Home');
    for (final tab in ['Plants', 'Quiz', 'Profile', 'Home']) {
      await tester.tap(find.bySemanticsLabel(tab));
      await settle(tester);
      expect(tester.takeException(), isNull, reason: tab);
    }
    await tester.tap(find.bySemanticsLabel('Plants'));
    await settle(tester);
    await tester.tap(find.text('Sampaguita'));
    await settle(tester);
    expect(find.text('Jasminum sambac'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Plant details');
    await endApp(tester, db);
  });

  testWidgets('quiz, settings and edit profile fit a 360 × 640 phone', (tester) async {
    final db = await start(tester, onboarded: true);
    await tester.tap(find.bySemanticsLabel('Quiz'));
    await settle(tester);
    await tester.tap(find.text('Sapling Quiz'));
    await settle(tester);
    expect(find.text('Question 1 of 10'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Quiz question');
    await tester.tap(find.bySemanticsLabel('Stop quiz'));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'Stop sheet');
    await tester.tap(find.text('Stop'));
    await settle(tester);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await settle(tester);
    await tester.tap(kidIcon(KidIcon.settings));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'Settings');
    await tester.tap(kidIcon(KidIcon.back));
    await settle(tester);
    await tester.tap(find.text('EDIT PROFILE'));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'Edit profile');
    await tester.tap(kidIcon(KidIcon.back));
    await settle(tester);
    await bringIntoView(tester, find.text('STICKER BOOK'));
    await tester.tap(find.text('STICKER BOOK'));
    await settle(tester);
    expect(find.text('0 of 15 stickers'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Sticker book');
    await tester.tap(kidIcon(KidIcon.back));
    await settle(tester);
    await bringIntoView(tester, find.text('BADGES'));
    await tester.tap(find.text('BADGES'));
    await settle(tester);
    expect(find.text('0 of 12 badges'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Badges');
    await tester.tap(kidIcon(KidIcon.back));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('^Shop')));
    await settle(tester);
    expect(find.text('Hats'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Shop');
    await endApp(tester, db);
  });
}
