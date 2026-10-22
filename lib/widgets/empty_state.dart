import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';
import 'gradient_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? C.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.withValues(alpha: .25),
                    c.withValues(alpha: .05),
                  ],
                ),
                border: Border.all(color: c.withValues(alpha: .35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: c.withValues(alpha: .20),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, size: 42, color: c),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: C.muted,
                  height: 1.45,
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 180,
                child: GradientButton(
                  label: actionLabel!,
                  height: 46,
                  onTap: onAction,
                ),
              ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.2),
            ],
          ],
        ),
      ),
    );
  }
}
