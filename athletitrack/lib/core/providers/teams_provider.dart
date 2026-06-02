import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'auth_provider.dart';
import '../services/offline_sync_service.dart';
import 'network_provider.dart';
class TeamsState {
  final List<Map<String, dynamic>> teams;
  final bool isLoading;
  final String? error;

  TeamsState({
    this.teams = const [],
    this.isLoading = false,
    this.error,
  });

  TeamsState copyWith({
    List<Map<String, dynamic>>? teams,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TeamsState(
      teams: teams ?? this.teams,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TeamsNotifier extends StateNotifier<TeamsState> {
  TeamsNotifier(this.ref) : super(TeamsState());
  
  final Ref ref;
  final _api = ApiClient();

  Future<void> fetchTeams() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?['id'];
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    
    final isOnline = ref.read(networkProvider);
    if (!isOnline) {
      final cached = ref.read(offlineSyncProvider).getCachedTeams(userId);
      if (cached != null) {
        final List<dynamic> rawTeams = cached['data'] ?? [];
        state = state.copyWith(isLoading: false, teams: rawTeams.cast<Map<String, dynamic>>());
      } else {
        state = state.copyWith(isLoading: false, error: 'No offline data available for teams');
      }
      return;
    }

    try {
      final role = authState.user?['role'];
      final body = (role == 'Coach') ? {'coach_id': userId} : {'athlete_id': userId};
      final response = await _api.dio.post('/list_teams.php', data: body);

      if (response.data['status'] == 'success') {
        final List<dynamic> rawTeams = response.data['teams'] ?? [];
        final List<Map<String, dynamic>> teamsList = rawTeams.cast<Map<String, dynamic>>();
        
        // Cache teams for offline use
        ref.read(offlineSyncProvider).cacheTeams(userId, teamsList);
        
        state = state.copyWith(isLoading: false, teams: teamsList);
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to fetch teams: ${e.toString()}');
    }
  }

  Future<bool> createTeam(String name, String category, String skillLevel, String teamCode, [PlatformFile? logo]) async {
    final authState = ref.read(authProvider);
    final userId = authState.user?['id'];
    if (userId == null) {
        state = state.copyWith(error: 'User not logged in.');
        return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      String? logoUrl;
      
      if (logo != null) {
        MultipartFile multipartFile;
        if (logo.bytes != null) {
          multipartFile = MultipartFile.fromBytes(logo.bytes!, filename: logo.name);
        } else if (logo.path != null) {
          multipartFile = await MultipartFile.fromFile(logo.path!, filename: logo.name);
        } else {
          throw Exception('Unable to read logo file data.');
        }

        final formData = FormData.fromMap({
          'logo': multipartFile,
        });
        final uploadRes = await _api.dio.post('/upload_logo.php', data: formData);
        if (uploadRes.data['status'] == 'success') {
          logoUrl = uploadRes.data['logo_url'];
        } else {
          state = state.copyWith(isLoading: false, error: uploadRes.data['message']);
          return false;
        }
      }

      final response = await _api.dio.post('/create_team.php', data: {
        'coach_id': userId,
        'name': name,
        'category': category,
        'skill_level': skillLevel,
        'team_code': teamCode,
        if (logoUrl != null) 'logo_url': logoUrl,
      });

      if (response.data['status'] == 'success') {
        // Fetch teams again to update list
        await fetchTeams();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create team: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteTeam(String teamId) async {
    final authState = ref.read(authProvider);
    final userId = authState.user?['id'];
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/delete_team.php', data: {
        'team_id': teamId,
        'coach_id': userId,
      });

      if (response.data['status'] == 'success') {
        await fetchTeams();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete team: ${e.toString()}');
      return false;
    }
  }

  Future<bool> leaveTeam(String teamId) async {
    final authState = ref.read(authProvider);
    final userId = authState.user?['id'];
    if (userId == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/leave_team.php', data: {
        'team_id': teamId,
        'athlete_id': userId,
      });

      if (response.data['status'] == 'success') {
        await fetchTeams();
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to leave team: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final teamsProvider = StateNotifierProvider<TeamsNotifier, TeamsState>((ref) {
  return TeamsNotifier(ref);
});
