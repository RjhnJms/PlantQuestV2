import 'package:flutter/material.dart';

import '../../theme/world_themes.dart';
import 'ambient_painter.dart';
import 'land_painter.dart';
import 'sky_painter.dart';

/// A layered, living background for one world (PLAN.md §9).
///
/// Back to front: sky and sun, drifting clouds, far land, middle land, near
/// ground, then small moving life. Static layers sit in their own
/// [RepaintBoundary] and are painted once; only clouds and ambient life
/// repaint each frame.
///
/// Inside a scrolling list, far and middle land lag behind the scroll a
/// little (parallax), which makes the world feel deep.
///
/// [reduceMotion] or the system "remove animations" setting freezes
/// everything and turns parallax off.
class WorldScene extends StatefulWidget {
  const WorldScene({super.key, required this.world, this.reduceMotion = false, this.parallax = true});

  /// 1 Bakuran, 2 Bukid, 3 Kalikasan.
  final int world;
  final bool reduceMotion;
  final bool parallax;

  @override
  State<WorldScene> createState() => _WorldSceneState();
}

class _WorldSceneState extends State<WorldScene> with SingleTickerProviderStateMixin {
  // One long, slow clock drives clouds and ambient life.
  static const _loop = Duration(minutes: 4);
  late final AnimationController _clock = AnimationController(vsync: this, duration: _loop);

  bool get _still => widget.reduceMotion || MediaQuery.disableAnimationsOf(context);

  double _seconds() => _clock.value * _loop.inSeconds;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncClock();
  }

  @override
  void didUpdateWidget(WorldScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncClock();
  }

  void _syncClock() {
    if (_still) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final world = widget.world;
    final scrollable = widget.parallax && !_still ? Scrollable.maybeOf(context) : null;

    Widget layer(CustomPainter painter, {double parallax = 0}) {
      final paint = RepaintBoundary(
        child: CustomPaint(painter: painter, size: Size.infinite),
      );
      if (scrollable == null || parallax == 0) return paint;
      return _Parallax(scrollable: scrollable, factor: parallax, child: paint);
    }

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          layer(SkyPainter(WorldTheme.of(world))),
          layer(CloudPainter(world: world, drift: () => _clock.value * 3, repaint: _clock)),
          layer(LandPainter(world: world, layer: LandLayer.far), parallax: 0.15),
          layer(LandPainter(world: world, layer: LandLayer.mid), parallax: 0.07),
          layer(LandPainter(world: world, layer: LandLayer.near)),
          layer(AmbientPainter(world: world, time: _seconds, repaint: _clock)),
        ],
      ),
    );
  }
}

/// Shifts its child against the scroll so it appears to move slower,
/// following Flutter's parallax recipe (a [Flow] repainted by the scroll
/// position, so no rebuilds while scrolling).
class _Parallax extends StatelessWidget {
  const _Parallax({required this.scrollable, required this.factor, required this.child});

  final ScrollableState scrollable;
  final double factor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Flow(
      delegate: _ParallaxDelegate(scrollable: scrollable, itemContext: context, factor: factor),
      children: [child],
    );
  }
}

class _ParallaxDelegate extends FlowDelegate {
  _ParallaxDelegate({required this.scrollable, required this.itemContext, required this.factor})
    : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext itemContext;
  final double factor;

  /// Never shift more than this, so layers never pull away from the edges.
  static const _maxShift = 40.0;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) => BoxConstraints.tight(constraints.biggest);

  @override
  void paintChildren(FlowPaintingContext context) {
    final viewport = scrollable.context.findRenderObject();
    final item = itemContext.findRenderObject();
    var shift = 0.0;
    if (viewport is RenderBox && item is RenderBox && item.hasSize && viewport.hasSize) {
      // How far this scene's top is above (+) or below (−) the viewport top.
      final top = item.localToGlobal(Offset.zero, ancestor: viewport).dy;
      shift = (-top * factor).clamp(-_maxShift, _maxShift);
    }
    context.paintChild(0, transform: Matrix4.translationValues(0, shift, 0));
  }

  @override
  bool shouldRepaint(_ParallaxDelegate old) =>
      scrollable != old.scrollable || itemContext != old.itemContext || factor != old.factor;
}
