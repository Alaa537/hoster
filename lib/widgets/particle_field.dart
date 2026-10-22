import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Floating particle field for premium ambient atmosphere.
class ParticleField extends StatefulWidget {
  final int count;
  final double maxOpacity;
  final bool interactive;

  const ParticleField({
    super.key,
    this.count = 42,
    this.maxOpacity = 0.55,
    this.interactive = false,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  final _rng = math.Random(42);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
    _particles = List.generate(widget.count, (_) => _Particle.random(_rng));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              t: _ctrl.value,
              maxOpacity: widget.maxOpacity,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x0, y0;
  final double speed;
  final double size;
  final double phase;
  final Color color;
  final double drift;

  _Particle({
    required this.x0,
    required this.y0,
    required this.speed,
    required this.size,
    required this.phase,
    required this.color,
    required this.drift,
  });

  factory _Particle.random(math.Random r) {
    final colors = [
      C.primary,
      C.accent,
      const Color(0xFF7C4DFF),
      C.info,
      C.primary.withValues(alpha: 0.7),
    ];
    return _Particle(
      x0: r.nextDouble(),
      y0: r.nextDouble(),
      speed: 0.15 + r.nextDouble() * 0.45,
      size: 1.2 + r.nextDouble() * 3.5,
      phase: r.nextDouble() * math.pi * 2,
      color: colors[r.nextInt(colors.length)],
      drift: (r.nextDouble() - 0.5) * 0.35,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  final double maxOpacity;

  _ParticlePainter({
    required this.particles,
    required this.t,
    required this.maxOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final life = (t * p.speed + p.phase) % 1.0;
      final y = (p.y0 - life * 0.55) % 1.2;
      final x = (p.x0 + math.sin(life * math.pi * 2 + p.phase) * p.drift) % 1.0;
      final fade = (math.sin(life * math.pi)).clamp(0.0, 1.0);
      final opacity = fade * maxOpacity * (0.4 + 0.6 * (p.size / 4.5));

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.6);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );

      // core bright point
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size * 0.35,
        Paint()..color = Colors.white.withValues(alpha: opacity * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}
