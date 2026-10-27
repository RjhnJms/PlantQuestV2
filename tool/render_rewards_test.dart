// Draws the reward ideas as PNGs in docs/previews/rewards/ so they can be
// looked at outside the app. Not part of the normal test run.
//
// Run:  flutter test tool/render_rewards_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/theme/app_colors.dart';
import 'package:plantquest/theme/app_sizes.dart';
import 'package:plantquest/theme/app_text.dart';
import 'package:plantquest/theme/app_theme.dart';
import 'package:plantquest/widgets/chunky_button.dart';
import 'package:plantquest/widgets/rewards/reward_pieces.dart';

const _out = 'docs/previews/rewards';

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

Widget _captioned(Widget child, String caption) => Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    child,
    Text(
      caption,
      style: AppText.label.copyWith(color: AppColors.text),
      textAlign: TextAlign.center,
    ),
  ],
);

void main() {
  testWidgets('render reward ideas', (tester) async {
    await _loadFonts();
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final saba = PlantCatalog.byId('saba');
    await _render(
      tester,
      'a-sticker-book',
      'A · Sticker book',
      'Finish a plant quiz to earn its sticker. 15 to collect. Then a "You got a sticker!" moment pops up.',
      Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (final (i, p) in PlantCatalog.all.indexed)
                StickerBadge(plant: p, earned: i < 6, size: 88, tilt: [-0.06, 0.04, -0.02, 0.07][i % 4]),
            ],
          ),
          const SizedBox(height: AppSizes.gapL),
          Container(
            width: 300,
            padding: const EdgeInsets.all(AppSizes.gapXl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(color: AppColors.coral, width: 3),
            ),
            child: Column(
              children: [
                Text('You got a sticker!', style: AppText.title.copyWith(color: AppColors.coralDark)),
                const SizedBox(height: AppSizes.gapM),
                StickerBadge(plant: saba, size: 140, tilt: -0.05),
                const Text('It went into your sticker book.', style: AppText.body, textAlign: TextAlign.center),
                const SizedBox(height: AppSizes.gapL),
                ChunkyButton(label: 'YAY!', onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );

    const looks = [
      (BinhiOutfit.none, 'Plain'),
      (BinhiOutfit(salakot: true, pattern: PotPattern.banig), 'Salakot +\nbanig pot'),
      (BinhiOutfit(garland: true, pattern: PotPattern.dots), 'Garland +\ndots pot'),
      (BinhiOutfit(sunglasses: true, pattern: PotPattern.stripes), 'Sunglasses +\nstripes pot'),
    ];
    await _render(
      tester,
      'b-binhi-wardrobe',
      "B · Binhi's wardrobe",
      'Unlocked by milestones (finish a world, 5 perfect quizzes, visit 7 days), not bought with leaves.',
      Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (o, label) in looks)
                _captioned(Binhi(stage: BinhiStage.blooming, size: 150, outfit: o, reduceMotion: true), label),
            ],
          ),
          const SizedBox(height: AppSizes.gapM),
          _captioned(
            const Binhi(
              stage: BinhiStage.blooming,
              size: 200,
              outfit: BinhiOutfit(salakot: true, garland: true, sunglasses: true, pattern: PotPattern.banig),
              reduceMotion: true,
            ),
            'Everything on',
          ),
        ],
      ),
    );

    await _render(
      tester,
      'c-gold-cards',
      'C · Gold plant cards',
      'Get every question right and the plant card turns gold and shines.',
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captioned(GoldPlantCard(plant: PlantCatalog.byId('gumamela'), gold: false, reduceMotion: true), 'Normal'),
          _captioned(GoldPlantCard(plant: PlantCatalog.byId('mango'), reduceMotion: true), 'Gold (perfect)'),
        ],
      ),
    );

    await _render(
      tester,
      'd-garden',
      'D · Garden decorations',
      'Each world you finish gives new things to place around Binhi.',
      Column(
        children: [
          _captioned(const GardenPatch(items: {}, reduceMotion: true), 'Empty garden'),
          const SizedBox(height: AppSizes.gapM),
          _captioned(
            GardenPatch(
              items: GardenItem.values.toSet(),
              outfit: const BinhiOutfit(salakot: true, pattern: PotPattern.banig),
              reduceMotion: true,
            ),
            'Fence, pond, butterflies, parol, watering can, bench',
          ),
        ],
      ),
    );

    await _render(
      tester,
      'e-bonus-facts',
      'E · Bonus fun facts',
      "A perfect quiz opens one extra fact on that plant's page.",
      Column(
        children: [
          BonusFactCard(
            plant: PlantCatalog.byId('makahiya'),
            fact: 'Makahiya can fold its leaves in about one second, and opens them again after a few minutes.',
          ),
          const SizedBox(height: AppSizes.gapM),
          BonusFactCard(plant: PlantCatalog.byId('narra'), fact: '', unlocked: false),
        ],
      ),
    );

    await _render(
      tester,
      'f-certificate',
      'F · Plant Expert certificate',
      'Learn all 15 plants to get a certificate with your name. Show it to your teacher!',
      const PlantExpertCertificate(name: 'Juan', avatarId: 'boy_cap'),
    );
  });
}
