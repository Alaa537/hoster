import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: C.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.primary.withValues(alpha: .25)),
                boxShadow: [
                  BoxShadow(
                    color: C.primary.withValues(alpha: .15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(icon, size: 18, color: C.primary),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Colors.white, C.primary],
                  ).createShader(r),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(color: C.muted, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.04, end: 0);
  }
}
