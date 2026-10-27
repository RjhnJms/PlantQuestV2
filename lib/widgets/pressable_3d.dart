import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_sizes.dart';

/// Extra feedback on every chunky press, set once at startup.
///
/// Step 6 plugs the soft tap sound in here, so widgets don't need to know
/// about audio.
abstract final class PressFeedback {
  static VoidCallback? onPress;
}

/// The shared "chunky 3D" surface behind buttons and cards.
///
/// The face sits on a darker ledge. On tap-down the face sinks onto the
/// ledge, the phone gives a light vibration, and the surface springs back
/// on release. Total height never changes, so nothing around it jumps.
class Pressable3D extends StatefulWidget {
  const Pressable3D({
    super.key,
    required this.child,
    required this.faceColor,
    required this.ledgeColor,
    this.onTap,
    this.borderColor,
    this.radius = AppSizes.radiusM,
    this.padding = EdgeInsets.zero,
    this.minHeight = 0,
    this.highlight = true,
    this.glow = true,
    this.semanticLabel,
    this.isButton = true,
  });

  final Widget child;
  final Color faceColor;
  final Color ledgeColor;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double minHeight;

  /// Soft lighter band on the top half, for the "sticker" look.
  final bool highlight;

  /// Soft colored shadow below (never grey).
  final bool glow;

  final String? semanticLabel;
  final bool isButton;

  @override
  State<Pressable3D> createState() => _Pressable3DState();
}

class _Pressable3DState extends State<Pressable3D> {
  static const _pressDuration = Duration(milliseconds: 70);
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTapDown(TapDownDetails _) {
    _setPressed(true);
    HapticFeedback.lightImpact();
    PressFeedback.onPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final ledge = _pressed ? AppSizes.depthPressed : AppSizes.depth;
    final sink = AppSizes.depth - ledge;
    final radius = BorderRadius.circular(widget.radius);
    final face = widget.faceColor;

    final surface = AnimatedContainer(
      duration: _pressDuration,
      curve: Curves.easeOut,
      margin: EdgeInsets.only(top: sink, bottom: ledge),
      constraints: BoxConstraints(minHeight: widget.minHeight),
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: face,
        gradient: widget.highlight
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.55, 1],
                colors: [Color.lerp(face, Colors.white, 0.2)!, face, face],
              )
            : null,
        border: widget.borderColor == null ? null : Border.all(color: widget.borderColor!, width: AppSizes.borderWidth),
        boxShadow: [
          if (widget.glow && !_pressed)
            BoxShadow(
              color: widget.ledgeColor.withValues(alpha: 0.28),
              offset: const Offset(0, AppSizes.depth + 4),
              blurRadius: 14,
            ),
          BoxShadow(color: widget.ledgeColor, offset: Offset(0, ledge)),
        ],
      ),
      child: widget.child,
    );

    // With a label, it replaces the child's text for screen readers, so the
    // label isn't read twice ("CHECK, CHECK"). The tap action is declared
    // here because excluded children can't provide it.
    final hasLabel = widget.semanticLabel != null;

    if (!_enabled) {
      return Semantics(
        button: widget.isButton,
        enabled: false,
        label: widget.semanticLabel,
        excludeSemantics: hasLabel,
        child: surface,
      );
    }

    return Semantics(
      button: widget.isButton,
      enabled: true,
      label: widget.semanticLabel,
      excludeSemantics: hasLabel,
      onTap: widget.onTap,
      child: GestureDetector(
        excludeFromSemantics: true,
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: surface,
      ),
    );
  }
}
