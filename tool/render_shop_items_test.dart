// Every shop item on Binhi (PLAN.md §5m), at two growth stages, plus
// everything at once. Saves docs/previews/shop-items/all.png.
//
// Run:  flutter test tool/render_shop_items_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi.dart';
import 'package:plantquest/features/shop/shop_screen.dart';
import 'package:plantquest/game/rewards.dart';
import 'package:plantquest/theme/app_colors.dart';

const _root = ValueKey('root');

void main() {
  testWidgets('shop items', (tester) async {
    final fredoka = FontLoader('Fredoka')
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Fredoka-Medium.ttf').readAsBytesSync())));
    await fredoka.load();
    tester.view.physicalSize = const Size(1400, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget tile(Widget art, String label) => Container(
      width: 130,
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.all(4),
      color: AppColors.card,
      child: Column(
        children: [
          SizedBox(height: 110, child: Center(child: art)),
          Text(label, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12)),
        ],
      ),
    );
    await tester.pumpWidget(
      RepaintBoundary(
        key: _root,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: AppColors.background,
            body: Wrap(
              children: [
                for (final i in OutfitItem.values) tile(ItemArt(item: i, stage: BinhiStage.sprout, size: 100), i.label),
                for (final i in OutfitItem.values.where((i) => i.slot != OutfitSlot.pack && i.slot != OutfitSlot.spot))
                  tile(ItemArt(item: i, stage: BinhiStage.blooming, size: 100), '${i.label} (blooming)'),
                tile(
                  const Binhi(
                    stage: BinhiStage.sapling,
                    size: 100,
                    reduceMotion: true,
                    outfit: BinhiOutfit(
                      hat: BinhiHat.strawHat,
                      glasses: BinhiGlasses.round,
                      neck: BinhiNeck.bowTie,
                      friend: BinhiFriend.butterfly,
                      pattern: PotPattern.rainbow,
                    ),
                  ),
                  'All at once',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_root));
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('docs/previews/shop-items/all.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  });
}
