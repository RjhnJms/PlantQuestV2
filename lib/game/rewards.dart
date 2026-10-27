import '../art/binhi/binhi_outfit.dart';

/// Where a shop item goes. One item per slot is worn at a time, except
/// colour packs, which simply add colours once bought.
enum OutfitSlot { hat, glasses, neck, friend, pattern, spot, pack }

/// Things bought with leaves in the Shop tab (PLAN.md §5b, §5m). The first
/// six cost 280 together, about what the game pays; the rest (added later)
/// are extras to save up for. Names are saved in the purchases table, so
/// they must never change.
enum OutfitItem {
  stripes('Stripes pot', 20, OutfitSlot.pattern),
  dots('Dots pot', 30, OutfitSlot.pattern),
  sunglasses('Sunglasses', 40, OutfitSlot.glasses),
  salakot('Salakot hat', 50, OutfitSlot.hat),
  garland('Sampaguita garland', 60, OutfitSlot.neck),
  banig('Banig pot', 80, OutfitSlot.pattern),

  /// Not for sale: earned by watering Binhi on 7 days (PLAN.md §5e).
  flowers('Flower pot', 0, OutfitSlot.pattern),

  crown('Flower crown', 45, OutfitSlot.hat),
  strawHat('Straw hat', 40, OutfitSlot.hat),
  bandana('Bandana', 25, OutfitSlot.hat),
  gradCap('Graduation cap', 70, OutfitSlot.hat),

  roundGlasses('Round glasses', 35, OutfitSlot.glasses),
  heartGlasses('Heart glasses', 45, OutfitSlot.glasses),
  goggles('Explorer goggles', 55, OutfitSlot.glasses),

  bowTie('Bow tie', 30, OutfitSlot.neck),
  scarf('Scout scarf', 35, OutfitSlot.neck),

  butterfly('Butterfly friend', 50, OutfitSlot.friend),
  ladybug('Ladybug friend', 40, OutfitSlot.friend),
  bee('Bee friend', 45, OutfitSlot.friend),
  bird('Maya bird friend', 70, OutfitSlot.friend),

  jeepney('Jeepney pot', 60, OutfitSlot.pattern),
  waves('Ocean waves pot', 40, OutfitSlot.pattern),
  picnic('Picnic pot', 35, OutfitSlot.pattern),
  pakwan('Pakwan pot', 45, OutfitSlot.pattern),
  rainbow('Rainbow pot', 75, OutfitSlot.pattern),
  capiz('Capiz pot', 65, OutfitSlot.pattern),

  beach('Beach', 80, OutfitSlot.spot),
  terraces('Rice terraces', 100, OutfitSlot.spot),
  night('Moonlit night', 90, OutfitSlot.spot),
  fiesta('Fiesta', 70, OutfitSlot.spot),

  pastelColours('Pastel pack', 30, OutfitSlot.pack),
  fiestaColours('Fiesta pack', 30, OutfitSlot.pack),
  earthColours('Earth pack', 25, OutfitSlot.pack),
  goldColours('Gold & silver', 60, OutfitSlot.pack);

  const OutfitItem(this.label, this.price, this.slot);
  final String label;
  final int price;
  final OutfitSlot slot;

  bool get isPattern => slot == OutfitSlot.pattern;

  /// Worn or shown (everything but colour packs).
  bool get wearable => slot != OutfitSlot.pack;

  /// Earned, not bought.
  bool get forSale => this != flowers;

  static List<OutfitItem> inSlot(OutfitSlot slot) => [
    for (final i in values)
      if (i.slot == slot) i,
  ];

  PotPattern get pattern => PotPattern.values.byName(switch (this) {
    stripes || dots || banig || flowers || jeepney || waves || picnic || pakwan || rainbow || capiz => name,
    _ => 'plain',
  });

  BinhiHat? get _hat => switch (this) {
    salakot => BinhiHat.salakot,
    crown => BinhiHat.crown,
    strawHat => BinhiHat.strawHat,
    bandana => BinhiHat.bandana,
    gradCap => BinhiHat.gradCap,
    _ => null,
  };

  BinhiGlasses? get _glasses => switch (this) {
    sunglasses => BinhiGlasses.sunglasses,
    roundGlasses => BinhiGlasses.round,
    heartGlasses => BinhiGlasses.hearts,
    goggles => BinhiGlasses.goggles,
    _ => null,
  };

  BinhiNeck? get _neck => switch (this) {
    garland => BinhiNeck.garland,
    bowTie => BinhiNeck.bowTie,
    scarf => BinhiNeck.scarf,
    _ => null,
  };

  BinhiFriend? get _friend => switch (this) {
    butterfly => BinhiFriend.butterfly,
    ladybug => BinhiFriend.ladybug,
    bee => BinhiFriend.bee,
    bird => BinhiFriend.bird,
    _ => null,
  };

  BinhiSpot get _spot => switch (this) {
    beach => BinhiSpot.beach,
    terraces => BinhiSpot.terraces,
    night => BinhiSpot.night,
    fiesta => BinhiSpot.fiesta,
    _ => BinhiSpot.meadow,
  };

  /// Binhi wearing only this item (shop pictures).
  BinhiOutfit get alone => putOn(BinhiOutfit.none);

  bool wornIn(BinhiOutfit o) => switch (slot) {
    OutfitSlot.hat => o.hat == _hat,
    OutfitSlot.glasses => o.glasses == _glasses,
    OutfitSlot.neck => o.neck == _neck,
    OutfitSlot.friend => o.friend == _friend,
    OutfitSlot.pattern => o.pattern == pattern,
    OutfitSlot.spot => o.spot == _spot,
    OutfitSlot.pack => false,
  };

  /// [o] with this item put on (it replaces whatever was in its slot).
  BinhiOutfit putOn(BinhiOutfit o) => switch (slot) {
    OutfitSlot.hat => o.withHat(_hat),
    OutfitSlot.glasses => o.withGlasses(_glasses),
    OutfitSlot.neck => o.withNeck(_neck),
    OutfitSlot.friend => o.withFriend(_friend),
    OutfitSlot.pattern => o.withPattern(pattern),
    OutfitSlot.spot => o.withSpot(_spot),
    OutfitSlot.pack => o,
  };

  /// [o] with this item taken off.
  BinhiOutfit takeOff(BinhiOutfit o) {
    if (!wornIn(o)) return o;
    return switch (slot) {
      OutfitSlot.hat => o.withHat(null),
      OutfitSlot.glasses => o.withGlasses(null),
      OutfitSlot.neck => o.withNeck(null),
      OutfitSlot.friend => o.withFriend(null),
      OutfitSlot.pattern => o.withPattern(PotPattern.plain),
      OutfitSlot.spot => o.withSpot(BinhiSpot.meadow),
      OutfitSlot.pack => o,
    };
  }

  static OutfitItem? byName(String name) => values.asNameMap()[name];
}

abstract final class Shop {
  /// Only owned items show (after Start over, nothing is owned).
  static BinhiOutfit wearable(BinhiOutfit chosen, Set<OutfitItem> owned) {
    var o = BinhiOutfit.none;
    for (final i in owned) {
      if (i.wearable && i.wornIn(chosen)) o = i.putOn(o);
    }
    return o;
  }

  /// Items the child could buy right now.
  static Set<OutfitItem> affordable(int wallet, Set<OutfitItem> owned) => {
    for (final i in OutfitItem.values)
      if (i.forSale && !owned.contains(i) && i.price <= wallet) i,
  };
}
