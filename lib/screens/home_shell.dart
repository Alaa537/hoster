import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/storage.dart';
import '../utils/constants.dart';
import '../utils/haptics.dart';
import '../widgets/banner_widget.dart';
import '../widgets/mesh_background.dart';
import '../widgets/pulse_icon.dart';
import '../widgets/premium_dialogs.dart';
import 'dashboard_screen.dart';
import 'server_screen.dart';
import 'files_screen.dart';
import 'app_screen.dart';
import 'more_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  bool _pendingRestart = false;

  static const _tabs = [
    DashboardScreen(),
    ServerScreen(),
    FilesScreen(),
    AppScreen(),
    MoreScreen(),
  ];

  static const _labels = ['لوحة', 'سيرفر', 'ملفات', 'بوتي', 'المزيد'];
  static const _icons = [
    Icons.dashboard_rounded,
    Icons.dns_rounded,
    Icons.folder_rounded,
    Icons.smart_toy_rounded,
    Icons.grid_view_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _checkPending();
  }

  Future<void> _checkPending() async {
    final v = await Store.getPendingRestart();
    if (mounted) setState(() => _pendingRestart = v);
  }

  void _switchTab(int i) {
    if (i == _i) return;
    Haptics.select();
    setState(() => _i = i);
  }

  @override
  Widget build(BuildContext context) {
    final bs = context.watch<AuthProvider>().bootstrap_;
    final banners = bs?.banners ?? const [];

    return Scaffold(
      body: MeshBackground(
        subtle: true,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (_pendingRestart) _restartBanner(),
              if (banners.isNotEmpty)
                ...banners.map((b) => BannerStrip(banner: b)),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.03, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_i),
                    child: _tabs[_i],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: BoxDecoration(
        color: C.surface.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: C.primary.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .45),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: C.primary.withValues(alpha: .12),
            blurRadius: 40,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: C.accent.withValues(alpha: .06),
            blurRadius: 48,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_labels.length, (i) {
            final active = _i == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => _switchTab(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? C.primary.withValues(alpha: .14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: active
                        ? Border.all(color: C.primary.withValues(alpha: .35))
                        : Border.all(color: Colors.transparent),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: C.primary.withValues(alpha: .18),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedScale(
                        scale: active ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        child: PulseIcon(
                          icon: _icons[i],
                          active: active,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: active ? 11 : 10.5,
                          fontWeight:
                              active ? FontWeight.w800 : FontWeight.w600,
                          color: active ? C.primary : C.muted,
                        ),
                        child: Text(_labels[i]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _restartBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            C.warning.withValues(alpha: .18),
            C.warning.withValues(alpha: .08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.warning.withValues(alpha: .45)),
        boxShadow: [
          BoxShadow(
            color: C.warning.withValues(alpha: .12),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: C.warning.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.pending_actions_rounded,
                color: C.warning, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'تغييرات معلّقة — أعد تشغيل التطبيق',
              style: TextStyle(
                color: C.warning,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final ok = await showConfirmDialog(
                context,
                title: 'إعادة تشغيل التطبيق؟',
                message: 'سيتم إعادة تشغيل البوت لتطبيق التغييرات.',
                confirmLabel: 'إعادة التشغيل',
                icon: Icons.restart_alt_rounded,
              );
              if (!ok || !mounted) return;
              try {
                final api = context.read<AuthProvider>().api!;
                await api.appRestart();
                await Store.setPendingRestart(false);
                if (mounted) setState(() => _pendingRestart = false);
              } catch (_) {}
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [C.warning, Color(0xFFFFAB00)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: C.warning.withValues(alpha: .4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Text(
                'إعادة',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
