// Frames of the real Sunrise loading screen as the app starts (normal and
// small phone). Saves to docs/previews/loading-live/.
//
// Run:  flutter test tool/render_loading_live_test.dart

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

const _out = 'docs/previews/loading-live';

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

  for (final (name, size) in [('phone', const Size(780, 1688)), ('small', const Size(720, 1280))]) {
    testWidgets('loading frames $name', (tester) async {
      await _loadFonts();
      tester.view.physicalSize = size;
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
      var at = 0;
      for (final ms in [100, 1500, 3000, 4500]) {
        await tester.pump(Duration(milliseconds: ms - at));
        at = ms;
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$_out/$name-${ms.toString().padLeft(4, '0')}ms.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      }
      await tester.pump(const Duration(seconds: 6));
      await endApp(tester, db);
    });
  }
}
