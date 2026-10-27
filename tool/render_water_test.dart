// Frames of watering Binhi on Home, for checking the pouring animation.
// Saves to docs/previews/water/. Not part of the normal test run.
//
// Run:  flutter test tool/render_water_test.dart

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
import 'package:plantquest/main.dart';

import '../test/features/flow_test.dart' show endApp;
import '../test/test_overrides.dart';

const _out = 'docs/previews/water';

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

  testWidgets('watering frames', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    await ProgressRepository(db).saveProfile(name: 'Juan', grade: 4, avatarId: 'boy_cap');
    await tester.pumpWidget(
      RepaintBoundary(
        key: _root,
        child: ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()),
      ),
    );
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.bySemanticsLabel('Water Binhi'));
    var at = 0;
    for (final ms in [250, 500, 800, 1100, 1500, 1900, 2300]) {
      await tester.pump(Duration(milliseconds: ms - at));
      at = ms;
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_out/${ms.toString().padLeft(4, '0')}ms.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
    await endApp(tester, db);
  });
}
