import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

class RequestsState {
  final List<Map<String, dynamic>> requests;
  final bool isLoading;
  final String? error;

  RequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
  });

  RequestsState copyWith({
    List<Map<String, dynamic>>? requests,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RequestsNotifier extends StateNotifier<RequestsState> {
  RequestsNotifier(this.ref) : super(RequestsState());
  
  final Ref ref;
  final _api = ApiClient();

  Future<void> fetchRequests() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?['id'];
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/get_notifications.php', data: {
        'user_id': userId,
      });

      if (response.data['status'] == 'success') {
        final List<dynamic> rawReqs = response.data['data'] ?? [];
        final List<Map<String, dynamic>> reqsList = rawReqs.cast<Map<String, dynamic>>();

        final prefs = await SharedPreferences.getInstance();
        final dismissed = prefs.getStringList('dismissed_notifications_$userId') ?? [];

        final filteredReqs = reqsList.where((req) {
          return !dismissed.contains(req['id'].toString());
        }).toList();

        state = state.copyWith(isLoading: false, requests: filteredReqs);
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to fetch notifications: ${e.toString()}');
    }
  }

  Future<void> dismissAll() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?['id'];
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getStringList('dismissed_notifications_$userId') ?? [];
    
    for (var req in state.requests) {
      dismissed.add(req['id'].toString());
    }

    await prefs.setStringList('dismissed_notifications_$userId', dismissed);
    state = state.copyWith(requests: []);
  }

  Future<bool> processRequest(String requestId, String action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/approve_athlete.php', data: {
        'request_id': requestId,
        'action': action,
      });

      if (response.data['status'] == 'success') {
        await fetchRequests();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to process request: ${e.toString()}');
      return false;
    }
  }
  
  Future<bool> joinTeam(String teamCode) async {
    final authState = ref.read(authProvider);
    final userId = authState.user?['id'];
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/join_team.php', data: {
        'athlete_id': userId,
        'team_code': teamCode,
      });

      if (response.data['status'] == 'success') {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to join team: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final requestsProvider = StateNotifierProvider<RequestsNotifier, RequestsState>((ref) {
  return RequestsNotifier(ref);
});
