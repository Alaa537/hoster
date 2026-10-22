import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/haptics.dart';

/// Glassmorphism card with blur, subtle border, optional glow & shimmer.
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? accent;
  final double blur;
  final double radius;
  final VoidCallback? onTap;
  final bool glow;
  final bool shimmer;
  final EdgeInsets? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
    this.blur = 20,
    this.radius = 20,
    this.onTap,
    this.glow = false,
    this.shimmer = false,
    this.margin,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    if (widget.shimmer) {
      _shimmerCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3200),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _shimmerCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.accent ?? C.primary;

    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: Stack(
          children: [
            Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    C.surface.withValues(alpha: .90),
                    C.surfaceHi.withValues(alpha: .68),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border.all(
                  color: a.withValues(alpha: widget.glow ? .38 : .18),
                  width: widget.glow ? 1.3 : 1.05,
                ),
              ),
              child: widget.child,
            ),
            if (_shimmerCtrl != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _shimmerCtrl!,
                    builder: (_, __) {
                      final p = _shimmerCtrl!.value;
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.radius),
                          gradient: LinearGradient(
                            begin: Alignment(-1.5 + 3 * p, -0.4),
                            end: Alignment(-0.5 + 3 * p, 0.4),
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.04),
                              Colors.white.withValues(alpha: 0.09),
                              Colors.white.withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final box = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: widget.glow
            ? [
                BoxShadow(
                  color: a.withValues(alpha: .30),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: a.withValues(alpha: .12),
                  blurRadius: 50,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: .35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .32),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: a.withValues(alpha: .06),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: inner,
    );

    if (widget.onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.tap();
          widget.onTap!();
        },
        borderRadius: BorderRadius.circular(widget.radius),
        splashColor: a.withValues(alpha: .14),
        highlightColor: a.withValues(alpha: .05),
        child: box,
      ),
    );
  }
}
