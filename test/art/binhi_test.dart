import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi.dart';
import 'package:plantquest/art/binhi/binhi_painter.dart';
import 'package:plantquest/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('BinhiStage rules (PLAN.md §3)', () {
    test('stage boundaries', () {
      expect(BinhiStage.forLeaves(0), BinhiStage.seed);
      expect(BinhiStage.forLeaves(9), BinhiStage.seed);
      expect(BinhiStage.forLeaves(10), BinhiStage.sprout);
      expect(BinhiStage.forLeaves(24), BinhiStage.sprout);
      expect(BinhiStage.forLeaves(25), BinhiStage.sapling);
      expect(BinhiStage.forLeaves(49), BinhiStage.sapling);
      expect(BinhiStage.forLeaves(50), BinhiStage.blooming);
      expect(BinhiStage.forLeaves(500), BinhiStage.blooming);
    });

    test('leaves to grow and progress', () {
      expect(BinhiStage.leavesToGrow(0), 10);
      expect(BinhiStage.leavesToGrow(9), 1);
      expect(BinhiStage.leavesToGrow(10), 15);
      expect(BinhiStage.leavesToGrow(60), 0);
      expect(BinhiStage.growthProgress(0), 0);
      expect(BinhiStage.growthProgress(5), 0.5);
      expect(BinhiStage.growthProgress(50), 1);
    });
  });

  test('hop pose starts and ends at rest', () {
    expect(BinhiPainter.hopPose(0), (0.0, 1.0, 1.0));
    expect(BinhiPainter.hopPose(1), (0.0, 1.0, 1.0));
    final (y, _, _) = BinhiPainter.hopPose(0.5);
    expect(y, lessThan(-20), reason: 'Binhi is up in the air mid-hop');
  });

  testWidgets('every stage and mood draws without errors', (tester) async {
    for (final stage in BinhiStage.values) {
      for (final mood in BinhiMood.values) {
        await tester.pumpWidget(_wrap(Binhi(stage: stage, mood: mood, reduceMotion: true)));
        expect(tester.takeException(), isNull, reason: '$stage $mood');
      }
    }
  });

  testWidgets('tapping Binhi calls onTap and the hop settles', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(Binhi(stage: BinhiStage.seed, reduceMotion: true, onTap: () => taps++)));
    await tester.tap(find.byType(Binhi));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('controller cheer hops without errors', (tester) async {
    final controller = BinhiController();
    await tester.pumpWidget(_wrap(Binhi(stage: BinhiStage.sprout, controller: controller, reduceMotion: true)));
    controller.cheer();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    controller.dispose();
  });
}
