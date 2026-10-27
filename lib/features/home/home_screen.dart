import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/avatars/avatar_view.dart';
import '../../art/binhi/binhi.dart';
import '../../art/binhi/binhi_spot.dart';
import '../../art/scenes/world_scene.dart';
import '../../content/plant_catalog.dart';
import '../../content/plant_content.dart';
import '../../art/watering_can.dart';
import '../../game/daily.dart';
import '../../game/rules.dart';
import '../../services/read_aloud.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../theme/world_themes.dart';
import '../../widgets/effects/reward_moment.dart';
import '../../widgets/kid_sheet.dart';
import '../../widgets/pressable_3d.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/stat_pill.dart';
import '../garden/garden_screen.dart';
import 'daily_gift.dart';
import 'path_stop.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 5 (docs/screens/05-home.jpg), tidied in the Oct 2026 layout pass
/// (PLAN.md D13): the adventure path fills the screen; the greeting and
/// counters float in a slim bar on top, and Binhi waits bottom-left in a
/// ring that shows how much he has grown. It opens at the current plant.
///
/// A switch under the bar flips Home between the Adventure path and My
/// Garden (PLAN.md D22). The choice is kept while the app is open.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// One storybook page per world (PLAN.md D23); it opens on the world
  /// with the current plant.
  final _pages = PageController();
  int _page = 0;
  bool _opened = false;
  bool _garden = false;

  /// Room above the first world for the floating bar and the switch.
  static const _barRoom = 86.0 + _HomeSwitch.height + AppSizes.gapS;

  /// Room under the pages for the page dots and Binhi's corner.
  static const _binhiRoom = 150.0;
  static const _dotsRoom = 34.0;

  @override
  void initState() {
    super.initState();
    // Visiting on a 7th day can earn Explorer Week; this also catches any
    // badge earned while a popup couldn't show.
    // Binhi's daily gift first, then any badge.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await offerDailyGift(context, ref);
      if (mounted) celebrateBadges(context, ref);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Once, after the path first loads: open the current plant's world.
  void _openCurrentWorld(PathState path) {
    if (_opened) return;
    _opened = true;
    final current = path.currentId;
    final world = current == null ? WorldInfo.all.length : PlantCatalog.byId(current).world;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pages.hasClients) return;
      _pages.jumpToPage(world - 1);
    });
  }

  void _goToPage(int page) {
    PressFeedback.onPress?.call();
    final still = ref.read(lessMotionProvider) || MediaQuery.disableAnimationsOf(context);
    still
        ? _pages.jumpToPage(page)
        : _pages.animateToPage(page, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final pathAsync = ref.watch(pathProvider);
    final path = pathAsync.value ?? PathState.from({});
    if (pathAsync.hasValue) _openCurrentWorld(path);
    final still = ref.watch(lessMotionProvider);
    final top = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showKidConfirm(
          context,
          title: 'Leave PlantQuest?',
          message: 'Your leaves and plants are saved.',
          keepLabel: 'STAY',
          doLabel: 'Leave',
          mood: BinhiMood.encouraging,
        );
        if (leave) await SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // The garden keeps its place (and weather) while the path shows.
            Positioned.fill(
              top: top + _barRoom,
              child: Offstage(
                offstage: !_garden,
                child: TickerMode(
                  enabled: _garden,
                  child: GardenScreen(embedded: true, visible: _garden),
                ),
              ),
            ),
            // The worlds as storybook pages: swipe for the next one.
            Positioned.fill(
              top: top + _barRoom,
              bottom: _binhiRoom,
              child: Offstage(
                offstage: _garden,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pages,
                        onPageChanged: (p) {
                          ref.read(readAloudProvider).stop();
                          setState(() => _page = p);
                        },
                        children: [
                          for (final world in WorldInfo.all) _WorldPage(world: world, path: path, reduceMotion: still),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: _dotsRoom,
                      child: _PageDots(page: _page, onTap: _goToPage),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(left: AppSizes.gutter, right: AppSizes.gutter, top: top + AppSizes.gapM, child: const _TopBar()),
            Positioned(
              left: AppSizes.gutter,
              right: AppSizes.gutter,
              top: top + 86 - AppSizes.gapS,
              child: _HomeSwitch(
                garden: _garden,
                onChanged: (garden) {
                  if (garden == _garden) return;
                  PressFeedback.onPress?.call();
                  ref.read(readAloudProvider).stop();
                  setState(() => _garden = garden);
                },
              ),
            ),
            if (!_garden)
              Positioned(
                left: AppSizes.gutter,
                right: AppSizes.gutter,
                bottom: AppSizes.gapL,
                child: _BinhiCorner(path: path),
              ),
          ],
        ),
      ),
    );
  }
}

/// Adventure | My Garden: which one Home shows.
class _HomeSwitch extends StatelessWidget {
  const _HomeSwitch({required this.garden, required this.onChanged});

  static const height = 52.0;

  final bool garden;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFEFE6D2).withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      boxShadow: const [BoxShadow(color: Color(0x1A263046), blurRadius: 6, offset: Offset(0, 2))],
    ),
    child: Stack(
      children: [
        AnimatedAlign(
          alignment: garden ? Alignment.centerRight : Alignment.centerLeft,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 2))],
              ),
            ),
          ),
        ),
        Row(
          children: [
            for (final (label, icon, isGarden) in [
              ('Adventure', KidIcon.home, false),
              ('My Garden', KidIcon.plants, true),
            ])
              Expanded(
                child: Semantics(
                  button: true,
                  selected: garden == isGarden,
                  label: label,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(isGarden),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KidIconView(icon, size: AppSizes.iconSmall, muted: garden != isGarden),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            style: AppText.label.copyWith(
                              fontSize: 16,
                              color: garden == isGarden ? AppColors.leafDark : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

/// Avatar, "Hi, name!", days and leaves, in one slim floating bar.
class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: const [BoxShadow(color: Color(0x22263046), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          AvatarView(avatarId: profile?.avatarId, size: 44),
          const SizedBox(width: AppSizes.gapS),
          Expanded(
            child: Text(
              'Hi, ${profile?.name ?? 'Explorer'}!',
              style: AppText.heading,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          StatPill.days(value: ref.watch(daysVisitedProvider).value),
          const SizedBox(width: 6),
          LeafTarget(child: StatPill.leaves(value: ref.watch(leavesProvider).value)),
        ],
      ),
    );
  }
}

/// Binhi in a growth ring, with a speech bubble. Tap him to hear him talk.
/// The shop's spot scene, in a circle just inside the growth ring.
class _SpotCircle extends CustomPainter {
  const _SpotCircle(this.spot);

  final BinhiSpot spot;

  @override
  void paint(Canvas canvas, Size size) {
    if (spot == BinhiSpot.meadow) return;
    final r = Rect.fromCircle(center: size.center(Offset.zero), radius: size.shortestSide / 2 - 7);
    canvas
      ..save()
      ..clipPath(Path()..addOval(r))
      ..translate(r.left, r.top);
    BinhiSpotPainter(spot).paint(canvas, r.size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpotCircle old) => old.spot != spot;
}

class _BinhiCorner extends ConsumerStatefulWidget {
  const _BinhiCorner({required this.path});

  final PathState path;

  @override
  ConsumerState<_BinhiCorner> createState() => _BinhiCornerState();
}

class _BinhiCornerState extends ConsumerState<_BinhiCorner> with SingleTickerProviderStateMixin {
  final _binhi = BinhiController();
  final _can = GlobalKey();
  int _talk = -1;

  /// Shown in the bubble right after watering.
  String? _thanks;

  /// The can flying over and pouring onto Binhi.
  late final AnimationController _pour = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  static const _lines = ['Hi! Let us learn about plants!', 'Leaves help me grow big!', 'I love sunshine and water.'];
  static const _thirsty = 'I am a little thirsty. Can you water me?';

  @override
  void dispose() {
    _pour.dispose();
    _binhi.dispose();
    super.dispose();
  }

  String get _nudge {
    final current = widget.path.currentId;
    return current == null ? 'You finished every plant!' : 'Tap ${PlantCatalog.byId(current).name} to explore!';
  }

  /// Thirsty Binhi swaps his last chatter line for a little reminder; with
  /// a review waiting he mentions it first.
  List<String> _chatter(bool thirsty) {
    final review = ref.read(reviewPlanProvider).value?.count ?? 0;
    return [
      if (review > 0) 'Some plant questions want another try. Find them on the Quiz tab!',
      ...thirsty ? [..._lines.take(2), _thirsty] : _lines,
    ];
  }

  /// The nudge first, then Binhi's chatter, then the nudge again.
  String _line(bool thirsty) {
    if (_thanks != null) return _thanks!;
    final lines = _chatter(thirsty);
    return _talk < 0 || _talk == lines.length ? _nudge : lines[_talk];
  }

  void _talkNow(bool thirsty) {
    setState(() {
      _thanks = null;
      _talk = (_talk + 1) % (_chatter(thirsty).length + 1);
    });
    _binhi.hop();
    ref.read(readAloudProvider).speak(_line(thirsty));
  }

  /// Watering Binhi (PLAN.md §5e): +2 leaves once a day; on the 7th day
  /// watered he earns the flower pot.
  Future<void> _water() async {
    if (_pour.isAnimating) return;
    PressFeedback.onPress?.call();
    final before = ref.read(leavesEarnedProvider).value ?? 0;
    final from = _centerOf(_can);
    final thirsty = ref.read(wateredTodayProvider).value == false;
    final still = ref.read(lessMotionProvider) || MediaQuery.disableAnimationsOf(context);
    final saving = ref.read(gameActionsProvider).waterBinhi();
    if (thirsty && !still) {
      // The can flies over, tips and pours; Binhi cheers as the water lands.
      Future<void>.delayed(_pour.duration! * 0.42, () {
        if (mounted) _binhi.cheer();
      });
      await _pour.forward(from: 0);
      _pour.value = 0;
    }
    final result = await saving;
    if (!mounted || result == null) return;
    final thanks = result.leaves > 0 ? 'Ahh, thank you! +${result.leaves} leaves' : 'Thank you! I had my water today.';
    setState(() => _thanks = thanks);
    _binhi.cheer();
    ref.read(readAloudProvider).speak(thanks);
    if (result.leaves == 0) return;
    await celebrateLeaves(context, ref, from: from, earned: result.leaves, earnedBefore: before);
    if (!result.flowerPot || !mounted) return;
    await showRewardMoment(
      context,
      title: 'A flower pot for Binhi!',
      art: Binhi(
        stage: BinhiStage.forLeaves(before + result.leaves),
        size: 140,
        outfit: ref.read(binhiOutfitProvider),
        mood: BinhiMood.cheering,
        reduceMotion: true,
      ),
      message:
          'You watered Binhi on ${DailyRules.flowerPotDays} days. Look at his new pot!\n'
          'You can change it in the Shop.',
      color: AppColors.bubblegum,
      titleColor: AppColors.bubblegumDark,
      reduceMotion: ref.read(lessMotionProvider),
      onShown: () => cheerReward(context, ref),
    );
  }

  static Offset? _centerOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    return box == null || !box.hasSize ? null : box.localToGlobal(box.size.center(Offset.zero));
  }

  @override
  Widget build(BuildContext context) {
    final leaves = ref.watch(leavesEarnedProvider).value ?? 0;
    final stage = BinhiStage.forLeaves(leaves);
    final toGrow = BinhiStage.leavesToGrow(leaves);
    final tag = toGrow == 0 ? 'Full bloom!' : '$toGrow to grow';
    final grown = toGrow == 0 ? 'Fully grown.' : '$toGrow more leaves to grow.';
    final still = ref.watch(lessMotionProvider);
    // Until we know, assume he had water (no droop flashing on start).
    final thirsty = ref.watch(wateredTodayProvider).value == false;
    final line = _line(thirsty);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 122,
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                child: Semantics(
                  button: true,
                  label:
                      'Binhi is ${stage.label}. $grown${thirsty ? ' He is a little thirsty.' : ''} Tap to hear Binhi.',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => _talkNow(thirsty),
                    child: SizedBox(
                      width: 104,
                      height: 112,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: const BoxDecoration(
                              color: AppColors.card,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 4))],
                            ),
                            child: CustomPaint(
                              // Binhi's spot from the shop, inside the growth ring.
                              painter: _SpotCircle(ref.watch(binhiOutfitProvider).spot),
                              foregroundPainter: _GrowthRing(BinhiStage.growthProgress(leaves)),
                              child: Center(
                                // A thirsty Binhi leans a little; never sad or hurt.
                                child: AnimatedRotation(
                                  turns: thirsty ? -0.02 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Binhi(
                                    stage: stage,
                                    outfit: ref.watch(binhiOutfitProvider),
                                    size: 70,
                                    controller: _binhi,
                                    reduceMotion: still,
                                    mood: _talk >= 0 || _thanks != null
                                        ? BinhiMood.cheering
                                        : thirsty
                                        ? BinhiMood.encouraging
                                        : BinhiMood.happy,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.leaf,
                                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                                border: Border.all(color: AppColors.card, width: 2),
                              ),
                              child: Text(tag, style: AppText.label.copyWith(color: AppColors.text, fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: AnimatedBuilder(
                  animation: _pour,
                  builder: (context, _) =>
                      _CanButton(key: _can, thirsty: thirsty, away: _pour.value > 0, onPressed: _water),
                ),
              ),
              // The flying, pouring can (drawn over Binhi, ignores taps).
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _pour,
                    builder: (context, _) =>
                        _pour.value == 0 ? const SizedBox() : CustomPaint(painter: _PourPainter(_pour.value)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                boxShadow: const [BoxShadow(color: Color(0x22263046), blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(line, style: AppText.label.copyWith(color: AppColors.text, fontSize: 15)),
                  ),
                  SpeakerButton(text: line),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The watering can next to Binhi. While he is thirsty it carries a small
/// drop badge so a child notices it.
class _CanButton extends StatelessWidget {
  const _CanButton({super.key, required this.thirsty, required this.onPressed, this.away = false});

  final bool thirsty;
  final VoidCallback onPressed;

  /// The can is off watering Binhi.
  final bool away;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: thirsty ? 'Water Binhi' : 'Water Binhi. He had water today.',
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 46,
        height: 46,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: thirsty ? AppColors.skyTint : AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: thirsty ? AppColors.sky : AppColors.border, width: 2),
          boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 3))],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!away) const Positioned.fill(child: CustomPaint(painter: WateringCanPainter())),
            if (thirsty && !away) const Positioned(right: -10, top: -12, child: KidIconView(KidIcon.drop, size: 18)),
          ],
        ),
      ),
    ),
  );
}

/// Watering Binhi, as [t] runs 0 → 1: the can lifts off its button and
/// flies over Binhi (0–0.22), tips forward (0.22–0.34), pours a stream of
/// drops onto his leaves with little splashes (0.34–0.8), then tips back
/// and flies home (0.8–1). Drawn in the corner's own coordinates (Binhi's
/// circle is 104 wide at the bottom left; the can button sits top right).
class _PourPainter extends CustomPainter {
  const _PourPainter(this.t);

  final double t;

  static const _canSize = 54.0;
  static const _home = Offset(99, 23);
  static const _over = Offset(76, -12);

  /// Where drops land: the top of Binhi's leaves.
  static const _landY = 50.0;

  static double _part(double t, double a, double b) => ((t - a) / (b - a)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final fly = Curves.easeOutCubic.transform(_part(t, 0, 0.22));
    final back = Curves.easeInCubic.transform(_part(t, 0.86, 1));
    final tip = Curves.easeInOut.transform(_part(t, 0.22, 0.34)) - Curves.easeInOut.transform(_part(t, 0.8, 0.88));
    final centre = Offset.lerp(Offset.lerp(_home, _over, fly)!, _home, back)!;
    // A gentle arc on the way there and back.
    final lift = math.sin(math.pi * fly) * 14 * (1 - back) + math.sin(math.pi * back) * 14;
    final c = centre - Offset(0, lift);
    final scale = 0.7 + 0.3 * fly * (1 - back);
    final angle = -0.7 * tip;
    final s = _canSize * scale;

    // The spout's tip, turned with the can (see WateringCanPainter).
    final spoutLocal = Offset(s * 0.08, s * 0.32) - Offset(s / 2, s / 2);
    final spout =
        c +
        Offset(
          spoutLocal.dx * math.cos(angle) - spoutLocal.dy * math.sin(angle),
          spoutLocal.dx * math.sin(angle) + spoutLocal.dy * math.cos(angle),
        );

    final pouring = _part(t, 0.32, 0.82);
    if (pouring > 0 && pouring < 1) _drops(canvas, spout, pouring);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(angle);
    canvas.translate(-s / 2, -s / 2);
    // A soft white disc behind the can so it reads against the path.
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.48, Paint()..color = Colors.white.withValues(alpha: 0.55));
    const WateringCanPainter().paint(canvas, Size(s, s));
    canvas.restore();
  }

  /// A stream of drops from the spout, thinning out at the end, with tiny
  /// splashes where they land.
  void _drops(Canvas canvas, Offset spout, double p) {
    final fall = _landY - spout.dy;
    if (fall <= 0) return;
    final strength = p < 0.85 ? 1.0 : (1 - p) / 0.15;
    final drop = Paint()..color = AppColors.sky;
    final rim = Paint()
      ..color = AppColors.skyDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const count = 7;
    for (var i = 0; i < count; i++) {
      final phase = (p * 5 + i / count) % 1;
      if (i / count > strength) continue;
      final x = spout.dx - 2 + math.sin(i * 2.3) * 3 - phase * 4;
      final y = spout.dy + phase * fall;
      final r = Rect.fromCenter(center: Offset(x, y), width: 5, height: 8);
      canvas.drawOval(r, drop);
      canvas.drawOval(r, rim);
      if (phase > 0.86) {
        final spread = (phase - 0.86) / 0.14;
        final splash = Paint()..color = AppColors.skyLight.withValues(alpha: 1 - spread);
        for (final dx in [-1.0, 1.0]) {
          canvas.drawCircle(Offset(x + dx * (4 + spread * 7), _landY - spread * 4), 2, splash);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PourPainter old) => old.t != t;
}

/// Binhi's growth toward his next stage, drawn around him.
class _GrowthRing extends CustomPainter {
  _GrowthRing(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 6);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, 2 * math.pi, false, line..color = AppColors.track);
    canvas.drawArc(r, -math.pi / 2, 2 * math.pi * progress.clamp(0.0, 1.0), false, line..color = AppColors.leaf);
  }

  @override
  bool shouldRepaint(_GrowthRing old) => old.progress != progress;
}

/// The world's name on its own scene (replaces the big world card).
class _WorldLabel extends StatelessWidget {
  const _WorldLabel({required this.world, required this.path});

  final WorldInfo world;
  final PathState path;

  @override
  Widget build(BuildContext context) {
    final open = path.isWorldOpen(world.number);
    final theme = WorldTheme.of(world.number);
    final done = path.doneInWorld(world.number);
    final line = open ? '$done of 5 done' : 'Finish ${WorldInfo.of(world.number - 1).name} to open';
    return Semantics(
      label: 'World ${world.number}, ${world.name}. $line',
      excludeSemantics: true,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: open ? theme.accent : AppColors.track,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                boxShadow: [
                  BoxShadow(color: open ? theme.accentDark : AppColors.borderDeep, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!open) ...[
                    const KidIconView(KidIcon.lock, size: AppSizes.iconSmall, muted: true),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
                      'World ${world.number} · ${world.name}',
                      style: AppText.label.copyWith(color: AppColors.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSizes.gapS),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                line,
                style: AppText.label.copyWith(color: AppColors.text, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One world as a storybook page (PLAN.md D23): its living scene in a
/// rounded card, the world's label on top, and its five plants on a trail
/// winding up from the bottom. Stops shrink a little on short screens.
class _WorldPage extends StatelessWidget {
  const _WorldPage({required this.world, required this.path, required this.reduceMotion});

  final WorldInfo world;
  final PathState path;
  final bool reduceMotion;

  /// Where the stops sit across the page, from the bottom up.
  static const _xs = [0.27, 0.72, 0.3, 0.7, 0.42];

  /// A stop's full height (START tag, circle, name) at full size.
  static const _stopHeight = 150.0;

  @override
  Widget build(BuildContext context) {
    final plants = PlantCatalog.inWorld(world.number);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapL),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL + 4),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            const labelRoom = 56.0;
            final scale = ((c.maxHeight - labelRoom) / 520).clamp(0.62, 1.0);
            final stop = _stopHeight * scale;
            final step = (c.maxHeight - labelRoom - stop - 8) / (plants.length - 1);
            // Centre of each stop's circle, from the bottom up.
            final centers = [
              for (var i = 0; i < plants.length; i++)
                Offset(w * _xs[i], c.maxHeight - 8 - stop + (30 + PathStop.size / 2) * scale - i * step),
            ];
            return Stack(
              children: [
                Positioned.fill(
                  child: WorldScene(world: world.number, parallax: false, reduceMotion: reduceMotion),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrailPainter(centers, [for (final p in plants) path.of(p.id) == StopState.done], scale),
                  ),
                ),
                for (var i = 0; i < plants.length; i++)
                  Positioned(
                    left: centers[i].dx - 75,
                    top: centers[i].dy - (30 + PathStop.size / 2) * scale,
                    width: 150,
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: PathStop(
                        plant: plants[i],
                        state: path.of(plants[i].id),
                        reduceMotion: reduceMotion,
                        lockedHint: _hintFor(plants[i]),
                        onOpen: () => context.push('/plant/${plants[i].id}'),
                      ),
                    ),
                  ),
                Positioned(
                  left: AppSizes.gapM,
                  right: AppSizes.gapM,
                  top: AppSizes.gapM,
                  child: _WorldLabel(world: world, path: path),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String? _hintFor(PlantInfo plant) {
    final i = PlantCatalog.all.indexOf(plant);
    return i == 0 ? null : 'Finish ${PlantCatalog.all[i - 1].name} first!';
  }
}

/// Which world page is showing, and a nudge toward the next one.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.page, required this.onTap});

  final int page;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final last = WorldInfo.all.length - 1;
    final next = page < last ? WorldInfo.all[page + 1] : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i <= last; i++)
          Semantics(
            button: true,
            selected: i == page,
            label: 'World ${i + 1}, ${WorldInfo.all[i].name}',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: i == page ? 26 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: i == page ? AppColors.leaf : AppColors.track,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: AppSizes.gapS),
        Flexible(
          child: GestureDetector(
            onTap: () => onTap(next == null ? 0 : page + 1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    next == null ? 'Back to ${WorldInfo.all.first.name}' : 'Swipe for ${next.name}',
                    style: AppText.label.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                KidIconView(next == null ? KidIcon.back : KidIcon.next, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Dotted trail between stops. Stretches already walked are sunshine.
class _TrailPainter extends CustomPainter {
  _TrailPainter(this.centers, this.done, [this.scale = 1]);

  final List<Offset> centers;
  final List<bool> done;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < centers.length - 1; i++) {
      final a = centers[i];
      final b = centers[i + 1];
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, (a.dy + b.dy) / 2, b.dx, (a.dy + b.dy) / 2, b.dx, b.dy);
      final metric = path.computeMetrics().first;
      final fill = Paint()..color = done[i] ? AppColors.sunshine : AppColors.card.withValues(alpha: 0.9);
      final edge = Paint()..color = done[i] ? AppColors.sunshineDark : AppColors.borderDeep;
      final gap = 52 * scale;
      for (var d = gap; d < metric.length - gap; d += 20 * scale) {
        final p = metric.getTangentForOffset(d)!.position;
        canvas
          ..drawCircle(p.translate(0, 2), 6.5 * scale, edge)
          ..drawCircle(p, 6.5 * scale, fill);
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.centers != centers || old.done.toString() != done.toString();
}
