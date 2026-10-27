import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../art/binhi/binhi.dart';
import '../state/providers.dart';
import '../state/settings.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/vine_progress.dart';
import '../widgets/sprout_logo.dart';
import 'app_info.dart';

/// Screen 1: the Loading screen, "Sunrise" (PLAN.md D18).
///
/// As the bar fills the sun climbs over the hill, blue spreads down the
/// sky, clouds and birds drift by and Binhi hops when it is done. While it
/// fills it counts today as a visited day and loads the player. Then it
/// sends first-time players to Welcome and everyone else to Home. The visit
/// is saved before any other screen shows, so the very first launch (when
/// the database is still being created) counts too.
class StartGate extends ConsumerStatefulWidget {
  const StartGate({super.key});

  @override
  ConsumerState<StartGate> createState() => _StartGateState();
}

class _StartGateState extends ConsumerState<StartGate> with TickerProviderStateMixin {
  late final AnimationController _bar = AnimationController(vsync: this);

  /// Clouds, birds and the sun's rays: a slow loop, off with less motion.
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 14));
  final _binhi = BinhiController();
  bool _started = false;
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _still = MediaQuery.disableAnimationsOf(context) || ref.read(lessMotionProvider);
    // A short, friendly fill. With animations turned off it is almost instant.
    // About 5 seconds in all: the vine grows from its first leaf to the
    // flower at the end, then Binhi hops.
    _bar.duration = _still ? const Duration(milliseconds: 250) : const Duration(milliseconds: 4500);
    if (!_still) _drift.repeat();
    _start();
  }

  Future<void> _start() async {
    // One steady grow from the very start to the very end, while the
    // progress loads alongside.
    final fill = _bar.forward(from: 0);
    await ref.read(gameActionsProvider).appOpened();
    final profile = await ref.read(repositoryProvider).getProfile();
    await fill;
    if (!mounted) return;
    if (!_still) {
      // "Good morning!": one happy hop before the day starts.
      _binhi.hop();
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
    }
    context.go(profile?.onboarded ?? false ? '/home' : '/welcome');
  }

  @override
  void dispose() {
    _bar.dispose();
    _drift.dispose();
    _binhi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = ref.watch(lessMotionProvider) || _still;
    final stage = ref.watch(binhiStageProvider).value ?? BinhiStage.sprout;
    return Scaffold(
      backgroundColor: AppColors.skyTint,
      body: LayoutBuilder(
        builder: (context, c) {
          final hillTop = c.maxHeight * 0.58;
          final binhiSize = math.min(130.0, c.maxHeight * 0.18);
          return AnimatedBuilder(
            animation: Listenable.merge([_bar, _drift]),
            builder: (context, _) {
              final t = _bar.value;
              return Stack(
                children: [
                  // Blue spreads down the sky as the sun rises.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: const [AppColors.sky, AppColors.coralTint, AppColors.sunshineTint],
                          stops: [0, 0.15 + 0.55 * t, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SkyPainter(drift: _drift.value, day: t, still: still),
                    ),
                  ),
                  // The sun climbs from behind the hill.
                  Positioned(
                    left: c.maxWidth * 0.66 - _Sun.size / 2,
                    top: hillTop - _Sun.size * 0.3 - t * (hillTop * 0.5),
                    child: _Sun(spin: _drift.value),
                  ),
                  Positioned.fill(
                    top: hillTop,
                    child: const CustomPaint(painter: _HillsPainter()),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: hillTop - binhiSize * 0.86,
                    child: Center(
                      child: Binhi(
                        stage: stage,
                        size: binhiSize,
                        controller: _binhi,
                        outfit: ref.watch(binhiOutfitProvider),
                        reduceMotion: still,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSizes.gapXl),
                          // Shrinks on very narrow phones instead of running off the edge.
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: SproutLogo(size: 40, withName: true, nameSize: 40),
                          ),
                          Text(AppInfo.tagline, style: AppText.heading.copyWith(color: AppColors.text)),
                          const Spacer(),
                          Text(
                            t < 0.5
                                ? 'Good morning, explorer!'
                                : t < 1
                                ? 'The sun is almost up!'
                                : 'Let\'s go!',
                            style: AppText.title.copyWith(color: Colors.white, fontSize: 26),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.gapM),
                          // A vine grows across as it loads.
                          Semantics(
                            label: 'Loading',
                            value: '${(t * 100).round()}%',
                            child: SizedBox(
                              height: 56,
                              width: double.infinity,
                              child: CustomPaint(painter: VineProgressPainter(t)),
                            ),
                          ),
                          const SizedBox(height: AppSizes.gapXl),
                          _Credits(still: _still),
                          const SizedBox(height: 6),
                          Text('Version ${AppInfo.version}', style: AppText.bodySmall.copyWith(color: Colors.white70)),
                          const SizedBox(height: AppSizes.gapL),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Who made PlantQuest (PLAN.md D28, owner picked the ribbon banner from
/// docs/previews/credits/): a sunny ribbon, then each name on a white pill.
/// Each piece pops in like a bubble, one after another (the "bubbly pop"
/// from docs/previews/credits/animations.html).
class _Credits extends StatefulWidget {
  const _Credits({required this.still});

  final bool still;

  @override
  State<_Credits> createState() => _CreditsState();
}

class _CreditsState extends State<_Credits> with SingleTickerProviderStateMixin {
  /// The whole show: the ribbon at 0.4 s, the names at 1.6 s and 2.8 s,
  /// each taking 1.1 s, so they are all in before the vine is done.
  static const _total = 3900.0;
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3900),
    value: widget.still ? 1 : 0,
  );

  /// Small, overshoot a little bigger, dip, settle.
  static final _bubble = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.12).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
    TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.96).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
  ]);

  @override
  void initState() {
    super.initState();
    if (!widget.still) _pop.forward();
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  Widget _bubbleIn(int i, Widget child) {
    final start = (400 + i * 1200) / _total;
    final end = (400 + i * 1200 + 1100) / _total;
    final t = CurvedAnimation(parent: _pop, curve: Interval(start, end.clamp(0.0, 1.0)));
    return AnimatedBuilder(
      animation: t,
      child: child,
      builder: (context, child) => Opacity(
        opacity: (t.value / 0.6).clamp(0.0, 1.0),
        child: Transform.scale(scale: t.value == 0 ? 0.2 : _bubble.transform(t.value), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget rise(int i, Widget child) => _bubbleIn(i, child);
    return Semantics(
      label: 'A PlantQuest story by ${AppInfo.developers.join(' and ')}',
      excludeSemantics: true,
      child: Column(
        children: [
          rise(
            0,
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // The ribbon's folded tails, behind the band.
                for (final left in [true, false])
                  Positioned(
                    left: left ? -16 : null,
                    right: left ? null : -16,
                    top: 7,
                    child: ClipPath(
                      clipper: _RibbonTail(left: left),
                      child: const SizedBox(width: 28, height: 26, child: ColoredBox(color: AppColors.sunshineDark)),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.sunshine,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [BoxShadow(color: AppColors.sunshineDark, offset: Offset(0, 3))],
                  ),
                  child: Text(
                    'A PLANTQUEST STORY BY',
                    style: AppText.label.copyWith(color: const Color(0xFF5B3A00), letterSpacing: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final (i, name) in AppInfo.developers.indexed)
            rise(
              i + 1,
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  boxShadow: const [BoxShadow(color: AppColors.leafDark, offset: Offset(0, 3))],
                ),
                child: Text(
                  name,
                  style: AppText.heading.copyWith(fontSize: 16, color: AppColors.text),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A ribbon tail with a notch cut into its outer end.
class _RibbonTail extends CustomClipper<Path> {
  const _RibbonTail({required this.left});

  final bool left;

  @override
  Path getClip(Size s) => left
      ? (Path()
          ..moveTo(0, 0)
          ..lineTo(s.width, 0)
          ..lineTo(s.width, s.height)
          ..lineTo(0, s.height)
          ..lineTo(s.width * 0.3, s.height / 2)
          ..close())
      : (Path()
          ..moveTo(0, 0)
          ..lineTo(s.width, 0)
          ..lineTo(s.width * 0.7, s.height / 2)
          ..lineTo(s.width, s.height)
          ..lineTo(0, s.height)
          ..close());

  @override
  bool shouldReclip(_RibbonTail old) => old.left != left;
}

/// The sun, with slowly turning rays and a soft glow.
class _Sun extends StatelessWidget {
  const _Sun({required this.spin});

  static const size = 140.0;
  final double spin;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _SunPainter(spin)),
  );
}

class _SunPainter extends CustomPainter {
  const _SunPainter(this.spin);
  final double spin;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.32;
    canvas.drawCircle(
      c,
      r * 1.55,
      Paint()
        ..color = AppColors.sunshine.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    final ray = Paint()
      ..color = AppColors.sunshine
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 10; i++) {
      final a = spin * 2 * math.pi + i * math.pi / 5;
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + d * (r * 1.25), c + d * (r * 1.5), ray);
    }
    canvas.drawCircle(c, r, Paint()..color = AppColors.sunshine);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.sunshineDark,
    );
    // A little shine.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(c.dx - r * 0.45, c.dy - r * 0.62, r * 0.5, r * 0.18), Radius.circular(r)),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(_SunPainter old) => old.spin != spin;
}

/// Clouds drifting right and two birds flying across, fading in as day
/// comes. [drift] loops 0..1.
class _SkyPainter extends CustomPainter {
  const _SkyPainter({required this.drift, required this.day, required this.still});

  final double drift;
  final double day;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.55 + 0.4 * day);
    // (start x share, y share, scale, speed)
    const clouds = [(0.05, 0.22, 1.0, 1.0), (0.55, 0.32, 0.7, 0.6), (0.85, 0.15, 0.85, 0.8)];
    for (final (x, y, s, speed) in clouds) {
      final w = 120 * s;
      final span = size.width + w;
      final dx = ((x * span + drift * span * speed) % span) - w / 2;
      _cloud(canvas, Offset(dx, size.height * y), w, cloud);
    }
    if (still || day < 0.15) return;
    final bird = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.text.withValues(alpha: 0.55 * ((day - 0.15) / 0.3).clamp(0, 1));
    for (final (lag, y) in [(0.0, 0.40), (0.06, 0.44)]) {
      final p = (drift * 2 + lag) % 1;
      final x = -30 + p * (size.width + 60);
      final flap = math.sin(p * 40) * 5;
      final o = Offset(x, size.height * y + math.sin(p * 6) * 10);
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 11, o.dy - 3 - flap)
          ..quadraticBezierTo(o.dx - 5, o.dy - 6 - flap, o.dx, o.dy)
          ..quadraticBezierTo(o.dx + 5, o.dy - 6 - flap, o.dx + 11, o.dy - 3 - flap),
        bird,
      );
    }
  }

  void _cloud(Canvas canvas, Offset o, double w, Paint paint) {
    final h = w * 0.32;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - w / 2, o.dy, w, h), Radius.circular(h / 2)), paint);
    canvas.drawCircle(Offset(o.dx - w * 0.15, o.dy + 2), h * 0.62, paint);
    canvas.drawCircle(Offset(o.dx + w * 0.12, o.dy - 2), h * 0.8, paint);
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.drift != drift || old.day != day || old.still != still;
}

class _HillsPainter extends CustomPainter {
  const _HillsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final back = Path()
      ..moveTo(0, 60)
      ..quadraticBezierTo(size.width * 0.25, -10, size.width * 0.55, 40)
      ..quadraticBezierTo(size.width * 0.8, 80, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(back, Paint()..color = AppColors.leafLight);
    final front = Path()
      ..moveTo(0, 90)
      ..quadraticBezierTo(size.width * 0.5, 0, size.width, 90)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(front, Paint()..color = AppColors.leaf);
  }

  @override
  bool shouldRepaint(_HillsPainter old) => false;
}
