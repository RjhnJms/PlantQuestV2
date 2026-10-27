// Draws the app icon and splash images with the game's own painters and
// saves them as PNGs in assets/brand/. Not part of the normal test run.
//
// Run:  flutter test tool/render_brand_test.dart
// Then: dart run flutter_launcher_icons && dart run flutter_native_splash:create

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi_painter.dart';
import 'package:plantquest/art/binhi/binhi_stage.dart';
import 'package:plantquest/theme/app_colors.dart';

/// Sunny sky with soft rays and a green hill (icon background).
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()..shader = ui.Gradient.linear(r.topCenter, r.bottomCenter, [AppColors.sky, AppColors.skyLight]),
    );
    final c = Offset(size.width / 2, size.height * 0.42);
    final ray = Paint()..color = AppColors.card.withValues(alpha: 0.18);
    for (var i = 0; i < 16; i++) {
      final a = i * math.pi / 8;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - 0.09) * size.width, c.dy + math.sin(a - 0.09) * size.width)
        ..lineTo(c.dx + math.cos(a + 0.09) * size.width, c.dy + math.sin(a + 0.09) * size.width)
        ..close();
      canvas.drawPath(path, ray);
    }
    final hill = Path()
      ..moveTo(0, size.height * 0.76)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.62, size.width, size.height * 0.76)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, size.height * 0.64), Offset(0, size.height), [
          AppColors.leafLight,
          AppColors.leaf,
        ]),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => false;
}

/// Binhi centered, taking [scale] of the canvas height.
class _BinhiPicture extends CustomPainter {
  _BinhiPicture({required this.scale, this.dy = 0, this.stage = BinhiStage.sprout});

  final double scale;
  final double dy;
  final BinhiStage stage;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height * scale;
    final w = h * BinhiPainter.designSize.aspectRatio;
    canvas
      ..save()
      ..translate((size.width - w) / 2, (size.height - h) / 2 + dy * size.height);
    BinhiPainter(stage: stage, mood: BinhiMood.happy, pose: () => const BinhiPose()).paint(canvas, Size(w, h));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BinhiPicture old) => false;
}

Future<void> _render(WidgetTester tester, String path, List<CustomPainter> layers, {double side = 1024}) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              children: [for (final l in layers) Positioned.fill(child: CustomPaint(painter: l))],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(path)..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render brand images', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Full icon (older Android, iOS, web): background + big Binhi.
    await _render(tester, 'assets/brand/icon.png', [_BackgroundPainter(), _BinhiPicture(scale: 0.98, dy: -0.1)]);
    // Adaptive icon (Android 8+): the phone crops to a circle or squircle,
    // so Binhi stays inside the middle ~60 %.
    await _render(tester, 'assets/brand/icon_background.png', [_BackgroundPainter()]);
    await _render(tester, 'assets/brand/icon_foreground.png', [_BinhiPicture(scale: 0.74, dy: -0.075)]);
    // Splash: Binhi on transparent, shown on the cream background.
    await _render(tester, 'assets/brand/splash.png', [
      _BinhiPicture(scale: 0.86, stage: BinhiStage.blooming),
    ], side: 768);
    // Android 12+ splash icon: must fit inside a centered circle (2/3 of the side).
    await _render(tester, 'assets/brand/splash_android12.png', [
      _BinhiPicture(scale: 0.5, stage: BinhiStage.blooming),
    ], side: 960);
  });
}
