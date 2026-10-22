import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Glass card with a sweeping shimmer highlight.
class ShimmerGlass extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? accent;
  final bool shimmer;
  final VoidCallback? onTap;

  const ShimmerGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.accent,
    this.shimmer = true,
    this.onTap,
  });

  @override
  State<ShimmerGlass> createState() => _ShimmerGlassState();
}

class _ShimmerGlassState extends State<ShimmerGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.accent ?? C.primary;

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Stack(
          children: [
            Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    C.surface.withValues(alpha: .90),
                    C.surfaceHi.withValues(alpha: .72),
                  ],
                ),
                border: Border.all(
                  color: a.withValues(alpha: .22),
                  width: 1.1,
                ),
              ),
              child: widget.child,
            ),
            if (widget.shimmer)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: _ShimmerPainter(progress: _ctrl.value),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: a.withValues(alpha: .10),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: content,
    );

    if (widget.onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.radius),
          splashColor: a.withValues(alpha: .12),
          child: content,
        ),
      );
    }
    return content;
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width + (size.width * 2.4) * progress;
    final rect = Rect.fromLTWH(x, 0, size.width * 0.45, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.10),
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0, 0.3, 0.5, 0.7, 1],
      ).createShader(rect)
      ..blendMode = BlendMode.srcATop;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) => old.progress != progress;
}
