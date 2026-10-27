// Draws the icon style ideas (lib/dev/icon_preview.dart) as PNGs in
// docs/previews/icons/. Not part of the normal test run.
//
// Run:  flutter test tool/render_icons_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/icons/kid_icon.dart';
import 'package:plantquest/dev/icon_preview.dart';
import 'package:plantquest/theme/app_theme.dart';

const _out = 'docs/previews/icons';

Future<void> _loadFonts() async {
  final fredoka = FontLoader('Fredoka');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    fredoka.addFont(Future.value(ByteData.sublistView(File('assets/fonts/Fredoka-$w.ttf').readAsBytesSync())));
  }
  await fredoka.load();
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf').readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
}

void main() {
  testWidgets('icon styles', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(800, 3400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    for (final (name, style) in [
      ('0-now', null),
      ('1-sticker', KidIconStyle.sticker),
      ('2-glossy', KidIconStyle.glossy),
      ('3-flat', KidIconStyle.flat),
    ]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: RepaintBoundary(
                key: key,
                child: IconSheet(style: style),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_out/$name.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
  });
}
