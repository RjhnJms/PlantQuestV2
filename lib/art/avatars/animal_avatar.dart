import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../sticker.dart';

/// Philippine animals as avatars (Oct 2026 preview, option C). Drawn in the
/// same 100 × 100 circle and sticker style as the kids.
enum AnimalAvatar {
  tarsier('Tarsier', AppColors.leafTint),
  carabao('Carabao', AppColors.skyTint),
  eagle('Philippine eagle', AppColors.sunshineTint),
  pawikan('Pawikan', AppColors.tealTint),
  butanding('Butanding', AppColors.skyLight),
  pilandok('Pilandok', AppColors.coralTint);

  const AnimalAvatar(this.label, this.background);
  final String label;
  final Color background;
}

class AnimalAvatarView extends StatelessWidget {
  const AnimalAvatarView(this.animal, {super.key, this.size = 64});

  final AnimalAvatar animal;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: animal.label,
    image: true,
    child: CustomPaint(size: Size.square(size), painter: AnimalAvatarPainter(animal)),
  );
}

class AnimalAvatarPainter extends CustomPainter {
  AnimalAvatarPainter(this.animal);

  final AnimalAvatar animal;

  static const _w = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 100;
    canvas
      ..save()
      ..translate((size.width - 100 * s) / 2, (size.height - 100 * s) / 2)
      ..scale(s);
    final circle = Rect.fromCircle(center: const Offset(50, 50), radius: 50);
    canvas
      ..drawOval(circle, Sticker.fill(circle, animal.background, lift: 0.35))
      ..save()
      ..clipPath(Path()..addOval(circle));
    switch (animal) {
      case AnimalAvatar.tarsier:
        _tarsier(canvas);
      case AnimalAvatar.carabao:
        _carabao(canvas);
      case AnimalAvatar.eagle:
        _eagle(canvas);
      case AnimalAvatar.pawikan:
        _pawikan(canvas);
      case AnimalAvatar.butanding:
        _butanding(canvas);
      case AnimalAvatar.pilandok:
        _pilandok(canvas);
    }
    canvas.restore();
    canvas
      ..drawCircle(const Offset(50, 50), 48.2, Sticker.stroke(const Color(0xFFFFFFFF), 3.6))
      ..drawCircle(const Offset(50, 50), 49.6, Sticker.stroke(Sticker.darken(animal.background, 0.18), 1.2))
      ..restore();
  }

  void _shape(Canvas c, Path p, Color color) => Sticker.shape(c, p, color, Sticker.darken(color, 0.35), width: _w);

  Path _oval(double x, double y, double w, double h) =>
      Path()..addOval(Rect.fromCenter(center: Offset(x, y), width: w, height: h));

  /// A shiny eye: [r] big, with a dark pupil and two sparkles.
  void _eye(Canvas c, Offset at, double r, {Color iris = AppColors.text}) {
    c.drawCircle(at, r, Sticker.solid(iris));
    if (iris != AppColors.text) c.drawCircle(at, r * 0.55, Sticker.solid(AppColors.text));
    c
      ..drawCircle(at.translate(r * 0.3, -r * 0.35), r * 0.3, Sticker.solid(const Color(0xFFFFFFFF)))
      ..drawCircle(at.translate(-r * 0.35, r * 0.4), r * 0.14, Sticker.solid(const Color(0xFFFFFFFF)));
  }

  void _smile(Canvas c, Offset at, double w) => c.drawPath(
    Path()
      ..moveTo(at.dx - w / 2, at.dy)
      ..quadraticBezierTo(at.dx, at.dy + w * 0.5, at.dx + w / 2, at.dy),
    Sticker.stroke(AppColors.text, 1.8),
  );

  void _blush(Canvas c, List<Offset> at) {
    for (final o in at) {
      c.drawOval(
        Rect.fromCenter(center: o, width: 7, height: 4),
        Sticker.solid(AppColors.bubblegum.withValues(alpha: 0.5)),
      );
    }
  }

  // The tarsier: huge eyes and big round ears.
  void _tarsier(Canvas c) {
    const fur = Color(0xFFB8875A);
    _shape(c, _oval(50, 100, 60, 40), fur);
    for (final x in [24.0, 76.0]) {
      _shape(c, _oval(x, 30, 22, 26), fur);
      c.drawOval(Rect.fromCenter(center: Offset(x, 31), width: 12, height: 15), Sticker.solid(const Color(0xFFE7B9A4)));
    }
    _shape(c, _oval(50, 54, 52, 48), fur);
    _shape(c, _oval(50, 63, 30, 20), const Color(0xFFE2C29B));
    for (final x in [38.5, 61.5]) {
      c.drawCircle(Offset(x, 50), 11, Sticker.solid(const Color(0xFFFFFFFF)));
      _eye(c, Offset(x, 50), 9.5, iris: AppColors.mangoOrange);
    }
    c.drawOval(Rect.fromCenter(center: const Offset(50, 61), width: 4, height: 2.6), Sticker.solid(AppColors.text));
    _smile(c, const Offset(50, 66), 7);
  }

  // The carabao: grey, with big curved horns and a wide nose.
  void _carabao(Canvas c) {
    const hide = Color(0xFF8C8C9C);
    _shape(c, _oval(50, 100, 66, 40), hide);
    for (final side in [-1.0, 1.0]) {
      final horn = Path()
        ..moveTo(50 + side * 12, 34)
        ..quadraticBezierTo(50 + side * 40, 34, 50 + side * 42, 14)
        ..quadraticBezierTo(50 + side * 34, 26, 50 + side * 14, 26)
        ..close();
      _shape(c, horn, const Color(0xFF6E6A78));
      _shape(c, _oval(50 + side * 26, 44, 14, 9), hide);
    }
    _shape(c, _oval(50, 52, 42, 44), hide);
    _shape(c, _oval(50, 66, 30, 18), const Color(0xFFB9A9AE));
    for (final x in [44.0, 56.0]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(x, 66), width: 4.4, height: 3.2),
        Sticker.solid(const Color(0xFF5D4C55)),
      );
    }
    for (final x in [41.0, 59.0]) {
      _eye(c, Offset(x, 48), 3.6);
    }
    _blush(c, const [Offset(36, 56), Offset(64, 56)]);
  }

  // The Philippine eagle: a shaggy crest and a big blue-grey beak.
  void _eagle(Canvas c) {
    const feathers = Color(0xFFF2E3C2);
    const brown = Color(0xFFA06A3A);
    _shape(c, _oval(50, 102, 70, 44), brown);
    final crest = Path()..moveTo(26, 46);
    for (var i = 0; i <= 8; i++) {
      final a = math.pi + i * math.pi / 8;
      final r = i.isEven ? 34.0 : 24.0;
      crest.lineTo(50 + r * math.cos(a), 44 + r * math.sin(a));
    }
    crest.close();
    _shape(c, crest, brown);
    _shape(c, _oval(50, 52, 44, 46), feathers);
    // A strong hooked beak, the eagle's best feature.
    final beak = Path()
      ..moveTo(42, 55)
      ..quadraticBezierTo(50, 48, 58, 55)
      ..quadraticBezierTo(58, 66, 51, 72)
      ..quadraticBezierTo(49, 66, 45, 64)
      ..quadraticBezierTo(41, 61, 42, 55)
      ..close();
    _shape(c, beak, const Color(0xFF9DB4C8));
    for (final x in [39.0, 61.0]) {
      _eye(c, Offset(x, 47), 4.2, iris: AppColors.skyDark);
    }
  }

  // The pawikan (sea turtle): a round green head over its shell.
  void _pawikan(Canvas c) {
    const skin = Color(0xFF7FBF6A);
    final shell = _oval(50, 98, 78, 46);
    _shape(c, shell, const Color(0xFF8A6A3E));
    for (final o in [const Offset(36, 90), const Offset(50, 86), const Offset(64, 90)]) {
      c.drawPath(
        Path()..addPolygon([
          for (var i = 0; i < 6; i++) o + Offset(7 * math.cos(i * math.pi / 3), 7 * math.sin(i * math.pi / 3)),
        ], true),
        Sticker.stroke(const Color(0xFFD9B26A), 1.6),
      );
    }
    for (final side in [-1.0, 1.0]) {
      _shape(c, _oval(50 + side * 32, 82, 22, 12), skin);
    }
    _shape(c, _oval(50, 54, 44, 42), skin);
    for (final o in [const Offset(40, 40), const Offset(58, 38), const Offset(50, 34)]) {
      c.drawCircle(o, 2.4, Sticker.solid(Sticker.darken(skin, 0.18)));
    }
    for (final x in [40.0, 60.0]) {
      _eye(c, Offset(x, 52), 4);
    }
    _smile(c, const Offset(50, 62), 10);
    _blush(c, const [Offset(35, 59), Offset(65, 59)]);
  }

  // The butanding (whale shark): wide, blue, covered in white spots.
  void _butanding(Canvas c) {
    const blue = Color(0xFF4F7BA8);
    final body = Path()
      ..moveTo(10, 62)
      ..quadraticBezierTo(14, 30, 50, 28)
      ..quadraticBezierTo(86, 30, 90, 62)
      ..quadraticBezierTo(86, 90, 50, 92)
      ..quadraticBezierTo(14, 90, 10, 62)
      ..close();
    _shape(c, body, blue);
    c
      ..save()
      ..clipPath(body);
    c.drawOval(
      Rect.fromCenter(center: const Offset(50, 86), width: 76, height: 30),
      Sticker.solid(const Color(0xFFE6EEF5)),
    );
    final spot = Sticker.solid(const Color(0xFFE6EEF5));
    for (final o in const [
      Offset(30, 40),
      Offset(42, 35),
      Offset(58, 35),
      Offset(70, 40),
      Offset(22, 54),
      Offset(78, 54),
      Offset(50, 40),
    ]) {
      c.drawCircle(o, 2.4, spot);
    }
    c.restore();
    for (final x in [30.0, 70.0]) {
      _eye(c, Offset(x, 56), 3.6);
    }
    c.drawPath(
      Path()
        ..moveTo(32, 68)
        ..quadraticBezierTo(50, 76, 68, 68),
      Sticker.stroke(const Color(0xFF2E4A66), 2.4),
    );
  }

  // The pilandok (mouse deer): big ears and a soft brown face.
  void _pilandok(Canvas c) {
    const fur = Color(0xFFC08A55);
    _shape(c, _oval(50, 102, 56, 40), fur);
    for (final side in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(50 + side * 10, 36)
        ..quadraticBezierTo(50 + side * 34, 10, 50 + side * 30, 36)
        ..quadraticBezierTo(50 + side * 24, 44, 50 + side * 10, 40)
        ..close();
      _shape(c, ear, fur);
    }
    final head = Path()
      ..moveTo(32, 46)
      ..quadraticBezierTo(32, 28, 50, 28)
      ..quadraticBezierTo(68, 28, 68, 46)
      ..quadraticBezierTo(66, 68, 50, 76)
      ..quadraticBezierTo(34, 68, 32, 46)
      ..close();
    _shape(c, head, fur);
    c.drawOval(
      Rect.fromCenter(center: const Offset(50, 66), width: 16, height: 14),
      Sticker.solid(const Color(0xFFF1DDBE)),
    );
    c.drawOval(Rect.fromCenter(center: const Offset(50, 70), width: 6, height: 4), Sticker.solid(AppColors.text));
    for (final x in [42.0, 58.0]) {
      _eye(c, Offset(x, 49), 4.4);
    }
    _blush(c, const [Offset(37, 58), Offset(63, 58)]);
  }

  @override
  bool shouldRepaint(AnimalAvatarPainter old) => old.animal != animal;
}

/// Avatar ids for animal friends, stored like the kids' ids.
abstract final class AnimalIds {
  static String of(AnimalAvatar a) => 'animal_${a.name}';

  static AnimalAvatar? parse(String? id) =>
      id != null && id.startsWith('animal_') ? AnimalAvatar.values.asNameMap()[id.substring(7)] : null;
}
