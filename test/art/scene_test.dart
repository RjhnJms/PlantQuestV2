import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/scenes/world_scene.dart';
import 'package:plantquest/theme/app_theme.dart';

void main() {
  for (final size in [const Size(375, 200), const Size(375, 640), const Size(800, 400)]) {
    testWidgets('all worlds draw at $size', (tester) async {
      for (final world in [1, 2, 3]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Center(
              child: SizedBox.fromSize(
                size: size,
                child: WorldScene(world: world),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull, reason: 'world $world');
      }
    });
  }

  testWidgets('scenes inside a scrolling list scroll without errors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ListView(
          children: [
            for (final w in [1, 2, 3]) SizedBox(height: 600, child: WorldScene(world: w)),
          ],
        ),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('less motion stops the clock so the scene can settle', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const SizedBox(height: 400, child: WorldScene(world: 2, reduceMotion: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
