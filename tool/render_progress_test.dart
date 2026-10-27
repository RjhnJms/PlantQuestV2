// Draws the progress bar ideas (lib/dev/progress_preview.dart) for the
// Sunrise loading screen as PNGs in docs/previews/progress/. Not part of the normal test run.
//
// Run:  flutter test tool/render_progress_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/dev/progress_preview.dart';
import 'package:plantquest/theme/app_theme.dart';

const _out = 'docs/previews/progress';

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
  testWidgets('progress ideas', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(780, 640);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    for (final style in ProgressStyle.values) {
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: Scaffold(body: ProgressMock(style: style)),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_out/${style.name}.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
    await tester.pumpWidget(const SizedBox());
  });
}
