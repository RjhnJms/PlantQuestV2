import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/icons/kid_icon.dart';
import 'package:plantquest/art/avatars/avatar_view.dart';
import 'package:plantquest/theme/app_theme.dart';
import 'package:plantquest/widgets/avatar_tile.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  test('6 boys and 6 girls with unique ids', () {
    expect(AvatarSpec.all, hasLength(12));
    expect(AvatarSpec.boys, hasLength(6));
    expect(AvatarSpec.girls, hasLength(6));
    expect(AvatarSpec.all.map((a) => a.id).toSet(), hasLength(12));
  });

  test('varied skin tones and hair styles', () {
    expect(AvatarSpec.all.map((a) => a.skin).toSet().length, greaterThanOrEqualTo(6));
    expect(AvatarSpec.boys.map((a) => a.skin).toSet().length, greaterThanOrEqualTo(5));
    expect(AvatarSpec.girls.map((a) => a.skin).toSet().length, greaterThanOrEqualTo(5));
    expect(AvatarSpec.all.map((a) => a.hairStyle).toSet(), hasLength(12));
  });

  test('unknown id falls back instead of crashing', () {
    expect(AvatarSpec.byId('nope'), AvatarSpec.all.first);
    expect(AvatarSpec.byId(null), AvatarSpec.all.first);
    expect(AvatarSpec.byId('girl_bob').id, 'girl_bob');
  });

  testWidgets('every avatar draws without errors', (tester) async {
    for (final spec in AvatarSpec.all) {
      await tester.pumpWidget(_wrap(AvatarView(avatarId: spec.id, size: 120)));
      expect(tester.takeException(), isNull, reason: spec.id);
    }
  });

  testWidgets('avatar tile reports selection and is big enough to tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        AvatarTile(
          avatarId: AvatarSpec.all.first.id,
          label: AvatarSpec.all.first.label,
          selected: true,
          onTap: () => taps++,
        ),
      ),
    );
    expect(tester.getSize(find.byType(AvatarTile)).height, greaterThanOrEqualTo(56));
    await tester.tap(find.byType(AvatarTile));
    expect(taps, 1);
    expect(find.byWidgetPredicate((w) => w is KidIconView && w.icon == KidIcon.tick), findsOneWidget);
  });
}
