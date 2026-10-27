import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/icons/kid_icon.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/main.dart';
import 'package:plantquest/services/backup_files.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show bringIntoView, endApp, kidIcon, settle;

/// Stands in for the phone's save and open choosers: keeps the last saved
/// file and hands it back when asked.
class _FakeFiles extends BackupFiles {
  String? savedName;
  Uint8List? saved;

  @override
  Future<bool> save(String name, Uint8List bytes) async {
    savedName = name;
    saved = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async => saved;
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('save to a file, start over, then load it back', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    for (final id in ['sampaguita', 'gumamela', 'makahiya']) {
      await repo.explorePlant(id);
    }
    final files = _FakeFiles();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...testOverrides(db), backupFilesProvider.overrideWithValue(files)],
        child: const PlantQuestApp(),
      ),
    );
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Profile'));
    await settle(tester);
    await tester.tap(kidIcon(KidIcon.settings));
    await settle(tester);

    await bringIntoView(tester, find.text('SAVE'));
    await tester.tap(find.text('SAVE'));
    await settle(tester);
    expect(find.text('Saved!'), findsOneWidget);
    expect(files.savedName, startsWith('PlantQuest-Jamie-'));
    await tester.tap(find.text('OK'));
    await settle(tester);

    await repo.startOver();
    expect(await repo.getLeaves(), 0);

    await tester.tap(find.text('LOAD'));
    await settle(tester);
    expect(find.text('Load this progress?'), findsOneWidget);
    await tester.tap(find.text('Load it'));
    await settle(tester);
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(await repo.getLeaves(), 15, reason: 'three plants explored, 5 leaves each');
    await tester.tap(find.text('OK'));
    await settle(tester);
    await endApp(tester, db);
  });
}
