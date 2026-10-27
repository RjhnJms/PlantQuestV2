import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/round_buttons.dart';
import 'colouring_screen.dart';

/// Inside the bahay kubo (PLAN.md §5l): every hung picture in a frame on
/// the woven wall, newest first, and the explored plants still waiting to
/// be coloured. Tap a picture to colour it some more.
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pictures = ref.watch(colouringsProvider).value ?? const [];
    final hung = pictures.where((p) => p.hung).toList();
    final explored = ref.watch(exploredPlantsProvider).value ?? const <String>{};
    final waiting = PlantCatalog.all.where((p) => explored.contains(p.id) && !hung.any((h) => h.plantId == p.id));
    void colour(String id) => context.push('/plant/$id/colour?from=gallery');

    return Scaffold(
      backgroundColor: const Color(0xFFE9C98E),
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _WallPainter())),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapS),
                    child: Row(
                      children: [
                        SquareIconButton.back(context),
                        const SizedBox(width: AppSizes.gapM),
                        Expanded(child: _Sign(text: hung.isEmpty ? 'Our bahay kubo' : 'My pictures (${hung.length})')),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 40, AppSizes.gutter, 0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 44,
                      crossAxisSpacing: AppSizes.gapL,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildListDelegate([
                      for (final p in hung)
                        _Hung(
                          label: PlantCatalog.byId(p.plantId).name,
                          onTap: () => colour(p.plantId),
                          child: PictureFrame(plantId: p.plantId, png: p.png),
                        ),
                      for (var i = hung.length; i < 2; i++) const _EmptyFrame(),
                    ]),
                  ),
                ),
                if (waiting.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapXxl, AppSizes.gutter, AppSizes.gapS),
                      child: _Sign(text: 'Colour a plant'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapS, AppSizes.gutter, AppSizes.gapXl),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 120,
                        mainAxisSpacing: AppSizes.gapS,
                        crossAxisSpacing: AppSizes.gapS,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildListDelegate([
                        for (final p in waiting)
                          ChunkyCard(
                            padding: const EdgeInsets.all(AppSizes.gapS),
                            radius: AppSizes.radiusM,
                            semanticLabel: 'Colour ${p.name}',
                            onTap: () => colour(p.id),
                            child: Column(
                              children: [
                                Expanded(child: PlantView(plant: p)),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(p.name, style: AppText.label.copyWith(color: AppColors.text)),
                                ),
                              ],
                            ),
                          ),
                      ]),
                    ),
                  ),
                ] else
                  const SliverToBoxAdapter(child: SizedBox(height: AppSizes.gapXl)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A wooden sign with white writing.
class _Sign extends StatelessWidget {
  const _Sign({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.barkDark,
        borderRadius: BorderRadius.circular(10),
        border: const Border(bottom: BorderSide(color: Color(0xFF4A2E16), width: 4)),
      ),
      child: Text(text, style: AppText.heading.copyWith(color: Colors.white)),
    ),
  );
}

/// A hung picture: a string up to a nail, the frame and a name tag.
class _Hung extends StatelessWidget {
  const _Hung({required this.label, required this.onTap, required this.child});

  final String label;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label picture. Tap to colour it more.',
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                const Positioned(
                  top: -26,
                  child: CustomPaint(size: Size(36, 26), painter: _StringPainter()),
                ),
                Center(child: child),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gapS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFFFF6E0), borderRadius: BorderRadius.circular(6)),
            child: Text(label, style: AppText.label.copyWith(color: AppColors.barkDark)),
          ),
        ],
      ),
    ),
  );
}

class _EmptyFrame extends StatelessWidget {
  const _EmptyFrame();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSizes.gapS),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.bark.withValues(alpha: 0.6), width: 3),
      ),
      child: Text(
        'Colour a plant to hang here',
        textAlign: TextAlign.center,
        style: AppText.label.copyWith(color: AppColors.barkDark),
      ),
    ),
  );
}

class _StringPainter extends CustomPainter {
  const _StringPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFF6E4A24);
    canvas
      ..drawPath(
        Path()
          ..moveTo(2, size.height)
          ..lineTo(size.width / 2, 3)
          ..lineTo(size.width - 2, size.height),
        p,
      )
      ..drawCircle(Offset(size.width / 2, 3), 3, Paint()..color = AppColors.barkDark);
  }

  @override
  bool shouldRepaint(_StringPainter old) => false;
}

/// Woven sawali wall, a strip of nipa roof at the top and a bamboo floor.
class _WallPainter extends CustomPainter {
  const _WallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = const Color(0xFFE9C98E);
    final dark = Paint()..color = const Color(0xFFDDB877);
    canvas.drawRect(Offset.zero & size, light);
    const cell = 18.0;
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final odd = ((x / cell).round() + (y / cell).round()).isOdd;
        canvas.drawRect(
          odd ? Rect.fromLTWH(x + 2, y + 6, cell - 4, cell - 12) : Rect.fromLTWH(x + 6, y + 2, cell - 12, cell - 4),
          dark,
        );
      }
    }
    final roof = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 54)
      ..lineTo(0, 74)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFB9893F));
    final thatch = Paint()
      ..color = const Color(0xFFA47532)
      ..strokeWidth = 3;
    for (var x = 0.0; x < size.width + 20; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x - 6, 74 - x / size.width * 20), thatch);
    }
  }

  @override
  bool shouldRepaint(_WallPainter old) => false;
}
