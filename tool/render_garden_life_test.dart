// Frames of My Garden coming alive (swaying, drifting, butterflies), for
// checking the motion. Saves to docs/previews/garden-life/.
//
// Run:  flutter test tool/render_garden_life_test.dart

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
import 'package:plantquest/app/router.dart';
import 'package:plantquest/main.dart';

import '../test/features/flow_test.dart' show endApp;
import '../test/test_overrides.dart';

const _out = 'docs/previews/garden-life';

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

  testWidgets('garden life frames', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Juan', grade: 4, avatarId: 'boy_cap');
    for (final id in ['sampaguita', 'gumamela', 'makahiya', 'kalamansi', 'palay', 'mongo', 'kangkong']) {
      await repo.explorePlant(id);
    }
    await tester.pumpWidget(
      RepaintBoundary(
        key: _root,
        child: ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()),
      ),
    );
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(routerProvider).go('/profile/garden');
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    var at = 0;
    for (final ms in [0, 1000, 2000, 3000]) {
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
