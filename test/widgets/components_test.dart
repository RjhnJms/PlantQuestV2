import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/theme/app_sizes.dart';
import 'package:plantquest/theme/app_theme.dart';
import 'package:plantquest/widgets/app_progress_bar.dart';
import 'package:plantquest/widgets/chunky_button.dart';
import 'package:plantquest/widgets/chunky_card.dart';
import 'package:plantquest/widgets/stat_pill.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(
    body: Center(
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  ),
);

void main() {
  group('ChunkyButton', () {
    testWidgets('calls onPressed once per tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(ChunkyButton(label: 'CHECK', onPressed: () => taps++)));
      await tester.tap(find.text('CHECK'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('disabled button ignores taps and says so to screen readers', (tester) async {
      await tester.pumpWidget(_wrap(const ChunkyButton(label: 'CHECK', onPressed: null)));
      await tester.tap(find.text('CHECK'), warnIfMissed: false);
      expect(
        tester.getSemantics(find.byType(ChunkyButton)),
        matchesSemantics(label: 'CHECK', isButton: true, hasEnabledState: true, isEnabled: false),
      );
    });

    testWidgets('screen readers hear the label once and can press it', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(ChunkyButton(label: 'CHECK', onPressed: () => taps++)));
      expect(
        tester.getSemantics(find.byType(ChunkyButton)),
        matchesSemantics(label: 'CHECK', isButton: true, hasEnabledState: true, isEnabled: true, hasTapAction: true),
      );
      tester.semantics.tap(find.semantics.byLabel('CHECK'));
      expect(taps, 1);
    });

    testWidgets('is at least the minimum tap size, even when small', (tester) async {
      for (final small in [false, true]) {
        await tester.pumpWidget(_wrap(ChunkyButton(label: 'GO', small: small, expand: false, onPressed: () {})));
        final size = tester.getSize(find.byType(ChunkyButton));
        expect(size.height, greaterThanOrEqualTo(AppSizes.minTap), reason: 'small=$small');
        expect(size.width, greaterThanOrEqualTo(AppSizes.minTap), reason: 'small=$small');
      }
    });

    testWidgets('pressing does not change the total height', (tester) async {
      await tester.pumpWidget(_wrap(ChunkyButton(label: 'GO', onPressed: () {})));
      final before = tester.getSize(find.byType(ChunkyButton));
      final gesture = await tester.startGesture(tester.getCenter(find.text('GO')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(ChunkyButton)), before);
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  testWidgets('tappable ChunkyCard is at least the minimum tap size', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(ChunkyCard(onTap: () => tapped = true, child: const Text('Hi'))));
    expect(tester.getSize(find.byType(ChunkyCard)).height, greaterThanOrEqualTo(AppSizes.minTap));
    await tester.tap(find.text('Hi'));
    expect(tapped, isTrue);
  });

  testWidgets('progress bar clamps out-of-range values', (tester) async {
    for (final v in [-1.0, 0.5, 2.0, double.nan]) {
      await tester.pumpWidget(_wrap(AppProgressBar(value: v, semanticLabel: 'bar')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'value=$v');
    }
  });

  testWidgets('stat pill ticks up to the new value', (tester) async {
    await tester.pumpWidget(_wrap(const StatPill.leaves(value: 3)));
    expect(find.text('3'), findsOneWidget);
    await tester.pumpWidget(_wrap(const StatPill.leaves(value: 9)));
    await tester.pumpAndSettle();
    expect(find.text('9'), findsOneWidget);
  });
}
