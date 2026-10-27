import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import 'pressable_3d.dart';

/// A rounded card on a 3D ledge. Tappable when [onTap] is set.
///
/// Defaults to the white card from the screenshots. Pass [color] and
/// [ledgeColor] for colored cards like the world banner or the Sprout Quiz
/// card, and [outlineColor] to ring it (selected answer, current plant).
class ChunkyCard extends StatelessWidget {
  const ChunkyCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.card,
    this.ledgeColor = AppColors.borderDeep,
    this.outlineColor,
    this.padding = const EdgeInsets.all(AppSizes.gapL),
    this.radius = AppSizes.radiusL,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color ledgeColor;

  /// Ring color. White cards get the soft [AppColors.border] ring by default.
  final Color? outlineColor;

  final EdgeInsetsGeometry padding;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isWhite = color == AppColors.card;
    return Pressable3D(
      onTap: onTap,
      faceColor: color,
      ledgeColor: ledgeColor,
      borderColor: outlineColor ?? (isWhite ? AppColors.border : null),
      radius: radius,
      padding: padding,
      minHeight: onTap != null ? AppSizes.minTap : 0,
      highlight: !isWhite,
      glow: !isWhite,
      semanticLabel: semanticLabel,
      isButton: onTap != null,
      child: child,
    );
  }
}
