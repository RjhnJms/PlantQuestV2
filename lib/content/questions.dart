// DRAFT — for teacher review.
//
// Quiz questions (PLAN.md §6). Each plant has three hand-written fact
// questions (one for its plant quiz, one for Sprout, one for Sapling); the
// rest are built from the plant text so they always match it:
//
// - Plant quiz (3):  picture choice · fact · tap the special part
// - Sprout (3/plant): picture choice · fact · tap a part
// - Sapling (3/plant): fact · tap the special part · "what does it do?"
//
// That is 45 questions per level. Ids are stored with answers: never
// rename one.

import '../art/plants/plant_drawing.dart';
import '../game/rules.dart';
import 'plant_catalog.dart';
import 'plant_content.dart';

enum QuestionType { multipleChoice, pictureChoice, tapPart }

class QuizOption {
  const QuizOption(this.id, this.label, {this.plantId});

  final String id;
  final String label;

  /// For picture choices: the plant to draw.
  final String? plantId;
}

class Question {
  const Question({
    required this.id,
    required this.plantId,
    required this.type,
    required this.prompt,
    required this.correctId,
    required this.reason,
    this.options = const [],
    this.part,
  });

  final String id;

  /// The plant this question is about (level quizzes only ask about
  /// unlocked plants).
  final String plantId;
  final QuestionType type;
  final String prompt;

  /// Empty for tap-the-part questions.
  final List<QuizOption> options;

  /// An option id, or a [PlantPart] name for tap-the-part.
  final String correctId;

  /// One sentence shown after every answer.
  final String reason;

  /// For tap-the-part: the part to find.
  final PlantPart? part;

  bool isCorrect(String answerId) => answerId == correctId;

  /// What "Answer: …" shows after a wrong try.
  String get correctLabel {
    if (type == QuestionType.tapPart) return partLabel(part!, plantId);
    return options.firstWhere((o) => o.id == correctId).label;
  }

  static String partLabel(PlantPart part, String plantId) => switch (part) {
    PlantPart.root => 'Root',
    PlantPart.stem => 'Stem',
    PlantPart.leaf => 'Leaf',
    PlantPart.special => PlantCatalog.byId(plantId).special.label,
  };
}

/// A hand-written fact: [answers] lists the right answer first.
class _Fact {
  const _Fact(this.prompt, this.answers, this.reason);
  final String prompt;
  final List<String> answers;
  final String reason;
}

/// Three facts per plant: plant quiz, Sprout, Sapling.
const _facts = <String, List<_Fact>>{
  'sampaguita': [
    _Fact('What color are sampaguita flowers?', [
      'White',
      'Red',
      'Yellow',
      'Blue',
    ], 'Sampaguita flowers are small and white.'),
    _Fact('Sampaguita is the national ___ of the Philippines.', [
      'flower',
      'tree',
      'fruit',
      'leaf',
    ], 'Sampaguita is our national flower.'),
    _Fact('When is the smell of sampaguita flowers strongest?', [
      'In the evening',
      'At noon',
      'Early in the morning',
      'Only when it rains',
    ], 'Sampaguita flowers open in the evening, so their smell is strongest then.'),
  ],
  'gumamela': [
    _Fact('What are gumamela flowers like?', [
      'Big and colorful',
      'Tiny and white',
      'Hidden under the ground',
      'Always blue',
    ], 'Gumamela has big, colorful flowers.'),
    _Fact('What can kids make with gumamela leaves and flowers?', [
      'Bubbles',
      'Bread',
      'Paper',
      'Rope',
    ], 'Kids crush gumamela in water to make bubbles.'),
    _Fact('What is on the long tube in the middle of a gumamela flower?', [
      'Yellow pollen',
      'Tiny leaves',
      'Roots',
      'Thorns',
    ], 'The long tube in the middle has yellow pollen.'),
  ],
  'makahiya': [
    _Fact('What does makahiya do when you touch its leaves?', [
      'The leaves fold up',
      'The leaves turn red',
      'The leaves fall off',
      'The leaves grow bigger',
    ], 'Makahiya leaves close up when you touch them.'),
    _Fact('What does the word "makahiya" mean?', [
      'Shy',
      'Brave',
      'Sleepy',
      'Hungry',
    ], 'Makahiya means shy, because its leaves close up.'),
    _Fact('What happens to makahiya leaves a few minutes after you touch them?', [
      'They open up again',
      'They dry up',
      'They turn into flowers',
      'They stay closed forever',
    ], 'After a few minutes, makahiya leaves open up again.'),
  ],
  'kalamansi': [
    _Fact('How does kalamansi juice taste?', ['Sour', 'Salty', 'Bitter', 'Spicy'], 'Kalamansi juice is sour.'),
    _Fact('What color is a ripe kalamansi fruit?', [
      'Orange',
      'Purple',
      'Blue',
      'White',
    ], 'Kalamansi fruits turn from green to orange when ripe.'),
    _Fact('Kalamansi juice is full of which vitamin?', [
      'Vitamin C',
      'Vitamin D',
      'Vitamin K',
      'Vitamin B12',
    ], 'Kalamansi juice is full of vitamin C.'),
  ],
  'malunggay': [
    _Fact('What are malunggay leaves like?', [
      'Tiny and round',
      'Huge and flat',
      'Long like grass',
      'Red and spiky',
    ], 'Malunggay has many tiny round leaves.'),
    _Fact('Which dish often has malunggay leaves?', [
      'Tinola',
      'Halo-halo',
      'Leche flan',
      'Taho',
    ], 'Malunggay leaves are often added to tinola.'),
    _Fact('How can you grow a new malunggay tree?', [
      'Plant a cut branch',
      'Plant one leaf in water',
      'Plant a flower',
      'Plant a stone',
    ], 'A new malunggay tree can grow from a cut branch.'),
  ],
  'palay': [
    _Fact('What food do we get from palay?', [
      'Rice',
      'Bread',
      'Mango',
      'Peanuts',
    ], 'Palay is the rice plant. We cook its grains to make kanin.'),
    _Fact('Where do farmers grow palay?', [
      'In wet fields called paddies',
      'On beach sand',
      'Inside caves',
      'On tree branches',
    ], 'Farmers grow palay in wet fields called paddies.'),
    _Fact('What is each grain of palay?', [
      'A rice seed',
      'A rice flower',
      'A tiny leaf',
      'A root',
    ], 'Each grain of palay is a rice seed.'),
  ],
  'mango': [
    _Fact('What color is a ripe mango?', [
      'Yellow',
      'Blue',
      'Black',
      'White',
    ], 'Mangoes turn from green to yellow when they ripen.'),
    _Fact('What does a big mango tree give us on a hot day?', [
      'Cool shade',
      'Snow',
      'Rain',
      'Wind',
    ], 'The big mango tree gives cool shade.'),
    _Fact('What color are young mango leaves?', [
      'Red or brown',
      'Blue',
      'White',
      'Pink with dots',
    ], 'Young mango leaves are red or brown. They turn green as they grow.'),
  ],
  'saba': [
    _Fact('What is saba?', [
      'A kind of banana',
      'A kind of rice',
      'A kind of fish',
      'A kind of flower',
    ], 'Saba is a kind of banana.'),
    _Fact('Which snack is made with saba?', [
      'Turon',
      'Pandesal',
      'Taho',
      'Polvoron',
    ], 'Saba is cooked to make turon and banana cue.'),
    _Fact('What is the "trunk" of a saba plant made of?', [
      'Rolled-up leaves',
      'Hard wood',
      'Stones',
      'Roots',
    ], 'The trunk of a saba plant is really rolled-up leaves, not wood.'),
  ],
  'mongo': [
    _Fact('Which dish is made with mongo seeds?', [
      'Ginisang monggo',
      'Leche flan',
      'Pandesal',
      'Lumpiang shanghai',
    ], 'Mongo seeds are cooked into ginisang monggo.'),
    _Fact('Where are mongo seeds found?', [
      'Inside thin pods',
      'Inside big flowers',
      'Under the leaves',
      'Inside the roots',
    ], 'Thin mongo pods hold the small green seeds.'),
    _Fact('What do the little bumps on mongo roots do?', [
      'Help feed the soil',
      'Store rainwater',
      'Make flowers',
      'Scare away birds',
    ], 'The little bumps on mongo roots help feed the soil.'),
  ],
  'niyog': [
    _Fact('What fruit does niyog give us?', ['Coconut', 'Mango', 'Banana', 'Kalamansi'], 'Niyog is the coconut palm.'),
    _Fact('What is inside a coconut?', [
      'Water and white meat',
      'Rice grains',
      'Sand',
      'Honey',
    ], 'A coconut has water inside and white meat to eat.'),
    _Fact('How can coconuts reach faraway islands?', [
      'By floating on the sea',
      'By flying with birds',
      'By rolling on the ground',
      'By growing wings',
    ], 'Coconuts can float on the sea to faraway islands.'),
  ],
  'narra': [
    _Fact('Narra is the national ___ of the Philippines.', [
      'tree',
      'flower',
      'fruit',
      'grass',
    ], 'Narra is our national tree.'),
    _Fact('What color are narra flowers?', ['Yellow', 'Blue', 'Black', 'Purple'], 'Narra has small yellow flowers.'),
    _Fact('Why is narra wood special?', [
      'It is strong and beautiful',
      'It is soft like cotton',
      'It melts in the sun',
      'It blows away in the wind',
    ], 'Narra wood is strong and beautiful.'),
  ],
  'kawayan': [
    _Fact('What is kawayan?', ['Bamboo', 'A kind of rice', 'A kind of banana', 'A fern'], 'Kawayan is bamboo.'),
    _Fact('What kind of plant is bamboo?', [
      'A giant grass',
      'A tiny flower',
      'A fruit tree',
      'A water plant',
    ], 'Bamboo is a giant grass that grows very fast.'),
    _Fact('What are young bamboo shoots called?', [
      'Labong',
      'Puso',
      'Togue',
      'Kanin',
    ], 'Young bamboo shoots are called labong.'),
  ],
  'pako': [
    _Fact('What kind of plant is pako?', ['A fern', 'A tree', 'A cactus', 'A fruit vine'], 'Pako is a fern.'),
    _Fact('Where does pako like to grow?', [
      'In wet, shady places',
      'In dry desert sand',
      'On snowy mountains',
      'In the salty sea',
    ], 'Pako grows in wet, shady places.'),
    _Fact('Ferns have no flowers or seeds. What grows new ferns?', [
      'Spores',
      'Fruits',
      'Pods',
      'Nuts',
    ], 'Tiny spores under fern leaves grow new ferns.'),
  ],
  'bakawan': [
    _Fact('Where does bakawan grow?', [
      'In salty water near the shore',
      'On high mountains',
      'In the desert',
      'Only in flower pots',
    ], 'Bakawan grows in salty water near the shore.'),
    _Fact('How do mangroves help the shore?', [
      'They block big waves',
      'They make snow',
      'They dry up the sea',
      'They make the sand hot',
    ], 'Mangroves protect the shore from big waves.'),
    _Fact('What do the stilt roots of bakawan do?', [
      'Hold the tree up in the water',
      'Catch birds',
      'Make the water salty',
      'Grow flowers',
    ], 'The stilt roots stand in the water and hold the tree up.'),
  ],
  'kangkong': [
    _Fact('Where can kangkong grow?', [
      'In water or wet soil',
      'Only in dry sand',
      'Only on rooftops',
      'Inside rocks',
    ], 'Kangkong grows in water or wet soil.'),
    _Fact('What shape are kangkong leaves?', [
      'Like arrowheads',
      'Like circles',
      'Like stars',
      'Like squares',
    ], 'Kangkong leaves are shaped like arrowheads.'),
    _Fact('Why can kangkong stems float?', [
      'They are hollow',
      'They are made of stone',
      'They are very heavy',
      'They are full of sand',
    ], 'Kangkong stems are hollow, so they can float.'),
  ],
};

abstract final class QuestionBank {
  static Question _fact(String plantId, int which, String suffix) {
    final f = _facts[plantId]![which];
    return Question(
      id: '${plantId}_$suffix',
      plantId: plantId,
      type: QuestionType.multipleChoice,
      prompt: f.prompt,
      options: [for (final (i, a) in f.answers.indexed) QuizOption('o$i', a)],
      correctId: 'o0',
      reason: f.reason,
    );
  }

  /// "Which one is Mango?" with three other plants, preferring the same
  /// world so the choices look alike.
  static Question _picture(String plantId, String suffix) {
    final plant = PlantCatalog.byId(plantId);
    final i = plant.order;
    final sameWorld = PlantCatalog.inWorld(plant.world).where((p) => p.id != plantId).toList();
    final others = [for (var k = 0; k < 3; k++) sameWorld[(i + k) % sameWorld.length]];
    return Question(
      id: '${plantId}_$suffix',
      plantId: plantId,
      type: QuestionType.pictureChoice,
      prompt: 'Which one is ${plant.name}?',
      options: [
        QuizOption(plant.id, plant.name, plantId: plant.id),
        for (final p in others) QuizOption(p.id, p.name, plantId: p.id),
      ],
      correctId: plant.id,
      reason: 'This is ${plant.name}. ${PlantContent.of(plantId).shortLine}',
    );
  }

  static Question _tap(String plantId, PlantPart part, String suffix) {
    final name = PlantCatalog.byId(plantId).name;
    return Question(
      id: '${plantId}_$suffix',
      plantId: plantId,
      type: QuestionType.tapPart,
      prompt: 'Tap the ${Question.partLabel(part, plantId).toLowerCase()} of the $name.',
      correctId: part.name,
      part: part,
      reason: PlantContent.of(plantId).parts[part]!,
    );
  }

  /// "What does the root of the Narra do?" — the four part sentences.
  static Question _partJob(String plantId, PlantPart part, String suffix) {
    final content = PlantContent.of(plantId);
    final name = PlantCatalog.byId(plantId).name;
    final order = [part, ...PlantPart.values.where((p) => p != part)];
    return Question(
      id: '${plantId}_$suffix',
      plantId: plantId,
      type: QuestionType.multipleChoice,
      prompt: 'Which sentence is about the ${Question.partLabel(part, plantId).toLowerCase()} of the $name?',
      options: [for (final p in order) QuizOption(p.name, content.parts[p]!)],
      correctId: part.name,
      reason: content.parts[part]!,
    );
  }

  static final Map<String, Question> _all = {
    for (final q in [
      for (final p in PlantCatalog.all) ...plantQuiz(p.id),
      ...level(QuizLevel.sprout),
      ...level(QuizLevel.sapling),
    ])
      q.id: q,
  };

  /// Any question by its id (null for an id from an older version).
  static Question? byId(String id) => _all[id];

  /// The 3-question quiz at the end of a plant's details.
  static List<Question> plantQuiz(String plantId) => [
    _picture(plantId, 'p_pic'),
    _fact(plantId, 0, 'p_fact'),
    _tap(plantId, PlantPart.special, 'p_tap'),
  ];

  static List<Question> level(QuizLevel level) => [
    for (final (i, plant) in PlantCatalog.all.indexed)
      ...switch (level) {
        QuizLevel.sprout => [
          _picture(plant.id, 's_pic'),
          _fact(plant.id, 1, 's_fact'),
          _tap(plant.id, const [PlantPart.leaf, PlantPart.stem, PlantPart.root][i % 3], 's_tap'),
        ],
        QuizLevel.sapling => [
          _fact(plant.id, 2, 'h_fact'),
          _tap(plant.id, PlantPart.special, 'h_tap'),
          _partJob(plant.id, i.isEven ? PlantPart.root : PlantPart.stem, 'h_job'),
        ],
      },
  ];
}
