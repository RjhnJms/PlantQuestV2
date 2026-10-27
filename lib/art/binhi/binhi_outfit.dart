import 'package:flutter/foundation.dart';

/// Patterns on Binhi's pot (kept below his face).
enum PotPattern {
  plain('Plain'),
  stripes('Stripes'),
  dots('Dots'),
  banig('Banig weave'),

  /// Earned by watering Binhi on 7 days (PLAN.md §5e).
  flowers('Flowers'),
  jeepney('Jeepney'),
  waves('Ocean waves'),
  picnic('Picnic'),
  pakwan('Pakwan'),
  rainbow('Rainbow'),
  capiz('Capiz');

  const PotPattern(this.label);
  final String label;
}

/// Hats, one at a time, perched on the pot rim.
enum BinhiHat { salakot, crown, strawHat, bandana, gradCap }

/// Glasses, one pair at a time.
enum BinhiGlasses { sunglasses, round, hearts, goggles }

/// Something around the rim, one at a time.
enum BinhiNeck { garland, bowTie, scarf }

/// A little friend that flies or sits near Binhi (PLAN.md §5m).
enum BinhiFriend { butterfly, ladybug, bee, bird }

/// The scene behind Binhi in his corner on Home and in the Shop.
enum BinhiSpot { meadow, beach, terraces, night, fiesta }

/// What Binhi is wearing (one thing per slot), and his spot.
///
/// The `salakot`, `garland` and `sunglasses` flags are the first three
/// items, kept as shortcuts.
@immutable
class BinhiOutfit {
  const BinhiOutfit({
    BinhiHat? hat,
    BinhiGlasses? glasses,
    BinhiNeck? neck,
    this.friend,
    this.pattern = PotPattern.plain,
    this.spot = BinhiSpot.meadow,
    bool salakot = false,
    bool garland = false,
    bool sunglasses = false,
  }) : hat = hat ?? (salakot ? BinhiHat.salakot : null),
       glasses = glasses ?? (sunglasses ? BinhiGlasses.sunglasses : null),
       neck = neck ?? (garland ? BinhiNeck.garland : null);

  static const none = BinhiOutfit();

  final BinhiHat? hat;
  final BinhiGlasses? glasses;
  final BinhiNeck? neck;
  final BinhiFriend? friend;
  final PotPattern pattern;
  final BinhiSpot spot;

  /// A woven farmer's hat perched on the pot rim.
  bool get salakot => hat == BinhiHat.salakot;

  /// A sampaguita garland draped over the rim.
  bool get garland => neck == BinhiNeck.garland;
  bool get sunglasses => glasses == BinhiGlasses.sunglasses;

  BinhiOutfit _with({
    Object? hat = _keep,
    Object? glasses = _keep,
    Object? neck = _keep,
    Object? friend = _keep,
    PotPattern? pattern,
    BinhiSpot? spot,
  }) => BinhiOutfit(
    hat: hat == _keep ? this.hat : hat as BinhiHat?,
    glasses: glasses == _keep ? this.glasses : glasses as BinhiGlasses?,
    neck: neck == _keep ? this.neck : neck as BinhiNeck?,
    friend: friend == _keep ? this.friend : friend as BinhiFriend?,
    pattern: pattern ?? this.pattern,
    spot: spot ?? this.spot,
  );

  static const _keep = Object();

  BinhiOutfit withHat(BinhiHat? hat) => _with(hat: hat);
  BinhiOutfit withGlasses(BinhiGlasses? glasses) => _with(glasses: glasses);
  BinhiOutfit withNeck(BinhiNeck? neck) => _with(neck: neck);
  BinhiOutfit withFriend(BinhiFriend? friend) => _with(friend: friend);
  BinhiOutfit withPattern(PotPattern pattern) => _with(pattern: pattern);
  BinhiOutfit withSpot(BinhiSpot spot) => _with(spot: spot);

  BinhiOutfit copyWith({bool? salakot, bool? garland, bool? sunglasses, PotPattern? pattern}) => _with(
    hat: salakot == null ? _keep : (salakot ? BinhiHat.salakot : (this.salakot ? null : hat)),
    neck: garland == null ? _keep : (garland ? BinhiNeck.garland : (this.garland ? null : neck)),
    glasses: sunglasses == null ? _keep : (sunglasses ? BinhiGlasses.sunglasses : (this.sunglasses ? null : glasses)),
    pattern: pattern,
  );

  @override
  bool operator ==(Object other) =>
      other is BinhiOutfit &&
      other.hat == hat &&
      other.glasses == glasses &&
      other.neck == neck &&
      other.friend == friend &&
      other.pattern == pattern &&
      other.spot == spot;

  @override
  int get hashCode => Object.hash(hat, glasses, neck, friend, pattern, spot);
}
