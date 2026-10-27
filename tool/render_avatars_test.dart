// Draws the avatar style ideas (lib/dev/avatar_preview.dart) as PNGs in
// docs/previews/avatars/. Not part of the normal test run.
//
// Run:  flutter test tool/render_avatars_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/avatars/avatar_view.dart';
import 'package:plantquest/dev/avatar_preview.dart';
import 'package:plantquest/theme/app_theme.dart';

const _out = 'docs/previews/avatars';

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
  testWidgets('avatar styles', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(800, 2200);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    for (final (name, look) in [
      ('0-now', AvatarLook.now),
      ('1-polished', AvatarLook.polished),
      ('2-outfits', AvatarLook.outfits),
      ('3-animals', null),
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
                child: AvatarSheet(look: look),
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
