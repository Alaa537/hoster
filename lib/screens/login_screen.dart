import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/haptics.dart';
import '../widgets/gradient_button.dart';
import '../widgets/particle_field.dart';
import '../widgets/neon_border.dart';
import '../widgets/premium_dialogs.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  bool _obscure = true;

  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      Haptics.error();
      return;
    }
    Haptics.medium();
    setState(() => _busy = true);
    final username = _user.text.trim();
    final password = _pass.text;
    final e = await context.read<AuthProvider>().login(username, password);
    if (!mounted) return;
    setState(() => _busy = false);
    if (e != null) {
      Haptics.error();
      await showErrorDialog(
        context,
        title: 'فشل تسجيل الدخول',
        message: e,
      );
    } else {
      Haptics.success();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          // Animated mesh blobs
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) {
              final t = _bgCtrl.value * 2 * math.pi;
              return Stack(children: [
                _blob(
                  size.width * (.22 + .18 * math.cos(t)),
                  size.height * (.22 + .08 * math.sin(t * 1.2)),
                  280,
                  C.primary.withValues(alpha: .28),
                ),
                _blob(
                  size.width * (.78 + .14 * math.sin(t * 1.1)),
                  size.height * (.68 + .12 * math.cos(t)),
                  260,
                  C.accent.withValues(alpha: .26),
                ),
                _blob(
                  size.width * (.5 + .2 * math.sin(t * 0.6)),
                  size.height * (.45 + .1 * math.cos(t * 0.9)),
                  200,
                  const Color(0xFF7C4DFF).withValues(alpha: .18),
                ),
              ]);
            },
          ),

          // Floating particles
          const Positioned.fill(
            child: ParticleField(count: 36, maxOpacity: 0.45),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 36),

                    // Logo with pulse glow
                    Center(
                      child: PulseGlow(
                        color: C.primary,
                        maxBlur: 36,
                        child: _logoMark(),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(.55, .55),
                          curve: Curves.elasticOut,
                          duration: 1000.ms,
                        ),

                    const SizedBox(height: 28),

                    // Title
                    Center(
                      child: ShaderMask(
                        shaderCallback: (r) => const LinearGradient(
                          colors: [C.primary, C.accent, C.primary],
                        ).createShader(r),
                        child: const Text(
                          'HOST PANEL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 700.ms, delay: 250.ms).slideY(begin: 0.2),

                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'تسجيل الدخول للمتابعة',
                        style: TextStyle(
                          color: C.muted,
                          fontSize: 13,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(duration: 700.ms, delay: 450.ms),

                    const SizedBox(height: 48),

                    // User field
                    _glowField(
                      controller: _user,
                      label: 'اسم المستخدم',
                      icon: Icons.person_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'أدخل اسم المستخدم';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 600.ms)
                        .slideX(begin: -0.12, end: 0, curve: Curves.easeOutCubic),

                    const SizedBox(height: 16),

                    // Pass field
                    _glowField(
                      controller: _pass,
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: C.muted,
                          size: 20,
                        ),
                        onPressed: () {
                          Haptics.tap();
                          setState(() => _obscure = !_obscure);
                        },
                      ),
                      onSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 750.ms)
                        .slideX(begin: -0.12, end: 0, curve: Curves.easeOutCubic),

                    const SizedBox(height: 36),

                    GradientButton(
                      label: 'دخول',
                      icon: Icons.login_rounded,
                      busy: _busy,
                      onTap: _submit,
                      height: 54,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 900.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ليس لديك حساب؟  ',
                          style: TextStyle(color: C.muted, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Haptics.tap();
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    const RegisterScreen(),
                                transitionsBuilder: (_, anim, __, child) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.08, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: anim,
                                        curve: Curves.easeOutCubic,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                transitionDuration:
                                    const Duration(milliseconds: 320),
                              ),
                            );
                          },
                          child: const Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              color: C.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms, delay: 1050.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoMark() {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [C.primary, C.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: C.primary.withValues(alpha: .45),
            blurRadius: 32,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: C.accent.withValues(alpha: .30),
            blurRadius: 48,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: C.bg,
        ),
        child: const Icon(
          Icons.cloud_rounded,
          size: 42,
          color: C.primary,
        ),
      ),
    );
  }

  Widget _glowField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: C.primary.withValues(alpha: .06),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        validator: validator,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: C.primary.withValues(alpha: .8), size: 22),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  Widget _blob(double x, double y, double r, Color color) {
    return Positioned(
      left: x - r,
      top: y - r,
      child: Container(
        width: r * 2,
        height: r * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
