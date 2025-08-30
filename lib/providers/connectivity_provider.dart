import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityProvider with ChangeNotifier {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  ConnectivityResult get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus != ConnectivityResult.none;
  bool get isWifi => _connectionStatus == ConnectivityResult.wifi;
  bool get isMobile => _connectionStatus == ConnectivityResult.mobile;

  ConnectivityProvider() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    _connectionStatus = result;
    notifyListeners();
  }

  String get connectionStatusText {
    switch (_connectionStatus) {
      case ConnectivityResult.wifi:
        return 'Connected to WiFi';
      case ConnectivityResult.mobile:
        return 'Connected to Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Connected to Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectivityResult.vpn:
        return 'Connected via VPN';
      case ConnectivityResult.other:
        return 'Connected to Network';
      case ConnectivityResult.none:
        return 'No Internet Connection';
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}