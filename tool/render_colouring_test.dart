// Every plant's colouring page (PLAN.md §5l). Top: the plain outline.
// Below: every part filled with a different colour, to check that the
// parts close up properly. Saves docs/previews/colouring/pages.png.
//
// Run:  flutter test tool/render_colouring_test.dart

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/colouring/colouring_art.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/game/colouring.dart';
import 'package:plantquest/theme/app_colors.dart';

const _root = ValueKey('root');

void main() {
  testWidgets('colouring pages', (tester) async {
    final fredoka = FontLoader('Fredoka')
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Fredoka-Medium.ttf').readAsBytesSync())));
    await fredoka.load();
    const plants = PlantCatalog.all;
    final filled = <String, ui.Image>{};
    final parts = <String, int>{};
    await tester.runAsync(() async {
      for (final p in plants) {
        final regions = await ColouringArt.regions(ColouringArt.of(p.id));
        final canvas = ColouringCanvas(regions);
        final r = math.Random(3);
        final ids = regions.ids;
        for (var id = 0; id < regions.count; id++) {
          final rgb = ColouringRules.colours[r.nextInt(10)];
          for (var i = 0; i < ids.length; i++) {
            if (ids[i] != id) continue;
            final o = i * 4;
            canvas.pixels
              ..[o] = rgb >> 16 & 0xFF
              ..[o + 1] = rgb >> 8 & 0xFF
              ..[o + 2] = rgb & 0xFF
              ..[o + 3] = 255;
          }
        }
        filled[p.id] = await ColouringArt.image(canvas.pixels);
        parts[p.id] = regions.count;
      }
    });

    Widget tile(String id, {ui.Image? colours}) => Container(
      margin: const EdgeInsets.all(4),
      color: AppColors.card,
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 200,
            child: CustomPaint(painter: ColouringPainter(art: ColouringArt.of(id), colours: colours)),
          ),
          Text(
            colours == null ? PlantCatalog.byId(id).name : '${parts[id]} parts',
            style: const TextStyle(fontSize: 12, fontFamily: 'Fredoka'),
          ),
        ],
      ),
    );

    tester.view.physicalSize = const Size(1400, 1700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      RepaintBoundary(
        key: _root,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: Wrap(
              children: [
                for (final p in plants.take(8)) tile(p.id),
                for (final p in plants.take(8)) tile(p.id, colours: filled[p.id]),
                for (final p in plants.skip(8)) tile(p.id),
                for (final p in plants.skip(8)) tile(p.id, colours: filled[p.id]),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('docs/previews/colouring/pages.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
