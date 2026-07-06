import 'package:connectivity_plus/connectivity_plus.dart';

/// ConnectivityService checks if the phone has internet.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService _instance = ConnectivityService._();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();

  /// Check current connection status
  /// Returns true if connected to WiFi or mobile data.
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    
    // List of results (can have multiple connections)
    // Check if ANY connection is available
    return result.any((r) => 
      r == ConnectivityResult.wifi || 
      r == ConnectivityResult.mobile
    );
  }

  /// Stream of connection changes
  /// This is a "notification" that fires every time the internet status changes.
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}