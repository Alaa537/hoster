import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../models/app_models.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/haptics.dart';
import '../widgets/glass_card.dart';
import '../widgets/skeleton.dart';
import '../widgets/app_toast.dart';
import '../utils/error_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  ServerResources? _res;
  AppStatus? _app;
  String? _err;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final api = context.read<AuthProvider>().api;
    if (api == null) return;
    try {
      final r = await Future.wait([api.serverResources(), api.appStatus()]);
      if (!mounted) return;
      setState(() {
        _res = r[0] as ServerResources;
        _app = r[1] as AppStatus;
        _err = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _err = friendlyError(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            Haptics.medium();
            await _load();
          },
          color: C.primary,
          backgroundColor: C.surface,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              _header().animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const SizedBox(height: 18),
              if (_loading) const SkeletonList(count: 3),
              if (_err != null) _errCard().animate().fadeIn().shake(hz: 2, duration: 400.ms),
              if (_res != null)
                _resourcesCard(_res!)
                    .animate()
                    .fadeIn(duration: 450.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),
              if (_app != null) ...[
                const SizedBox(height: 16),
                _appCard(_app!)
                    .animate()
                    .fadeIn(duration: 450.ms, delay: 80.ms)
                    .slideY(begin: 0.06, curve: Curves.easeOutCubic),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final user = context.watch<AuthProvider>().user;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [C.primary, C.accent],
                ).createShader(r),
                child: const Text(
                  'HOST PANEL',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'مرحباً، ${user?.username ?? '—'}',
                style: const TextStyle(color: C.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        if (user?.isAdmin == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [C.accent, C.accentDim]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: C.accent.withValues(alpha: .35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _errCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: C.danger.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.danger.withValues(alpha: .4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: C.danger.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: C.danger, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _err!,
                style: const TextStyle(color: C.danger, fontSize: 13),
              ),
            ),
          ],
        ),
      );

  Widget _resourcesCard(ServerResources r) {
    final stateC = stateColor(r.state);
    return GlassCard(
      accent: stateC,
      glow: r.state == 'running',
      shimmer: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: stateC,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: stateC.withValues(alpha: .6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  r.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateC.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stateC.withValues(alpha: .4)),
                ),
                child: Text(
                  r.state.toUpperCase(),
                  style: TextStyle(
                    color: stateC,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _metaChip(Icons.timer_outlined, fTime(r.uptimeSeconds)),
              const SizedBox(width: 10),
              _metaChip(
                Icons.favorite_rounded,
                r.healthLevel.toUpperCase(),
                color: r.healthLevel == 'ok' ? C.success : C.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _bar('CPU', r.cpu, null, null, C.primary),
          const SizedBox(height: 14),
          _bar('MEM', r.memPercent, r.memUsed, r.memLimit, C.accent),
          const SizedBox(height: 14),
          _bar('DISK', r.diskPercent, r.diskUsed, r.diskLimit, C.info),
          const SizedBox(height: 16),
          Row(
            children: [
              _net('↓', fSize(r.netRx), C.success),
              const SizedBox(width: 16),
              _net('↑', fSize(r.netTx), C.accent),
            ],
          ),
          if (r.healthIssues.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...r.healthIssues.take(3).map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: C.warning, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            i,
                            style: const TextStyle(
                              color: C.warning,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String text, {Color? color}) {
    final c = color ?? C.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: C.surfaceHi,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: c,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double? pct, int? used, int? limit, Color color) {
    final v = (pct ?? 0).clamp(0.0, 100.0);
    final colorByPct =
        v < 70 ? C.success : v < 88 ? C.warning : C.danger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                label,
                style: const TextStyle(
                  color: C.muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      color: C.border.withValues(alpha: .6),
                    ),
                    FractionallySizedBox(
                      widthFactor: (v / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorByPct.withValues(alpha: .7),
                              colorByPct,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: colorByPct.withValues(alpha: .4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              child: Text(
                '${v.toStringAsFixed(1)}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colorByPct,
                ),
              ),
            ),
          ],
        ),
        if (limit != null && limit > 0)
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 40),
            child: Text(
              '${fSize(used ?? 0)} / ${fSize(limit)}',
              style: const TextStyle(color: C.mutedLo, fontSize: 10.5),
            ),
          ),
      ],
    );
  }

  Widget _net(String arrow, String val, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withValues(alpha: .25)),
        ),
        child: Row(
          children: [
            Text(
              arrow,
              style: TextStyle(
                color: c,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                val,
                style: TextStyle(
                  color: c,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appCard(AppStatus app) {
    final running = app.state == 'running' || app.state == 'online';
    final stateC = running ? C.success : C.muted;
    return GlassCard(
      accent: stateC,
      glow: running,
      shimmer: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: stateC.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: stateC,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حالة التطبيق',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app.state.toUpperCase(),
                      style: TextStyle(
                        color: stateC,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: C.border),
          const SizedBox(height: 12),
          _infoRow(Icons.timer_outlined, fTime(app.uptimeSeconds)),
          if (app.name.isNotEmpty)
            _infoRow(Icons.label_outline_rounded, app.name),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: C.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: C.muted, fontSize: 12.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
