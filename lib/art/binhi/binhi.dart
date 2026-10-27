import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'binhi_outfit.dart';
import 'binhi_painter.dart';
import 'binhi_stage.dart';

export 'binhi_outfit.dart';
export 'binhi_stage.dart';

/// Lets a screen make Binhi move, e.g. cheer on a correct answer.
class BinhiController extends ChangeNotifier {
  int _hopTarget = 0;

  /// One squash-and-stretch hop.
  void hop() => _request(1);

  /// Two quick hops in a row (correct answers, rewards).
  void cheer() => _request(2);

  void _request(int count) {
    _hopTarget += count;
    notifyListeners();
  }
}

/// Binhi the mascot. Breathes and blinks at rest, sways gently, and hops
/// when tapped.
///
/// [reduceMotion] (the "less motion" setting) or the system's
/// "remove animations" switch keeps Binhi still apart from a small hop.
class Binhi extends StatefulWidget {
  const Binhi({
    super.key,
    required this.stage,
    this.mood = BinhiMood.happy,
    this.size = 120,
    this.onTap,
    this.controller,
    this.reduceMotion = false,
    this.semanticLabel,
    this.outfit = BinhiOutfit.none,
  });

  /// Hats, garlands, sunglasses and pot patterns (rewards).
  final BinhiOutfit outfit;

  final BinhiStage stage;
  final BinhiMood mood;

  /// Width in logical pixels. Height is 1.3 × width.
  final double size;

  /// Called after a tap starts the hop (e.g. to make Binhi talk).
  final VoidCallback? onTap;

  final BinhiController? controller;
  final bool reduceMotion;
  final String? semanticLabel;

  @override
  State<Binhi> createState() => BinhiState();
}

class BinhiState extends State<Binhi> with TickerProviderStateMixin {
  late final AnimationController _breathe = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  );
  late final AnimationController _sway = AnimationController(vsync: this, duration: const Duration(milliseconds: 3900));
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
  late final AnimationController _hop = AnimationController(vsync: this, duration: const Duration(milliseconds: 620));
  late final Listenable _repaint = Listenable.merge([_breathe, _sway, _blink, _hop]);

  final _random = math.Random();
  Timer? _blinkTimer;
  int _hopsQueued = 0;
  int _seenTarget = 0;
  bool _still = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerHop);
    _seenTarget = widget.controller?._hopTarget ?? 0;
    _hop.addStatusListener(_onHopStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(Binhi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerHop);
      widget.controller?.addListener(_onControllerHop);
      _seenTarget = widget.controller?._hopTarget ?? 0;
    }
    if (oldWidget.reduceMotion != widget.reduceMotion) _updateMotion();
  }

  void _updateMotion() {
    final still = widget.reduceMotion || MediaQuery.disableAnimationsOf(context);
    if (still == _still && (_breathe.isAnimating || still)) return;
    _still = still;
    if (still) {
      _breathe.stop();
      _sway.stop();
      _sway.value = 0.5;
      _breathe.value = 0;
      _blinkTimer?.cancel();
    } else {
      _breathe.repeat(reverse: true);
      _sway.value = 0.5;
      _sway.repeat(reverse: true);
      _scheduleBlink();
    }
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 2000 + _random.nextInt(3200)), () async {
      if (!mounted || _still) return;
      await _blink.forward(from: 0);
      if (!mounted) return;
      await _blink.reverse();
      // Sometimes a quick double blink, like a real kid.
      if (mounted && _random.nextDouble() < 0.2) {
        await _blink.forward(from: 0);
        if (mounted) await _blink.reverse();
      }
      if (mounted) _scheduleBlink();
    });
  }

  void _onControllerHop() {
    final target = widget.controller!._hopTarget;
    final count = target - _seenTarget;
    _seenTarget = target;
    if (count > 0) _queueHops(count);
  }

  void _queueHops(int count) {
    _hopsQueued = math.min(_hopsQueued + count, 3);
    if (!_hop.isAnimating) _startHop();
  }

  void _startHop() {
    if (_hopsQueued <= 0) return;
    _hopsQueued--;
    _hop.forward(from: 0);
  }

  void _onHopStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _hop.value = 0;
      _startHop();
    }
  }

  /// Hop now (same as a tap, without calling [Binhi.onTap]).
  void hop() => _queueHops(1);

  void _handleTap() {
    HapticFeedback.selectionClick();
    _queueHops(1);
    widget.onTap?.call();
  }

  BinhiPose _pose() => BinhiPose(breathe: _breathe.value, sway: _sway.value, blink: _blink.value, hop: _hop.value);

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerHop);
    _blinkTimer?.cancel();
    _breathe.dispose();
    _sway.dispose();
    _blink.dispose();
    _hop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final picture = RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, widget.size * 1.3),
        painter: BinhiPainter(
          stage: widget.stage,
          mood: widget.mood,
          pose: _pose,
          outfit: widget.outfit,
          repaint: _repaint,
        ),
      ),
    );

    final label = widget.semanticLabel ?? 'Binhi is ${widget.stage.label}';
    if (widget.onTap == null) {
      return Semantics(label: label, image: true, child: picture);
    }
    return Semantics(
      label: label,
      button: true,
      onTap: _handleTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _handleTap,
        child: picture,
      ),
    );
  }
}
