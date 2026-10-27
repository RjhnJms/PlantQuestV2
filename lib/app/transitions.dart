import 'package:flutter/material.dart';

/// Playful page changes (PLAN.md §9): the new page slides in from the side
/// while growing to full size with a tiny bounce; the page underneath eases
/// back. With "less motion" (or the phone's "remove animations") pages just
/// fade.
class PlayfulPageTransitionsBuilder extends PageTransitionsBuilder {
  const PlayfulPageTransitionsBuilder();

  /// Set from the "less motion" setting (see main.dart).
  static bool calm = false;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (calm || MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    final enter = CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
    final under = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, child) {
        final t = enter.value;
        final back = under.value;
        return FractionalTranslation(
          translation: Offset((1 - t) * 0.35 - back * 0.08, 0),
          child: Transform.scale(
            scale: (0.92 + 0.08 * t) * (1 - 0.04 * back),
            child: Opacity(opacity: animation.value.clamp(0.0, 1.0), child: child),
          ),
        );
      },
      child: child,
    );
  }
}
