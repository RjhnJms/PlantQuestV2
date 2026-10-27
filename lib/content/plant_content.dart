// DRAFT — for teacher review.
//
// Words kids read (and hear) about each plant. Rules from PLAN.md §2:
// short Grade 3 sentences, no emojis. Every plant is marked
// `reviewed: false` until a teacher checks it.

import '../art/plants/plant_drawing.dart';

class PlantContent {
  const PlantContent({
    required this.shortLine,
    required this.description,
    required this.parts,
    required this.funFact,
    this.reviewed = false,
  });

  /// One line for the Plants list card.
  final String shortLine;

  /// Two sentences at the top of Plant details.
  final String description;

  /// One sentence per tappable part.
  final Map<PlantPart, String> parts;

  final String funFact;
  final bool reviewed;

  static PlantContent of(String plantId) => _all[plantId]!;

  static bool has(String plantId) => _all.containsKey(plantId);

  static const _all = <String, PlantContent>{
    'sampaguita': PlantContent(
      shortLine: 'Our national flower. It smells sweet.',
      description: 'Sampaguita is the national flower of the Philippines. Its small white flowers smell very sweet.',
      parts: {
        PlantPart.root: 'Roots hold the plant in the soil and drink water.',
        PlantPart.stem: 'Thin stems carry water up to the leaves and flowers.',
        PlantPart.leaf: 'Its shiny green leaves make food from sunlight.',
        PlantPart.special: 'People string the white flowers into garlands.',
      },
      funFact: 'Sampaguita flowers open in the evening. That is when their smell is strongest.',
    ),
    'gumamela': PlantContent(
      shortLine: 'Big, bright flowers that bees love.',
      description: 'Gumamela is a shrub with big, colorful flowers. Bees and butterflies love to visit it.',
      parts: {
        PlantPart.root: 'Roots hold the shrub firmly in the ground.',
        PlantPart.stem: 'Its woody stem is strong and holds up the branches.',
        PlantPart.leaf: 'Its wide leaves are green and a little shiny.',
        PlantPart.special: 'The big flower has a long tube in the middle with yellow pollen.',
      },
      funFact: 'Kids crush gumamela leaves and flowers in water to make bubbles.',
    ),
    'makahiya': PlantContent(
      shortLine: 'It folds its leaves when you touch it!',
      description: 'Makahiya means "shy." Its leaves close up when you touch them.',
      parts: {
        PlantPart.root: 'Its roots hold the plant as it spreads on the ground.',
        PlantPart.stem: 'Its thin stems have tiny prickles. Be gentle!',
        PlantPart.leaf: 'Each leaf has many tiny leaflets that fold up when touched.',
        PlantPart.special: 'Its flowers look like soft pink balls.',
      },
      funFact: 'After a few minutes, the shy leaves open up again.',
    ),
    'kalamansi': PlantContent(
      shortLine: 'A tiny sour fruit for juice.',
      description: 'Kalamansi is a small tree with little round fruits. The juice is sour and full of vitamin C.',
      parts: {
        PlantPart.root: 'Roots hold the tree and pull up water from the soil.',
        PlantPart.stem: 'Its trunk and branches are woody and hold up the leaves.',
        PlantPart.leaf: 'Its leaves smell like citrus when you rub them.',
        PlantPart.special: 'Its small fruits turn from green to orange when ripe.',
      },
      funFact: 'People squeeze kalamansi on pancit and mix it into juice.',
    ),
    'malunggay': PlantContent(
      shortLine: 'Tiny leaves, full of vitamins.',
      description: 'Malunggay is a fast-growing tree with tiny round leaves. Its leaves go into soups like tinola.',
      parts: {
        PlantPart.root: 'Its thick root holds the tree and stores water.',
        PlantPart.stem: 'Its trunk is soft and grows very fast.',
        PlantPart.leaf: 'Each branch holds many tiny round leaflets.',
        PlantPart.special: 'Its long green pods look like drumsticks.',
      },
      funFact: 'A new malunggay tree can grow from a cut branch.',
    ),
    'palay': PlantContent(
      shortLine: 'The plant that gives us rice.',
      description: 'Palay is the rice plant. Farmers grow it in wet fields called paddies.',
      parts: {
        PlantPart.root: 'Many thin roots hold the plant in the muddy field.',
        PlantPart.stem: 'Its hollow stems hold up the heavy grains.',
        PlantPart.leaf: 'Its long thin leaves look like blades of grass.',
        PlantPart.special: 'Each grain is a rice seed. We cook it to make kanin.',
      },
      funFact: 'Long ago, people carved the Banaue Rice Terraces into mountains by hand.',
    ),
    'mango': PlantContent(
      shortLine: 'Sweet yellow fruit of summer.',
      description: 'The mango tree is big and gives cool shade. Its fruit is sweet and yellow when ripe.',
      parts: {
        PlantPart.root: 'Its deep main root holds up the big tree.',
        PlantPart.stem: 'Its thick trunk is strong and woody.',
        PlantPart.leaf: 'Its young leaves are red or brown. They turn green as they grow.',
        PlantPart.special: 'The mango fruit turns from green to yellow when it ripens.',
      },
      funFact: 'The Philippine carabao mango is one of the sweetest mangoes in the world.',
    ),
    'saba': PlantContent(
      shortLine: 'A banana for turon and banana cue.',
      description: 'Saba is a kind of banana. People cook it to make turon and banana cue.',
      parts: {
        PlantPart.root: 'Its roots grow from a big round base under the ground.',
        PlantPart.stem: 'Its "trunk" is really rolled-up leaves, not wood.',
        PlantPart.leaf: 'Its huge leaves are used to wrap food.',
        PlantPart.special: 'Its bananas grow in a big bunch with a purple heart at the end.',
      },
      funFact: 'The purple banana heart is called puso. It can be cooked too.',
    ),
    'mongo': PlantContent(
      shortLine: 'Small beans for ginisang monggo.',
      description: 'Mongo is a small bean plant. Its little green seeds are cooked into ginisang monggo.',
      parts: {
        PlantPart.root: 'Its roots have little bumps that help feed the soil.',
        PlantPart.stem: 'Its soft stem holds up the leaves and pods.',
        PlantPart.leaf: 'Its leaves grow in groups of three.',
        PlantPart.special: 'Its thin pods hold the small green seeds.',
      },
      funFact: 'Mongo seeds can sprout into togue in just a few days.',
    ),
    'niyog': PlantContent(
      shortLine: 'The coconut palm, the tree of life.',
      description: 'Niyog is the coconut palm. People use almost every part of it.',
      parts: {
        PlantPart.root: 'Many thin roots spread out to hold the tall palm.',
        PlantPart.stem: 'Its tall trunk has rings and no branches.',
        PlantPart.leaf: 'Its long leaves look like giant feathers.',
        PlantPart.special: 'A coconut has water inside and white meat to eat.',
      },
      funFact: 'Coconuts can float on the sea to faraway islands.',
    ),
    'narra': PlantContent(
      shortLine: 'Our national tree.',
      description: 'Narra is the national tree of the Philippines. Its wood is strong and beautiful.',
      parts: {
        PlantPart.root: 'Big roots spread wide to hold up the huge tree.',
        PlantPart.stem: 'Its thick trunk gives hard, reddish wood.',
        PlantPart.leaf: 'Its many leaves give lots of cool shade.',
        PlantPart.special: 'Its small yellow flowers smell sweet.',
      },
      funFact: 'Narra flowers fall all at once, so the ground turns yellow like gold.',
    ),
    'kawayan': PlantContent(
      shortLine: 'A giant grass that grows fast.',
      description: 'Kawayan is bamboo. It is a giant grass that grows very fast.',
      parts: {
        PlantPart.root: 'Its roots grow from stems that spread under the ground.',
        PlantPart.stem: 'Its tall hollow poles have rings called nodes.',
        PlantPart.leaf: 'Its thin leaves grow in fans on small branches.',
        PlantPart.special: 'Young shoots, called labong, can be cooked and eaten.',
      },
      funFact: 'Some kinds of bamboo can grow almost one meter in one day!',
    ),
    'pako': PlantContent(
      shortLine: 'A fern you can eat.',
      description: 'Pako is a fern that grows in wet, shady places. Its young leaves are made into salad.',
      parts: {
        PlantPart.root: 'Its thin, dark roots hold it in damp soil.',
        PlantPart.stem: 'Its stalks hold up the long leaves.',
        PlantPart.leaf: 'Its big leaves are called fronds.',
        PlantPart.special: 'Ferns have no flowers or seeds. Tiny spores under the leaves grow new ferns.',
      },
      funFact: 'Young pako leaves are curled up like a snail. They unroll as they grow.',
    ),
    'bakawan': PlantContent(
      shortLine: 'A tree that grows in the sea.',
      description: 'Bakawan is a mangrove tree. It grows in salty water near the shore.',
      parts: {
        PlantPart.root: 'Its stilt roots stand in the water and hold the tree up.',
        PlantPart.stem: 'Its trunk stands above the water on its roots.',
        PlantPart.leaf: 'Its thick leaves can live with salty water.',
        PlantPart.special: 'Its long seedlings grow on the tree, then drop into the mud.',
      },
      funFact: 'Mangroves protect the shore from big waves. They are homes for fish too.',
    ),
    'kangkong': PlantContent(
      shortLine: 'A vegetable that grows on water.',
      description: 'Kangkong grows in water or wet soil. Its leaves and stems are cooked as a vegetable.',
      parts: {
        PlantPart.root: 'Its roots grow from the stem and hang in the water.',
        PlantPart.stem: 'Its stems are hollow, so they can float!',
        PlantPart.leaf: 'Its leaves are shaped like arrowheads.',
        PlantPart.special: 'Its flowers are shaped like little trumpets.',
      },
      funFact: 'Kangkong grows back after you cut it.',
    ),
  };
}

/// The three worlds.
class WorldInfo {
  const WorldInfo(this.number, this.name, this.subtitle);

  final int number;
  final String name;

  /// English meaning, e.g. "Backyard".
  final String subtitle;

  static const all = [
    WorldInfo(1, 'Bakuran', 'Backyard'),
    WorldInfo(2, 'Bukid', 'Farm'),
    WorldInfo(3, 'Kalikasan', 'Nature'),
  ];

  static WorldInfo of(int number) => all[number - 1];
}
