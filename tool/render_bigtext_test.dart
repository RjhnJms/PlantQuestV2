// Home's My Garden with big phone text (a plant fact showing, then the
// Decorate panel). Saves to docs/previews/bigtext/.
//
// Run:  flutter test tool/render_bigtext_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/art/garden/garden_art.dart';
import 'package:plantquest/game/garden.dart';
import 'package:plantquest/game/weather.dart';
import 'package:plantquest/main.dart';

import '../test/features/flow_test.dart' show endApp, settle;
import '../test/test_overrides.dart';

const _out = 'docs/previews/bigtext';

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

const _root = ValueKey('root');

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('big text garden', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    tester.platformDispatcher.textScaleFactorTestValue = 1.35;
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Rejohn', grade: 4, avatarId: 'boy_cap');
    await repo.explorePlant('sampaguita');
    await tester.pumpWidget(
      RepaintBoundary(
        key: _root,
        child: ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()),
      ),
    );
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('My Garden'));
    await settle(tester);
    final sky = find.bySemanticsLabel('Sky. Make it rain.');
    final k = tester.getSize(sky).width / GardenLayout.size.width;
    await tester.tapAt(tester.getTopLeft(sky) + GardenGroundPainter.cloudsFor(GardenWeather.sunny).first.$1 * k);
    await settle(tester);
    Future<void> shot(String name) => tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_out/$name.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
    await shot('1-fact');
    await tester.tap(find.text('DECORATE'));
    await settle(tester);
    await shot('2-decorate');
    await endApp(tester, db);
  });
}
