import 'package:flutter/material.dart';

/// A number that counts up (or down) to its new value instead of jumping.
///
/// The first build shows [value] right away; only later changes animate.
class TickingNumber extends StatelessWidget {
  const TickingNumber({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
    this.duration = const Duration(milliseconds: 700),
  });

  final int value;
  final TextStyle style;
  final String prefix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value.toDouble(), end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$prefix${v.round()}', style: style),
    );
  }
}
