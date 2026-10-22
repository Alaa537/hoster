import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Animated glowing border that rotates a gradient around the child.
class GlowBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double thickness;
  final List<Color>? colors;
  final Duration duration;

  const GlowBorder({
    super.key,
    required this.child,
    this.radius = 18,
    this.thickness = 1.5,
    this.colors,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<GlowBorder> createState() => _GlowBorderState();
}

class _GlowBorderState extends State<GlowBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [C.primary, C.accent, const Color(0xFF7C4DFF), C.primary];

    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: SweepGradient(
              colors: colors,
              transform: GradientRotation(_c.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: .25),
                blurRadius: 16,
              ),
            ],
          ),
          padding: EdgeInsets.all(widget.thickness),
          child: Container(
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(widget.radius - 1),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
