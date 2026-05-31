import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_client.dart';

class AttendanceState {
  final List<Map<String, dynamic>> columns;
  final List<Map<String, dynamic>> rows;
  final bool isLoading;
  final String? error;

  AttendanceState({
    this.columns = const [],
    this.rows = const [],
    this.isLoading = false,
    this.error,
  });

  AttendanceState copyWith({
    List<Map<String, dynamic>>? columns,
    List<Map<String, dynamic>>? rows,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AttendanceState(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier(this.ref) : super(AttendanceState());
  
  final Ref ref;
  final _api = ApiClient();

  Future<void> fetchAttendance(String teamId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/get_attendance.php', data: {
        'team_id': teamId,
      });

      if (response.data['status'] == 'success') {
        final List<dynamic> rawCols = response.data['columns'] ?? [];
        final List<dynamic> rawRows = response.data['rows'] ?? [];
        
        state = state.copyWith(
          isLoading: false, 
          columns: rawCols.cast<Map<String, dynamic>>(),
          rows: rawRows.cast<Map<String, dynamic>>()
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to fetch attendance: ${e.toString()}');
    }
  }

  Future<bool> submitProof({
    required String postId,
    required String userId,
    required List<PlatformFile> files,
    String message = '',
    required String teamId,
    bool isExcuse = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final formData = FormData.fromMap({
        'post_id': postId,
        'user_id': userId,
        'message': message,
        'is_excuse': isExcuse.toString(),
      });

      for (var file in files) {
        if (file.bytes != null) {
          formData.files.add(MapEntry(
            'files[]',
            MultipartFile.fromBytes(file.bytes!, filename: file.name),
          ));
        } else if (file.path != null) {
          formData.files.add(MapEntry(
            'files[]',
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ));
        }
      }

      final response = await _api.dio.post('/upload_proof.php', data: formData);

      if (response.data['status'] == 'success') {
        // Refresh attendance or posts if needed
        await fetchAttendance(teamId);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to submit proof: ${e.toString()}');
      return false;
    }
  }

  Future<bool> unsubmitProof(String proofId, String teamId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _api.dio.post('/unsubmit_proof.php', data: {
        'proof_id': proofId,
      });

      if (response.data['status'] == 'success') {
        await fetchAttendance(teamId);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to unsubmit proof: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateProofStatus(String proofId, String teamId, String status, {String? coachNote}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = <String, dynamic>{
        'proof_id': proofId,
        'status': status,
      };
      if (coachNote != null) {
        data['coach_note'] = coachNote;
      }
      final response = await _api.dio.post('/update_proof_status.php', data: data);

      if (response.data['status'] == 'success') {
        await fetchAttendance(teamId);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update proof status: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref);
});
