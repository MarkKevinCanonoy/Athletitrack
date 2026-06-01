import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/offline_sync_service.dart';
import 'attendance_provider.dart';

class NetworkNotifier extends StateNotifier<bool> {
  final Ref ref;
  NetworkNotifier(this.ref) : super(true) {
    _init();
  }

  void _init() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // In connectivity_plus >= 5.0.0, onConnectivityChanged returns a List<ConnectivityResult>
      final isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (isOnline != state) {
        state = isOnline;
        if (isOnline) {
          // Trigger offline sync when returning online
          ref.read(offlineSyncProvider).syncPendingUploads(ref);
        }
      }
    });
    
    // Check initial state
    Connectivity().checkConnectivity().then((results) {
      final isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      state = isOnline;
    });
  }
}

final networkProvider = StateNotifierProvider<NetworkNotifier, bool>((ref) {
  return NetworkNotifier(ref);
});

