import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/avatars/animal_avatar.dart';
import '../../art/avatars/avatar_view.dart';
import '../../art/binhi/binhi.dart';
import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../game/badges.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/badge_medal.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/rewards/reward_pieces.dart';
import '../colouring/colouring_screen.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 13 as a plant explorer's passport (PLAN.md D27, owner picked A
/// from docs/previews/profile/): an ID page with your photo, name, grade
/// and start date, then "stamp" boxes for badges, the sticker book, My
/// Garden, your pictures and Binhi, and two ink stamps for your numbers.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider).value;
    final stickers = ref.watch(stickersProvider);
    final days = ref.watch(daysVisitedProvider).value;
    final explored = ref.watch(exploredPlantsProvider).value ?? const <String>{};
    final best = ref.watch(bestLevelScoreProvider).value;
    final earned = ref.watch(leavesEarnedProvider).value ?? 0;
    final pictures = (ref.watch(colouringsProvider).value ?? const []).where((c) => c.hung).toList();
    final stage = BinhiStage.forLeaves(earned);
    final toGrow = BinhiStage.leavesToGrow(earned);
    final joined = p == null ? '–' : '${_months[p.joinedAt.month - 1]} ${p.joinedAt.year}';
    final growing = PlantCatalog.all.where((x) => explored.contains(x.id)).toList();
    final latestSticker = PlantCatalog.all.where((x) => stickers.contains(x.id)).lastOrNull;

    return Scaffold(
      backgroundColor: _Passport.page,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            Row(
              children: [
                const Expanded(child: Text('My passport', style: AppText.display)),
                SquareIconButton(
                  icon: KidIcon.settings,
                  semanticLabel: 'Settings',
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.gapL),
            _IdPage(name: p?.name ?? 'Explorer', grade: p?.grade, joined: joined, avatarId: p?.avatarId),
            const SizedBox(height: AppSizes.gapXl),
            const Text('Stamps', style: AppText.title),
            const SizedBox(height: AppSizes.gapS),
            const _BadgeStamps(),
            const SizedBox(height: AppSizes.gapM),
            _Pair(
              left: _StampBox(
                title: 'STICKER BOOK',
                titleColor: AppColors.coralDark,
                value: '${stickers.length} of 15',
                semanticLabel: 'Sticker book. ${stickers.length} of 15 stickers. Open.',
                onTap: () => context.push('/profile/stickers'),
                art: latestSticker == null
                    ? null
                    : StickerBadge(plant: latestSticker, size: 40, tilt: -0.12, showName: false),
              ),
              right: _StampBox(
                title: 'MY GARDEN',
                titleColor: AppColors.leafDark,
                value: '${growing.length} growing',
                semanticLabel: 'My Garden. ${growing.length} of 15 plants growing. Open.',
                onTap: () => context.push('/profile/garden'),
                art: growing.isEmpty ? null : SizedBox(width: 40, height: 48, child: PlantView(plant: growing.last)),
              ),
            ),
            const SizedBox(height: AppSizes.gapM),
            _Pair(
              left: _StampBox(
                title: 'MY PICTURES',
                titleColor: AppColors.barkDark,
                value: '${pictures.length} hung',
                semanticLabel: 'My pictures. ${pictures.length} on the bahay kubo wall. Open.',
                onTap: () => context.push('/garden/gallery'),
                art: pictures.isEmpty
                    ? null
                    : SizedBox(
                        width: 34,
                        child: PictureFrame(plantId: pictures.first.plantId, png: pictures.first.png, border: 3),
                      ),
              ),
              right: _StampBox(
                title: 'YOUR BINHI',
                titleColor: AppColors.leafDark,
                value: toGrow == 0 ? 'Fully grown!' : '$toGrow to grow',
                semanticLabel: 'Your Binhi. Binhi is ${stage.label}. Open the shop.',
                onTap: () {
                  markShopSeen(ref);
                  context.go('/shop');
                },
                art: Binhi(stage: stage, size: 44, outfit: ref.watch(binhiOutfitProvider), reduceMotion: true),
              ),
            ),
            const SizedBox(height: AppSizes.gapL),
            Row(
              children: [
                Expanded(
                  child: _InkStamp(
                    label: 'DAYS EXPLORING',
                    value: '${days ?? '–'}',
                    semantic: 'Days exploring',
                    tilt: -0.08,
                  ),
                ),
                const SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: _InkStamp(
                    label: 'BEST SCORE',
                    value: best == null ? '–' : '${best.$1}/${best.$2}',
                    semantic: 'Best score',
                    tilt: 0.07,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Passport colours.
abstract final class _Passport {
  static const page = Color(0xFFE9F2E4);
  static const cover = Color(0xFF2E6B4A);
  static const coverEdge = Color(0xFF1F4A33);
  static const gold = Color(0xFFF2D27A);
  static const paper = Color(0xFFFFFBF0);
  static const guilloche = Color(0xFFF4EAD2);
  static const dash = Color(0xFFC9BFA8);
  static const ink = Color(0xFF3B7DDD);
}

/// The ID page inside the green cover: photo, name, grade, start date and
/// a signature.
class _IdPage extends StatelessWidget {
  const _IdPage({required this.name, required this.grade, required this.joined, required this.avatarId});

  final String name;
  final int? grade;
  final String joined;
  final String? avatarId;

  @override
  Widget build(BuildContext context) {
    final label = AppText.label.copyWith(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1);
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: _Passport.cover,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        boxShadow: const [BoxShadow(color: _Passport.coverEdge, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(
              'REPUBLIKA NG HALAMAN · PLANT EXPLORER',
              style: AppText.label.copyWith(color: _Passport.gold, letterSpacing: 1.6),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: const _GuillochePainter(),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.gapM),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Change your look',
                          child: GestureDetector(
                            onTap: () => context.push('/profile/edit'),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderDeep, width: 3),
                              ),
                              child: AvatarView(avatarId: avatarId, size: 80),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.gapM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NAME', style: label),
                              Text(name, style: AppText.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: AppSizes.gapL,
                                runSpacing: 4,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('GRADE', style: label),
                                      Text('${grade ?? '–'}', style: AppText.heading),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('SINCE', style: label),
                                      Text(joined, style: AppText.heading),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.gapM),
                    Row(
                      children: [
                        // The holder's signature, in blue ink.
                        Expanded(
                          flex: 2,
                          child: ExcludeSemantics(
                            child: Transform.rotate(
                              angle: -0.06,
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  text: name,
                                  style: const TextStyle(
                                    fontFamily: AppText.family,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    color: _Passport.ink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: ChunkyButton(
                              label: 'EDIT PROFILE',
                              icon: KidIcon.edit,
                              small: true,
                              expand: false,
                              tone: ButtonTone.white,
                              onPressed: () => context.push('/profile/edit'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cream security paper with fine diagonal lines.
class _GuillochePainter extends CustomPainter {
  const _GuillochePainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _Passport.paper);
    final line = Paint()
      ..color = _Passport.guilloche
      ..strokeWidth = 2;
    for (var x = -size.height; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), line);
    }
  }

  @override
  bool shouldRepaint(_GuillochePainter old) => false;
}

/// Two stamp boxes side by side, the same height.
class _Pair extends StatelessWidget {
  const _Pair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const SizedBox(width: AppSizes.gapM),
        Expanded(child: right),
      ],
    ),
  );
}

/// A passport page box with a dashed edge.
class _Dashed extends StatelessWidget {
  const _Dashed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _DashedPainter(),
    child: Padding(padding: const EdgeInsets.all(AppSizes.gapM), child: child),
  );
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius((Offset.zero & size).deflate(1), const Radius.circular(AppSizes.radiusM));
    canvas.drawRRect(r, Paint()..color = _Passport.paper);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _Passport.dash;
    for (final ui.PathMetric m in (Path()..addRRect(r)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 12) {
        canvas.drawPath(m.extractPath(d, d + 7), edge);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => false;
}

/// One stamp box: a label, a value and a little picture stamped in the
/// corner.
class _StampBox extends StatelessWidget {
  const _StampBox({
    required this.title,
    required this.titleColor,
    required this.value,
    required this.semanticLabel,
    required this.onTap,
    this.art,
  });

  final String title;
  final Color titleColor;
  final String value;
  final String semanticLabel;
  final VoidCallback onTap;
  final Widget? art;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      child: _Dashed(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.label.copyWith(color: titleColor)),
            Text(value, style: AppText.heading),
            const SizedBox(height: AppSizes.gapS),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                height: 50,
                child: art == null
                    ? const KidIconView(KidIcon.next, size: AppSizes.iconSmall, muted: true)
                    : Transform.rotate(angle: -0.1, child: art),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Badges and animal friends, as the first stamp page.
class _BadgeStamps extends ConsumerWidget {
  const _BadgeStamps();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimed = ref.watch(badgesProvider).value ?? const <Achievement>{};
    final animals = ref.watch(animalsUnlockedProvider);
    final shown = Achievement.values.where(claimed.contains).toList().reversed.take(5).toList();
    return Semantics(
      button: true,
      label: 'Badges. ${claimed.length} of ${Achievement.values.length}. Open.',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => context.push('/profile/badges'),
        child: _Dashed(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('BADGES', style: AppText.label.copyWith(color: const Color(0xFF8A5A00))),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.sunshineTint,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                    child: Text(
                      '${claimed.length} of ${Achievement.values.length}',
                      style: AppText.label.copyWith(color: const Color(0xFF8A5A00)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.gapS),
              if (shown.isEmpty)
                const Text('Finish your first plant to get a badge!', style: AppText.bodySmall)
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (i, b) in shown.indexed)
                      Transform.rotate(
                        angle: i.isEven ? -0.08 : 0.07,
                        child: BadgeMedal(icon: b.icon, color: b.color, size: 50),
                      ),
                  ],
                ),
              const SizedBox(height: AppSizes.gapS),
              Row(
                children: [
                  for (final a in animals.take(3)) ...[AnimalAvatarView(a, size: 28), const SizedBox(width: 4)],
                  if (animals.isEmpty) const KidIconView(KidIcon.lock, size: AppSizes.iconSmall, muted: true),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Animal friends: ${animals.length} of ${AnimalAvatar.values.length} unlocked',
                      style: AppText.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An oval ink stamp with a number, slightly crooked.
class _InkStamp extends StatelessWidget {
  const _InkStamp({required this.label, required this.value, required this.semantic, required this.tilt});

  final String label;
  final String value;
  final String semantic;
  final double tilt;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$semantic: $value',
    excludeSemantics: true,
    child: Transform.rotate(
      angle: tilt,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.gapM, horizontal: AppSizes.gapS),
        decoration: ShapeDecoration(
          color: _Passport.ink.withValues(alpha: 0.06),
          shape: const StadiumBorder(side: BorderSide(color: _Passport.ink, width: 3)),
        ),
        child: Column(
          children: [
            FittedBox(
              child: Text(label, style: AppText.label.copyWith(color: _Passport.ink, letterSpacing: 1)),
            ),
            Text(value, style: AppText.title.copyWith(color: _Passport.ink)),
          ],
        ),
      ),
    ),
  );
}
