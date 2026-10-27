// Draws every plant's Label it and Grow it screen onto one sheet each, to
// check the layout works for all 15 plants. Saves to docs/previews/minigames/.
// Not part of the normal test run.
//
// Run:  flutter test tool/render_minigames_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/features/games/grow_game.dart';
import 'package:plantquest/features/games/label_game.dart';
import 'package:plantquest/theme/app_colors.dart';
import 'package:plantquest/theme/app_theme.dart';

import '../test/features/flow_test.dart' show endApp;
import '../test/test_overrides.dart';

const _out = 'docs/previews/minigames';
const _cell = Size(360, 760);

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

Future<void> _sheet(WidgetTester tester, String name, Widget Function(String id) screen) async {
  await _loadFonts();
  tester.view.physicalSize = Size(_cell.width * 5, _cell.height * 3);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
  final key = GlobalKey();
  await tester.pumpWidget(
    ProviderScope(
      overrides: testOverrides(db),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: AppColors.border,
            child: Wrap(
              children: [
                for (final p in PlantCatalog.all)
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: SizedBox(width: _cell.width - 4, height: _cell.height - 4, child: screen(p.id)),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
  expect(tester.takeException(), isNull);
  await endApp(tester, db);
}

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('Label it, all plants', (tester) => _sheet(tester, 'all-label', (id) => LabelGameScreen(plantId: id)));
  testWidgets('Grow it, all plants', (tester) => _sheet(tester, 'all-grow', (id) => GrowGameScreen(plantId: id)));
}
