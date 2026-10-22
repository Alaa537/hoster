import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Animated rotating neon gradient border around a child.
class NeonBorder extends StatefulWidget {
  final Widget child;
  final double radius;
  final double strokeWidth;
  final List<Color>? colors;
  final Duration duration;
  final EdgeInsets padding;
  final bool glow;

  const NeonBorder({
    super.key,
    required this.child,
    this.radius = 20,
    this.strokeWidth = 1.6,
    this.colors,
    this.duration = const Duration(seconds: 4),
    this.padding = const EdgeInsets.all(1.5),
    this.glow = true,
  });

  @override
  State<NeonBorder> createState() => _NeonBorderState();
}

class _NeonBorderState extends State<NeonBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [C.primary, C.accent, const Color(0xFF7C4DFF), C.primary];

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        return CustomPaint(
          painter: _NeonPainter(
            progress: _ctrl.value,
            colors: colors,
            radius: widget.radius,
            strokeWidth: widget.strokeWidth,
            glow: widget.glow,
          ),
          child: Padding(
            padding: widget.padding,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius - 1),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _NeonPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double radius;
  final double strokeWidth;
  final bool glow;

  _NeonPainter({
    required this.progress,
    required this.colors,
    required this.radius,
    required this.strokeWidth,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    final sweep = SweepGradient(
      colors: colors,
      transform: GradientRotation(progress * 2 * math.pi),
    );

    final paint = Paint()
      ..shader = sweep.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (glow) {
      final glowPaint = Paint()
        ..shader = sweep.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = Colors.white.withValues(alpha: 0.3);
      canvas.drawRRect(rrect, glowPaint);
    }

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _NeonPainter old) =>
      old.progress != progress || old.glow != glow;
}

/// Soft pulsing glow behind a widget.
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double maxBlur;
  final double minOpacity;
  final double maxOpacity;

  const PulseGlow({
    super.key,
    required this.child,
    this.color = C.primary,
    this.maxBlur = 28,
    this.minOpacity = 0.15,
    this.maxOpacity = 0.45,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        final opacity =
            widget.minOpacity + (widget.maxOpacity - widget.minOpacity) * t;
        final blur = widget.maxBlur * (0.6 + 0.4 * t);
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: opacity),
                blurRadius: blur,
                spreadRadius: 2 + 4 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
