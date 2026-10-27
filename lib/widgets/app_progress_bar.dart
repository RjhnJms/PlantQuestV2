import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded, chunky progress bar with a shiny top stripe.
///
/// Used for loading, Binhi's growth and quiz progress. Changes in [value]
/// slide smoothly.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.leaf,
    this.trackColor = AppColors.track,
    this.height = 16,
    this.semanticLabel,
    this.duration = const Duration(milliseconds: 600),
  });

  /// 0.0 to 1.0. Values outside are clamped.
  final double value;
  final Color color;
  final Color trackColor;
  final double height;
  final String? semanticLabel;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final target = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final radius = BorderRadius.circular(height / 2);

    return Semantics(
      label: semanticLabel,
      value: '${(target * 100).round()}%',
      child: Container(
        height: height,
        decoration: BoxDecoration(color: trackColor, borderRadius: radius),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: target),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => LayoutBuilder(
            builder: (context, constraints) {
              // Never draw a sliver thinner than the bar is tall, so a tiny
              // value still looks like a round blob, not a scratch.
              final width = v <= 0 ? 0.0 : (constraints.maxWidth * v).clamp(height, constraints.maxWidth);
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.lerp(color, Colors.white, 0.15)!, color],
                    ),
                  ),
                  child: width < height * 1.5
                      ? null
                      : Padding(
                          padding: EdgeInsets.fromLTRB(height * 0.45, height * 0.2, height * 0.45, 0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: height * 0.22,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.45),
                                borderRadius: radius,
                              ),
                            ),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
