import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../game/rules.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/effects/pop_in.dart';
import '../../widgets/pressable_3d.dart';
import '../../art/icons/kid_icon.dart';

/// One stop on the adventure path: done (sunshine), current (START tag,
/// gentle bounce) or locked (shakes and says what to finish first).
class PathStop extends StatefulWidget {
  const PathStop({
    super.key,
    required this.plant,
    required this.state,
    required this.onOpen,
    this.lockedHint,
    this.reduceMotion = false,
  });

  static const size = 84.0;

  final PlantInfo plant;
  final StopState state;
  final VoidCallback onOpen;

  /// What a locked stop says when tapped, e.g. "Finish Sampaguita first!".
  final String? lockedHint;
  final bool reduceMotion;

  @override
  State<PathStop> createState() => _PathStopState();
}

class _PathStopState extends State<PathStop> with TickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  Timer? _hintTimer;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _syncBounce();
  }

  @override
  void didUpdateWidget(PathStop oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncBounce();
  }

  void _syncBounce() {
    final bounce = widget.state == StopState.current && !widget.reduceMotion;
    if (bounce && !_bounce.isAnimating) {
      _bounce.repeat(reverse: true);
    } else if (!bounce && _bounce.isAnimating) {
      _bounce
        ..stop()
        ..value = 0;
    }
  }

  void _tap() {
    PressFeedback.onPress?.call();
    if (widget.state != StopState.locked) {
      HapticFeedback.lightImpact();
      widget.onOpen();
      return;
    }
    HapticFeedback.mediumImpact();
    _shake.forward(from: 0);
    _hintTimer?.cancel();
    setState(() => _showHint = true);
    _hintTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _shake.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final (face, ledge, ring) = switch (state) {
      StopState.done => (AppColors.sunshine, AppColors.sunshineDark, AppColors.sunshineDark),
      StopState.current => (AppColors.card, AppColors.grapeDark, AppColors.grape),
      StopState.locked => (AppColors.track, AppColors.borderDeep, AppColors.borderDeep),
    };
    final label = switch (state) {
      StopState.done => '${widget.plant.name}, done',
      StopState.current => '${widget.plant.name}, start here',
      StopState.locked => '${widget.plant.name}, locked',
    };

    final circle = Container(
      width: PathStop.size,
      height: PathStop.size,
      decoration: BoxDecoration(
        color: face,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: state == StopState.current ? 4 : 3),
        boxShadow: [
          BoxShadow(color: ledge, offset: const Offset(0, 6)),
          BoxShadow(color: ledge.withValues(alpha: 0.3), offset: const Offset(0, 10), blurRadius: 12),
        ],
      ),
      child: ClipOval(
        child: state == StopState.locked
            ? const KidIconView(KidIcon.lock, size: AppSizes.iconMedium, muted: true)
            : Padding(
                padding: const EdgeInsets.all(6),
                child: PlantView(plant: widget.plant),
              ),
      ),
    );

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: _tap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        child: SizedBox(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 26,
                child: state == StopState.current
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.text,
                          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                        ),
                        child: Text('START', style: AppText.label.copyWith(color: AppColors.card)),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: Listenable.merge([_shake, _bounce]),
                builder: (context, child) {
                  final shakeX = math.sin(_shake.value * math.pi * 6) * 9 * (1 - _shake.value);
                  final bounceY = -6 * Curves.easeInOut.transform(_bounce.value);
                  return Transform.translate(offset: Offset(shakeX, bounceY), child: child);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Pops open when the stop unlocks or gets done.
                    PopIn(trigger: state, scale: widget.reduceMotion ? 1.06 : 1.18, child: circle),
                    if (state == StopState.done)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.leaf,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.card, width: 2.5),
                          ),
                          child: const KidIconView(KidIcon.tick, size: AppSizes.iconSmall),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _pill(
                _showHint && widget.lockedHint != null ? widget.lockedHint! : widget.plant.name,
                muted: state == StopState.locked && !_showHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text, {required bool muted}) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 180),
    child: Container(
      key: ValueKey(text),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        text,
        style: AppText.label.copyWith(fontSize: 14, color: muted ? AppColors.textMuted : AppColors.text),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
