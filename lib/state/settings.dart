import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// The "less motion" setting (PLAN.md §9). Before onboarding it is off.
final lessMotionProvider = Provider<bool>((ref) => ref.watch(profileProvider).value?.lessMotion ?? false);

/// Sound effects on or off. Speaker buttons work either way.
final soundOnProvider = Provider<bool>((ref) => ref.watch(profileProvider).value?.soundOn ?? true);
