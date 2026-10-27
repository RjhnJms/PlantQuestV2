import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/plants/plant_drawing.dart';
import 'package:plantquest/art/plants/plant_view.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(
    body: Center(child: SizedBox(width: 300, child: child)),
  ),
);

void main() {
  test('15 plants, 5 per world, all with artwork', () {
    expect(PlantCatalog.all, hasLength(15));
    for (final w in [1, 2, 3]) {
      expect(PlantCatalog.inWorld(w), hasLength(5));
    }
    for (final p in PlantCatalog.all) {
      expect(PlantArt.has(p.id), isTrue, reason: p.id);
    }
    expect(PlantCatalog.all.map((p) => p.id).toSet(), hasLength(15));
  });

  // Every part must be reachable by a tap somewhere on the drawing, and the
  // zone must be big enough for a child's finger.
  for (final p in PlantCatalog.all) {
    test('${p.id}: every part can be tapped', () {
      final drawing = PlantArt.of(p.id);
      final hits = <PlantPart, int>{};
      for (var y = 0.0; y < PlantDrawing.designSize.height; y += 2) {
        for (var x = 0.0; x < PlantDrawing.designSize.width; x += 2) {
          final part = drawing.hitTest(Offset(x, y));
          if (part != null) hits[part] = (hits[part] ?? 0) + 1;
        }
      }
      for (final part in PlantPart.values) {
        // 40 samples × 4 square units ≈ a 13 × 13 design-unit area at least.
        expect(hits[part] ?? 0, greaterThan(40), reason: '${p.id} $part zone is too small');
      }
    });
  }

  test('thumbnail crops keep the same shape and stay inside the design box', () {
    final shape = PlantDrawing.thumbnailRect.width / PlantDrawing.thumbnailRect.height;
    for (final p in PlantCatalog.all) {
      final crop = PlantArt.of(p.id).thumbnailCrop;
      expect(crop.width / crop.height, closeTo(shape, 0.001), reason: p.id);
      expect(crop.left, greaterThanOrEqualTo(0), reason: p.id);
      expect(crop.right, lessThanOrEqualTo(200), reason: p.id);
    }
  });

  testWidgets('every plant draws in every look', (tester) async {
    for (final p in PlantCatalog.all) {
      for (final mode in PlantMode.values) {
        for (final locked in [false, true]) {
          await tester.pumpWidget(_wrap(PlantView(plant: p, mode: mode, locked: locked, highlight: PlantPart.leaf)));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull, reason: '${p.id} $mode locked=$locked');
        }
      }
    }
  });

  testWidgets('tapping the stem area reports the stem', (tester) async {
    PlantPart? tapped;
    await tester.pumpWidget(
      _wrap(PlantView(plant: PlantInfo.mango, mode: PlantMode.detail, onPartTap: (p) => tapped = p)),
    );
    final box = tester.getRect(find.byType(PlantView));
    // Mango trunk sits at design x=100, y≈170 in a 200 × 262 box.
    await tester.tapAt(Offset(box.left + box.width * 0.5, box.top + box.height * 170 / 262));
    expect(tapped, PlantPart.stem);
  });
}
