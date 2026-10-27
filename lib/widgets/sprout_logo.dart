import 'package:flutter/material.dart';

import '../art/sticker.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// The two-leaf sprout mark, optionally with the "PlantQuest" word.
class SproutLogo extends StatelessWidget {
  const SproutLogo({super.key, this.size = 56, this.withName = false, this.nameSize = 44});

  final double size;
  final bool withName;
  final double nameSize;

  @override
  Widget build(BuildContext context) {
    final mark = CustomPaint(size: Size(size, size), painter: const _SproutPainter());
    if (!withName) return ExcludeSemantics(child: mark);
    return Semantics(
      label: 'PlantQuest',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          const SizedBox(width: 6),
          Text(
            'PlantQuest',
            style: AppText.display.copyWith(fontSize: nameSize, color: AppColors.leafDark),
          ),
        ],
      ),
    );
  }
}

class _SproutPainter extends CustomPainter {
  const _SproutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 60;
    canvas
      ..save()
      ..scale(s);
    final stem = Path()
      ..moveTo(30, 58)
      ..quadraticBezierTo(31, 40, 30, 28);
    canvas
      ..drawPath(stem, Sticker.stroke(AppColors.leafDark, 7))
      ..drawPath(stem, Sticker.stroke(AppColors.leaf, 4));
    Sticker.leaf(canvas, const Offset(30, 30), -1.05, 26, 12);
    Sticker.leaf(canvas, const Offset(30, 30), 1.0, 28, 13, color: AppColors.leafLight);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SproutPainter oldDelegate) => false;
}
