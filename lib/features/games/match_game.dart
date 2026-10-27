import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/plants/plant_view.dart';
import '../../content/plant_catalog.dart';
import '../../content/plant_games.dart';
import '../../game/rules.dart';
import '../../state/effects.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/pressable_3d.dart';
import 'game_pieces.dart';
import '../../art/icons/kid_icon.dart';

/// Match it (PLAN.md §6b): tap a plant, then what it is known for. Four
/// plants a round, from the ones the child has unlocked (at least World
/// 1), with plants not matched before picked first.
class MatchGameScreen extends ConsumerStatefulWidget {
  const MatchGameScreen({super.key, this.random});

  /// For tests.
  final math.Random? random;

  @override
  ConsumerState<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends ConsumerState<MatchGameScreen> with GameVoice {
  static const _colors = [AppColors.coral, AppColors.grape, AppColors.teal, AppColors.sunshine];
  late final _random = widget.random ?? math.Random();

  late List<String> _plants;
  late List<String> _uses; // plant ids, in a different order
  final _matched = <String>[];
  String? _picked;
  final _keys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final unlocked = ref.read(pathProvider).value?.unlockedIds ?? const <String>{};
    final pool = QuizLevel.questionPool(unlocked).toList()..shuffle(_random);
    final wins = ref.read(gameWinsProvider).value ?? const {};
    pool.sort((a, b) => (wins.contains((MiniGame.match, a)) ? 1 : 0) - (wins.contains((MiniGame.match, b)) ? 1 : 0));
    _plants = pool.take(4).toList()..sort((a, b) => PlantCatalog.byId(a).order - PlantCatalog.byId(b).order);
    do {
      _uses = [..._plants]..shuffle(_random);
    } while (_uses.indexed.where((e) => e.$2 == _plants[e.$1]).length > 1);
    _matched.clear();
    _picked = null;
    hint = null;
    for (final id in _plants) {
      _keys[id] = GlobalKey();
    }
  }

  Color? _colorOf(String id) {
    final i = _matched.indexOf(id);
    return i < 0 ? null : _colors[i];
  }

  void _pickUse(String useOf) {
    final id = _picked;
    if (id == null) {
      say('First tap a plant on the left.');
      return;
    }
    final use = PlantGameContent.of(useOf).use;
    if (id == useOf) {
      setState(() {
        _matched.add(id);
        _picked = null;
      });
      say(use.fact);
      celebrateCorrect(ref, screenCenterOf(_keys[useOf]!));
    } else {
      comfortWrong(ref);
      setState(() => _picked = null);
      say('Hmm, not quite. Think about what ${PlantCatalog.byId(id).name} is known for.');
    }
  }

  Future<int> _win() async {
    final actions = ref.read(gameActionsProvider);
    var total = 0;
    for (final id in _plants) {
      total += await actions.winGame(MiniGame.match, id);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final done = _matched.length == _plants.length;
    return GameFrame(
      title: 'What is it known for?',
      howTo: 'Tap a plant, then tap what it is known for.',
      learns: 'how Filipinos use plants for food, homes and nature.',
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (final id in _plants) ...[
                    _MatchTile(
                      color: _colorOf(id),
                      picked: _picked == id,
                      label: PlantCatalog.byId(id).name,
                      onTap: _matched.contains(id) ? null : () => setState(() => _picked = id),
                      leading: SizedBox(width: 42, height: 48, child: PlantView(plant: PlantCatalog.byId(id))),
                    ),
                    const SizedBox(height: AppSizes.gapS),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSizes.gapM),
            Expanded(
              child: Column(
                children: [
                  for (final id in _uses) ...[
                    _MatchTile(
                      key: _keys[id],
                      color: _colorOf(id),
                      picked: false,
                      label: PlantGameContent.of(id).use.label,
                      onTap: _matched.contains(id) ? null : () => _pickUse(id),
                      leading: SizedBox(
                        width: 42,
                        height: 48,
                        child: KidIconView(PlantGameContent.of(id).use.icon, size: AppSizes.iconLarge),
                      ),
                    ),
                    const SizedBox(height: AppSizes.gapS),
                  ],
                ],
              ),
            ),
          ],
        ),
        GameHint(hint),
        const SizedBox(height: AppSizes.gapS),
        if (done)
          GameDone(
            key: ValueKey(_plants.join()),
            text: 'You matched every plant to what it is known for!',
            onWin: _win,
            onPlayAgain: () => setState(_deal),
          ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    super.key,
    required this.color,
    required this.picked,
    required this.label,
    required this.onTap,
    required this.leading,
  });

  final Color? color;
  final bool picked;
  final String label;
  final VoidCallback? onTap;
  final Widget leading;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    selected: picked,
    label: color != null ? '$label, matched' : label,
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap == null
          ? null
          : () {
              PressFeedback.onPress?.call();
              onTap!();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapS, vertical: 6),
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.25) ?? (picked ? AppColors.skyTint : AppColors.card),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: color ?? (picked ? AppColors.skyDark : AppColors.borderDeep),
            width: picked || color != null ? 3 : 2,
          ),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 6),
            Expanded(
              // One-word plant names shrink a little instead of breaking.
              child: label.contains(' ')
                  ? Text(label, style: AppText.label.copyWith(color: AppColors.text, fontSize: 15))
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(label, style: AppText.label.copyWith(color: AppColors.text, fontSize: 15)),
                    ),
            ),
            if (color != null) const KidIconView(KidIcon.check, size: AppSizes.iconSmall),
          ],
        ),
      ),
    ),
  );
}
