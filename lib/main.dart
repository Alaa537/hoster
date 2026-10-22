import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/telegram_fab.dart';
import 'services/connectivity_service.dart';
import 'widgets/premium_dialogs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF07070F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await ConnectivityService.I.start();
  runApp(const HostingApp());
}

class HostingApp extends StatelessWidget {
  const HostingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'HOST PANEL',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const _ConnectivityGate(child: SplashScreen()),
        builder: (context, child) => Stack(children: [
          if (child != null) child,
          const Positioned(
            left: 16,
            bottom: 100,
            child: TelegramFab(),
          ),
        ]),
      ),
    );
  }
}

/// Listens to connectivity and shows offline dialog when connection is lost.
class _ConnectivityGate extends StatefulWidget {
  final Widget child;
  const _ConnectivityGate({required this.child});

  @override
  State<_ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<_ConnectivityGate> {
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    ConnectivityService.I.stream.listen(_onConnectivity);
  }

  void _onConnectivity(bool online) {
    if (!mounted) return;
    if (!online && !_dialogShowing) {
      _dialogShowing = true;
      showOfflineDialog(
        context,
        onRetry: () async {
          final ok = await ConnectivityService.I.checkNow();
          if (!ok && mounted) {
            // will re-trigger if still offline
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted && !ConnectivityService.I.isOnline) {
                _dialogShowing = false;
                _onConnectivity(false);
              }
            });
          }
        },
      ).then((_) => _dialogShowing = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
