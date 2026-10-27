// Draws the leaf shop idea as PNGs in docs/previews/shop/.
// Not part of the normal test run.
//
// Run:  flutter test tool/render_shop_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi.dart';
import 'package:plantquest/dev/shop_preview.dart';
import 'package:plantquest/game/rewards.dart';
import 'package:plantquest/theme/app_colors.dart';
import 'package:plantquest/theme/app_sizes.dart';
import 'package:plantquest/theme/app_text.dart';
import 'package:plantquest/theme/app_theme.dart';

const _out = 'docs/previews/shop';

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

Future<void> _render(WidgetTester tester, String name, String title, String how, Widget child) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Center(
            child: RepaintBoundary(
              key: key,
              child: Container(
                width: 400,
                color: AppColors.background,
                padding: const EdgeInsets.all(AppSizes.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: AppText.title),
                    const SizedBox(height: 4),
                    Text(how, style: AppText.bodySmall),
                    const SizedBox(height: AppSizes.gapL),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render leaf shop idea', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(900, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const outfit = BinhiOutfit(pattern: PotPattern.dots);
    await _render(
      tester,
      '1-shop',
      'The shop',
      'Example: Juan has earned 95 leaves in all and spent 50 (stripes + dots), so 45 are left to spend.',
      const ShopMockPage(wallet: 45, earned: 95, owned: {OutfitItem.stripes, OutfitItem.dots}, outfit: outfit),
    );
    await _render(
      tester,
      '2-buying',
      'Buying something',
      'Tap BUY, then one more tap to be sure. Binhi puts it on right away.',
      const Column(
        children: [
          BuySheetMock(item: OutfitItem.sunglasses, wallet: 45, stage: BinhiStage.blooming),
          SizedBox(height: AppSizes.gapXl),
          Icon(Icons.arrow_downward_rounded, size: 36, color: AppColors.textMuted),
          SizedBox(height: AppSizes.gapXl),
          ThanksMock(
            item: OutfitItem.sunglasses,
            stage: BinhiStage.blooming,
            outfit: BinhiOutfit(sunglasses: true, pattern: PotPattern.dots),
          ),
        ],
      ),
    );
    await _render(
      tester,
      '3-home',
      'On Home',
      "The leaf pill shows leaves to spend (5 after buying). Binhi's growth bar uses all leaves ever earned, so he never shrinks. A SHOP button opens the shop.",
      const HomeTopMock(wallet: 5, earned: 95, outfit: BinhiOutfit(sunglasses: true, pattern: PotPattern.dots)),
    );
  });
}
