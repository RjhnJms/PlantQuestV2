import 'dart:math' as math;

import 'dart:ui';

/// Where a plant grows in My Garden (PLAN.md §5d).
enum GardenHome {
  /// Flowers and ferns, in a clay pot.
  pot,

  /// Crops, side by side in the garden bed.
  bed,

  /// Trees and wild plants, straight in the ground.
  ground,

  /// Water plants, in the pond.
  pond,
}

/// Decorations bought with leaves. [name]s are stored in the purchases
/// table as `garden_<name>`: never rename one once released.
enum GardenDeco {
  bench('Bench', 20),
  fence('Fence', 25),
  butterfly('Butterfly', 15),
  palayok('Clay jar', 30),
  stones('Stepping stones', 10),
  birdbath('Bird bath', 20),
  lamp('Capiz lamp', 25),
  swing('Swing', 35),
  carabao('Carabao statue', 45);

  const GardenDeco(this.label, this.price);
  final String label;
  final int price;

  String get item => 'garden_$name';

  static GardenDeco? byItem(String item) =>
      item.startsWith('garden_') ? values.asNameMap()[item.substring('garden_'.length)] : null;
}

/// One thing standing in the garden: its feet at [x], [y] in the design
/// space ([GardenLayout.size]) and its square [box] size.
typedef GardenSpot = ({double x, double y, double box});

/// The garden's fixed plan, in a 360 × 1000 design space that the screen
/// scales to its width. Pieces are named `plant_<id>`, `bed` and
/// `deco_<name>`; the child can move them, and moves are saved by name.
abstract final class GardenLayout {
  static const size = Size(360, 1000);

  /// Nothing may stand on the hedge or in the sky.
  static const top = 200.0;

  static const bed = 'bed';
  static String plant(String id) => 'plant_$id';
  static String deco(GardenDeco d) => 'deco_${d.name}';

  /// Crops in the garden bed, left to right.
  static const bedPlants = ['palay', 'mongo'];

  static GardenHome homeOf(String plantId) => switch (plantId) {
    'sampaguita' || 'gumamela' || 'pako' => GardenHome.pot,
    'palay' || 'mongo' => GardenHome.bed,
    'kangkong' || 'bakawan' => GardenHome.pond,
    _ => GardenHome.ground,
  };

  /// The pond stays put; its plants grow inside it.
  static const pond = Rect.fromLTWH(206, 440, 150, 150);

  /// The bahay kubo's walls and roof (a tap goes inside), and the spot on
  /// its wall where the newest picture hangs (PLAN.md §5l).
  static const kubo = Rect.fromLTRB(14, 70, 202, 176);
  static const kuboFrame = Rect.fromLTWH(39, 134, 26, 30);
  static const pondPlants = <String, GardenSpot>{
    'kangkong': (x: 259, y: 556, box: 60),
    'bakawan': (x: 320, y: 550, box: 62),
  };

  /// Binhi lives on the path.
  static const binhi = (x: 173.0, y: 496.0, box: 88.0);

  static const _start = <String, GardenSpot>{
    'plant_gumamela': (x: 45, y: 307, box: 92),
    'plant_sampaguita': (x: 216, y: 277, box: 84),
    'plant_pako': (x: 318, y: 660, box: 78),
    'bed': (x: 262, y: 389, box: 166),
    'plant_makahiya': (x: 72, y: 437, box: 96),
    'plant_kalamansi': (x: 58, y: 572, box: 120),
    'plant_malunggay': (x: 62, y: 712, box: 116),
    'plant_mango': (x: 290, y: 890, box: 130),
    'plant_kawayan': (x: 140, y: 900, box: 110),
    'plant_saba': (x: 55, y: 995, box: 110),
    'plant_narra': (x: 190, y: 1000, box: 120),
    'plant_niyog': (x: 300, y: 1000, box: 130),
    'deco_bench': (x: 288, y: 222, box: 104),
    'deco_fence': (x: 120, y: 640, box: 90),
    'deco_butterfly': (x: 150, y: 400, box: 34),
    'deco_palayok': (x: 200, y: 600, box: 60),
    'deco_stones': (x: 125, y: 548, box: 70),
    'deco_birdbath': (x: 28, y: 392, box: 60),
    'deco_lamp': (x: 172, y: 366, box: 76),
    'deco_swing': (x: 205, y: 780, box: 106),
    'deco_carabao': (x: 300, y: 762, box: 92),
  };

  /// Where [piece] starts before the child moves it.
  static GardenSpot startOf(String piece) => _start[piece] ?? (x: size.width / 2, y: 600, box: 100);

  /// The garden bed is wider than tall; everything else is square.
  static double heightOf(String piece) => piece == bed ? 104 : startOf(piece).box;

  /// The round patch of ground a piece takes up: (centre, radius), from
  /// its feet and its box (PLAN.md §5d: pieces don't overlap).
  static (Offset, double) footprint(Offset feet, double box, double height) =>
      (feet - Offset(0, height * 0.35), math.min(box, height) * 0.38);

  /// Where a dropped piece ends up so it doesn't cover anything: it slides
  /// out of the way of the [others] (their footprints) just far enough,
  /// staying inside the garden. With no room nearby it stays close.
  static Offset makeRoom(String piece, Offset feet, Iterable<(Offset, double)> others) {
    final box = startOf(piece).box;
    final height = heightOf(piece);
    var at = clamp(piece, feet);
    for (var round = 0; round < 12; round++) {
      var moved = false;
      for (final (centre, r) in others) {
        final (mine, myR) = footprint(at, box, height);
        final gap = mine - centre;
        final need = myR + r - gap.distance;
        if (need <= 0.5) continue;
        final away = gap.distance < 0.01 ? const Offset(1, 0) : gap / gap.distance;
        at = clamp(piece, at + away * (need + 1));
        moved = true;
      }
      if (!moved) break;
    }
    return at;
  }

  /// Keeps a moved piece inside the garden (a little may hang off the
  /// sides, the way trees do).
  static Offset clamp(String piece, Offset feet) {
    final box = startOf(piece).box;
    return Offset(feet.dx.clamp(box * 0.35, size.width - box * 0.35), feet.dy.clamp(top, size.height));
  }
}
