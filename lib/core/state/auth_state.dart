import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../services/biometric_service.dart';
import '../storage/secure_storage.dart';

/// Auth state — persisted across app restarts via SecureStorage.
class AuthState {
  const AuthState({
    this.user,
    this.accessToken,
    this.isLoading = false,
    this.error,
  });
  final User? user;
  final String? accessToken;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => accessToken != null && user != null;

  AuthState copyWith({User? user, String? accessToken, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static AuthState initial() => const AuthState();
}

class User {
  const User({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.status,
    this.createdAt,
  });
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? status;
  final DateTime? createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'status': status,
        'createdAt': createdAt?.toIso8601String(),
      };
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api) : super(AuthState.initial());

  final ApiClient _api;

  /// Bootstrap: load tokens from secure storage, fetch /auth/me
  Future<void> bootstrap() async {
    final token = await SecureStorage.getAccessToken();
    if (token == null) {
      state = AuthState.initial();
      return;
    }
    state = state.copyWith(accessToken: token);
    try {
      await refreshMe();
    } catch (_) {
      // Token may be expired — refresh interceptor will handle on next call
    }
  }

  Future<void> login({required String identifier, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post<dynamic>(
        '/auth/login',
        data: <String, dynamic>{'identifier': identifier, 'password': password},
      );
      final data = _api.unwrap<Map<String, dynamic>>(response, (d) => (d as Map<String, dynamic>));
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String?;

      await SecureStorage.setAccessToken(accessToken);
      await SecureStorage.setRefreshToken(refreshToken);
      await SecureStorage.setUserId(user.id);

      state = AuthState(user: user, accessToken: accessToken);
      // Trigger business state refresh after successful login.
      // The caller (router redirect) will then see hasActiveBusiness update.
    } on ApiError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> register({
    required String fullName,
    String? email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post<dynamic>(
        '/auth/register',
        data: <String, dynamic>{
          'fullName': fullName,
          if (email != null) 'email': email,
          'phone': phone,
          'password': password,
          'acceptedTerms': true,
        },
      );
      final data = _api.unwrap<Map<String, dynamic>>(response, (d) => (d as Map<String, dynamic>));
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String?;

      await SecureStorage.setAccessToken(accessToken);
      await SecureStorage.setRefreshToken(refreshToken);
      await SecureStorage.setUserId(user.id);

      state = AuthState(user: user, accessToken: accessToken);
      // Trigger business state refresh after successful login.
      // The caller (router redirect) will then see hasActiveBusiness update.
    } on ApiError catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshMe() async {
    try {
      final response = await _api.get<dynamic>('/auth/me');
      final data = _api.unwrap<Map<String, dynamic>>(response, (d) => (d as Map<String, dynamic>));
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      state = state.copyWith(user: user);
    } catch (e) {
      debugPrint('refreshMe error: $e');
    }
  }

  /// Attempt biometric login: if the user has previously opted in and
  /// a valid token exists in SecureStorage, authenticate via biometrics
  /// and restore the session without re-entering password.
  Future<bool> loginWithBiometric() async {
    final biometricEnabled = await SecureStorage.getBiometricEnabled();
    if (!biometricEnabled) return false;

    final token = await SecureStorage.getAccessToken();
    if (token == null) return false;

    final success = await BiometricService.instance.authenticate(
      reason: 'Authenticate to open RetailOS',
    );
    if (!success) return false;

    state = state.copyWith(accessToken: token);
    try {
      await refreshMe();
      return true;
    } catch (_) {
      state = AuthState.initial();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post<dynamic>('/auth/logout');
    } catch (_) {
      // ignore network errors on logout
    }
    await SecureStorage.clearAuth();
    state = AuthState.initial();
  }

  /// Alias for [bootstrap] (used by the bootstrap orchestration).
  Future<void> restoreSession() => bootstrap();

  /// Accept a staff invitation (stub — calls register-like flow when implemented).
  Future<void> acceptInvitation({required String token, required String password}) async {
    // TODO: implement invitation acceptance via /auth/invitations/:token
    state = state.copyWith(error: 'Invitation flow not yet implemented');
  }

  void clearError() => state = state.copyWith(error: null);
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthNotifier(api);
});
