import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'rewards.dart';

/// Colouring pages (PLAN.md §5l): the rules and the pixel work, kept free
/// of Flutter so they can be tested on their own.

abstract final class ColouringRules {
  /// Leaves for the first picture hung of each plant.
  static const leaves = 2;

  /// The page in design units; the plant stands on the ground at [ground].
  static const pageWidth = 200.0;
  static const pageHeight = 250.0;
  static const ground = 212.0;

  /// Pixels per design unit in the colour layer (360 × 450).
  static const pixelScale = 1.8;
  static final pixelWidth = (pageWidth * pixelScale).round();
  static final pixelHeight = (pageHeight * pixelScale).round();

  /// A part smaller than this share of the page is "small" (a petal, a
  /// leaf). A scribble that starts in a small part may cross into other
  /// small parts, so a bush can be coloured in one go; it never spills into
  /// a big part like the sky.
  static const smallShare = 0.02;

  /// The 12 colours, as 0xRRGGBB, with names for screen readers.
  static const colours = [
    0xFF5C7A, 0xFF9F43, 0xFFC93C, 0x4CC35A, 0x2E9142, 0x8B5A2B, //
    0x6EC6FF, 0x3B7DDD, 0x8E6CFF, 0xFF8FB1, 0x2B3148, 0xFFFFFF,
  ];
  static const names = [
    'Red', 'Orange', 'Yellow', 'Green', 'Dark green', 'Brown', //
    'Sky blue', 'Blue', 'Purple', 'Pink', 'Black', 'White',
  ];

  /// Colour packs from the shop (PLAN.md §5m): six more colours each.
  static const packs = <OutfitItem, List<(int, String)>>{
    OutfitItem.pastelColours: [
      (0xFFC4D0, 'Pastel pink'), (0xFFE0B3, 'Peach'), (0xFFF5B8, 'Cream yellow'), //
      (0xC9F0C0, 'Mint'), (0xC6E7FF, 'Baby blue'), (0xDCCBFF, 'Lilac'),
    ],
    OutfitItem.fiestaColours: [
      (0xE0006A, 'Magenta'), (0xFF6B00, 'Bright orange'), (0x00A86B, 'Jade'), //
      (0x0057B8, 'Royal blue'), (0xFFD400, 'Lemon'), (0x7A1FA2, 'Violet'),
    ],
    OutfitItem.earthColours: [
      (0x5C3A1E, 'Dark brown'), (0x8A5A2B, 'Wood'), (0xC08A4B, 'Tan'), //
      (0x6B8E23, 'Olive'), (0xA0522D, 'Clay'), (0xD2B48C, 'Sand'),
    ],
    OutfitItem.goldColours: [
      (0xD4AF37, 'Gold'), (0xF2D27A, 'Light gold'), (0xB0B7C3, 'Silver'), //
      (0xE3E7EE, 'Light silver'), (0xC98A4B, 'Bronze'), (0x9AA3B5, 'Grey'),
    ],
  };

  /// Every colour the child can use, given what they own.
  static List<(int, String)> palette(Set<OutfitItem> owned) => [
    for (var i = 0; i < colours.length; i++) (colours[i], names[i]),
    for (final MapEntry(key: pack, value: list) in packs.entries)
      if (owned.contains(pack)) ...list,
  ];
}

enum ColouringTool {
  crayon('Crayon'),
  paint('Paint'),
  fill('Fill'),
  eraser('Eraser');

  const ColouringTool(this.label);
  final String label;

  /// Brush radius in design units (fill has none).
  double get radius => switch (this) {
    crayon => 5,
    paint => 10,
    eraser => 11,
    fill => 0,
  };
}

/// Which part of the page each pixel belongs to, worked out from the
/// outline: every area closed in by lines is one part. Line pixels belong
/// to the part next to them, so colour reaches right up under the lines.
class RegionMap {
  RegionMap._(this.width, this.height, this.ids, this.sizes);

  final int width;
  final int height;

  /// Part of each pixel, or -1 (a line pixel with no part beside it).
  final Int32List ids;

  /// Pixels in each part.
  final List<int> sizes;

  int get count => sizes.length;

  /// [isLine] has one entry per pixel, row by row; non-zero means outline.
  factory RegionMap.label(Uint8List isLine, int width, int height) {
    final ids = Int32List(width * height)..fillRange(0, width * height, -1);
    final sizes = <int>[];
    final queue = Queue<int>();
    for (var start = 0; start < ids.length; start++) {
      if (isLine[start] != 0 || ids[start] != -1) continue;
      final id = sizes.length;
      var size = 0;
      ids[start] = id;
      queue.add(start);
      while (queue.isNotEmpty) {
        final i = queue.removeFirst();
        size++;
        final x = i % width;
        void visit(int j) {
          if (isLine[j] == 0 && ids[j] == -1) {
            ids[j] = id;
            queue.add(j);
          }
        }

        if (x > 0) visit(i - 1);
        if (x < width - 1) visit(i + 1);
        if (i >= width) visit(i - width);
        if (i < ids.length - width) visit(i + width);
      }
      sizes.add(size);
    }
    // Give line pixels to a neighbouring part, a few pixels deep.
    for (var pass = 0; pass < 3; pass++) {
      final before = Int32List.fromList(ids);
      for (var i = 0; i < ids.length; i++) {
        if (before[i] != -1) continue;
        final x = i % width;
        final n = [
          if (x > 0) before[i - 1],
          if (x < width - 1) before[i + 1],
          if (i >= width) before[i - width],
          if (i < ids.length - width) before[i + width],
        ].where((v) => v != -1);
        if (n.isNotEmpty) ids[i] = n.first;
      }
    }
    return RegionMap._(width, height, ids, sizes);
  }

  int at(int x, int y) => (x < 0 || y < 0 || x >= width || y >= height) ? -1 : ids[y * width + x];

  bool isSmall(int id) => sizes[id] < width * height * ColouringRules.smallShare;
}

/// The child's colours on one page: premultiplied RGBA pixels under the
/// outline. Points are in pixels of the layer.
class ColouringCanvas {
  ColouringCanvas(this.regions, {math.Random? random})
    : pixels = Uint8List(regions.width * regions.height * 4),
      _random = random ?? math.Random();

  final RegionMap regions;
  final Uint8List pixels;
  final math.Random _random;

  int get width => regions.width;
  int get height => regions.height;

  static const maxUndo = 10;
  final _undo = <Uint8List>[];
  bool get canUndo => _undo.isNotEmpty;

  /// Nothing coloured at all.
  bool get isEmpty {
    for (var i = 3; i < pixels.length; i += 4) {
      if (pixels[i] != 0) return false;
    }
    return true;
  }

  /// Bumped on every change, so a painter knows to repaint.
  int version = 0;

  ColouringTool? _tool;
  int _colour = 0;
  int _part = -1;
  double _x = 0;
  double _y = 0;

  /// For paint: the page before this stroke, and how strongly each pixel
  /// has been painted so far, so going back over a spot in one stroke
  /// doesn't darken it (a new stroke does).
  Uint8List? _base;
  Uint8List? _cover;

  void load(Uint8List rgba) {
    if (rgba.length == pixels.length) pixels.setAll(0, rgba);
    _undo.clear();
    version++;
  }

  void _remember() {
    _undo.add(Uint8List.fromList(pixels));
    if (_undo.length > maxUndo) _undo.removeAt(0);
  }

  void undo() {
    if (_undo.isEmpty) return;
    pixels.setAll(0, _undo.removeLast());
    version++;
  }

  void clear() {
    if (isEmpty) return;
    _remember();
    pixels.fillRange(0, pixels.length, 0);
    version++;
  }

  /// Fills the whole part under ([x], [y]). False on a line with no part.
  bool fill(double x, double y, int rgb) {
    final part = regions.at(x.floor(), y.floor());
    if (part < 0) return false;
    _remember();
    final ids = regions.ids;
    for (var i = 0; i < ids.length; i++) {
      if (ids[i] == part) _set(i, rgb, 255);
    }
    version++;
    return true;
  }

  /// Starts a crayon, paint or eraser stroke at ([x], [y]).
  void begin(ColouringTool tool, double x, double y, int rgb) {
    assert(tool != ColouringTool.fill);
    _remember();
    _tool = tool;
    _colour = rgb;
    _part = regions.at(x.floor(), y.floor());
    _x = x;
    _y = y;
    if (tool == ColouringTool.paint) {
      _base = Uint8List.fromList(pixels);
      _cover = Uint8List(regions.ids.length);
    }
    _stamp(x, y);
    version++;
  }

  void moveTo(double x, double y) {
    if (_tool == null) return;
    final d = math.sqrt((x - _x) * (x - _x) + (y - _y) * (y - _y));
    final step = _tool == ColouringTool.crayon ? 1.4 : 2.0;
    final n = math.max(1, (d / step).ceil());
    for (var s = 1; s <= n; s++) {
      _stamp(_x + (x - _x) * s / n, _y + (y - _y) * s / n);
    }
    _x = x;
    _y = y;
    version++;
  }

  void end() {
    _tool = null;
    _base = null;
    _cover = null;
  }

  bool _allowed(int i) {
    final id = regions.ids[i];
    if (id < 0 || _part < 0) return false;
    if (id == _part) return true;
    return regions.isSmall(_part) && regions.isSmall(id);
  }

  void _stamp(double cx, double cy) {
    final tool = _tool!;
    final r = tool.radius * ColouringRules.pixelScale;
    switch (tool) {
      case ColouringTool.crayon:
        // Waxy grain: scattered dots, some lighter than others.
        final dots = (r * 3).round();
        for (var k = 0; k < dots; k++) {
          final a = _random.nextDouble() * 2 * math.pi;
          final d = math.sqrt(_random.nextDouble()) * r;
          final x = (cx + math.cos(a) * d).floor();
          final y = (cy + math.sin(a) * d).floor();
          final alpha = 0.55 + _random.nextDouble() * 0.45;
          for (final (dx, dy) in const [(0, 0), (1, 0), (0, 1)]) {
            final px = x + dx, py = y + dy;
            if (px < 0 || py < 0 || px >= width || py >= height) continue;
            final i = py * width + px;
            if (_allowed(i)) _over(i, _colour, alpha);
          }
        }
      case ColouringTool.paint:
        _disc(cx, cy, r, (i, dist) {
          // Soft edge, see-through like watercolour.
          final edge = ((r - dist) / (r * 0.4)).clamp(0.0, 1.0);
          final cover = (edge * 255).round();
          if (cover <= _cover![i]) return;
          _cover![i] = cover;
          final base = _base!;
          final o = i * 4;
          pixels.setRange(o, o + 4, base, o);
          _over(i, _colour, cover / 255 * 0.55);
        });
      case ColouringTool.eraser:
        _disc(cx, cy, r, (i, _) => pixels.fillRange(i * 4, i * 4 + 4, 0));
      case ColouringTool.fill:
        break;
    }
  }

  void _disc(double cx, double cy, double r, void Function(int i, double dist) each) {
    final x0 = math.max(0, (cx - r).floor()), x1 = math.min(width - 1, (cx + r).ceil());
    final y0 = math.max(0, (cy - r).floor()), y1 = math.min(height - 1, (cy + r).ceil());
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final dist = math.sqrt((x + 0.5 - cx) * (x + 0.5 - cx) + (y + 0.5 - cy) * (y + 0.5 - cy));
        if (dist > r) continue;
        final i = y * width + x;
        if (_allowed(i)) each(i, dist);
      }
    }
  }

  void _set(int i, int rgb, int alpha) {
    final o = i * 4;
    pixels[o] = (rgb >> 16 & 0xFF) * alpha ~/ 255;
    pixels[o + 1] = (rgb >> 8 & 0xFF) * alpha ~/ 255;
    pixels[o + 2] = (rgb & 0xFF) * alpha ~/ 255;
    pixels[o + 3] = alpha;
  }

  /// Lays [rgb] at [alpha] over the pixel (premultiplied "source over").
  void _over(int i, int rgb, double alpha) {
    final o = i * 4;
    final keep = 1 - alpha;
    pixels[o] = ((rgb >> 16 & 0xFF) * alpha + pixels[o] * keep).round();
    pixels[o + 1] = ((rgb >> 8 & 0xFF) * alpha + pixels[o + 1] * keep).round();
    pixels[o + 2] = ((rgb & 0xFF) * alpha + pixels[o + 2] * keep).round();
    pixels[o + 3] = (255 * alpha + pixels[o + 3] * keep).round();
  }
}
