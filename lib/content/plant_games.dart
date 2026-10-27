// DRAFT — for teacher review.
//
// Words for the mini-games (PLAN.md §6b). Short Grade 3 sentences, like
// plant_content.dart. Label it uses each plant's part sentences from there.

import '../art/icons/kid_icon.dart';

/// How a plant usually starts, for Grow it. Not every plant grows from a
/// seed: saba and kawayan come up as shoots, pako from spores, and bakawan
/// from a seedling pod that grows on the tree.
enum StartKind {
  seed(['Seed', 'Sprout', 'Young plant', 'Grown plant']),
  coconut(['Coconut', 'Sprout', 'Young palm', 'Grown tree']),
  cutting(['Cutting', 'New roots', 'Young plant', 'Grown plant']),
  babyShoot(['Baby shoot', 'Bigger shoot', 'Young plant', 'Grown plant']),
  bambooShoot(['Bamboo shoot', 'Tall shoot', 'Young bamboo', 'Grown bamboo']),
  spores(['Spores', 'Tiny fern', 'Young fern', 'Grown fern']),
  seedlingPod(['Seedling pod', 'Pod in the mud', 'Young tree', 'Grown tree']);

  const StartKind(this.labels);

  /// The four picture names, first to last.
  final List<String> labels;
}

/// What a plant is known for, for Match it.
class PlantUse {
  const PlantUse(this.label, this.icon, this.fact);

  final String label;
  final KidIcon icon;

  /// Shown (and read) after a right match.
  final String fact;
}

class PlantGameContent {
  const PlantGameContent({required this.start, required this.grownFact, required this.use, this.reviewed = false});

  final StartKind start;

  /// The last Grow it sentence: how the grown plant makes new plants.
  final String grownFact;
  final PlantUse use;
  final bool reviewed;

  /// The four Grow it sentences, first to last.
  List<String> growFacts(String name) => [
    switch (start) {
      StartKind.seed => 'A $name seed rests in the soil.',
      StartKind.coconut => 'A coconut is a giant seed. It lies on the ground.',
      StartKind.cutting => 'People plant a piece of stem, called a cutting.',
      StartKind.babyShoot => 'A baby shoot grows at the base of a big banana plant.',
      StartKind.bambooShoot => 'A bamboo shoot pokes up from an underground stem.',
      StartKind.spores => 'Ferns start from spores. They are as tiny as dust!',
      StartKind.seedlingPod => 'A long seedling pod drops from the tree into the mud.',
    },
    switch (start) {
      StartKind.seed => 'It drinks water, and a tiny shoot pops out.',
      StartKind.coconut => 'A green shoot grows out of the coconut.',
      StartKind.cutting => 'The cutting grows new roots in the soil.',
      StartKind.babyShoot => 'It grows taller and gets its own roots.',
      StartKind.bambooShoot => 'It grows very fast, taller every day!',
      StartKind.spores => 'A spore grows into a tiny new fern.',
      StartKind.seedlingPod => 'The pod sticks in the mud and grows roots.',
    },
    'Leaves grow and catch the sunlight.',
    grownFact,
  ];

  static PlantGameContent of(String plantId) => _all[plantId]!;

  static bool has(String plantId) => _all.containsKey(plantId);

  static const _all = <String, PlantGameContent>{
    'sampaguita': PlantGameContent(
      start: StartKind.cutting,
      grownFact: 'It blooms with sweet white flowers.',
      use: PlantUse('Flower garlands', KidIcon.garland, 'Sampaguita flowers are strung into sweet garlands.'),
    ),
    'gumamela': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'Its big flowers can make new seeds.',
      use: PlantUse('Bubble fun', KidIcon.bubbles, 'Kids crush gumamela leaves and flowers in water to make bubbles.'),
    ),
    'makahiya': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'Its pink, fluffy flowers turn into seed pods.',
      use: PlantUse('Shy leaves', KidIcon.hand, 'Makahiya leaves fold up when you touch them.'),
    ),
    'kalamansi': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'It grows little round fruits with seeds inside.',
      use: PlantUse('Juice and sawsawan', KidIcon.drink, 'Kalamansi juice goes into drinks and dipping sauces.'),
    ),
    'malunggay': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'It grows long pods full of seeds.',
      use: PlantUse('In soup', KidIcon.soup, 'Malunggay leaves go into tinola and other soups.'),
    ),
    'palay': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'It makes grains. Each grain is a seed, and we eat it as rice!',
      use: PlantUse('Rice we eat', KidIcon.rice, 'Palay grains become the rice on our plates.'),
    ),
    'mango': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'It grows sweet mangoes. Each one has a big seed inside.',
      use: PlantUse('Sweet ripe fruit', KidIcon.mango, 'Ripe mangoes are sweet and yellow. Yum!'),
    ),
    'saba': PlantGameContent(
      start: StartKind.babyShoot,
      grownFact: 'It grows bananas, and new baby shoots come up beside it.',
      use: PlantUse('Turon snack', KidIcon.turon, 'Saba is cooked into turon and banana cue.'),
    ),
    'mongo': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'It makes pods full of new seeds!',
      use: PlantUse('Ginisang monggo', KidIcon.pot, 'Mongo beans are cooked into ginisang monggo.'),
    ),
    'niyog': PlantGameContent(
      start: StartKind.coconut,
      grownFact: 'It grows new coconuts high up near its leaves.',
      use: PlantUse('Coconut water', KidIcon.drop, 'Young coconuts have sweet water you can drink.'),
    ),
    'narra': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'Its yellow flowers turn into round, flat seed pods.',
      use: PlantUse('National tree', KidIcon.tree, 'Narra is our national tree. Its wood makes strong furniture.'),
    ),
    'kawayan': PlantGameContent(
      start: StartKind.bambooShoot,
      grownFact: 'New shoots keep coming up from its underground stems.',
      use: PlantUse('For houses', KidIcon.home, 'Kawayan is used to build houses like the bahay kubo.'),
    ),
    'pako': PlantGameContent(
      start: StartKind.spores,
      grownFact: 'Under its leaves, it makes new spores.',
      use: PlantUse('Pako salad', KidIcon.salad, 'Young pako leaves are eaten in a fresh salad.'),
    ),
    'bakawan': PlantGameContent(
      start: StartKind.seedlingPod,
      grownFact: 'New seedling pods grow while they are still on the tree.',
      use: PlantUse('Guards the coast', KidIcon.waves, 'Bakawan roots hold the mud and slow down big waves.'),
    ),
    'kangkong': PlantGameContent(
      start: StartKind.seed,
      grownFact: 'Its flowers make seeds, and its stems can grow new roots.',
      use: PlantUse(
        'Adobong kangkong',
        KidIcon.plate,
        'Kangkong grows in wet places and is cooked as adobong kangkong.',
      ),
    ),
  };
}
