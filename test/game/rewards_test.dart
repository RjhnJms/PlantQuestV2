import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/binhi/binhi_outfit.dart';
import 'package:plantquest/game/rewards.dart';

void main() {
  test('the first six items cost about what the whole game pays', () {
    expect(OutfitItem.values.take(6).fold<int>(0, (sum, i) => sum + i.price), 280);
  });

  test('one item per slot: a new hat replaces the old one', () {
    final o = OutfitItem.crown.putOn(const BinhiOutfit(salakot: true, sunglasses: true));
    expect(o.hat, BinhiHat.crown);
    expect(o.salakot, isFalse);
    expect(o.sunglasses, isTrue, reason: 'other slots stay');
    expect(OutfitItem.goggles.putOn(o).glasses, BinhiGlasses.goggles);
    expect(OutfitItem.bee.putOn(o).friend, BinhiFriend.bee);
    expect(OutfitItem.beach.putOn(o).spot, BinhiSpot.beach);
    expect(OutfitItem.crown.takeOff(o).hat, isNull);
    expect(OutfitItem.strawHat.takeOff(o), o, reason: 'not wearing it');
  });

  test('colour packs are owned, never worn', () {
    expect(OutfitItem.pastelColours.wearable, isFalse);
    expect(OutfitItem.pastelColours.putOn(BinhiOutfit.none), BinhiOutfit.none);
    expect(Shop.wearable(const BinhiOutfit(salakot: true), {OutfitItem.pastelColours}), BinhiOutfit.none);
  });

  test('every shop group has items and every item has a home', () {
    for (final slot in OutfitSlot.values) {
      expect(OutfitItem.inSlot(slot), isNotEmpty, reason: slot.name);
    }
    for (final i in OutfitItem.values.where((i) => i.wearable)) {
      expect(i.wornIn(i.alone), isTrue, reason: i.name);
    }
  });

  test('only owned items can be worn', () {
    const everything = BinhiOutfit(salakot: true, garland: true, sunglasses: true, pattern: PotPattern.banig);
    expect(Shop.wearable(everything, {}), BinhiOutfit.none);
    expect(
      Shop.wearable(everything, {OutfitItem.salakot, OutfitItem.sunglasses, OutfitItem.dots}),
      const BinhiOutfit(salakot: true, sunglasses: true),
    );
    expect(
      Shop.wearable(const BinhiOutfit(pattern: PotPattern.dots), {OutfitItem.dots}),
      const BinhiOutfit(pattern: PotPattern.dots),
    );
  });

  test('putting on a pattern replaces the old one; taking off leaves the rest', () {
    const o = BinhiOutfit(salakot: true, pattern: PotPattern.stripes);
    expect(OutfitItem.dots.putOn(o), const BinhiOutfit(salakot: true, pattern: PotPattern.dots));
    expect(OutfitItem.salakot.takeOff(o), const BinhiOutfit(pattern: PotPattern.stripes));
    expect(OutfitItem.stripes.wornIn(o), isTrue);
    expect(OutfitItem.dots.wornIn(o), isFalse);
  });

  test('affordable: not owned and enough leaves', () {
    expect(Shop.affordable(19, {}), isEmpty);
    expect(Shop.affordable(20, {}), {OutfitItem.stripes});
    expect(Shop.affordable(25, {OutfitItem.stripes}), {OutfitItem.bandana, OutfitItem.earthColours});
  });
}
