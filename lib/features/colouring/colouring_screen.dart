import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/binhi/binhi.dart';
import '../../art/colouring/colouring_art.dart';
import '../../art/icons/kid_icon.dart';
import '../../content/plant_catalog.dart';
import '../../data/progress_repository.dart';
import '../../game/colouring.dart';
import '../../services/sound_service.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/round_buttons.dart';

/// Colouring a plant's page by hand (PLAN.md §5l): four tools, twelve
/// colours, and colour always stays inside the part where it started.
/// HANG IT puts the picture on the bahay kubo wall in My Garden.
///
/// [fromGallery]: opened from the bahay kubo wall, so after hanging it goes
/// back down to the garden instead of opening a new one.
class ColouringScreen extends ConsumerStatefulWidget {
  const ColouringScreen({super.key, required this.plantId, this.fromGallery = false});

  final String plantId;
  final bool fromGallery;

  @override
  ConsumerState<ColouringScreen> createState() => _ColouringScreenState();
}

class _ColouringScreenState extends ConsumerState<ColouringScreen> {
  late final ui.Picture _art = ColouringArt.of(widget.plantId);
  late final ProgressRepository _repo = ref.read(repositoryProvider);

  ColouringCanvas? _canvas;
  ui.Image? _image;
  ColouringTool _tool = ColouringTool.crayon;
  int _colour = ColouringRules.colours.first;

  int? _pointer;
  bool _drawing = false;
  bool _rendering = false;
  bool _renderAgain = false;
  bool _hanging = false;

  /// Unsaved changes; saved a moment after the last one, or on leaving.
  bool _dirty = false;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final regions = await ColouringArt.regions(_art);
    final canvas = ColouringCanvas(regions);
    final saved = await _repo.getColouring(widget.plantId);
    if (saved != null) {
      final pixels = await ColouringArt.pixelsOf(saved.png);
      if (pixels != null) canvas.load(pixels);
    }
    if (!mounted) return;
    setState(() => _canvas = canvas);
    await _render();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (_dirty) _save();
    _image?.dispose();
    super.dispose();
  }

  /// Turns the pixels into an image for the painter, one at a time.
  Future<void> _render() async {
    final canvas = _canvas;
    if (canvas == null) return;
    if (_rendering) {
      _renderAgain = true;
      return;
    }
    _rendering = true;
    do {
      _renderAgain = false;
      final img = await ColouringArt.image(Uint8List.fromList(canvas.pixels));
      if (!mounted) {
        img.dispose();
        break;
      }
      setState(() {
        _image?.dispose();
        _image = img;
      });
    } while (_renderAgain);
    _rendering = false;
  }

  void _changed() {
    _dirty = true;
    _render();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 900), _save);
  }

  Future<void> _save() async {
    final canvas = _canvas;
    if (canvas == null || !_dirty) return;
    _dirty = false;
    await _repo.saveColouring(widget.plantId, await ColouringArt.png(Uint8List.fromList(canvas.pixels)));
  }

  /// A point on the paper in colour-layer pixels.
  Offset _toPixels(Offset local, Size size) {
    final page = ColouringPainter.pageRect(size);
    final k = ColouringRules.pixelWidth / page.width;
    return (local - page.topLeft) * k;
  }

  void _down(PointerDownEvent e, Size size) {
    final canvas = _canvas;
    if (canvas == null || _pointer != null) return;
    final p = _toPixels(e.localPosition, size);
    if (_tool == ColouringTool.fill) {
      if (canvas.fill(p.dx, p.dy, _colour)) _changed();
      return;
    }
    _pointer = e.pointer;
    _drawing = true;
    canvas.begin(_tool, p.dx, p.dy, _colour);
    _changed();
  }

  void _move(PointerMoveEvent e, Size size) {
    if (e.pointer != _pointer || !_drawing) return;
    final p = _toPixels(e.localPosition, size);
    _canvas!.moveTo(p.dx, p.dy);
    _changed();
  }

  void _up(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    _drawing = false;
    _canvas?.end();
    setState(() {});
  }

  void _pickColour(int rgb) {
    setState(() {
      _colour = rgb;
      if (_tool == ColouringTool.eraser) _tool = ColouringTool.crayon;
    });
  }

  Future<void> _hang() async {
    final canvas = _canvas;
    if (canvas == null || _hanging) return;
    setState(() => _hanging = true);
    _saveTimer?.cancel();
    _dirty = false;
    final png = await ColouringArt.png(Uint8List.fromList(canvas.pixels));
    final earnedBefore = await _repo.getLeavesEarned();
    final leaves = await _repo.hangColouring(widget.plantId, png);
    if (!mounted) return;
    ref.read(soundServiceProvider).play(Sfx.correct);
    ref.read(justHungProvider.notifier).set(widget.plantId);
    final toGarden = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _HungCard(plantId: widget.plantId, png: png, leaves: leaves),
    );
    if (!mounted) return;
    setState(() => _hanging = false);
    if (leaves > 0) {
      await celebrateLeaves(context, ref, from: null, earned: leaves, earnedBefore: earnedBefore);
      if (!mounted) return;
    }
    if (toGarden != true) return;
    if (widget.fromGallery) {
      // Colouring sits on the wall, which sits on the garden.
      context.pop();
      if (context.canPop()) context.pop();
    } else {
      context.pushReplacement('/profile/garden');
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = PlantCatalog.byId(widget.plantId);
    final canvas = _canvas;
    final empty = canvas == null || canvas.isEmpty;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapS),
              child: Row(
                children: [
                  SquareIconButton.back(context),
                  const SizedBox(width: AppSizes.gapM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text('Colour ${plant.name}', style: AppText.heading),
                        ),
                        const Text('Any colours you like!', style: AppText.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.gapS),
                  SquareIconButton(
                    icon: KidIcon.restart,
                    semanticLabel: 'Undo',
                    onPressed: canvas != null && canvas.canUndo
                        ? () {
                            canvas.undo();
                            _changed();
                          }
                        : null,
                  ),
                ],
              ),
            ),
            Expanded(child: _desk()),
            const _Label('COLOURS'),
            _Swatches(
              colours: ColouringRules.palette(ref.watch(ownedProvider).value ?? const {}),
              selected: _colour,
              onPick: _pickColour,
            ),
            const _Label('TOOLS'),
            _Tools(selected: _tool, colour: _colour, onPick: (t) => setState(() => _tool = t)),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapL),
              child: Row(
                children: [
                  Expanded(
                    child: ChunkyButton(
                      label: 'START AGAIN',
                      tone: ButtonTone.white,
                      small: true,
                      onPressed: empty
                          ? null
                          : () {
                              canvas.clear();
                              _changed();
                            },
                    ),
                  ),
                  const SizedBox(width: AppSizes.gapS),
                  Expanded(
                    child: ChunkyButton(label: 'HANG IT', onPressed: empty || _hanging ? null : _hang),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The page, taped onto a little wooden desk.
  Widget _desk() => Container(
    margin: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFE9D3A8),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      border: const Border(bottom: BorderSide(color: Color(0xFFD6BC8A), width: 5)),
    ),
    child: LayoutBuilder(
      builder: (context, c) {
        final page = ColouringPainter.pageRect(c.biggest);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fromRect(
              rect: page,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Color(0x338A5A2B), blurRadius: 12, offset: Offset(0, 5))],
                ),
              ),
            ),
            Positioned.fill(
              child: Semantics(
                label: 'Colouring page. Colour with your finger.',
                child: Listener(
                  onPointerDown: (e) => _down(e, c.biggest),
                  onPointerMove: (e) => _move(e, c.biggest),
                  onPointerUp: _up,
                  onPointerCancel: _up,
                  child: CustomPaint(
                    painter: ColouringPainter(art: _art, colours: _image, version: _canvas?.version ?? 0),
                  ),
                ),
              ),
            ),
            _Tape(left: page.left + 14, top: page.top - 9, angle: -0.14, tint: const Color(0xFFFFD6E0)),
            _Tape(left: page.right - 72, top: page.top - 9, angle: 0.12, tint: const Color(0xFFCDEBFF)),
          ],
        );
      },
    ),
  );
}

class _Tape extends StatelessWidget {
  const _Tape({required this.left, required this.top, required this.angle, required this.tint});

  final double left;
  final double top;
  final double angle;
  final Color tint;

  @override
  Widget build(BuildContext context) => Positioned(
    left: left,
    top: top,
    child: IgnorePointer(
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 58,
          height: 20,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tint.withValues(alpha: 0.85), Color.lerp(tint, Colors.white, 0.5)!.withValues(alpha: 0.85)],
              stops: const [0.5, 0.5],
              tileMode: TileMode.repeated,
              begin: Alignment.topLeft,
              end: const Alignment(-0.8, -0.6),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(AppSizes.gutter + 2, AppSizes.gapM, AppSizes.gutter, AppSizes.gapS),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: AppText.label.copyWith(color: AppColors.textMuted, letterSpacing: 1)),
    ),
  );
}

class _Swatches extends StatelessWidget {
  const _Swatches({required this.colours, required this.selected, required this.onPick});

  final List<(int, String)> colours;
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter + 4),
    child: LayoutBuilder(
      builder: (context, c) {
        const gap = 10.0;
        final d = math.min(44.0, (c.maxWidth - gap * 5) / 6);
        final spacing = (c.maxWidth - d * 6) / 5;
        Widget swatch(int rgb, String name) => Semantics(
          button: true,
          selected: rgb == selected,
          label: name,
          child: GestureDetector(
            onTap: () => onPick(rgb),
            child: AnimatedScale(
              scale: rgb == selected ? 1.12 : 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: rgb == selected ? AppColors.text : Colors.transparent,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: CustomPaint(painter: _SwatchPainter(Color(0xFF000000 | rgb))),
              ),
            ),
          ),
        );
        if (colours.length <= 12) {
          return Wrap(
            spacing: spacing,
            runSpacing: gap,
            children: [for (final (rgb, name) in colours) swatch(rgb, name)],
          );
        }
        // Colour packs: two rows that slide sideways, so the page keeps its room.
        return SizedBox(
          height: d * 2 + gap + 12,
          child: GridView.count(
            scrollDirection: Axis.horizontal,
            crossAxisCount: 2,
            mainAxisSpacing: spacing,
            crossAxisSpacing: gap,
            padding: const EdgeInsets.all(6),
            clipBehavior: Clip.none,
            children: [for (final (rgb, name) in colours) swatch(rgb, name)],
          ),
        );
      },
    ),
  );
}

/// A round blob of paint with a little shine.
class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(
      c,
      r - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = Colors.black.withValues(alpha: 0.08),
    );
    if (color.computeLuminance() > 0.8) {
      canvas.drawCircle(
        c,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.borderDeep,
      );
    }
    canvas.drawOval(
      Rect.fromLTWH(c.dx - r * 0.5, c.dy - r * 0.68, r * 0.55, r * 0.4),
      Paint()..color = Colors.white.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.color != color;
}

class _Tools extends StatelessWidget {
  const _Tools({required this.selected, required this.colour, required this.onPick});

  final ColouringTool selected;
  final int colour;
  final ValueChanged<ColouringTool> onPick;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gutter),
    child: Row(
      children: [
        for (final (i, t) in ColouringTool.values.indexed) ...[
          if (i > 0) const SizedBox(width: AppSizes.gapS),
          Expanded(
            child: Semantics(
              button: true,
              selected: t == selected,
              label: t.label,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onPick(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  transform: Matrix4.translationValues(0, t == selected ? -3 : 0, 0),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: t == selected ? AppColors.leafTint : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    border: Border(
                      top: BorderSide(color: t == selected ? AppColors.leaf : AppColors.border, width: 2),
                      left: BorderSide(color: t == selected ? AppColors.leaf : AppColors.border, width: 2),
                      right: BorderSide(color: t == selected ? AppColors.leaf : AppColors.border, width: 2),
                      bottom: BorderSide(color: t == selected ? AppColors.leaf : AppColors.border, width: 4),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 44, height: 34, child: CustomPaint(painter: ToolIconPainter(t))),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t.label, style: AppText.label.copyWith(color: AppColors.text, fontSize: 13)),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t == selected && t != ColouringTool.eraser ? Color(0xFF000000 | colour) : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// The four tools, drawn like the real things in a 44 × 34 box.
class ToolIconPainter extends CustomPainter {
  const ToolIconPainter(this.tool);

  final ColouringTool tool;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 44, size.height / 34);
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.text;
    final shine = Paint()..color = Colors.white.withValues(alpha: 0.55);
    void shape(Path p, Color c) => canvas
      ..drawPath(p, Paint()..color = c)
      ..drawPath(p, ink);
    Path rect(double l, double t, double r, double b, [double radius = 0]) =>
        Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));

    switch (tool) {
      case ColouringTool.crayon || ColouringTool.paint || ColouringTool.eraser:
        canvas
          ..translate(22, 17)
          ..rotate(-0.6)
          ..translate(-22, -17);
      case ColouringTool.fill:
        break;
    }
    switch (tool) {
      case ColouringTool.crayon:
        shape(rect(4, 12, 31, 22, 2), AppColors.coral);
        shape(rect(10, 12, 25, 22), const Color(0xFFFFE3E8));
        shape(Path()..addPolygon(const [Offset(31, 12), Offset(40, 17), Offset(31, 22)], true), AppColors.coral);
        canvas.drawRRect(RRect.fromLTRBR(5, 13.5, 9, 15.5, const Radius.circular(1)), shine);
      case ColouringTool.paint:
        shape(rect(1, 14, 20, 20, 1), const Color(0xFFD9934A));
        shape(rect(20, 12.5, 27, 21.5), const Color(0xFFD6DAE2));
        shape(
          Path()
            ..moveTo(27, 12.5)
            ..cubicTo(34, 12.5, 40, 15, 42, 17)
            ..cubicTo(40, 19, 34, 21.5, 27, 21.5)
            ..close(),
          AppColors.sky,
        );
      case ColouringTool.fill:
        shape(
          Path()
            ..moveTo(9, 11)
            ..lineTo(31, 11)
            ..lineTo(28.5, 31)
            ..lineTo(11.5, 31)
            ..close(),
          const Color(0xFFD6DAE2),
        );
        canvas.drawRect(const Rect.fromLTRB(10, 15, 30, 20), Paint()..color = AppColors.leaf);
        canvas.drawPath(
          Path()
            ..moveTo(11, 11)
            ..cubicTo(11, 2, 29, 2, 29, 11),
          ink,
        );
        canvas.drawPath(
          Path()
            ..moveTo(31, 14)
            ..cubicTo(37, 17, 37, 23, 35, 27),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..color = AppColors.leaf,
        );
      case ColouringTool.eraser:
        shape(rect(5, 10, 39, 24, 4), AppColors.bubblegum);
        shape(rect(5, 10, 17, 24, 4), AppColors.sky);
        canvas.drawRRect(RRect.fromLTRBR(21, 12.5, 35, 14.5, const Radius.circular(1)), shine);
    }
  }

  @override
  bool shouldRepaint(ToolIconPainter old) => old.tool != tool;
}

/// "Ang ganda!": the framed picture, Binhi, and the way to the garden.
class _HungCard extends ConsumerWidget {
  const _HungCard({required this.plantId, required this.png, required this.leaves});

  final String plantId;
  final Uint8List png;
  final int leaves;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earned = ref.watch(leavesEarnedProvider).value ?? 0;
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusL)),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.gapL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: -0.05,
              child: SizedBox(
                width: 150,
                child: PictureFrame(plantId: plantId, png: png),
              ),
            ),
            const SizedBox(height: AppSizes.gapM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Binhi(
                  stage: BinhiStage.forLeaves(earned),
                  size: 52,
                  outfit: ref.watch(binhiOutfitProvider),
                  reduceMotion: ref.watch(lessMotionProvider),
                ),
                const SizedBox(width: AppSizes.gapS),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.leafTint,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: const Text("Ang ganda! I'll hang it in our bahay kubo.", style: AppText.body),
                  ),
                ),
              ],
            ),
            if (leaves > 0) ...[
              const SizedBox(height: AppSizes.gapM),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.leafTint,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                ),
                child: Text('+$leaves leaves', style: AppText.label.copyWith(color: AppColors.leafDark)),
              ),
            ],
            const SizedBox(height: AppSizes.gapL),
            ChunkyButton(label: 'SEE IT IN MY GARDEN', onPressed: () => Navigator.of(context).pop(true)),
          ],
        ),
      ),
    );
  }
}

/// A finished picture in a wooden frame (the reward card and the wall).
class PictureFrame extends StatelessWidget {
  const PictureFrame({super.key, required this.plantId, required this.png, this.border = 8});

  final String plantId;
  final Uint8List png;
  final double border;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.bark, width: border),
      borderRadius: BorderRadius.circular(border * 0.6),
      boxShadow: const [BoxShadow(color: Color(0x22000000), offset: Offset(0, 5))],
    ),
    child: ColouringPicture(plantId: plantId, png: png),
  );
}
