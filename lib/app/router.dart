import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../dev/dev_menu.dart';
import '../dev/layout_preview.dart';
import '../dev/rewards_preview.dart';
import '../features/colouring/colouring_screen.dart';
import '../features/colouring/gallery_screen.dart';
import '../features/games/grow_game.dart';
import '../features/games/label_game.dart';
import '../features/games/match_game.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/about_you_screen.dart';
import '../features/onboarding/get_started_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/plants/plant_detail_screen.dart';
import '../features/plants/plants_screen.dart';
import '../features/garden/garden_screen.dart';
import '../features/profile/badges_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/profile/sticker_book_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/quiz/quiz_tab.dart';
import '../features/settings/settings_screen.dart';
import '../game/rules.dart';
import '../services/read_aloud.dart';
import '../state/providers.dart';
import 'bottom_nav.dart';
import 'start_gate.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Stops reading aloud whenever a page opens or closes (PLAN.md §8).
class _StopSpeechObserver extends NavigatorObserver {
  _StopSpeechObserver(this.ref);
  final Ref ref;

  void _stop() => ref.read(readAloudProvider).stop();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _stop();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _stop();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _stop();
}

/// All screens and how they connect (PLAN.md §4).
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    observers: [_StopSpeechObserver(ref)],
    routes: [
      GoRoute(path: '/', builder: (_, _) => const StartGate()),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'start',
            builder: (_, _) => const GetStartedScreen(),
            routes: [GoRoute(path: 'about', builder: (_, _) => const AboutYouScreen())],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => Scaffold(
          body: shell,
          bottomNavigationBar: Consumer(
            builder: (context, ref, _) => AppBottomNav(
              currentIndex: shell.currentIndex,
              dotIndex: ref.watch(shopDotProvider) ? AppBottomNav.shopIndex : null,
              onTap: (i) {
                ref.read(readAloudProvider).stop();
                if (i == AppBottomNav.shopIndex) markShopSeen(ref);
                shell.goBranch(i, initialLocation: i == shell.currentIndex);
              },
            ),
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/plants', builder: (_, _) => const PlantsScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/quiz', builder: (_, _) => const QuizTab())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/shop', builder: (_, _) => const ShopScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      GoRoute(
        path: '/plant/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => PlantDetailScreen(plantId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/plant/:id/label',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => LabelGameScreen(plantId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/plant/:id/colour',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => ColouringScreen(
          plantId: state.pathParameters['id']!,
          fromGallery: state.uri.queryParameters['from'] == 'gallery',
        ),
      ),
      GoRoute(
        path: '/plant/:id/grow',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => GrowGameScreen(plantId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/games/match', parentNavigatorKey: _rootKey, builder: (_, _) => const MatchGameScreen()),
      GoRoute(
        path: '/quiz/plant/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => QuizScreen(plantId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/quiz/review', parentNavigatorKey: _rootKey, builder: (_, _) => const QuizScreen(review: true)),
      GoRoute(
        path: '/quiz/level/:level',
        parentNavigatorKey: _rootKey,
        builder: (_, state) => QuizScreen(level: QuizLevel.values.byName(state.pathParameters['level']!)),
      ),
      GoRoute(path: '/settings', parentNavigatorKey: _rootKey, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/profile/edit', parentNavigatorKey: _rootKey, builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/profile/stickers', parentNavigatorKey: _rootKey, builder: (_, _) => const StickerBookScreen()),
      GoRoute(path: '/profile/badges', parentNavigatorKey: _rootKey, builder: (_, _) => const BadgesScreen()),
      GoRoute(path: '/profile/garden', parentNavigatorKey: _rootKey, builder: (_, _) => const GardenScreen()),
      GoRoute(path: '/garden/gallery', parentNavigatorKey: _rootKey, builder: (_, _) => const GalleryScreen()),
      // The work-in-progress previews stay reachable while building, and in
      // the browser preview at #/dev. Not in the phone release.
      if (kDebugMode || kIsWeb) GoRoute(path: '/dev', builder: (_, _) => const DevMenu()),
      if (kDebugMode || kIsWeb) GoRoute(path: '/rewards-preview', builder: (_, _) => const RewardsPreview()),
      if (kDebugMode || kIsWeb) GoRoute(path: '/layout-preview', builder: (_, _) => const LayoutPreview()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
