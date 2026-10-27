import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/game/garden.dart';

void main() {
  test('every plant has a home, and pond and bed plants have their place', () {
    for (final p in PlantCatalog.all) {
      final home = GardenLayout.homeOf(p.id);
      switch (home) {
        case GardenHome.pond:
          expect(GardenLayout.pondPlants, contains(p.id));
        case GardenHome.bed:
          expect(GardenLayout.bedPlants, contains(p.id));
        case GardenHome.pot || GardenHome.ground:
          final start = GardenLayout.startOf(GardenLayout.plant(p.id));
          expect(start.y, greaterThan(0), reason: p.id);
      }
    }
    expect(GardenLayout.homeOf('gumamela'), GardenHome.pot);
    expect(GardenLayout.homeOf('palay'), GardenHome.bed);
    expect(GardenLayout.homeOf('kangkong'), GardenHome.pond);
    expect(GardenLayout.homeOf('narra'), GardenHome.ground);
  });

  test('every piece starts inside the garden', () {
    final pieces = [
      for (final p in PlantCatalog.all) GardenLayout.plant(p.id),
      GardenLayout.bed,
      for (final d in GardenDeco.values) GardenLayout.deco(d),
    ];
    for (final piece in pieces) {
      final s = GardenLayout.startOf(piece);
      expect(GardenLayout.clamp(piece, Offset(s.x, s.y)), Offset(s.x, s.y), reason: piece);
    }
  });

  test('moving clamps to the garden', () {
    final piece = GardenLayout.plant('gumamela');
    final out = GardenLayout.clamp(piece, const Offset(-100, 5));
    expect(out.dx, greaterThan(0));
    expect(out.dy, GardenLayout.top);
    expect(GardenLayout.clamp(piece, const Offset(999, 9999)).dy, GardenLayout.size.height);
  });

  test('decoration names round-trip and never clash with outfits', () {
    for (final d in GardenDeco.values) {
      expect(GardenDeco.byItem(d.item), d);
      expect(d.item, startsWith('garden_'));
    }
    expect(GardenDeco.byItem('salakot'), isNull);
    expect(GardenDeco.byItem('garden_unicorn'), isNull);
  });

  test('a piece dropped on another slides beside it instead of covering it', () {
    final gumamela = GardenLayout.plant('gumamela');
    final sampaguita = GardenLayout.plant('sampaguita');
    final s = GardenLayout.startOf(sampaguita);
    final other = GardenLayout.footprint(Offset(s.x, s.y), s.box, GardenLayout.heightOf(sampaguita));
    final at = GardenLayout.makeRoom(gumamela, Offset(s.x + 4, s.y), [other]);
    final mine = GardenLayout.footprint(at, GardenLayout.startOf(gumamela).box, GardenLayout.heightOf(gumamela));
    expect((mine.$1 - other.$1).distance, greaterThanOrEqualTo(mine.$2 + other.$2));
    expect(GardenLayout.clamp(gumamela, at), at, reason: 'still inside the garden');
    // Far from anything, it stays where it was dropped.
    expect(GardenLayout.makeRoom(gumamela, const Offset(180, 600), [other]), const Offset(180, 600));
  });
}
