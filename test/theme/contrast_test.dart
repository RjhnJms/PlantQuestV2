import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/theme/app_colors.dart';
import 'package:plantquest/widgets/chunky_button.dart';

void main() {
  group('WCAG AA contrast', () {
    for (final pair in AppColors.textPairs) {
      test(pair.name, () {
        expect(
          pair.ratio,
          greaterThanOrEqualTo(pair.required),
          reason: '${pair.name} is ${pair.ratio.toStringAsFixed(2)}:1, needs ${pair.required}:1',
        );
      });
    }

    for (final tone in ButtonTone.values) {
      test('button label on ${tone.name}', () {
        // Button labels are 20px bold = large text, but we hold them to the
        // stricter 4.5:1 except grape (white on grape is 3.66:1).
        final pair = ContrastPair(tone.name, tone.foreground, tone.face, largeText: tone == ButtonTone.grape);
        expect(pair.ratio, greaterThanOrEqualTo(pair.required));
      });
    }
  });
}
