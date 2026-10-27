import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/plants/plant_drawing.dart';
import 'package:plantquest/art/plants/plant_touch.dart';
import 'package:plantquest/art/plants/plant_view.dart';
import 'package:plantquest/content/plant_catalog.dart';

void main() {
  test('makahiya folds fast, stays shut, then opens again', () {
    expect(PlantTouch.after(Offset.zero, 0).fold, 0);
    expect(PlantTouch.after(Offset.zero, 0.1).fold, 1);
    expect(PlantTouch.after(Offset.zero, 0.5).fold, 1);
    expect(PlantTouch.after(Offset.zero, 0.8).fold, closeTo(0.5, 0.01));
    expect(PlantTouch.after(Offset.zero, 1).fold, 0);
  });

  test('the wobble settles, and every plant has a reaction', () {
    expect(PlantTouch.after(Offset.zero, PlantTouch.effectShare).sway, closeTo(0, 1e-9));
    expect(PlantTouch.effectOf('makahiya'), TouchEffect.fold);
    expect({for (final p in PlantCatalog.all) PlantTouch.effectOf(p.id)}.length, greaterThan(5));
  });

  testWidgets('tapping a plant on its page starts the reaction', (tester) async {
    PlantPart? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 393,
            child: PlantView(
              plant: PlantCatalog.byId('makahiya'),
              mode: PlantMode.detail,
              react: true,
              onPartTap: (p) => tapped = p,
            ),
          ),
        ),
      ),
    );
    PlantPainter painter() => tester.widget<CustomPaint>(find.byType(CustomPaint).last).painter! as PlantPainter;
    expect(painter().touch, isNull);
    await tester.tap(find.byType(PlantView));
    await tester.pump(); // the reaction's clock starts on this frame
    await tester.pump(const Duration(milliseconds: 600));
    expect(tapped, isNotNull);
    expect(painter().touch?.fold, 1);
    await tester.pump(PlantTouch.duration);
    expect(painter().touch, isNull, reason: 'open again and still');
  });
}
