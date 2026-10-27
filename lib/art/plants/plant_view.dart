import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../content/plant_catalog.dart';
import 'plant_drawing.dart';
import 'plant_touch.dart';
import 'plants_bakuran.dart';
import 'plants_bukid.dart';
import 'plants_kalikasan.dart';

export 'plant_drawing.dart' show PlantMode, PlantPart;

/// Artwork for each plant id.
abstract final class PlantArt {
  static const Map<String, PlantDrawing> _byId = {
    'sampaguita': SampaguitaDrawing(),
    'gumamela': GumamelaDrawing(),
    'makahiya': MakahiyaDrawing(),
    'kalamansi': KalamansiDrawing(),
    'malunggay': MalunggayDrawing(),
    'palay': PalayDrawing(),
    'mango': MangoDrawing(),
    'saba': SabaDrawing(),
    'mongo': MongoDrawing(),
    'niyog': NiyogDrawing(),
    'narra': NarraDrawing(),
    'kawayan': KawayanDrawing(),
    'pako': PakoDrawing(),
    'bakawan': BakawanDrawing(),
    'kangkong': KangkongDrawing(),
  };

  static PlantDrawing of(String id) => _byId[id]!;

  static bool has(String id) => _byId.containsKey(id);
}

/// Shows a plant. In [PlantMode.detail] with [onPartTap], the whole drawing
/// is one tap target and the tap goes to the part under the finger
/// (generous zones for thin parts).
class PlantView extends StatefulWidget {
  const PlantView({
    super.key,
    required this.plant,
    this.mode = PlantMode.thumbnail,
    this.highlight,
    this.locked = false,
    this.onPartTap,
    this.react = false,
    this.reduceMotion = false,
    this.touches = 0,
  });

  final PlantInfo plant;
  final PlantMode mode;

  /// The part to glow (the one just tapped).
  final PlantPart? highlight;

  /// Locked plants show as a mystery silhouette.
  final bool locked;

  final ValueChanged<PlantPart>? onPartTap;

  /// Taps also make the plant react: it sways, and does its own little
  /// thing (a makahiya folds its leaves) — PLAN.md §5j.
  final bool react;

  /// Less motion: no sway or effects (a makahiya still folds).
  final bool reduceMotion;

  /// Counts touches made outside the drawing (the part buttons, a tap in
  /// My Garden): each new count makes the plant react at the [highlight]ed
  /// part, or at its special part (flowers, fruit…) when none is chosen.
  final int touches;

  @override
  State<PlantView> createState() => _PlantViewState();
}

class _PlantViewState extends State<PlantView> with TickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  // Kept at full length even when the phone removes animations: the
  // makahiya's fold is what the plant really does (the wobble is skipped).
  late final AnimationController _touch = AnimationController(
    vsync: this,
    duration: PlantTouch.duration,
    animationBehavior: AnimationBehavior.preserve,
  );
  Offset _touchAt = Offset.zero;

  /// The last pick came from a tap on the drawing (already reacting there).
  bool _tappedHere = false;

  @override
  void initState() {
    super.initState();
    if (widget.highlight != null) _glow.value = 1;
  }

  @override
  void didUpdateWidget(PlantView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight != oldWidget.highlight && widget.highlight != null) {
      _glow.forward(from: 0);
    }
    if (widget.touches != oldWidget.touches) {
      final part = widget.highlight ?? PlantPart.special;
      if (_tappedHere) {
        _tappedHere = false;
      } else if (widget.react && !widget.locked) {
        _touchAt = PlantArt.of(widget.plant.id).glowZone(part).getBounds().center;
        _touch.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _touch.dispose();
    _glow.dispose();
    super.dispose();
  }

  String get _label {
    if (widget.locked) return 'Mystery plant';
    final part = widget.highlight;
    return part == null ? widget.plant.name : '${widget.plant.name}, ${_partName(part)}';
  }

  String _partName(PlantPart p) => switch (p) {
    PlantPart.root => 'root',
    PlantPart.stem => 'stem',
    PlantPart.leaf => 'leaf',
    PlantPart.special => widget.plant.special.label.toLowerCase(),
  };

  @override
  Widget build(BuildContext context) {
    final drawing = PlantArt.of(widget.plant.id);
    final aspect = widget.mode != PlantMode.detail
        ? PlantDrawing.thumbnailRect.width / PlantDrawing.thumbnailRect.height
        : PlantDrawing.designSize.aspectRatio;

    final art = AspectRatio(
      aspectRatio: aspect,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_glow, _touch]),
          builder: (context, _) {
            final touching = _touch.isAnimating && !widget.locked;
            var touch = touching ? PlantTouch.after(_touchAt, _touch.value) : null;
            final still = widget.reduceMotion || MediaQuery.disableAnimationsOf(context);
            if (touch != null && still) touch = PlantTouch(at: _touchAt, t: 1, fold: touch.fold);
            return CustomPaint(
              painter: PlantPainter(
                drawing: drawing,
                mode: widget.mode,
                highlight: widget.locked ? null : widget.highlight,
                silhouette: widget.locked,
                glow: Curves.easeOut.transform(_glow.value),
                touch: touch,
                effect: touch == null ? null : PlantTouch.effectOf(widget.plant.id),
              ),
            );
          },
        ),
      ),
    );

    final onPartTap = widget.onPartTap;
    if (onPartTap == null || widget.locked) {
      return Semantics(label: _label, image: true, child: art);
    }
    return Semantics(
      label: '$_label. Tap a part of the plant.',
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final box = context.findRenderObject()! as RenderBox;
            final painter = PlantPainter(drawing: drawing, mode: widget.mode);
            final point = painter.toDesign(details.localPosition, box.size);
            final part = drawing.hitTest(point);
            if (part != null) {
              HapticFeedback.selectionClick();
              if (widget.react) {
                _touchAt = point;
                _touch.forward(from: 0);
                _tappedHere = true;
              }
              onPartTap(part);
            }
          },
          child: art,
        ),
      ),
    );
  }
}
