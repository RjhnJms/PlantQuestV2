import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/transitions.dart';
import 'services/music_service.dart';
import 'services/sound_service.dart';
import 'state/effects.dart';
import 'state/settings.dart';
import 'theme/app_theme.dart';
import 'widgets/effects/confetti.dart';
import 'widgets/effects/flying_leaves.dart';
import 'widgets/pressable_3d.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PlantQuestApp()));
}

class PlantQuestApp extends ConsumerStatefulWidget {
  const PlantQuestApp({super.key});

  @override
  ConsumerState<PlantQuestApp> createState() => _PlantQuestAppState();
}

class _PlantQuestAppState extends ConsumerState<PlantQuestApp> {
  // Days visited is counted by the start screen (app/start_gate.dart).

  @override
  void initState() {
    super.initState();
    // Every chunky button, card, stop and tab makes the soft wooden tap.
    // The first tap also lets the browser start the music.
    PressFeedback.onPress = () {
      ref.read(soundServiceProvider).play(Sfx.tap);
      ref.read(musicServiceProvider).nudge();
    };
    ref.read(musicServiceProvider);
  }

  @override
  void dispose() {
    PressFeedback.onPress = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlayfulPageTransitionsBuilder.calm = ref.watch(lessMotionProvider);
    return MaterialApp.router(
      title: 'PlantQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
      // Confetti and flying leaves float above every screen.
      builder: (context, child) => ConfettiLayer(
        controller: ref.watch(confettiProvider),
        child: FlyingLeavesLayer(controller: ref.watch(flyingLeavesProvider), child: child!),
      ),
    );
  }
}
