import 'package:flutter/material.dart';

import '../app/bottom_nav.dart';
import '../art/avatars/avatar_view.dart';
import '../art/binhi/binhi.dart';
import '../art/plants/plant_drawing.dart';
import '../art/plants/plant_view.dart';
import '../art/scenes/world_scene.dart';
import '../content/plant_catalog.dart';
import '../features/home/path_stop.dart';
import '../game/rules.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import '../widgets/app_progress_bar.dart';
import '../widgets/chunky_button.dart';
import '../widgets/chunky_card.dart';
import '../widgets/round_buttons.dart';
import '../widgets/stat_pill.dart';
import '../art/icons/kid_icon.dart';

// Layout ideas for a cleaner app, shown as still mock-ups (nothing works).
// Three styles, each on Home and a Plant page. Browser: #/layout-preview

enum LayoutStyle {
  tidy('A · Tidy up', 'Same screens, fewer boxes. Each thing appears once.'),
  nextStep('B · Next step first', 'One big "what to do next" button. Everything else is a tap away.'),
  tabs('C · Tabs', 'The path fills Home. Plant pages split into Learn · Play · Quiz.'),
  mix('Pick · C Home + A Plant', 'The path fills Home with a growth ring on Binhi; tidy Plant page.');

  const LayoutStyle(this.title, this.line);
  final String title;
  final String line;
}

class LayoutPreview extends StatefulWidget {
  const LayoutPreview({super.key});

  @override
  State<LayoutPreview> createState() => _LayoutPreviewState();
}

class _LayoutPreviewState extends State<LayoutPreview> {
  var _style = LayoutStyle.tidy;
  var _plantPage = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.border,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.gapS),
            child: Wrap(
              spacing: AppSizes.gapS,
              runSpacing: AppSizes.gapS,
              children: [
                for (final s in LayoutStyle.values)
                  ChoiceChip(
                    label: Text(s.title),
                    selected: s == _style,
                    onSelected: (_) => setState(() => _style = s),
                  ),
                ChoiceChip(
                  label: Text(_plantPage ? 'Plant page' : 'Home'),
                  selected: true,
                  onSelected: (_) => setState(() => _plantPage = !_plantPage),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutMock(style: _style, plantPage: _plantPage),
          ),
        ],
      ),
    ),
  );
}

/// One mock screen.
class LayoutMock extends StatelessWidget {
  const LayoutMock({super.key, required this.style, required this.plantPage});

  final LayoutStyle style;
  final bool plantPage;

  @override
  Widget build(BuildContext context) => switch ((style, plantPage)) {
    (LayoutStyle.tidy, false) => const _HomeTidy(),
    (LayoutStyle.tidy, true) => const _PlantTidy(),
    (LayoutStyle.nextStep, false) => const _HomeNext(),
    (LayoutStyle.nextStep, true) => const _PlantNext(),
    (LayoutStyle.tabs, false) => const _HomeTabs(),
    (LayoutStyle.tabs, true) => const _PlantTabs(),
    (LayoutStyle.mix, false) => const _HomeTabs(ring: true),
    (LayoutStyle.mix, true) => const _PlantTidy(),
  };
}

// ------------------------------------------------------------ shared bits

const _done = ['sampaguita', 'gumamela', 'makahiya', 'kalamansi', 'malunggay', 'palay'];
const _plant = PlantInfo.sampaguita;
final _next = PlantCatalog.byId('mango');

StopState _stateOf(String id) =>
    _done.contains(id) ? StopState.done : (id == 'mango' ? StopState.current : StopState.locked);

Widget _nav(int i) => AppBottomNav(currentIndex: i, onTap: (_) {});

Widget _greeting() => Row(
  children: [
    const AvatarView(avatarId: 'boy_cap', size: 44),
    const SizedBox(width: AppSizes.gapS),
    Expanded(child: Text('Hi, Juan!', style: AppText.title.copyWith(fontSize: 24))),
    const StatPill.days(value: 1),
    const SizedBox(width: 6),
    const StatPill.leaves(value: 49),
  ],
);

/// A short stretch of the adventure path on the world scene.
class _PathStrip extends StatelessWidget {
  const _PathStrip({required this.ids, this.height = 520, this.top = 24});

  final List<String> ids;
  final double height;

  /// Room above the first stop.
  final double top;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Stack(
      children: [
        const Positioned.fill(child: WorldScene(world: 2, parallax: false, reduceMotion: true)),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                for (final (i, id) in ids.indexed)
                  Positioned(
                    left: [0.18, 0.52, 0.22, 0.56][i % 4] * c.maxWidth,
                    top: top + i * (height - top - 40) / ids.length,
                    child: PathStop(
                      plant: PlantCatalog.byId(id),
                      state: _stateOf(id),
                      onOpen: () {},
                      reduceMotion: true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _plantArt({double? height}) => SizedBox(
  height: height,
  child: CustomPaint(
    size: Size.infinite,
    painter: PlantPainter(drawing: PlantArt.of(_plant.id), mode: PlantMode.detail),
  ),
);

Widget _partChips() => Row(
  children: [
    for (final (i, p) in ['Root', 'Stem', 'Leaf', 'Flower'].indexed) ...[
      if (i > 0) const SizedBox(width: 6),
      Expanded(
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            border: Border.all(color: AppColors.borderDeep, width: 2),
            boxShadow: const [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 3))],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(p, style: AppText.label.copyWith(color: AppColors.text, fontSize: 16)),
          ),
        ),
      ),
    ],
  ],
);

Widget _gameButton(String label, IconData icon, Color color, Color ledge, {bool done = false}) => Expanded(
  child: ChunkyCard(
    onTap: () {},
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapS, vertical: AppSizes.gapS),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 22, color: AppColors.text),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label, style: AppText.label.copyWith(color: AppColors.text, fontSize: 15)),
        ),
        if (done)
          const Icon(Icons.check_circle_rounded, color: AppColors.leafDark, size: 20)
        else
          Text('+3', style: AppText.label.copyWith(color: AppColors.leafDark)),
      ],
    ),
  ),
);

Widget _plantHeader(BuildContext context) => Row(
  children: [
    SquareIconButton.back(context),
    const SizedBox(width: AppSizes.gapM),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_plant.name, style: AppText.title),
          Text(_plant.scientificName, style: AppText.bodySmall.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    ),
    const StatPill.leaves(value: 49),
  ],
);

// ------------------------------------------------------------ A · Tidy

class _HomeTidy extends StatelessWidget {
  const _HomeTidy();

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: _nav(0),
    body: SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapM),
            child: Column(
              children: [
                _greeting(),
                const SizedBox(height: AppSizes.gapM),
                // One Binhi line instead of a big card.
                const ChunkyCard(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.gapM, vertical: AppSizes.gapS),
                  child: Row(
                    children: [
                      Binhi(stage: BinhiStage.blooming, size: 54, reduceMotion: true),
                      SizedBox(width: AppSizes.gapM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Binhi is in full bloom!', style: AppText.heading),
                            SizedBox(height: 6),
                            AppProgressBar(value: 1, height: 10, semanticLabel: 'Growth'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 0, AppSizes.gutter, AppSizes.gapS),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.sunshine, borderRadius: BorderRadius.circular(99)),
                  child: Text('World 2 · Bukid', style: AppText.label.copyWith(color: AppColors.text)),
                ),
                const Spacer(),
                const Text('6 of 15 done', style: AppText.bodySmall),
              ],
            ),
          ),
          const _PathStrip(ids: ['palay', 'mango', 'saba', 'mongo'], height: 560),
        ],
      ),
    ),
  );
}

class _PlantTidy extends StatelessWidget {
  const _PlantTidy();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapM),
              children: [
                _plantHeader(context),
                const SizedBox(height: AppSizes.gapM),
                // Plant, part buttons and the part sentence share one card.
                ChunkyCard(
                  padding: const EdgeInsets.all(AppSizes.gapM),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Our national flower. Its small white flowers smell very sweet.',
                              style: AppText.body.copyWith(fontSize: 16),
                            ),
                          ),
                          const SpeakerButton(text: ''),
                        ],
                      ),
                      _plantArt(height: 300),
                      _partChips(),
                      const SizedBox(height: AppSizes.gapS),
                      Text(
                        'Tap a part to learn about it.',
                        style: AppText.bodySmall.copyWith(color: AppColors.grapeInk),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.gapM),
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: AppColors.sunshineDark),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Did you know? Its flowers open in the evening.',
                        style: AppText.body.copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Everything to DO sits together at the bottom.
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 0, AppSizes.gutter, AppSizes.gapL),
            child: Column(
              children: [
                Row(
                  children: [
                    _gameButton('Label it', Icons.label_rounded, AppColors.sky, AppColors.skyDark, done: true),
                    const SizedBox(width: AppSizes.gapS),
                    _gameButton('Grow it', Icons.spa_rounded, AppColors.leaf, AppColors.leafDark),
                  ],
                ),
                const SizedBox(height: AppSizes.gapS),
                ChunkyButton(label: 'START QUIZ', icon: KidIcon.quiz, onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------- B · Next step

class _HomeNext extends StatelessWidget {
  const _HomeNext();

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: _nav(0),
    body: ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 330,
          child: Stack(
            children: [
              const Positioned.fill(child: WorldScene(world: 1, parallax: false, reduceMotion: true)),
              Positioned(
                left: AppSizes.gutter,
                right: AppSizes.gutter,
                top: MediaQuery.paddingOf(context).top + AppSizes.gapM,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.gapS),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: _greeting(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                      child: Text('Next up: ${_next.name}!', style: AppText.heading),
                    ),
                    const SizedBox(height: 6),
                    const Binhi(stage: BinhiStage.blooming, size: 130, mood: BinhiMood.cheering, reduceMotion: true),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChunkyCard(
                color: AppColors.leafTint,
                ledgeColor: AppColors.leaf,
                child: Row(
                  children: [
                    SizedBox(width: 84, height: 84, child: PlantView(plant: _next)),
                    const SizedBox(width: AppSizes.gapM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PLANT 7 OF 15', style: AppText.label.copyWith(color: AppColors.leafDark)),
                          Text('Meet the ${_next.name}', style: AppText.title.copyWith(fontSize: 22)),
                          const SizedBox(height: 6),
                          ChunkyButton(label: 'GO!', small: true, expand: false, onPressed: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.gapM),
              Row(
                children: [
                  for (final (i, (label, icon, color)) in [
                    ('Quiz', Icons.extension_rounded, AppColors.grape),
                    ('Games', Icons.sports_esports_rounded, AppColors.sky),
                    ('Stickers', Icons.auto_awesome_rounded, AppColors.coral),
                  ].indexed) ...[
                    if (i > 0) const SizedBox(width: AppSizes.gapS),
                    Expanded(
                      child: ChunkyCard(
                        onTap: () {},
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.gapM),
                        child: Column(
                          children: [
                            Icon(icon, color: color, size: 32),
                            const SizedBox(height: 4),
                            Text(label, style: AppText.label.copyWith(color: AppColors.text)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSizes.gapL),
              Row(
                children: [
                  const Expanded(child: Text('Your path', style: AppText.heading)),
                  Text('See all ›', style: AppText.label.copyWith(color: AppColors.skyDark)),
                ],
              ),
              const SizedBox(height: AppSizes.gapS),
              Row(
                children: [
                  for (final p in PlantCatalog.all)
                    Expanded(
                      child: Container(
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: switch (_stateOf(p.id)) {
                            StopState.done => AppColors.leaf,
                            StopState.current => AppColors.sunshine,
                            StopState.locked => AppColors.track,
                          },
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlantNext extends StatelessWidget {
  const _PlantNext();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapM),
              children: [
                _plantHeader(context),
                const SizedBox(height: AppSizes.gapM),
                // Three steps, like a little map of this page.
                Row(
                  children: [
                    for (final (i, (label, state)) in [('Explore', 2), ('Play', 1), ('Quiz', 0)].indexed) ...[
                      if (i > 0)
                        const Expanded(
                          child: Divider(color: AppColors.borderDeep, thickness: 3, indent: 4, endIndent: 4),
                        ),
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: [AppColors.track, AppColors.sunshine, AppColors.leaf][state],
                            child: state == 2
                                ? const Icon(Icons.check_rounded, color: AppColors.text)
                                : Text('${i + 1}', style: AppText.label.copyWith(color: AppColors.text)),
                          ),
                          const SizedBox(height: 2),
                          Text(label, style: AppText.label.copyWith(color: AppColors.text)),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.gapM),
                ChunkyCard(
                  padding: const EdgeInsets.all(AppSizes.gapM),
                  child: Column(children: [_plantArt(height: 280), _partChips()]),
                ),
                const SizedBox(height: AppSizes.gapM),
                Text(
                  'You found all 4 parts! Now play a game with ${_plant.name}.',
                  style: AppText.body.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 0, AppSizes.gutter, AppSizes.gapL),
            child: ChunkyButton(
              label: 'NEXT: GROW IT',
              icon: KidIcon.grow,
              tone: ButtonTone.sunshine,
              onPressed: () {},
            ),
          ),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------------ C · Tabs

class _HomeTabs extends StatelessWidget {
  const _HomeTabs({this.ring = false});

  /// Show Binhi's growth as a ring around him.
  final bool ring;

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: _nav(0),
    body: Stack(
      children: [
        const Positioned.fill(child: _PathStrip(ids: ['palay', 'mango', 'saba', 'mongo'], height: 900, top: 150)),
        Positioned(
          left: AppSizes.gutter,
          right: AppSizes.gutter,
          top: MediaQuery.paddingOf(context).top + AppSizes.gapM,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.gapS),
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
            ),
            child: _greeting(),
          ),
        ),
        // Binhi floats in the corner; tap him for his growth.
        Positioned(
          left: AppSizes.gutter,
          bottom: AppSizes.gapL,
          child: Row(
            children: [
              if (ring)
                const _GrowthRing(progress: 0.7)
              else
                const Binhi(stage: BinhiStage.blooming, size: 80, reduceMotion: true),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusM)),
                child: Text('Tap Mango to explore!', style: AppText.label.copyWith(color: AppColors.text)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PlantTabs extends StatelessWidget {
  const _PlantTabs();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapL),
        children: [
          _plantHeader(context),
          const SizedBox(height: AppSizes.gapM),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(AppSizes.radiusM)),
            child: Row(
              children: [
                for (final (i, label) in ['Learn', 'Play', 'Quiz'].indexed)
                  Expanded(
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.card : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Text(
                        label,
                        style: AppText.heading.copyWith(
                          fontSize: 17,
                          color: i == 0 ? AppColors.text : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.gapM),
          ChunkyCard(
            padding: const EdgeInsets.all(AppSizes.gapM),
            child: Column(children: [_plantArt(height: 320), _partChips()]),
          ),
          const SizedBox(height: AppSizes.gapM),
          Text(
            'Sampaguita is our national flower. Its small white flowers smell very sweet.',
            style: AppText.body.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSizes.gapS),
          Text(
            'Did you know? Its flowers open in the evening.',
            style: AppText.bodySmall.copyWith(color: AppColors.grapeInk),
          ),
        ],
      ),
    ),
  );
}

/// Binhi in a white circle with his growth drawn as a green ring and a
/// small "7 more" tag: progress stays visible without a card.
class _GrowthRing extends StatelessWidget {
  const _GrowthRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 104,
    height: 112,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.borderDeep, offset: Offset(0, 4))],
          ),
          child: CustomPaint(
            painter: _RingPainter(progress),
            child: const Center(child: Binhi(stage: BinhiStage.sapling, size: 70, reduceMotion: true)),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.leaf, borderRadius: BorderRadius.circular(99)),
            child: Text('7 to grow', style: AppText.label.copyWith(color: AppColors.text, fontSize: 12)),
          ),
        ),
      ],
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 6);
    canvas
      ..drawArc(
        r,
        0,
        6.283,
        false,
        Paint()
          ..color = AppColors.track
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7,
      )
      ..drawArc(
        r,
        -1.5708,
        6.283 * progress,
        false,
        Paint()
          ..color = AppColors.leaf
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
