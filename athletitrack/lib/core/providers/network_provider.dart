import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simulated network provider. In a real app, this would use connectivity_plus
// and listen to actual network state changes.
class NetworkNotifier extends StateNotifier<bool> {
  NetworkNotifier() : super(true); // true = online, false = offline

  void setOffline() {
    state = false;
  }

  void setOnline() {
    state = true;
  }
}

final networkProvider = StateNotifierProvider<NetworkNotifier, bool>((ref) {
  return NetworkNotifier();
});
