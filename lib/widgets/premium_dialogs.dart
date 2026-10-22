import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';
import '../utils/haptics.dart';
import 'gradient_button.dart';

/// Premium glass-style dialogs for confirmations, prompts, info, errors, and offline.

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'تأكيد',
  String cancelLabel = 'إلغاء',
  bool danger = false,
  IconData? icon,
  bool barrierDismissible = true,
}) async {
  Haptics.medium();
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'confirm',
    barrierColor: Colors.black.withValues(alpha: .65),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: _PremiumDialogShell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogIcon(
                  icon: icon ??
                      (danger ? Icons.warning_amber_rounded : Icons.help_outline_rounded),
                  color: danger ? C.danger : C.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: C.muted,
                      height: 1.55,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: GhostButton(
                        label: cancelLabel,
                        onTap: () {
                          Haptics.tap();
                          Navigator.pop(ctx, false);
                        },
                        color: C.muted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        label: confirmLabel,
                        height: 48,
                        colors: danger
                            ? [C.danger, const Color(0xFFFF1744)]
                            : null,
                        onTap: () {
                          Haptics.success();
                          Navigator.pop(ctx, true);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}

Future<String?> showPromptDialog(
  BuildContext context, {
  required String title,
  String? message,
  String? hint,
  String initial = '',
  String confirmLabel = 'حسناً',
  bool obscure = false,
  int maxLines = 1,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) async {
  Haptics.medium();
  final controller = TextEditingController(text: initial);
  final formKey = GlobalKey<FormState>();

  final result = await showGeneralDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'prompt',
    barrierColor: Colors.black.withValues(alpha: .65),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
        child: FadeTransition(
          opacity: anim,
          child: _PremiumDialogShell(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogIcon(icon: Icons.edit_rounded, color: C.primary),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: C.muted, height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: controller,
                    obscureText: obscure,
                    maxLines: maxLines,
                    autofocus: true,
                    keyboardType: keyboardType,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    validator: validator,
                    decoration: InputDecoration(
                      hintText: hint,
                      filled: true,
                      fillColor: C.surfaceHi,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: GhostButton(
                          label: 'إلغاء',
                          onTap: () {
                            Haptics.tap();
                            Navigator.pop(ctx);
                          },
                          color: C.muted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          label: confirmLabel,
                          height: 48,
                          onTap: () {
                            if (formKey.currentState?.validate() ?? true) {
                              Haptics.success();
                              Navigator.pop(ctx, controller.text);
                            }
                          },
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
    },
  );
  return result;
}

Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  IconData icon = Icons.info_outline_rounded,
  Color? color,
  String buttonLabel = 'حسناً',
}) async {
  Haptics.tap();
  final c = color ?? C.info;
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'info',
    barrierColor: Colors.black.withValues(alpha: .65),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.88, end: 1)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: FadeTransition(
          opacity: anim,
          child: _PremiumDialogShell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogIcon(icon: icon, color: c),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, color: C.muted, height: 1.55),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: buttonLabel,
                    height: 48,
                    colors: [c, c.withValues(alpha: .8)],
                    onTap: () {
                      Haptics.tap();
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'حسناً',
}) {
  return showInfoDialog(
    context,
    title: title,
    message: message,
    icon: Icons.error_outline_rounded,
    color: C.danger,
    buttonLabel: buttonLabel,
  );
}

Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'ممتاز',
}) {
  return showInfoDialog(
    context,
    title: title,
    message: message,
    icon: Icons.check_circle_outline_rounded,
    color: C.success,
    buttonLabel: buttonLabel,
  );
}

/// Full-screen style offline overlay / dialog
Future<void> showOfflineDialog(BuildContext context, {VoidCallback? onRetry}) async {
  Haptics.error();
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'offline',
    barrierColor: Colors.black.withValues(alpha: .75),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
        child: FadeTransition(
          opacity: anim,
          child: _PremiumDialogShell(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        C.warning.withValues(alpha: .35),
                        C.warning.withValues(alpha: .05),
                      ],
                    ),
                    border: Border.all(color: C.warning.withValues(alpha: .4), width: 2),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 42,
                    color: C.warning,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                      duration: 1400.ms,
                      curve: Curves.easeInOut,
                    ),
                const SizedBox(height: 22),
                const Text(
                  'لا يوجد اتصال بالإنترنت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تحقق من اتصال الشبكة وحاول مرة أخرى.\nبعض الميزات لن تعمل بدون إنترنت.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: C.muted, height: 1.55),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'إعادة المحاولة',
                    icon: Icons.refresh_rounded,
                    height: 50,
                    colors: const [C.warning, Color(0xFFFFAB00)],
                    onTap: () {
                      Haptics.medium();
                      Navigator.pop(ctx);
                      onRetry?.call();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Haptics.tap();
                    Navigator.pop(ctx);
                  },
                  child: const Text('إغلاق', style: TextStyle(color: C.muted)),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ─── Internal helpers ───────────────────────────────────────────

class _PremiumDialogShell extends StatelessWidget {
  final Widget child;
  const _PremiumDialogShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      C.surfaceHi.withValues(alpha: .95),
                      C.surface.withValues(alpha: .92),
                    ],
                  ),
                  border: Border.all(
                    color: C.primary.withValues(alpha: .22),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: C.primary.withValues(alpha: .12),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .5),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _DialogIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: .30),
            color.withValues(alpha: .06),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: .45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .35),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: 34, color: color),
    );
  }
}
