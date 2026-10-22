import 'package:flutter/services.dart';

enum SecurityStatus {
  ok, vpn, mitm, tampered, ssl,
  rooted, frida, emulator, debugger, xposed, error,
}

class SecurityResult {
  final SecurityStatus status;
  final String? message;
  final Map<String, dynamic> debug;

  SecurityResult._(this.status, [this.message, this.debug = const {}]);

  factory SecurityResult.ok() => SecurityResult._(SecurityStatus.ok);
  factory SecurityResult.vpn([String? m]) =>
      SecurityResult._(SecurityStatus.vpn, m ?? 'VPN نشط');
  factory SecurityResult.mitm([String? m]) =>
      SecurityResult._(SecurityStatus.mitm, m ?? 'أداة مراقبة');
  factory SecurityResult.tampered(String m, [Map<String, dynamic>? d]) =>
      SecurityResult._(SecurityStatus.tampered, m, d ?? const {});
  factory SecurityResult.rooted() =>
      SecurityResult._(SecurityStatus.rooted, 'Rooted');
  factory SecurityResult.frida() =>
      SecurityResult._(SecurityStatus.frida, 'Frida');
  factory SecurityResult.debugger() =>
      SecurityResult._(SecurityStatus.debugger, 'Debugger');
  factory SecurityResult.xposed() =>
      SecurityResult._(SecurityStatus.xposed, 'Xposed');
  factory SecurityResult.error(String m, [Map<String, dynamic>? d]) =>
      SecurityResult._(SecurityStatus.error, m, d ?? const {});

  bool get isOk => status == SecurityStatus.ok;
}

class SecurityService {
  static const _channel = MethodChannel('hosting/security');

  static Future<T?> _native<T>(String method) async {
    try {
      return await _channel.invokeMethod<T>(method);
    } catch (_) {
      return null;
    }
  }

  /// Local device checks only — remote signature verification removed.
  static Future<SecurityResult> verify() async {
    // 1) Debugger
    if (await _native<bool>('isDebuggable') == true) {
      return SecurityResult.debugger();
    }
    // 2) Root
    if (await _native<bool>('isRooted') == true) {
      return SecurityResult.rooted();
    }
    // 3) Frida
    if (await _native<bool>('isFridaRunning') == true) {
      return SecurityResult.frida();
    }
    // 4) Xposed
    if (await _native<bool>('hasXposed') == true) {
      return SecurityResult.xposed();
    }
    // 5) VPN
    if (await _native<bool>('isVpnActive') == true) {
      return SecurityResult.vpn();
    }
    // 6) MITM / proxy tools
    final proxy = await _native<String>('getHttpProxy');
    if (proxy != null && proxy.isNotEmpty) {
      return SecurityResult.mitm('Proxy: $proxy');
    }
    final procs = (await _native<String>('getRunningProcs') ?? '').toLowerCase();
    for (final n in [
      'canary',
      'charles',
      'fiddler',
      'mitmproxy',
      'burpsuite',
      'reqable'
    ]) {
      if (procs.contains(n)) return SecurityResult.mitm('Process: $n');
    }

    return SecurityResult.ok();
  }
}
