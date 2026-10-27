import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../game/colouring.dart';
import '../plants/plant_drawing.dart';
import '../plants/plant_view.dart';
import '../sticker.dart';

/// Colouring pages (PLAN.md §5l): each plant's own drawing as an outline,
/// standing on a little hill (or in water) under a sun and a cloud.
abstract final class ColouringArt {
  static const page = Size(ColouringRules.pageWidth, ColouringRules.pageHeight);

  static final _cache = <String, ui.Picture>{};

  /// The outline for [plantId], in page units. White inside, ink lines.
  static ui.Picture of(String plantId) => _cache[plantId] ??= record(PlantArt.of(plantId));

  static ui.Picture record(PlantDrawing drawing) {
    final recorder = ui.PictureRecorder();
    final c = Canvas(recorder);
    Sticker.lineArt = true;
    try {
      _scene(c, water: drawing.inWater);
      // The plant's ground line sits on the page's ground; tall plants are
      // scaled to fit under the sun.
      final crop = drawing.thumbnailCrop;
      final s = math.min((ColouringRules.ground - 36) / (PlantDrawing.ground - crop.top), 192 / crop.width);
      c
        ..save()
        ..translate(100, ColouringRules.ground)
        ..scale(s)
        ..translate(-100, -PlantDrawing.ground);
      drawing.body(c);
      c.restore();
    } finally {
      Sticker.lineArt = false;
    }
    return recorder.endRecording();
  }

  static void _scene(Canvas c, {required bool water}) {
    final line = Sticker.stroke(Sticker.ink, 3);
    final thin = Sticker.stroke(Sticker.ink.withValues(alpha: 0.75), 1.8);
    final white = Paint()..color = Colors.white;
    void shape(Path p) => c
      ..drawPath(p, white)
      ..drawPath(p, line);

    // Sun with rays.
    shape(Path()..addOval(Rect.fromCircle(center: const Offset(30, 32), radius: 13)));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final dir = Offset(math.cos(a), math.sin(a));
      c.drawLine(const Offset(30, 32) + dir * 19, const Offset(30, 32) + dir * 25, thin);
    }
    // A cloud.
    shape(
      Path()
        ..moveTo(146, 44)
        ..cubicTo(136, 44, 136, 32, 146, 32)
        ..cubicTo(148, 23, 162, 21, 166, 30)
        ..cubicTo(172, 25, 182, 29, 180, 37)
        ..cubicTo(188, 38, 188, 44, 180, 44)
        ..close(),
    );
    const g = ColouringRules.ground;
    if (water) {
      final surface = Path()..moveTo(-4, g - 4);
      for (var x = -4.0; x < 204; x += 26) {
        surface.quadraticBezierTo(x + 6.5, g - 9, x + 13, g - 4);
        surface.quadraticBezierTo(x + 19.5, g + 1, x + 26, g - 4);
      }
      surface
        ..lineTo(204, 254)
        ..lineTo(-4, 254)
        ..close();
      shape(surface);
      for (final (x, y) in const [(20.0, 230.0), (150.0, 236.0), (70.0, 242.0)]) {
        c.drawLine(Offset(x, y), Offset(x + 22, y), thin);
      }
    } else {
      shape(
        Path()
          ..moveTo(-4, g + 10)
          ..cubicTo(40, g - 6, 150, g - 6, 204, g + 8)
          ..lineTo(204, 254)
          ..lineTo(-4, 254)
          ..close(),
      );
      for (final (x, y) in const [(14.0, 236.0), (40.0, 244.0), (168.0, 234.0), (182.0, 246.0)]) {
        c.drawPath(
          Path()
            ..moveTo(x, y)
            ..lineTo(x + 3, y - 8)
            ..lineTo(x + 6, y)
            ..moveTo(x + 5, y)
            ..lineTo(x + 8, y - 6)
            ..lineTo(x + 11, y),
          thin,
        );
      }
    }
  }

  /// Works out the page's parts from [art] at the colour layer's size.
  static Future<RegionMap> regions(ui.Picture art) async {
    final w = ColouringRules.pixelWidth, h = ColouringRules.pixelHeight;
    final recorder = ui.PictureRecorder();
    Canvas(recorder)
      ..scale(ColouringRules.pixelScale)
      ..drawPicture(art);
    final image = await recorder.endRecording().toImage(w, h);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
    image.dispose();
    final isLine = Uint8List(w * h);
    for (var i = 0; i < isLine.length; i++) {
      final o = i * 4;
      final a = bytes[o + 3];
      // Premultiplied: dark and mostly opaque means ink.
      if (a > 128 && bytes[o] + bytes[o + 1] + bytes[o + 2] < a * 3 * 0.55) isLine[i] = 1;
    }
    return RegionMap.label(isLine, w, h);
  }

  /// The colour layer's pixels as an image to paint.
  static Future<ui.Image> image(Uint8List rgba) {
    final done = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      ColouringRules.pixelWidth,
      ColouringRules.pixelHeight,
      ui.PixelFormat.rgba8888,
      done.complete,
    );
    return done.future;
  }

  static Future<Uint8List> png(Uint8List rgba) async {
    final img = await image(rgba);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return data!.buffer.asUint8List();
  }

  /// A saved picture back to pixels; null if it can't be read.
  static Future<Uint8List?> pixelsOf(Uint8List png) async {
    try {
      final codec = await ui.instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      final img = frame.image;
      if (img.width != ColouringRules.pixelWidth || img.height != ColouringRules.pixelHeight) return null;
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      img.dispose();
      return data?.buffer.asUint8List();
    } on Object {
      return null;
    }
  }

  /// Draws [art] with only its ink showing (white turns see-through), so
  /// the colours underneath show inside the lines.
  static final inkOnly = Paint()
    ..colorFilter = ColorFilter.matrix([
      0, 0, 0, 0, Sticker.ink.r * 255, //
      0, 0, 0, 0, Sticker.ink.g * 255,
      0, 0, 0, 0, Sticker.ink.b * 255,
      -0.299, -0.587, -0.114, 1, 0,
    ]);
}

/// A colouring page: white paper, the child's colours, then the outline.
class ColouringPainter extends CustomPainter {
  const ColouringPainter({required this.art, this.colours, this.version = 0});

  final ui.Picture art;
  final ui.Image? colours;

  /// Changes whenever the colours do.
  final int version;

  /// Where the page sits in [size] (it keeps its shape).
  static Rect pageRect(Size size) {
    final s = math.min(size.width / ColouringArt.page.width, size.height / ColouringArt.page.height);
    final w = ColouringArt.page.width * s, h = ColouringArt.page.height * s;
    return Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = pageRect(size);
    canvas.drawRect(r, Paint()..color = Colors.white);
    final img = colours;
    if (img != null) {
      canvas.drawImageRect(
        img,
        Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
        r,
        Paint()..filterQuality = FilterQuality.medium,
      );
    }
    canvas
      ..save()
      ..translate(r.left, r.top)
      ..scale(r.width / ColouringArt.page.width)
      ..saveLayer(Offset.zero & ColouringArt.page, ColouringArt.inkOnly)
      ..drawPicture(art)
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(ColouringPainter old) => old.art != art || old.colours != colours || old.version != version;
}

/// A finished picture (saved as PNG [png]) for [plantId], e.g. in a frame.
class ColouringPicture extends StatefulWidget {
  const ColouringPicture({super.key, required this.plantId, required this.png});

  final String plantId;
  final Uint8List png;

  @override
  State<ColouringPicture> createState() => _ColouringPictureState();
}

class _ColouringPictureState extends State<ColouringPicture> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(ColouringPicture old) {
    super.didUpdateWidget(old);
    if (!identical(old.png, widget.png)) _decode();
  }

  Future<void> _decode() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.png);
      final img = (await codec.getNextFrame()).image;
      if (!mounted) return img.dispose();
      setState(() {
        _image?.dispose();
        _image = img;
      });
    } on Object {
      // An unreadable picture shows as an uncoloured page.
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: ColouringArt.page.width / ColouringArt.page.height,
    child: CustomPaint(
      painter: ColouringPainter(art: ColouringArt.of(widget.plantId), colours: _image),
    ),
  );
}
