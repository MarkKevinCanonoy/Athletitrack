import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';

// Represents the authentication state of the user
class AuthState {
  final bool isAuthenticated;
  final String? role; // 'Coach' or 'Athlete'
  final String? token;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;
  final String? pendingEmail; // Used during OTP verification
  final bool isInCooldown;

  AuthState({
    this.isAuthenticated = false,
    this.role,
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
    this.pendingEmail,
    this.isInCooldown = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? role,
    String? token,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? pendingEmail,
    bool? isInCooldown,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      pendingEmail: pendingEmail ?? this.pendingEmail,
      isInCooldown: isInCooldown ?? this.isInCooldown,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  final _api = ApiClient();

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.dio.post('/login.php', data: {
        'email': email,
        'password': password,
      });

      if (response.data['status'] == 'success') {
        final token = response.data['token'];
        final user = response.data['user'] as Map<String, dynamic>;
        final role = user['role'];
        _api.setToken(token);
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          role: role,
          user: user,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error occurred');
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password, String role) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.dio.post('/register.php', data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role,
      });

      if (response.data['status'] == 'success') {
        state = state.copyWith(isLoading: false, pendingEmail: email, isInCooldown: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error occurred');
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (state.pendingEmail == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.dio.post('/verify_otp.php', data: {
        'email': state.pendingEmail,
        'otp_code': otp,
      });

      if (response.data['status'] == 'success') {
        final token = response.data['token'];
        final user = response.data['user'] as Map<String, dynamic>;
        final role = user['role'];
        _api.setToken(token);
        
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          role: role,
          user: user,
          isLoading: false,
          pendingEmail: null,
        );
        return true; // Verification success, user is logged in
      } else {
        final message = response.data['message'] as String?;
        final isCooldown = message != null && message.contains('Too many failed attempts');
        state = state.copyWith(isLoading: false, error: message, isInCooldown: isCooldown);
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error occurred');
      return false;
    }
  }

  Future<bool> resendOtp() async {
    if (state.pendingEmail == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.dio.post('/resend_otp.php', data: {
        'email': state.pendingEmail,
      });

      if (response.data['status'] == 'success') {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        final message = response.data['message'] as String?;
        final isCooldown = message != null && message.contains('Too many failed attempts');
        state = state.copyWith(isLoading: false, error: message, isInCooldown: isCooldown);
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error occurred');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<bool> updateProfile(String newName) async {
    final user = state.user;
    if (user == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.dio.post('/update_profile.php', data: {
        'user_id': user['id'],
        'full_name': newName,
      });

      if (response.data['status'] == 'success') {
        final updatedUser = Map<String, dynamic>.from(user);
        updatedUser['full_name'] = newName;
        state = state.copyWith(isLoading: false, user: updatedUser);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update profile');
      return false;
    }
  }

  void logout() {
    _api.clearToken();
    state = AuthState(); // Reset to unauthenticated
  }
}

// Global provider for the AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

