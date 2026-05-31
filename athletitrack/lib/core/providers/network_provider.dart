import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_sync_service.dart';
import 'attendance_provider.dart';

// Simulated network provider. In a real app, this would use connectivity_plus
// and listen to actual network state changes.
class NetworkNotifier extends StateNotifier<bool> {
  final Ref ref;
  NetworkNotifier(this.ref) : super(true); // true = online, false = offline

  void setOffline() {
    state = false;
  }

  void setOnline() {
    state = true;
    // Trigger offline sync when returning online
    ref.read(offlineSyncProvider).syncPendingUploads(ref.read(attendanceProvider.notifier));
  }
}

final networkProvider = StateNotifierProvider<NetworkNotifier, bool>((ref) {
  return NetworkNotifier(ref);
});
