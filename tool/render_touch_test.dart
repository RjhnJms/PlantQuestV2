// Every plant reacting to a touch on its special part (PLAN.md §5j), plus
// Makahiya open and folded. Saves docs/previews/touch/all.png.
//
// Run:  flutter test tool/render_touch_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/plants/plant_drawing.dart';
import 'package:plantquest/art/plants/plant_touch.dart';
import 'package:plantquest/art/plants/plant_view.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/theme/app_colors.dart';

const _root = ValueKey('root');

Widget _tile(String id, {double elapsed = 0.16, bool touched = true, String? caption}) {
  final drawing = PlantArt.of(id);
  final at = drawing.regions()[PlantPart.special]!.getBounds().center;
  final touch = touched ? PlantTouch.after(at, elapsed) : null;
  return Container(
    margin: const EdgeInsets.all(4),
    color: AppColors.card,
    child: Column(
      children: [
        SizedBox(
          width: 150,
          height: 196,
          child: CustomPaint(
            painter: PlantPainter(
              drawing: drawing,
              mode: PlantMode.detail,
              touch: touch,
              effect: touched ? PlantTouch.effectOf(id) : null,
            ),
          ),
        ),
        Text(caption ?? '${PlantCatalog.byId(id).name}: ${PlantTouch.effectOf(id).name}', style: const TextStyle(fontSize: 12, fontFamily: 'Fredoka')),
      ],
    ),
  );
}

void main() {
  testWidgets('touch reactions', (tester) async {
    final fredoka = FontLoader('Fredoka')
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Fredoka-Medium.ttf').readAsBytesSync())));
    await fredoka.load();
    tester.view.physicalSize = const Size(1640, 2000);
    tester.view.devicePixelRatio = 2;
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
                _tile('makahiya', touched: false, caption: 'Makahiya: open'),
                _tile('makahiya', elapsed: 0.3, caption: 'Makahiya: folded'),
                for (final p in PlantCatalog.all.where((p) => p.id != 'makahiya')) _tile(p.id),
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
      File('docs/previews/touch/all.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
