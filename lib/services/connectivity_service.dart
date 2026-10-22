import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Global connectivity monitor. Emits true when online, false when offline.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService I = ConnectivityService._();

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription? _sub;
  bool _online = true;
  bool _started = false;

  bool get isOnline => _online;
  Stream<bool> get stream => _controller.stream;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final result = await Connectivity().checkConnectivity();
      _online = _isConnected(result);
      _controller.add(_online);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      _online = true; // optimistic
    }

    _sub = Connectivity().onConnectivityChanged.listen((result) {
      final next = _isConnected(result);
      if (next != _online) {
        _online = next;
        _controller.add(_online);
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn);
  }

  Future<bool> checkNow() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _online = _isConnected(result);
      _controller.add(_online);
      return _online;
    } catch (_) {
      return _online;
    }
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
