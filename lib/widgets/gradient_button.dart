import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/haptics.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool busy;
  final double height;
  final List<Color>? colors;
  final bool expanded;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.busy = false,
    this.height = 54,
    this.colors,
    this.expanded = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with TickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final AnimationController _shineCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _pressCtrl;
    _shineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  void _down() {
    if (widget.busy || widget.onTap == null) return;
    _pressCtrl.reverse();
    Haptics.tap();
  }

  void _up() => _pressCtrl.forward();

  @override
  Widget build(BuildContext context) {
    final c = widget.colors ?? [C.primary, C.accent];
    final enabled = !widget.busy && widget.onTap != null;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _down(),
        onTapUp: (_) {
          _up();
          if (enabled) widget.onTap!();
        },
        onTapCancel: _up,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          width: widget.expanded ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: enabled
                  ? c
                  : c.map((x) => x.withValues(alpha: .38)).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: c.first.withValues(alpha: .50),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: c.last.withValues(alpha: .28),
                      blurRadius: 36,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shine sweep
                if (enabled)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shineCtrl,
                      builder: (_, __) {
                        final p = _shineCtrl.value;
                        return Transform.translate(
                          offset: Offset(
                            -80 + (MediaQuery.of(context).size.width + 160) * p,
                            0,
                          ),
                          child: Transform.rotate(
                            angle: -0.4,
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.28),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Content
                widget.busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.black,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.black, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color;
  final double height;

  const GhostButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.color = C.primary,
    this.height = 48,
  });

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        Haptics.tap();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: widget.height,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _pressed ? .20 : .10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.color.withValues(alpha: .42),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _pressed ? .25 : .12),
              blurRadius: 14,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.color, size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final double size;
  final String? tooltip;

  const GlowIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color = C.primary,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.tap();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color.withValues(alpha: .12),
            border: Border.all(color: color.withValues(alpha: .32)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .22),
                blurRadius: 14,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size * 0.45),
        ),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}
