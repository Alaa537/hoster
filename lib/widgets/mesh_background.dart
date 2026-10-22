import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'particle_field.dart';

/// Premium animated mesh gradient with floating particles.
class MeshBackground extends StatefulWidget {
  final Widget child;
  final bool subtle;
  final bool particles;
  const MeshBackground({
    super.key,
    required this.child,
    this.subtle = false,
    this.particles = true,
  });

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.subtle ? .11 : .26;
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: C.bg)),
        // Soft vignette
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.15,
                colors: [
                  Colors.transparent,
                  C.bg.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            final t = _c.value * 2 * math.pi;
            return Stack(children: [
              _blob(
                cx: 0.20 + 0.14 * math.cos(t * 0.65),
                cy: 0.16 + 0.10 * math.sin(t * 0.85),
                r: 420,
                color: C.primary.withValues(alpha: opacity),
              ),
              _blob(
                cx: 0.84 + 0.11 * math.sin(t * 1.05),
                cy: 0.55 + 0.13 * math.cos(t * 0.75),
                r: 380,
                color: C.accent.withValues(alpha: opacity),
              ),
              _blob(
                cx: 0.48 + 0.17 * math.sin(t * 0.48),
                cy: 0.90 + 0.07 * math.cos(t * 1.15),
                r: 320,
                color: const Color(0xFF7C4DFF).withValues(alpha: opacity * 0.8),
              ),
              // extra subtle teal blob
              _blob(
                cx: 0.65 + 0.10 * math.cos(t * 0.9),
                cy: 0.28 + 0.08 * math.sin(t * 1.3),
                r: 240,
                color: C.info.withValues(alpha: opacity * 0.5),
              ),
            ]);
          },
        ),
        if (widget.particles)
          Positioned.fill(
            child: ParticleField(
              count: widget.subtle ? 28 : 48,
              maxOpacity: widget.subtle ? 0.35 : 0.55,
            ),
          ),
        Positioned.fill(child: widget.child),
      ],
    );
  }

  Widget _blob({
    required double cx,
    required double cy,
    required double r,
    required Color color,
  }) {
    return LayoutBuilder(builder: (ctx, cons) {
      return Positioned(
        left: cons.maxWidth * cx - r,
        top: cons.maxHeight * cy - r,
        child: Container(
          width: r * 2,
          height: r * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: color.a * .4),
                Colors.transparent,
              ],
              stops: const [0, .42, 1],
            ),
          ),
        ),
      );
    });
  }
}
