import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/binhi/binhi.dart';
import '../colouring/colouring_screen.dart';
import '../../art/garden/garden_art.dart';
import '../../art/icons/kid_icon.dart';
import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../game/garden.dart';
import '../../game/rules.dart';
import '../../game/weather.dart';
import '../../services/garden_ambience.dart';
import '../../services/sound_service.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../widgets/effects/reward_moment.dart';
import '../../widgets/pressable_3d.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/stat_pill.dart';

/// My Garden (PLAN.md §5d): every explored plant grows here in its own
/// home (a pot, the garden bed, the ground or the pond) beside the family's
/// bahay kubo. Hold a piece, then drag it to move it; tap a plant to open
/// it. Decorations are bought with leaves.
///
/// [embedded] is the garden inside Home's "My Garden" switch (PLAN.md
/// D22): no back button or leaves pill (Home's bar has them), and the
/// decorations open from a Decorate button instead of a fixed tray.
class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key, this.embedded = false, this.visible = true});

  final bool embedded;

  /// On Home the garden is built hidden; the gate opens when it shows.
  final bool visible;

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> with TickerProviderStateMixin {
  final _binhi = BinhiController();

  /// The bamboo gate swinging open, the first time the garden shows each
  /// day (PLAN.md §5g).
  late final AnimationController _gate = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  /// The day the gate last opened (for the whole app, not per screen).
  static String? _gateDay;

  /// The garden's gentle life: swaying plants, drifting clouds, birds and
  /// butterflies (PLAN.md §5g). Still with less motion.
  late final AnimationController _life = AnimationController(vsync: this, duration: GardenLife.loop);

  /// Falling rain, looping while it rains (still with less motion).
  late final AnimationController _rain = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  /// Nature sounds for the weather (PLAN.md §5k).
  late final GardenAmbience _ambience = ref.read(gardenAmbienceProvider);

  /// The weather the child is playing with (PLAN.md §5f): it opens on a
  /// random one; a cloud tap makes rain, a sun tap clears it.
  late GardenWeather _weather = ref.read(gardenWeatherPickProvider)();

  /// A rainbow shows after watering Binhi today, or when the rain stops.
  bool _rainbow = false;

  /// Puddles stay once it has rained.
  late bool _puddles = _weather == GardenWeather.rainy;

  /// The child has changed the weather (watering's rainbow won't override).
  bool _played = false;

  /// A little plant fact about the last change, shown for a few seconds.
  String? _note;
  Timer? _noteTimer;
  final _noteCount = <WeatherChange, int>{};

  /// The piece just tapped: it wiggles and shows its name for a moment.
  String? _poked;
  int _pokes = 0;

  /// Taps per piece: each makes its plant react too (a makahiya folds).
  final _touches = <String, int>{};
  Timer? _pokeTimer;

  /// Moves made here, shown at once while the save catches up.
  final _moved = <String, Offset>{};
  String? _lifted;
  Offset _liftedFrom = Offset.zero;
  bool _buying = false;

  @override
  void initState() {
    super.initState();
    if (widget.visible) WidgetsBinding.instance.addPostFrameCallback((_) => _openGate());
    // Watering Binhi today brings a rainbow (and the rain has stopped).
    ref.listenManual(wateredTodayProvider, (_, next) {
      if (next.value == true && !_played) setState(() => _rainbow = true);
    }, fireImmediately: true);
  }

  @override
  void didUpdateWidget(GardenScreen old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _openGate();
  }

  void _openGate() {
    if (!mounted) return;
    final today = dayKey(DateTime.now());
    final still = ref.read(lessMotionProvider) || MediaQuery.disableAnimationsOf(context);
    if (_gateDay == today || still) return;
    _gateDay = today;
    _gate.forward(from: 0);
  }

  /// A tap on the garden's sky, in design units.
  void _tapSky(Offset p) {
    if (GardenGroundPainter.hitsSun(p)) {
      if (_weather == GardenWeather.sunny && !_rainbow) return;
      final rainStopped = _weather == GardenWeather.rainy && !_rainbow;
      _change(GardenWeather.sunny, rainbow: rainStopped, says: rainStopped ? WeatherChange.rainbow : WeatherChange.sun);
    } else if (GardenGroundPainter.hitsCloud(p, _weather, rainbow: _rainbow)) {
      if (_weather == GardenWeather.rainy && !_rainbow) return;
      _change(GardenWeather.rainy, rainbow: false, says: WeatherChange.rain);
    }
  }

  void _change(GardenWeather to, {required bool rainbow, required WeatherChange says}) {
    PressFeedback.onPress?.call();
    final n = _noteCount[says] ?? 0;
    _noteCount[says] = n + 1;
    _noteTimer?.cancel();
    _noteTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _note = null);
    });
    setState(() {
      _played = true;
      _weather = to;
      _rainbow = rainbow;
      if (to == GardenWeather.rainy) _puddles = true;
      _note = WeatherRules.note(says, n);
    });
    if (says != WeatherChange.rain) _binhi.cheer();
    if (says == WeatherChange.rainbow) _ambience.chime();
  }

  @override
  void dispose() {
    _ambience.hide(this);
    _noteTimer?.cancel();
    _pokeTimer?.cancel();
    _gate.dispose();
    _life.dispose();
    _rain.dispose();
    _binhi.dispose();
    super.dispose();
  }

  Offset _feet(String piece, Map<String, (double, double)> saved) {
    final moved = _moved[piece];
    if (moved != null) return moved;
    final s = saved[piece];
    if (s != null) return Offset(s.$1, s.$2);
    final start = GardenLayout.startOf(piece);
    return Offset(start.x, start.y);
  }

  /// A tap on a plant or decoration: a happy wiggle and its name.
  void _poke(String piece) {
    PressFeedback.onPress?.call();
    _pokeTimer?.cancel();
    _pokeTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _poked = null);
    });
    setState(() {
      _poked = piece;
      _pokes++;
      _touches[piece] = (_touches[piece] ?? 0) + 1;
    });
  }

  void _lift(String piece, Offset from) {
    HapticFeedback.selectionClick();
    ref.read(soundServiceProvider).play(Sfx.tap);
    setState(() {
      _lifted = piece;
      _liftedFrom = from;
    });
  }

  void _drag(String piece, Offset by, double scale) =>
      setState(() => _moved[piece] = GardenLayout.clamp(piece, _liftedFrom + by / scale));

  /// Where everything stands (footprints), from the last build; a dropped
  /// piece makes room among them.
  final _footprints = <String, (Offset, double)>{};

  void _drop(String piece) {
    var to = _moved[piece];
    if (to != null) {
      // Slide just far enough not to cover another plant or decoration.
      to = GardenLayout.makeRoom(piece, to, [
        for (final MapEntry(:key, :value) in _footprints.entries)
          if (key != piece) value,
      ]);
      _moved[piece] = to;
    }
    setState(() => _lifted = null);
    if (to != null) unawaited(ref.read(gameActionsProvider).moveGardenPiece(piece, to.dx, to.dy));
  }

  Future<void> _buy(GardenDeco deco, int wallet) async {
    if (_buying) return;
    _buying = true;
    try {
      final sure = await showRewardMoment(
        context,
        title: 'Buy the ${deco.label}?',
        art: SizedBox.square(dimension: 110, child: CustomPaint(painter: GardenDecoPainter(deco))),
        message:
            'It costs ${deco.price} leaves. You will have ${wallet - deco.price} left.\n'
            'Hold it, then drag it anywhere you like.',
        color: AppColors.leaf,
        titleColor: AppColors.text,
        buttonLabel: 'BUY · ${deco.price}',
        secondLabel: 'Not now',
        reduceMotion: ref.read(lessMotionProvider),
      );
      if (!sure || !mounted) return;
      final bought = await ref.read(gameActionsProvider).buyDecoration(deco);
      if (!bought || !mounted) return;
      _binhi.cheer();
      cheerReward(context, ref);
    } finally {
      _buying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final explored = ref.watch(exploredPlantsProvider).value ?? const <String>{};
    final decos = ref.watch(decorationsProvider).value ?? const <GardenDeco>{};
    final saved = ref.watch(gardenSpotsProvider).value ?? const {};
    final walletLoaded = ref.watch(leavesProvider).value;
    final wallet = walletLoaded ?? 0;
    final earned = ref.watch(leavesEarnedProvider).value ?? 0;
    final still = ref.watch(lessMotionProvider);
    final weather = _weather;
    final rainbow = _rainbow;
    final raining = weather == GardenWeather.rainy && !rainbow;
    final moving = !still && !MediaQuery.disableAnimationsOf(context);
    if (raining && moving) {
      if (!_rain.isAnimating) _rain.repeat();
    } else if (_rain.isAnimating) {
      _rain.stop();
    }
    // Rain, birds or a breeze while this garden is on screen.
    widget.visible ? _ambience.show(this, weather, rainbow: rainbow) : _ambience.hide(this);
    if (moving) {
      if (!_life.isAnimating) _life.repeat();
    } else if (_life.isAnimating) {
      _life.stop();
    }

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${explored.length} of 15 plants growing', style: AppText.bodySmall),
        _WeatherTag(weather: weather, rainbow: rainbow),
      ],
    );

    final area = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: LayoutBuilder(
          builder: (context, c) {
            final k = c.maxWidth / GardenLayout.size.width;
            return Stack(
              children: [
                SingleChildScrollView(
                  physics: _lifted == null ? null : const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    width: c.maxWidth,
                    height: math.max(GardenLayout.size.height * k, c.maxHeight),
                    child: _garden(k, explored, decos, saved, earned, still, weather, rainbow, moving ? _life : null),
                  ),
                ),
                // The gate swinging open (only while it plays).
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _gate,
                      builder: (context, _) {
                        if (!_gate.isAnimating) return const SizedBox();
                        final open = Curves.easeInOutCubic.transform(_gate.value);
                        final door = c.maxWidth / 2 * (1 - open);
                        return Opacity(
                          opacity: (1 - (_gate.value - 0.8) * 5).clamp(0.0, 1.0),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: door,
                                child: const CustomPaint(painter: BambooDoorPainter(left: true)),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: door,
                                child: const CustomPaint(painter: BambooDoorPainter(left: false)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: AppSizes.gapM,
                  bottom: AppSizes.gapM,
                  right: AppSizes.gapM,
                  // A plant fact gets the whole width (big phone text
                  // squeezed it next to the button); the tip shares the
                  // row with Decorate.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _note == null
                            ? const SizedBox.shrink()
                            : Padding(
                                key: ValueKey(_note),
                                padding: const EdgeInsets.only(bottom: AppSizes.gapS),
                                child: _WeatherNote(text: _note!),
                              ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _Hint(empty: explored.isEmpty)),
                          if (widget.embedded) ...[
                            const SizedBox(width: AppSizes.gapS),
                            ChunkyButton(
                              label: 'DECORATE',
                              icon: KidIcon.shop,
                              small: true,
                              expand: false,
                              tone: ButtonTone.white,
                              onPressed: _openTray,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 0, AppSizes.gutter, AppSizes.gapS), child: info),
          Expanded(child: area),
          const SizedBox(height: AppSizes.gapM),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gapM, AppSizes.gapS, AppSizes.gutter, AppSizes.gapS),
              child: Row(
                children: [
                  SquareIconButton.back(context),
                  const SizedBox(width: AppSizes.gapM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Garden', style: AppText.title),
                        info,
                      ],
                    ),
                  ),
                  LeafTarget(child: StatPill.leaves(value: walletLoaded)),
                ],
              ),
            ),
            Expanded(child: area),
            _Tray(owned: decos, wallet: wallet, onBuy: (d) => _buy(d, wallet)),
          ],
        ),
      ),
    );
  }

  /// Home's garden: the decorations tray in a sheet.
  void _openTray() {
    PressFeedback.onPress?.call();
    showModalBottomSheet<void>(
      context: context,
      // Over the whole app, so the tab bar doesn't cover it.
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => Consumer(
        builder: (context, ref, _) {
          final decos = ref.watch(decorationsProvider).value ?? const <GardenDeco>{};
          final wallet = ref.watch(leavesProvider).value ?? 0;
          return SafeArea(
            child: _Tray(owned: decos, wallet: wallet, onBuy: (d) => _buy(d, wallet)),
          );
        },
      ),
    );
  }

  /// The picture for the kubo wall, if any has been hung.
  Widget? _kuboPicture(bool still) {
    final hung = (ref.watch(colouringsProvider).value ?? const []).where((c) => c.hung).firstOrNull;
    if (hung == null) return null;
    final fresh = ref.watch(justHungProvider) == hung.plantId && widget.visible;
    if (fresh) {
      // Shown once; later visits just show it hanging there.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(justHungProvider.notifier).set(null);
      });
    }
    return _KuboPicture(
      key: ValueKey((hung.plantId, hung.hungAt)),
      plantId: hung.plantId,
      png: hung.png,
      drop: fresh && !still,
    );
  }

  Widget _garden(
    double k,
    Set<String> explored,
    Set<GardenDeco> decos,
    Map<String, (double, double)> saved,
    int earned,
    bool still,
    GardenWeather weather,
    bool rainbow,
    Animation<double>? life,
  ) {
    final pieces = <_Piece>[];

    void movable(String id, Widget child, String label, {required String name, double? height}) {
      final feet = _feet(id, saved);
      pieces.add(
        _Piece(
          id: id,
          feet: feet,
          box: GardenLayout.startOf(id).box,
          height: height ?? GardenLayout.heightOf(id),
          child: _Movable(
            label: label,
            lifted: _lifted == id,
            onTap: () => _poke(id),
            onLift: () => _lift(id, feet),
            onDrag: (by) => _drag(id, by, k),
            onDrop: () => _drop(id),
            child: _Poke(name: name, poke: _poked == id ? _pokes : null, child: child),
          ),
        ),
      );
    }

    for (final plant in PlantCatalog.all.where((p) => explored.contains(p.id))) {
      final home = GardenLayout.homeOf(plant.id);
      if (home == GardenHome.bed || home == GardenHome.pond) continue;
      // Trees lean slowly; smaller plants sway more.
      final tree = GardenLayout.startOf(GardenLayout.plant(plant.id)).box >= 110;
      movable(
        GardenLayout.plant(plant.id),
        home == GardenHome.pot
            ? PottedPlant(
                plant: plant,
                life: life,
                touches: _touches[GardenLayout.plant(plant.id)] ?? 0,
                reduceMotion: still,
              )
            : Sway(
                life: life,
                amount: tree ? 0.025 : 0.05,
                times: tree ? 1 : 2,
                phase: Sway.phaseOf(plant.id),
                child: PlantView(
                  plant: plant,
                  react: true,
                  touches: _touches[GardenLayout.plant(plant.id)] ?? 0,
                  reduceMotion: still,
                ),
              ),
        '${plant.name}. Hold, then drag to move.',
        name: plant.name,
      );
    }

    final crops = [for (final id in GardenLayout.bedPlants) explored.contains(id) ? PlantCatalog.byId(id) : null];
    if (crops.any((p) => p != null)) {
      movable(
        GardenLayout.bed,
        GardenBedView(plants: crops, life: life, touches: _touches[GardenLayout.bed] ?? 0, reduceMotion: still),
        'Garden bed with ${crops.nonNulls.map((p) => p.name).join(' and ')}. Hold, then drag to move.',
        name: crops.nonNulls.map((p) => p.name).join(' & '),
      );
    }

    for (final d in decos) {
      Widget art = CustomPaint(painter: GardenDecoPainter(d));
      if (d == GardenDeco.butterfly && life != null) art = _Flutter(life: life, child: art);
      movable(GardenLayout.deco(d), art, '${d.label}. Hold, then drag to move.', name: d.label);
    }

    // The pond and its water plants stay put.
    const pond = GardenLayout.pond;
    pieces.add(
      _Piece(
        id: 'pond',
        feet: Offset(pond.center.dx, pond.bottom),
        box: pond.width,
        height: pond.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: CustomPaint(painter: GardenPondPainter())),
            for (final MapEntry(key: id, value: spot) in GardenLayout.pondPlants.entries)
              if (explored.contains(id))
                Positioned(
                  left: (spot.x - spot.box / 2 - pond.left) * k,
                  top: (spot.y - spot.box - pond.top) * k,
                  width: spot.box * k,
                  height: spot.box * k,
                  child: Semantics(
                    button: true,
                    label: '${PlantCatalog.byId(id).name}, in the pond.',
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () => _poke('pond_$id'),
                      child: _Poke(
                        name: PlantCatalog.byId(id).name,
                        poke: _poked == 'pond_$id' ? _pokes : null,
                        child: Sway(
                          life: life,
                          amount: 0.06,
                          phase: Sway.phaseOf(id),
                          child: PlantView(
                            plant: PlantCatalog.byId(id),
                            mode: PlantMode.planted,
                            react: true,
                            touches: _touches['pond_$id'] ?? 0,
                            reduceMotion: still,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );

    const b = GardenLayout.binhi;
    pieces.add(
      _Piece(
        id: 'binhi',
        feet: Offset(b.x, b.y),
        box: b.box,
        height: b.box,
        child: Binhi(
          stage: BinhiStage.forLeaves(earned),
          size: b.box * k,
          outfit: ref.watch(binhiOutfitProvider),
          controller: _binhi,
          reduceMotion: still,
          onTap: _binhi.hop,
        ),
      ),
    );

    final raining = weather == GardenWeather.rainy && !rainbow;

    // Things nearer the front (lower down) stand in front; the piece being
    // carried is always on top.
    pieces.sort((a, b) => a.feet.dy.compareTo(b.feet.dy));
    final carried = pieces.where((p) => p.id == _lifted).toList();
    pieces
      ..removeWhere((p) => p.id == _lifted)
      ..addAll(carried);
    _footprints
      ..clear()
      ..addAll({for (final p in pieces) p.id: GardenLayout.footprint(p.feet, p.box, p.height)});
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Tap a cloud for rain, the sun to clear it.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _tapSky(d.localPosition / k),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: Stack(
                key: ValueKey((weather, rainbow, _puddles)),
                children: [
                  // The moving sky and back trees, then the still ground.
                  Positioned.fill(
                    child: life == null
                        ? CustomPaint(
                            painter: GardenGroundPainter(weather: weather, rainbow: rainbow, layer: GardenLayer.sky),
                          )
                        : AnimatedBuilder(
                            animation: life,
                            builder: (context, _) => CustomPaint(
                              painter: GardenGroundPainter(
                                weather: weather,
                                rainbow: rainbow,
                                layer: GardenLayer.sky,
                                t: life.value,
                              ),
                            ),
                          ),
                  ),
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: GardenGroundPainter(
                          weather: weather,
                          rainbow: rainbow,
                          puddles: _puddles,
                          layer: GardenLayer.ground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // The bahay kubo: its newest picture hangs by the door; a tap goes
        // inside to the wall of pictures (PLAN.md §5l).
        Positioned(
          left: GardenLayout.kubo.left * k,
          top: GardenLayout.kubo.top * k,
          width: GardenLayout.kubo.width * k,
          height: GardenLayout.kubo.height * k,
          child: Semantics(
            button: true,
            label: 'Bahay kubo. See your pictures.',
            child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => context.push('/garden/gallery')),
          ),
        ),
        if (_kuboPicture(still) case final picture?)
          Positioned(
            left: (GardenLayout.kuboFrame.left - 6) * k,
            top: (GardenLayout.kuboFrame.top - 12) * k,
            width: (GardenLayout.kuboFrame.width + 12) * k,
            height: (GardenLayout.kuboFrame.height + 12) * k,
            child: IgnorePointer(child: picture),
          ),
        // For screen readers, the sky as two buttons.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 150 * k,
          child: Semantics(
            button: true,
            label: raining ? 'Sky. Make it sunny.' : 'Sky. Make it rain.',
            onTap: () => _tapSky(raining ? GardenGroundPainter.sunCentre : _anyCloud(weather, rainbow)),
            child: const SizedBox.expand(),
          ),
        ),
        for (final p in pieces)
          // A dropped piece glides to where it made room.
          AnimatedPositioned(
            key: ValueKey(p.id),
            duration: p.id == _lifted ? Duration.zero : const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: (p.feet.dx - p.box / 2) * k,
            top: (p.feet.dy - p.height) * k,
            width: p.box * k,
            height: p.height * k,
            child: p.child,
          ),
        // Butterflies flutter about (they hide in the rain).
        if (life != null && !raining)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: life,
                builder: (context, _) => CustomPaint(painter: GardenButterflyPainter(life.value)),
              ),
            ),
          ),
        if (weather == GardenWeather.rainy && !rainbow)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _rain,
                builder: (context, _) => CustomPaint(painter: GardenRainPainter(_rain.value)),
              ),
            ),
          ),
        if (explored.isEmpty)
          Positioned(
            left: 40 * k,
            right: 40 * k,
            top: 300 * k,
            child: const ChunkyCard(
              child: Text(
                'Explore a plant and it will grow here!',
                style: AppText.heading,
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// The newest hung picture in a little frame on the bahay kubo wall. Just
/// after hanging it drops onto its nail with a swing.
class _KuboPicture extends StatefulWidget {
  const _KuboPicture({super.key, required this.plantId, required this.png, required this.drop});

  final String plantId;
  final Uint8List png;
  final bool drop;

  @override
  State<_KuboPicture> createState() => _KuboPictureState();
}

class _KuboPictureState extends State<_KuboPicture> with SingleTickerProviderStateMixin {
  late final AnimationController _drop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
    value: widget.drop ? 0 : 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.drop) {
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _drop.forward();
      });
    }
  }

  @override
  void dispose() {
    _drop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final nail = c.maxHeight * 0.08;
      return AnimatedBuilder(
        animation: _drop,
        builder: (context, child) {
          final t = _drop.value;
          final fall = Curves.easeOutBack.transform((t / 0.45).clamp(0.0, 1.0));
          final swing = t < 0.45 ? -0.3 * (1 - fall) : math.sin((t - 0.45) / 0.55 * math.pi * 3) * 0.16 * (1 - t);
          final glow = t > 0.6 ? math.sin((t - 0.6) / 0.4 * math.pi) : 0.0;
          return Opacity(
            opacity: (t / 0.15).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -c.maxHeight * 1.6 * (1 - fall)),
              child: Transform.rotate(
                angle: swing,
                alignment: Alignment(0, -1 + nail / c.maxHeight * 2),
                child: Transform.scale(scale: 1 + glow * 0.12, child: child),
              ),
            ),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: nail * 2.4,
              child: const CustomPaint(painter: _NailString()),
            ),
            Positioned(
              left: c.maxWidth * 0.12,
              right: c.maxWidth * 0.12,
              top: nail * 2,
              bottom: 0,
              child: PictureFrame(plantId: widget.plantId, png: widget.png, border: c.maxWidth * 0.08),
            ),
          ],
        ),
      );
    },
  );
}

class _NailString extends CustomPainter {
  const _NailString();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.barkDark;
    canvas
      ..drawPath(
        Path()
          ..moveTo(size.width * 0.3, size.height)
          ..lineTo(size.width / 2, size.height * 0.2)
          ..lineTo(size.width * 0.7, size.height),
        p,
      )
      ..drawCircle(Offset(size.width / 2, size.height * 0.2), 1.6, Paint()..color = AppColors.barkDark);
  }

  @override
  bool shouldRepaint(_NailString old) => false;
}

/// The bought butterfly: wings flapping as it bobs where it was placed.
class _Flutter extends StatelessWidget {
  const _Flutter({required this.life, required this.child});

  final Animation<double> life;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: life,
    child: child,
    builder: (context, child) => Transform.translate(
      offset: Offset(0, GardenLife.wave(life.value, 3, 0) * 4),
      child: Transform.scale(scaleX: 0.35 + 0.65 * GardenLife.wave(life.value, 24, 0).abs(), child: child),
    ),
  );
}

class _Piece {
  const _Piece({required this.id, required this.feet, required this.box, required this.height, required this.child});

  final String id;

  /// Bottom centre, in design units.
  final Offset feet;
  final double box;
  final double height;
  final Widget child;
}

/// A tapped piece wiggles happily and shows its name above it. [poke]
/// counts taps (null when it isn't the piece just tapped), so each tap
/// wiggles again.
class _Poke extends StatefulWidget {
  const _Poke({required this.name, required this.poke, required this.child});

  final String name;
  final int? poke;
  final Widget child;

  @override
  State<_Poke> createState() => _PokeState();
}

/// The tree under [child] never changes shape (so the plant inside keeps
/// its state and can react to the same tap); only the wiggle and the name
/// tag come and go.
class _PokeState extends State<_Poke> with SingleTickerProviderStateMixin {
  late final AnimationController _wiggle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void didUpdateWidget(_Poke old) {
    super.didUpdateWidget(old);
    if (widget.poke != null && widget.poke != old.poke) _wiggle.forward(from: 0);
  }

  @override
  void dispose() {
    _wiggle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned.fill(
        child: AnimatedBuilder(
          animation: _wiggle,
          child: widget.child,
          builder: (context, child) {
            final t = _wiggle.value;
            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.skewX(math.sin(t * math.pi * 4) * 0.12 * (1 - t))
                ..scaleByDouble(1, 1 + math.sin(t * math.pi) * 0.06, 1, 1),
              child: child,
            );
          },
        ),
      ),
      if (widget.poke != null)
        Positioned(
          left: -40,
          right: -40,
          top: -30,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  boxShadow: const [BoxShadow(color: Color(0x33263046), blurRadius: 6, offset: Offset(0, 2))],
                ),
                child: Text(widget.name, style: AppText.label.copyWith(color: AppColors.text)),
              ),
            ),
          ),
        ),
    ],
  );
}

/// Hold to pick up, drag to move, let go to put down. A lifted piece grows
/// a little so the child can see what they're holding.
class _Movable extends StatelessWidget {
  const _Movable({
    required this.label,
    required this.lifted,
    required this.onLift,
    required this.onDrag,
    required this.onDrop,
    required this.child,
    this.onTap,
  });

  final String label;
  final bool lifted;
  final VoidCallback onLift;
  final ValueChanged<Offset> onDrag;
  final VoidCallback onDrop;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    label: label,
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: (_) => onLift(),
      onLongPressMoveUpdate: (d) => onDrag(d.offsetFromOrigin),
      onLongPressEnd: (_) => onDrop(),
      onLongPressCancel: onDrop,
      child: AnimatedScale(
        scale: lifted ? 1.08 : 1,
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    ),
  );
}

/// The weather under the garden's title, with what to tap next.
class _WeatherTag extends StatelessWidget {
  const _WeatherTag({required this.weather, required this.rainbow});

  final GardenWeather weather;
  final bool rainbow;

  @override
  Widget build(BuildContext context) {
    final raining = weather == GardenWeather.rainy && !rainbow;
    // Short on screen (narrow phones); the full sentence for screen readers.
    final (title, tip, said) = rainbow
        ? ('Rainbow!', 'Tap a cloud', 'Tap a cloud for rain')
        : raining
        ? (weather.label, 'Tap the sun', 'Tap the sun to stop it')
        : (weather.label, 'Tap a cloud', 'Tap a cloud for rain');
    return Semantics(
      label: '${title.endsWith('!') ? title : '$title.'} $said.',
      excludeSemantics: true,
      child: Row(
        children: [
          KidIconView(raining ? KidIcon.drop : KidIcon.sun, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: AppText.label.copyWith(color: rainbow ? AppColors.grapeDark : AppColors.text, fontSize: 13),
                  ),
                  TextSpan(
                    text: ' · $tip',
                    style: AppText.label.copyWith(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// A plant fact about the weather that just changed, with a speaker.
class _WeatherNote extends StatelessWidget {
  const _WeatherNote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      boxShadow: const [BoxShadow(color: Color(0x22263046), blurRadius: 6, offset: Offset(0, 2))],
    ),
    child: Row(
      children: [
        const KidIconView(KidIcon.idea, size: AppSizes.iconSmall),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppText.label.copyWith(color: AppColors.text)),
        ),
        SpeakerButton(text: text),
      ],
    ),
  );
}

/// A point on one of the clouds (for the screen reader's "Make it rain").
Offset _anyCloud(GardenWeather weather, bool rainbow) =>
    GardenGroundPainter.cloudsFor(weather, rainbow: rainbow).first.$1;

class _Hint extends StatelessWidget {
  const _Hint({required this.empty});
  final bool empty;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const KidIconView(KidIcon.hand, size: AppSizes.iconSmall),
            const SizedBox(width: 6),
            Flexible(child: Text(empty ? 'Your garden is waiting' : 'Hold to move', style: AppText.label)),
          ],
        ),
      ),
    ),
  );
}

/// Decorations to buy with leaves. Bought ones are in the garden already.
class _Tray extends StatelessWidget {
  const _Tray({required this.owned, required this.wallet, required this.onBuy});

  final Set<GardenDeco> owned;
  final int wallet;
  final ValueChanged<GardenDeco> onBuy;

  List<GardenDeco> get _order => [
    ...GardenDeco.values.where((d) => !owned.contains(d)),
    ...GardenDeco.values.where(owned.contains),
  ];

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(AppSizes.gapM),
    padding: const EdgeInsets.all(AppSizes.gapM),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      border: Border.all(color: AppColors.border, width: AppSizes.borderWidth),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Decorate', style: AppText.heading),
        const SizedBox(height: AppSizes.gapS),
        // Swipe for more; owned ones move to the end.
        SizedBox(
          // Taller when the phone uses big text.
          height: 92 + MediaQuery.textScalerOf(context).scale(32),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _order.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSizes.gapS),
            itemBuilder: (context, i) => SizedBox(
              width: 80,
              child: _DecoTile(
                deco: _order[i],
                owned: owned.contains(_order[i]),
                wallet: wallet,
                onBuy: () => onBuy(_order[i]),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DecoTile extends StatelessWidget {
  const _DecoTile({required this.deco, required this.owned, required this.wallet, required this.onBuy});

  final GardenDeco deco;
  final bool owned;
  final int wallet;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final short = deco.price - wallet;
    final canBuy = !owned && short <= 0;
    final Widget status;
    final String label;
    if (owned) {
      label = '${deco.label}. In your garden.';
      status = Text('Placed', style: AppText.label.copyWith(color: AppColors.leafDark, fontSize: 12));
    } else if (canBuy) {
      label = '${deco.label}. ${deco.price} leaves. Tap to buy.';
      status = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KidIconView(KidIcon.leaf, size: 16),
          Text(' ${deco.price}', style: AppText.label.copyWith(fontSize: 13)),
        ],
      );
    } else {
      label = '${deco.label}. ${deco.price} leaves. You need $short more.';
      status = Text('$short more', style: AppText.bodySmall.copyWith(fontSize: 12));
    }
    return ChunkyCard(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.gapS, horizontal: 4),
      color: owned ? AppColors.leafTint : AppColors.card,
      ledgeColor: owned ? AppColors.leaf : AppColors.borderDeep,
      onTap: canBuy ? onBuy : null,
      semanticLabel: label,
      child: Opacity(
        opacity: owned || canBuy ? 1 : 0.55,
        child: Column(
          children: [
            SizedBox(height: 40, width: 56, child: CustomPaint(painter: GardenDecoPainter(deco))),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(deco.label, style: AppText.bodySmall),
            ),
            status,
          ],
        ),
      ),
    );
  }
}
