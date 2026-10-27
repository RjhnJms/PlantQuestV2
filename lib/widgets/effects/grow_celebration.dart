import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../art/binhi/binhi.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../chunky_button.dart';
import 'confetti.dart';
import 'motion_feel.dart';

/// The full-screen "Binhi grew!" moment (PLAN.md §3). Sun rays spin behind
/// Binhi, he pops up into his new stage and cheers, confetti falls.
Future<void> showGrowCelebration(
  BuildContext context, {
  required BinhiStage stage,
  BinhiOutfit outfit = BinhiOutfit.none,
  MotionFeel feel = MotionFeel.bouncy,
  bool reduceMotion = false,
  VoidCallback? onShown,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a, b) =>
          _GrowCelebration(stage: stage, outfit: outfit, feel: feel, reduceMotion: reduceMotion, onShown: onShown),
      transitionsBuilder: (context, a, b, child) => FadeTransition(opacity: a, child: child),
    ),
  );
}

class _GrowCelebration extends StatefulWidget {
  const _GrowCelebration({
    required this.stage,
    required this.outfit,
    required this.feel,
    required this.reduceMotion,
    this.onShown,
  });

  final BinhiStage stage;
  final BinhiOutfit outfit;
  final MotionFeel feel;
  final bool reduceMotion;
  final VoidCallback? onShown;

  @override
  State<_GrowCelebration> createState() => _GrowCelebrationState();
}

class _GrowCelebrationState extends State<_GrowCelebration> with TickerProviderStateMixin {
  late final AnimationController _rays = AnimationController(vsync: this, duration: const Duration(seconds: 12));
  late final AnimationController _rise = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  final _confetti = ConfettiController();
  final _binhi = BinhiController();
  final _timers = <Timer>[];

  @override
  void initState() {
    super.initState();
    if (!widget.reduceMotion) _rays.repeat();
    _rise.forward();
    widget.onShown?.call();
    _timers.add(
      Timer(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        for (var i = 0; i < widget.feel.hops; i++) {
          _binhi.hop();
        }
        final size = MediaQuery.sizeOf(context);
        if (!widget.reduceMotion) {
          _confetti.burst(
            Offset(size.width / 2, size.height * 0.42),
            count: widget.feel.confetti,
            seconds: widget.feel.burstSeconds + 0.6,
          );
        }
      }),
    );
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _rays.dispose();
    _rise.dispose();
    _confetti.dispose();
    _binhi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.text.withValues(alpha: 0.55),
      child: ConfettiLayer(
        controller: _confetti,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.gutter),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _rays,
                          builder: (context, _) =>
                              CustomPaint(size: const Size(300, 300), painter: _RaysPainter(_rays.value * math.pi * 2)),
                        ),
                        AnimatedBuilder(
                          animation: _rise,
                          builder: (context, child) => Transform.scale(
                            scale: Curves.elasticOut.transform(_rise.value) * 0.9 + 0.1,
                            child: child,
                          ),
                          child: Binhi(
                            stage: widget.stage,
                            outfit: widget.outfit,
                            mood: BinhiMood.cheering,
                            size: 170,
                            controller: _binhi,
                            reduceMotion: widget.reduceMotion,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Binhi grew into ${widget.stage.label}!',
                    style: AppText.display.copyWith(color: AppColors.card, fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.gapS),
                  Text(
                    'Thank you for the leaves!',
                    style: AppText.heading.copyWith(color: AppColors.sunshineTint),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.gapXl),
                  ChunkyButton(label: 'YAY!', tone: ButtonTone.sunshine, onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.angle);

  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    canvas
      ..drawCircle(c, r * 0.62, Paint()..color = AppColors.sunshine.withValues(alpha: 0.35))
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(angle);
    final ray = Paint()..color = AppColors.sunshine.withValues(alpha: 0.4);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.12) * r, math.sin(a - 0.12) * r)
        ..lineTo(math.cos(a + 0.12) * r, math.sin(a + 0.12) * r)
        ..close();
      canvas.drawPath(path, ray);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.angle != angle;
}
